using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UpaMatch.Api.Data;
using UpaMatch.Api.Dtos;
using UpaMatch.Api.Models;
using UpaMatch.Api.Services;

namespace UpaMatch.Api.Controllers;

/// <summary>Registro, inicio de sesión y "¿quién soy?".</summary>
[ApiController]
[Route("api/auth")]
public class AuthController(
    UpaMatchDbContext db,
    TokenService tokens,
    IPasswordHasher<Usuario> hasher) : ControllerBase
{
    /// <summary>
    /// Mismo mensaje si falla el correo o la contraseña, para no revelar qué
    /// correos existen.
    /// </summary>
    public const string CredencialesIncorrectas = "Correo o contraseña incorrectos.";

    /// <summary>Paso 1 del registro: crea la cuenta y ya deja la sesión abierta.</summary>
    [HttpPost("registro")]
    public async Task<ActionResult<SesionResponse>> Registro(CredencialesRequest datos)
    {
        var correo = Reglas.NormalizarCorreo(datos.Correo);
        var contrasena = datos.Contrasena ?? "";

        if (!Reglas.CorreoValido(correo))
            return BadRequest("Escribe un correo válido.");
        if (contrasena.Length < Reglas.ContrasenaMin)
            return BadRequest($"La contraseña debe tener al menos {Reglas.ContrasenaMin} caracteres.");
        if (await db.Usuarios.AnyAsync(u => u.Correo == correo))
            return Conflict("Ese correo ya está registrado. Inicia sesión.");

        var usuario = new Usuario
        {
            Id = Guid.NewGuid(),
            Correo = correo,
            CreadoEn = DateTime.UtcNow,
        };
        usuario.ContrasenaHash = hasher.HashPassword(usuario, contrasena);

        db.Usuarios.Add(usuario);
        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            // Dos registros con el mismo correo al mismo tiempo: gana el primero.
            db.ChangeTracker.Clear();
            if (await db.Usuarios.AnyAsync(u => u.Correo == correo))
                return Conflict("Ese correo ya está registrado. Inicia sesión.");
            throw;
        }

        return new SesionResponse(tokens.Crear(usuario), usuario.Id, usuario.Correo, TienePerfil: false);
    }

    [HttpPost("login")]
    public async Task<ActionResult<SesionResponse>> Login(CredencialesRequest datos)
    {
        var correo = Reglas.NormalizarCorreo(datos.Correo);
        var contrasena = datos.Contrasena ?? "";

        var usuario = await db.Usuarios
            .Include(u => u.Mascota)
            .FirstOrDefaultAsync(u => u.Correo == correo);

        if (usuario is null)
        {
            // Se cifra igual para que tarde lo mismo exista o no el correo.
            hasher.HashPassword(new Usuario(), contrasena);
            return Unauthorized(CredencialesIncorrectas);
        }

        var resultado = hasher.VerifyHashedPassword(usuario, usuario.ContrasenaHash, contrasena);
        if (resultado == PasswordVerificationResult.Failed)
            return Unauthorized(CredencialesIncorrectas);

        if (resultado == PasswordVerificationResult.SuccessRehashNeeded)
        {
            usuario.ContrasenaHash = hasher.HashPassword(usuario, contrasena);
            await db.SaveChangesAsync();
        }

        return new SesionResponse(
            tokens.Crear(usuario), usuario.Id, usuario.Correo, usuario.Mascota is not null);
    }

    /// <summary>
    /// La app lo llama al abrirse para comprobar que la sesión guardada sigue
    /// siendo válida.
    /// </summary>
    [Authorize]
    [HttpGet("yo")]
    public async Task<ActionResult<UsuarioResponse>> Yo()
    {
        var id = TokenService.UsuarioId(User);
        var usuario = await db.Usuarios
            .Include(u => u.Mascota)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (usuario is null) return Unauthorized();

        return new UsuarioResponse(usuario.Id, usuario.Correo, usuario.Mascota is not null);
    }
}
