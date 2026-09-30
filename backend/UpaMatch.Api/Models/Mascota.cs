namespace UpaMatch.Api.Models;

/// <summary>Perfil que se muestra en la app. Uno por usuario.</summary>
public class Mascota
{
    /// <summary>Es también la llave del usuario: un usuario, una mascota.</summary>
    public Guid UsuarioId { get; set; }

    public string Nombre { get; set; } = "";

    public int Edad { get; set; }

    /// <summary>persona, perro, gato u otro (igual que <c>ProfileKind</c> en la app).</summary>
    public string Tipo { get; set; } = "";

    public string Raza { get; set; } = "";

    public string Ciudad { get; set; } = "";

    public string Descripcion { get; set; } = "";

    /// <summary>
    /// Link completo de Instagram. Obligatorio: no hay chat en la app, el
    /// contacto después del match es por ahí.
    /// </summary>
    public string Instagram { get; set; } = "";

    public DateTime ActualizadoEn { get; set; }

    public Usuario Usuario { get; set; } = null!;

    public List<MascotaInteres> Intereses { get; set; } = [];
}

/// <summary>Un interés de la mascota ("Paseos", "Ama la playa"...).</summary>
public class MascotaInteres
{
    public Guid UsuarioId { get; set; }

    public string Interes { get; set; } = "";
}
