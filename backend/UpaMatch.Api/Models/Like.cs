namespace UpaMatch.Api.Models;

/// <summary>
/// Quién le dio "sí" a quién. Si existen los dos sentidos (A→B y B→A), es match.
/// </summary>
public class Like
{
    public Guid DeUsuarioId { get; set; }

    public Guid AUsuarioId { get; set; }

    public bool EsSuperLike { get; set; }

    public DateTime CreadoEn { get; set; }
}
