using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using UpaMatch.Api.Data;
using UpaMatch.Api.Models;
using UpaMatch.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddDbContext<UpaMatchDbContext>(o =>
    o.UseSqlServer(builder.Configuration.GetConnectionString("UpaMatch")));

builder.Services.AddScoped<IPasswordHasher<Usuario>, PasswordHasher<Usuario>>();
builder.Services.AddSingleton<TokenService>();

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        // Deja el claim "sub" con su nombre original (TokenService lo lee así).
        o.MapInboundClaims = false;
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidIssuer = TokenService.Emisor,
            ValidAudience = TokenService.Emisor,
            IssuerSigningKey = TokenService.Llave(builder.Configuration),
        };
    });
builder.Services.AddAuthorization();

// La app en Chrome corre en otro puerto de localhost cada vez.
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p
    .SetIsOriginAllowed(origen => new Uri(origen).Host is "localhost" or "127.0.0.1")
    .AllowAnyHeader()
    .AllowAnyMethod()));

var app = builder.Build();

// Crea la base de datos y aplica los cambios pendientes al arrancar.
using (var scope = app.Services.CreateScope())
{
    scope.ServiceProvider.GetRequiredService<UpaMatchDbContext>().Database.Migrate();
}

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

// Para las pruebas de integración.
public partial class Program;
