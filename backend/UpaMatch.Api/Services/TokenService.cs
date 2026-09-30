using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using UpaMatch.Api.Models;

namespace UpaMatch.Api.Services;

/// <summary>
/// Crea el token que la app guarda para no volver a pedir la contraseña.
/// </summary>
public class TokenService(IConfiguration config)
{
    public const string Emisor = "UpaMatch";

    public static SymmetricSecurityKey Llave(IConfiguration config)
    {
        var clave = config["Jwt:Clave"];
        if (string.IsNullOrWhiteSpace(clave) || Encoding.UTF8.GetByteCount(clave) < 32)
        {
            throw new InvalidOperationException(
                "Falta Jwt:Clave en appsettings (mínimo 32 caracteres).");
        }
        return new SymmetricSecurityKey(Encoding.UTF8.GetBytes(clave));
    }

    public string Crear(Usuario usuario)
    {
        var dias = config.GetValue("Jwt:DiasValidez", 30);

        var token = new JwtSecurityToken(
            issuer: Emisor,
            audience: Emisor,
            claims:
            [
                new Claim(JwtRegisteredClaimNames.Sub, usuario.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, usuario.Correo),
            ],
            expires: DateTime.UtcNow.AddDays(dias),
            signingCredentials: new SigningCredentials(Llave(config), SecurityAlgorithms.HmacSha256));

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    /// <summary>El id del usuario dueño del token de la petición.</summary>
    public static Guid? UsuarioId(ClaimsPrincipal user) =>
        Guid.TryParse(user.FindFirstValue(JwtRegisteredClaimNames.Sub), out var id) ? id : null;
}
