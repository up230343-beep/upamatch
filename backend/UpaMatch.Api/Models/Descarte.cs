namespace UpaMatch.Api.Models;

/// <summary>
/// Quién le dio "no" a quién. Junto con <see cref="Like"/> ("sí") guarda cada
/// calificación, para no volver a mostrar un perfil que ya se calificó.
/// </summary>
public class Descarte
{
    public Guid DeUsuarioId { get; set; }

    public Guid AUsuarioId { get; set; }

    public DateTime CreadoEn { get; set; }
}
