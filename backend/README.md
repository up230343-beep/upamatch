# UpaMatch — API de cuentas y perfiles

API de registro, inicio de sesión y datos de perfil (mascota). Hecha con ASP.NET Core (.NET 10), Entity Framework Core y SQL Server.

## Qué es

- **Registro** (correo y contraseña) y **login** (token JWT de 30 días).
- **Datos de la mascota** (nombre, edad, tipo, raza, ciudad, descripción, intereses, Instagram).
- Las **fotos NO van aquí**: la API de fotos (`FotosApi`, ASP.NET Core con Azure Blob) corre aparte en puerto 5250.
- Esta API corre en `http://localhost:5260`.

## Cómo correrla

```bash
cd backend/UpaMatch.Api
dotnet run
```

Al arrancar crea la base de datos `UpaMatch` y aplica las migraciones automáticamente.

## Base de datos

Por defecto usa LocalDB `(localdb)\MSSQLLocalDB` (viene con Visual Studio, no pide admin).

Para usar SQL Server completo u otra instancia, cambiar `ConnectionStrings:UpaMatch` en `UpaMatch.Api/appsettings.json`:

```json
"Server=localhost;Database=UpaMatch;Trusted_Connection=True;TrustServerCertificate=True"
```

El script SQL idempotente (para verlo o correrlo a mano en SSMS) está en `backend/database/upamatch.sql`.

## Tablas

| Tabla | Columnas | Notas |
| --- | --- | --- |
| **Usuarios** | Id (GUID), Correo (único, minúsculas), ContrasenaHash, CreadoEn | Una fila por usuario |
| **Mascotas** | UsuarioId (PK/FK 1:1), Nombre, Edad, Tipo, Raza, Ciudad, Descripcion, Instagram, ActualizadoEn | Datos del perfil de mascota |
| **MascotaIntereses** | UsuarioId, Interes | Hasta 8 intereses por mascota |
| **Likes** | DeUsuarioId, AUsuarioId, EsSuperLike, CreadoEn | Quién le dio "sí" a quién; match si A→B y B→A existen |

## Contraseñas

Nunca se guardan tal cual. Se cifran con `PasswordHasher` de ASP.NET Core Identity (PBKDF2 con sal).

El login responde el **mismo mensaje** y **tarda lo mismo** exista o no el correo, para evitar enumerar usuarios:
```
"Correo o contraseña incorrectos."
```

## Endpoints

| Método | Ruta | Auth | Qué hace | Errores |
| --- | --- | --- | --- | --- |
| POST | `/api/auth/registro` | no | Crea la cuenta y devuelve sesión: `{token, usuarioId, correo, tienePerfil}` | 400 correo inválido / contraseña < 8; 409 correo ya registrado |
| POST | `/api/auth/login` | no | Autentica y devuelve sesión | 401 "Correo o contraseña incorrectos." |
| GET | `/api/auth/yo` | sí | `{usuarioId, correo, tienePerfil}`; la app lo usa al abrir para verificar sesión viva | 401 |
| GET | `/api/perfil` | sí | Devuelve datos de la mascota | 404 si aún no completó el paso 2 |
| PUT | `/api/perfil` | sí | Crea o actualiza la mascota y devuelve lo guardado | 400 con el mensaje del primer error de validación |

**Auth sí**: header `Authorization: Bearer <token>`. Los errores vienen en texto plano, listos para mostrarse.

## Reglas de validación

Definidas en `Reglas.cs`:

- **Contraseña**: mínimo 8 caracteres.
- **Nombre mascota**: 1–40 caracteres, obligatorio.
- **Edad**: 0–99.
- **Ciudad**: 1–60 caracteres, obligatoria.
- **Raza**: 0–60 caracteres.
- **Descripción**: 0–300 caracteres.
- **Intereses**: máximo 8, cada uno 1–30 caracteres.
- **Instagram**: acepta "@usuario", "usuario" o el link completo; siempre se guarda como `https://www.instagram.com/usuario`.

## Probar a mano

Archivo `UpaMatch.Api/UpaMatch.Api.http` (VS Code con extensión REST Client o Visual Studio):
```
dotnet tool install -g dotnet-httprepl
httprepl http://localhost:5260
```

O usar Postman / Thunder Client.

## Cambiar el modelo

1. Editar `Models/` y `Data/UpaMatchDbContext.cs`.
2. Crear migración:
   ```bash
   cd backend
   dotnet tool restore
   dotnet tool run dotnet-ef migrations add NombreDelCambio --project UpaMatch.Api
   ```
3. Regenerar script SQL:
   ```bash
   dotnet tool run dotnet-ef migrations script --idempotent --project UpaMatch.Api -o database/upamatch.sql
   ```

## Producción

La clave `Jwt:Clave` en `appsettings.Development.json` es solo para desarrollo.

En producción (Azure, servidor remoto), poner una nueva en la configuración del servidor como variable de entorno `Jwt__Clave`, mínimo 32 caracteres.

## Estructura de carpetas

```
backend/
├── UpaMatch.Api/
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   └── PerfilController.cs
│   ├── Models/
│   ├── Data/
│   │   └── UpaMatchDbContext.cs
│   ├── Dtos/
│   ├── Services/
│   │   └── TokenService.cs
│   ├── Reglas.cs
│   ├── Migrations/
│   ├── appsettings.json
│   └── appsettings.Development.json
├── database/
│   └── upamatch.sql
└── README.md (este archivo)
```
