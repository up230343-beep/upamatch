namespace UpaMatch.Api.Dtos;

/// <summary>Correo y contraseña: lo mismo para registrarse que para entrar.</summary>
public record CredencialesRequest(string? Correo, string? Contrasena);

/// <summary>Lo que la app guarda para recordar la sesión.</summary>
public record SesionResponse(string Token, Guid UsuarioId, string Correo, bool TienePerfil);

public record UsuarioResponse(Guid UsuarioId, string Correo, bool TienePerfil);

/// <summary>Datos de la mascota, de ida y de vuelta.</summary>
public record PerfilDto(
    string? Nombre,
    int Edad,
    string? Tipo,
    string? Raza,
    string? Ciudad,
    string? Descripcion,
    List<string>? Intereses,
    string? Instagram);
