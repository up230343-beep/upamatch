using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UpaMatch.Api.Data;
using UpaMatch.Api.Dtos;
using UpaMatch.Api.Models;
using UpaMatch.Api.Services;

namespace UpaMatch.Api.Controllers;

/// <summary>Los datos de la mascota del usuario que inició sesión.</summary>
[ApiController]
[Authorize]
[Route("api/perfil")]
public class PerfilController(UpaMatchDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PerfilDto>> Obtener()
    {
        var mascota = await db.Mascotas
            .Include(m => m.Intereses)
            .FirstOrDefaultAsync(m => m.UsuarioId == TokenService.UsuarioId(User));

        if (mascota is null) return NotFound("Todavía no has llenado los datos de tu mascota.");

        return ADto(mascota);
    }

    /// <summary>Crea o actualiza el perfil (paso 2 del registro y "Editar perfil").</summary>
    [HttpPut]
    public async Task<ActionResult<PerfilDto>> Guardar(PerfilDto datos)
    {
        var usuarioId = TokenService.UsuarioId(User);
        if (usuarioId is null || !await db.Usuarios.AnyAsync(u => u.Id == usuarioId))
            return Unauthorized();

        var error = Validar(datos, out var limpio, out var instagram);
        if (error is not null) return BadRequest(error);

        var mascota = await db.Mascotas
            .Include(m => m.Intereses)
            .FirstOrDefaultAsync(m => m.UsuarioId == usuarioId);

        if (mascota is null)
        {
            mascota = new Mascota { UsuarioId = usuarioId.Value };
            db.Mascotas.Add(mascota);
        }

        mascota.Nombre = limpio.Nombre!;
        mascota.Edad = limpio.Edad;
        mascota.Tipo = limpio.Tipo!;
        mascota.Raza = limpio.Raza!;
        mascota.Ciudad = limpio.Ciudad!;
        mascota.Descripcion = limpio.Descripcion!;
        mascota.Instagram = instagram;
        mascota.ActualizadoEn = DateTime.UtcNow;

        mascota.Intereses.Clear();
        mascota.Intereses.AddRange(limpio.Intereses!.Select(i =>
            new MascotaInteres { UsuarioId = usuarioId.Value, Interes = i }));

        await db.SaveChangesAsync();
        return ADto(mascota);
    }

    private static PerfilDto ADto(Mascota m) => new(
        m.Nombre, m.Edad, m.Tipo, m.Raza, m.Ciudad, m.Descripcion,
        m.Intereses.Select(i => i.Interes).Order().ToList(),
        m.Instagram);

    /// <summary>Recorta espacios, revisa límites y devuelve el primer error.</summary>
    private static string? Validar(PerfilDto d, out PerfilDto limpio, out string? instagram)
    {
        static string T(string? s) => (s ?? "").Trim();

        var intereses = (d.Intereses ?? [])
            .Select(T)
            .Where(i => i.Length > 0)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        limpio = d with
        {
            Nombre = T(d.Nombre),
            Tipo = T(d.Tipo).ToLowerInvariant(),
            Raza = T(d.Raza),
            Ciudad = T(d.Ciudad),
            Descripcion = T(d.Descripcion),
            Intereses = intereses,
        };
        instagram = null;

        if (limpio.Nombre!.Length == 0) return "Escribe el nombre.";
        if (limpio.Nombre.Length > Reglas.NombreMax) return $"El nombre admite hasta {Reglas.NombreMax} caracteres.";
        if (limpio.Edad < 0 || limpio.Edad > Reglas.EdadMax) return "La edad no es válida.";
        if (!Reglas.Tipos.Contains(limpio.Tipo)) return "Elige de quién es el perfil.";
        if (limpio.Raza!.Length > Reglas.RazaMax) return $"La raza admite hasta {Reglas.RazaMax} caracteres.";
        if (limpio.Ciudad!.Length == 0) return "Escribe la ciudad.";
        if (limpio.Ciudad.Length > Reglas.CiudadMax) return $"La ciudad admite hasta {Reglas.CiudadMax} caracteres.";
        if (limpio.Descripcion!.Length > Reglas.DescripcionMax)
            return $"La descripción admite hasta {Reglas.DescripcionMax} caracteres.";
        if (intereses.Count > Reglas.InteresesMax) return $"Elige hasta {Reglas.InteresesMax} intereses.";
        if (intereses.Any(i => i.Length > Reglas.InteresMax))
            return $"Cada interés admite hasta {Reglas.InteresMax} caracteres.";
        if (!Reglas.TryNormalizarInstagram(d.Instagram, out instagram))
            return "El Instagram no es válido. Escribe tu usuario (@usuario) o el link.";

        return null;
    }
}
