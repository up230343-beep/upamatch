using System.Text.RegularExpressions;

namespace UpaMatch.Api;

/// <summary>
/// Límites y validaciones de los datos. Están en un solo lugar para que la base
/// de datos y los controladores digan lo mismo.
/// </summary>
public static partial class Reglas
{
    public const int ContrasenaMin = 8;
    public const int NombreMax = 40;
    public const int EdadMax = 99;
    public const int RazaMax = 60;
    public const int CiudadMax = 60;
    public const int DescripcionMax = 300;
    public const int InteresMax = 30;
    public const int InteresesMax = 8;

    /// <summary>Los mismos valores que <c>ProfileKind</c> en la app.</summary>
    public static readonly string[] Tipos = ["persona", "perro", "gato", "otro"];

    public static string NormalizarCorreo(string? correo) =>
        (correo ?? "").Trim().ToLowerInvariant();

    public static bool CorreoValido(string correo) =>
        correo.Length <= 254 && CorreoRegex().IsMatch(correo);

    /// <summary>
    /// Acepta "@usuario", "usuario" o el link completo, y siempre devuelve el
    /// link completo. Vacío devuelve null (el controlador lo marca como error).
    /// </summary>
    public static bool TryNormalizarInstagram(string? entrada, out string? link)
    {
        link = null;
        var texto = (entrada ?? "").Trim();
        if (texto.Length == 0) return true;

        var usuario = InstagramLinkRegex().Match(texto) is { Success: true } m
            ? m.Groups["usuario"].Value
            : texto.TrimStart('@');

        if (!InstagramUsuarioRegex().IsMatch(usuario)) return false;

        link = $"https://www.instagram.com/{usuario}";
        return true;
    }

    [GeneratedRegex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$")]
    private static partial Regex CorreoRegex();

    [GeneratedRegex(@"^(https?://)?(www\.)?instagram\.com/(?<usuario>[^/?#]+)/?([?#].*)?$", RegexOptions.IgnoreCase)]
    private static partial Regex InstagramLinkRegex();

    [GeneratedRegex(@"^[A-Za-z0-9._]{1,30}$")]
    private static partial Regex InstagramUsuarioRegex();
}
