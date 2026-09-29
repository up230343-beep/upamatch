using Microsoft.EntityFrameworkCore;
using UpaMatch.Api.Models;

namespace UpaMatch.Api.Data;

public class UpaMatchDbContext(DbContextOptions<UpaMatchDbContext> options) : DbContext(options)
{
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Mascota> Mascotas => Set<Mascota>();
    public DbSet<MascotaInteres> MascotaIntereses => Set<MascotaInteres>();
    public DbSet<Like> Likes => Set<Like>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Usuario>(e =>
        {
            e.ToTable("Usuarios");
            e.HasKey(u => u.Id);
            e.Property(u => u.Correo).HasMaxLength(254).IsRequired();
            e.HasIndex(u => u.Correo).IsUnique();
            e.Property(u => u.ContrasenaHash).IsRequired();
        });

        modelBuilder.Entity<Mascota>(e =>
        {
            e.ToTable("Mascotas");
            e.HasKey(m => m.UsuarioId);
            e.Property(m => m.Nombre).HasMaxLength(Reglas.NombreMax).IsRequired();
            e.Property(m => m.Tipo).HasMaxLength(20).IsRequired();
            e.Property(m => m.Raza).HasMaxLength(Reglas.RazaMax).IsRequired();
            e.Property(m => m.Ciudad).HasMaxLength(Reglas.CiudadMax).IsRequired();
            e.Property(m => m.Descripcion).HasMaxLength(Reglas.DescripcionMax).IsRequired();
            e.Property(m => m.Instagram).HasMaxLength(200).IsRequired();
            e.HasOne(m => m.Usuario)
                .WithOne(u => u.Mascota)
                .HasForeignKey<Mascota>(m => m.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasMany(m => m.Intereses)
                .WithOne()
                .HasForeignKey(i => i.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<MascotaInteres>(e =>
        {
            e.ToTable("MascotaIntereses");
            e.HasKey(i => new { i.UsuarioId, i.Interes });
            e.Property(i => i.Interes).HasMaxLength(Reglas.InteresMax);
        });

        modelBuilder.Entity<Like>(e =>
        {
            e.ToTable("Likes");
            e.HasKey(l => new { l.DeUsuarioId, l.AUsuarioId });
            // SQL Server no deja dos borrados en cascada hacia la misma tabla,
            // así que un lado se borra en cascada y el otro no.
            e.HasOne<Usuario>().WithMany()
                .HasForeignKey(l => l.DeUsuarioId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasOne<Usuario>().WithMany()
                .HasForeignKey(l => l.AUsuarioId)
                .OnDelete(DeleteBehavior.NoAction);
            e.HasIndex(l => l.AUsuarioId);
        });
    }
}
