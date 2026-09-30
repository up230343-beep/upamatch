namespace UpaMatch.Api.Models;

/// <summary>Cuenta con la que se entra a la app.</summary>
public class Usuario
{
    public Guid Id { get; set; }

    /// <summary>Siempre en minúsculas y sin espacios, para que no se repita.</summary>
    public string Correo { get; set; } = "";

    /// <summary>La contraseña cifrada (PBKDF2). Nunca se guarda tal cual.</summary>
    public string ContrasenaHash { get; set; } = "";

    public DateTime CreadoEn { get; set; }

    /// <summary>Nulo hasta que termina el paso 2 del registro.</summary>
    public Mascota? Mascota { get; set; }
}
