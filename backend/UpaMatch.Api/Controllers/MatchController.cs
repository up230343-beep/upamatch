using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UpaMatch.Api.Data;
using UpaMatch.Api.Dtos;
using UpaMatch.Api.Models;
using UpaMatch.Api.Services;

namespace UpaMatch.Api.Controllers;

/// <summary>
/// Buscar match y solicitudes.
///
/// Regla del Instagram: solo se manda cuando ya hay match (los dos se dieron
/// "sí"). En los perfiles para buscar match y en las solicitudes pendientes no
/// sale del servidor, así que no se puede sacar ni viendo el tráfico.
/// </summary>
[ApiController]
[Authorize]
[Route("api/match")]
public class MatchController(UpaMatchDbContext db) : ControllerBase
{
    public const int LimiteMax = 50;
    public const string Pendiente = "pendiente";
    public const string Aceptada = "aceptada";

    /// <summary>
    /// Perfiles que todavía no has calificado. No incluye el tuyo ni los que
    /// ya calificaste (sí o no). <paramref name="tipo"/> y la edad son opcionales.
    /// </summary>
    [HttpGet("perfiles")]
    public async Task<ActionResult<List<TarjetaDto>>> Perfiles(
        string? tipo = null,
        int? edadMin = null,
        int? edadMax = null,
        int limite = 20)
    {
        if (TokenService.UsuarioId(User) is not Guid yo) return Unauthorized();

        limite = Math.Clamp(limite, 1, LimiteMax);

        IQueryable<Mascota> consulta = db.Mascotas
            .AsNoTracking()
            .Include(m => m.Intereses)
            .Where(m => m.UsuarioId != yo
                && !db.Likes.Any(l => l.DeUsuarioId == yo && l.AUsuarioId == m.UsuarioId)
                && !db.Descartes.Any(d => d.DeUsuarioId == yo && d.AUsuarioId == m.UsuarioId));

        var tipoLimpio = (tipo ?? "").Trim().ToLowerInvariant();
        if (tipoLimpio.Length > 0) consulta = consulta.Where(m => m.Tipo == tipoLimpio);
        if (edadMin is int min) consulta = consulta.Where(m => m.Edad >= min);
        if (edadMax is int max) consulta = consulta.Where(m => m.Edad <= max);

        var mascotas = await consulta
            .OrderByDescending(m => m.ActualizadoEn)
            .ThenBy(m => m.UsuarioId)
            .Take(limite)
            .ToListAsync();

        return mascotas.Select(ATarjeta).ToList();
    }

    /// <summary>
    /// Guarda el "sí" o el "no". Si el otro ya te había dado "sí", es match y
    /// la respuesta trae su perfil con Instagram para avisarte.
    ///
    /// Cada perfil se califica una sola vez: si se vuelve a mandar, se queda
    /// la primera respuesta.
    /// </summary>
    [HttpPost("calificar")]
    public async Task<ActionResult<CalificacionResponse>> Calificar(CalificarRequest datos)
    {
        if (TokenService.UsuarioId(User) is not Guid yo) return Unauthorized();
        if (datos.UsuarioId == yo) return BadRequest("No puedes calificar tu propio perfil.");

        var otro = await db.Mascotas
            .AsNoTracking()
            .Include(m => m.Intereses)
            .FirstOrDefaultAsync(m => m.UsuarioId == datos.UsuarioId);
        if (otro is null) return NotFound("Ese perfil ya no existe.");

        var yaCalificado =
            await db.Likes.AnyAsync(l => l.DeUsuarioId == yo && l.AUsuarioId == otro.UsuarioId)
            || await db.Descartes.AnyAsync(d => d.DeUsuarioId == yo && d.AUsuarioId == otro.UsuarioId);

        if (!yaCalificado)
        {
            var ahora = DateTime.UtcNow;
            if (datos.Si)
            {
                db.Likes.Add(new Like
                {
                    DeUsuarioId = yo,
                    AUsuarioId = otro.UsuarioId,
                    EsSuperLike = datos.EsSuperLike,
                    CreadoEn = ahora,
                });
            }
            else
            {
                db.Descartes.Add(new Descarte
                {
                    DeUsuarioId = yo,
                    AUsuarioId = otro.UsuarioId,
                    CreadoEn = ahora,
                });
            }

            try
            {
                await db.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // Dos toques seguidos llegaron a la vez: ya quedó guardado por
                // la otra petición. Abajo se lee lo que quedó.
                db.ChangeTracker.Clear();
            }
        }

        // Se lee de la base (y no de lo que pidió) para responder con lo que de
        // verdad quedó guardado.
        var miSi = await db.Likes.AsNoTracking()
            .FirstOrDefaultAsync(l => l.DeUsuarioId == yo && l.AUsuarioId == otro.UsuarioId);
        var suSi = await db.Likes.AsNoTracking()
            .FirstOrDefaultAsync(l => l.DeUsuarioId == otro.UsuarioId && l.AUsuarioId == yo);

        if (miSi is null || suSi is null) return new CalificacionResponse(false, null);

        return new CalificacionResponse(true, ASolicitud(otro, suSi, miSi));
    }

    /// <summary>
    /// Las dos listas: pendientes (te dieron "sí" y no has contestado) y
    /// aceptadas (ya son match). Si contestaste "no", no sale en ninguna.
    /// </summary>
    [HttpGet("solicitudes")]
    public async Task<ActionResult<SolicitudesResponse>> Solicitudes()
    {
        if (TokenService.UsuarioId(User) is not Guid yo) return Unauthorized();

        var recibidos = await db.Likes.AsNoTracking()
            .Where(l => l.AUsuarioId == yo)
            .ToListAsync();

        var misSi = await db.Likes.AsNoTracking()
            .Where(l => l.DeUsuarioId == yo)
            .ToDictionaryAsync(l => l.AUsuarioId);

        var misNo = (await db.Descartes.AsNoTracking()
            .Where(d => d.DeUsuarioId == yo)
            .Select(d => d.AUsuarioId)
            .ToListAsync()).ToHashSet();

        var vigentes = recibidos.Where(l => !misNo.Contains(l.DeUsuarioId)).ToList();
        var ids = vigentes.Select(l => l.DeUsuarioId).ToList();

        var mascotas = await db.Mascotas.AsNoTracking()
            .Include(m => m.Intereses)
            .Where(m => ids.Contains(m.UsuarioId))
            .ToDictionaryAsync(m => m.UsuarioId);

        var pendientes = new List<SolicitudDto>();
        var aceptadas = new List<SolicitudDto>();

        foreach (var suSi in vigentes)
        {
            // Sin perfil de mascota no hay nada que enseñar.
            if (!mascotas.TryGetValue(suSi.DeUsuarioId, out var mascota)) continue;

            var solicitud = ASolicitud(mascota, suSi, misSi.GetValueOrDefault(suSi.DeUsuarioId));
            (solicitud.Estado == Aceptada ? aceptadas : pendientes).Add(solicitud);
        }

        return new SolicitudesResponse(
            pendientes.OrderByDescending(s => s.Fecha).ToList(),
            aceptadas.OrderByDescending(s => s.Fecha).ToList());
    }

    /// <summary>
    /// El perfil completo de una solicitud (al abrirla). Solo funciona si esa
    /// persona de verdad te dio "sí"; si no, 404, para que no sirva para ver el
    /// perfil (ni el Instagram) de cualquiera.
    /// </summary>
    [HttpGet("solicitudes/{usuarioId:guid}")]
    public async Task<ActionResult<SolicitudDto>> Solicitud(Guid usuarioId)
    {
        if (TokenService.UsuarioId(User) is not Guid yo) return Unauthorized();

        const string noExiste = "Esa solicitud ya no existe.";

        var suSi = await db.Likes.AsNoTracking()
            .FirstOrDefaultAsync(l => l.DeUsuarioId == usuarioId && l.AUsuarioId == yo);
        if (suSi is null) return NotFound(noExiste);

        if (await db.Descartes.AnyAsync(d => d.DeUsuarioId == yo && d.AUsuarioId == usuarioId))
            return NotFound(noExiste);

        var mascota = await db.Mascotas.AsNoTracking()
            .Include(m => m.Intereses)
            .FirstOrDefaultAsync(m => m.UsuarioId == usuarioId);
        if (mascota is null) return NotFound(noExiste);

        var miSi = await db.Likes.AsNoTracking()
            .FirstOrDefaultAsync(l => l.DeUsuarioId == yo && l.AUsuarioId == usuarioId);

        return ASolicitud(mascota, suSi, miSi);
    }

    private static List<string> Intereses(Mascota m) =>
        m.Intereses.Select(i => i.Interes).Order().ToList();

    /// <summary>Sin Instagram, siempre.</summary>
    private static TarjetaDto ATarjeta(Mascota m) => new(
        m.UsuarioId, m.Nombre, m.Edad, m.Tipo, m.Raza, m.Ciudad, m.Descripcion, Intereses(m));

    /// <summary>
    /// <paramref name="suSi"/>: el "sí" que te dio. <paramref name="miSi"/>: el
    /// tuyo, o null si no has contestado. El Instagram solo se pone si hay los dos.
    /// </summary>
    private static SolicitudDto ASolicitud(Mascota m, Like suSi, Like? miSi)
    {
        var esMatch = miSi is not null;
        return new SolicitudDto(
            m.UsuarioId, m.Nombre, m.Edad, m.Tipo, m.Raza, m.Ciudad, m.Descripcion, Intereses(m),
            Estado: esMatch ? Aceptada : Pendiente,
            EsSuperLike: suSi.EsSuperLike,
            // Aceptada: cuándo se hizo el match (el segundo "sí").
            Fecha: esMatch && miSi!.CreadoEn > suSi.CreadoEn ? miSi.CreadoEn : suSi.CreadoEn,
            Instagram: esMatch ? m.Instagram : null);
    }
}
