using System.Text.Json.Serialization;

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

/// <summary>
/// Un perfil para buscar match. A propósito NO trae el Instagram: ese dato
/// solo sale del servidor cuando ya hay match (ver <see cref="SolicitudDto"/>).
/// </summary>
public record TarjetaDto(
    Guid UsuarioId,
    string Nombre,
    int Edad,
    string Tipo,
    string Raza,
    string Ciudad,
    string Descripcion,
    List<string> Intereses);

/// <summary>"Sí" o "no" a un perfil.</summary>
public record CalificarRequest(Guid UsuarioId, bool Si, bool EsSuperLike = false);

/// <summary>
/// Una solicitud: alguien te dio "sí". <c>Estado</c> es "pendiente" (no has
/// contestado) o "aceptada" (ya es match).
///
/// <c>Instagram</c> solo viene en las aceptadas; en las pendientes el campo ni
/// siquiera aparece en el JSON.
/// </summary>
public record SolicitudDto(
    Guid UsuarioId,
    string Nombre,
    int Edad,
    string Tipo,
    string Raza,
    string Ciudad,
    string Descripcion,
    List<string> Intereses,
    string Estado,
    bool EsSuperLike,
    DateTime Fecha,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Instagram);

/// <summary>Las dos listas de la pantalla de solicitudes, de la más nueva a la más vieja.</summary>
public record SolicitudesResponse(List<SolicitudDto> Pendientes, List<SolicitudDto> Aceptadas);

/// <summary>
/// Respuesta al calificar. Si <c>Match</c> es true, <c>Perfil</c> trae al otro
/// (ya con su Instagram) para avisarle a quien acaba de completar el match.
/// </summary>
public record CalificacionResponse(
    bool Match,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] SolicitudDto? Perfil);
