# UpaMatch — Front-end Flutter

Implementación en Flutter de las pantallas de UpaMatch, siguiendo el mockup de
Figma (*Mockups v2 · 390 × 844 · iPhone 14*).

**Solo interfaz.** No hay llamadas de red, base de datos ni autenticación: los
datos vienen de `lib/data/mock/mock_data.dart`. Los puntos donde hay que
enchufar el backend están marcados con `TODO(backend)`.

## Pantallas

Del mockup de Figma:

| Ruta            | Pantalla             | Archivo                                              |
| --------------- | -------------------- | ---------------------------------------------------- |
| `/`             | 01 Inicio de sesión  | `lib/features/auth/login_screen.dart`                 |
| `/crear-cuenta` | 02 Crear cuenta      | `lib/features/onboarding/create_account_screen.dart`  |
| `/inicio`       | 03 Explorar perfiles | `lib/features/explore/explore_screen.dart`            |

Añadidas después, con el mismo estilo visual (no están en Figma):

| Pestaña | Pantalla | Archivo                                       |
| ------- | -------- | --------------------------------------------- |
| Chats   | 04       | `lib/features/chats/chats_screen.dart`         |
| Perfil  | 05       | `lib/features/profile/profile_screen.dart`     |
| Likes   | —        | `lib/features/likes/likes_screen.dart`         |

Pantallas que se abren encima del shell (ruta propia):

| Ruta / cómo se abre | Pantalla              | Archivo                                                  |
| ------------------- | --------------------- | -------------------------------------------------------- |
| `/chat`             | 06 Detalle de chat    | `lib/features/chats/chat_detail_screen.dart`              |
| diálogo             | 07 ¡Es un match!      | `lib/features/match/match_dialog.dart`                    |
| `/perfil-detalle`   | 08 Detalle de perfil  | `lib/features/profile_detail/profile_detail_screen.dart`  |
| hoja inferior       | 09 Filtros            | `lib/features/explore/widgets/filters_sheet.dart`         |

Flujo sin backend: en Explorar, pasar o dar like avanza al siguiente perfil.
Si das like a alguien que está en `MockData.likesReceived` (Luna, Sofía, Nina)
sale el match, y "Enviar mensaje" abre su chat. La pestaña Likes lista a esos
perfiles; al tocar uno se abre su detalle y el like de vuelta también es match.

Explorar, Likes, Chats y Perfil son pestañas de `MainShell`
(`lib/features/shell/main_shell.dart`): se entra por `/inicio` y se cambia con
la barra inferior. La barra de estado, la barra de navegación y el home
indicator los dibuja el shell, no cada pantalla.

**Likes** todavía no existe en Figma; se hizo con el mismo estilo (rejilla de
tarjetas moradas) y muestra un estado vacío si no hay likes. Cuando haya
diseño, se sustituye.

El botón principal del login y del registro navega a la siguiente pantalla,
para poder recorrer el flujo completo sin backend.

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

Para verlo en el navegador:

```bash
flutter run -d chrome
```

Comprobaciones:

```bash
flutter analyze
flutter test
```

## Estructura

```
lib/
├── main.dart                     App + MaterialApp
├── routes/app_routes.dart        Rutas con nombre e índices de pestaña
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       Paleta y degradados del mockup
│   │   ├── app_text_styles.dart  Escala tipográfica
│   │   └── app_theme.dart        ThemeData, radios, padding de página
│   └── widgets/                  Piezas compartidas
│       ├── app_text_field.dart      Campo con etiqueta + caja desplegable
│       ├── avatar_circle.dart       Avatar redondo (foto, emoji o hueco)
│       ├── avatar_strip.dart        Título + fila horizontal de avatares
│       ├── brand_logo.dart          Logo (corazón + huella)
│       ├── circle_icon_button.dart  Botón circular de las cabeceras
│       ├── gradient_button.dart     Botón morado principal
│       ├── phone_chrome.dart        Barra de estado 9:41 y home indicator
│       └── pill_chip.dart           Píldoras: filtro / selección / translúcida
├── data/
│   ├── models/
│   │   ├── profile.dart          Profile, NearbyProfile, ProfileKind
│   │   └── conversation.dart     Conversation
│   └── mock/mock_data.dart       Contenido de ejemplo
└── features/
    ├── auth/login_screen.dart
    ├── onboarding/create_account_screen.dart
    ├── shell/
    │   ├── main_shell.dart              Contenedor de las 4 pestañas
    │   └── widgets/main_bottom_nav.dart Barra inferior
    ├── explore/
    │   ├── explore_screen.dart
    │   └── widgets/
    │       ├── profile_card.dart   Tarjeta grande de perfil
    │       └── swipe_actions.dart  Botones pasar / like / super like
    ├── likes/likes_screen.dart
    ├── chats/chats_screen.dart
    └── profile/profile_screen.dart
```

Regla: ningún color ni tamaño suelto dentro de las pantallas. Todo sale de
`AppColors`, `AppTextStyles` y `AppTheme`.

## Cómo agregar una pantalla

1. **Modelo** en `lib/data/models/` si la pantalla necesita datos nuevos.
2. **Datos de ejemplo** en `MockData` (`lib/data/mock/mock_data.dart`).
3. **Pantalla** en `lib/features/<área>/`. Solo colores, textos y medidas de
   `AppColors`, `AppTextStyles` y `AppTheme`; reutiliza lo de `core/widgets/`.
4. **Cómo se abre**:
   - Pestaña → agrégala al `IndexedStack` de `MainShell` y a `MainBottomNav`.
   - Pantalla encima → ruta en `AppRoutes` y `Navigator.pushNamed`. Si recibe
     datos, van en `arguments`. Estas pantallas dibujan su propio
     `MockStatusBar` y `HomeIndicator`.
   - Hoja inferior o diálogo → una función `showXxx(context)` en el mismo
     archivo (ver `filters_sheet.dart` y `match_dialog.dart`).
5. **Test** en `test/widget_test.dart` y una fila en las tablas de arriba.

Ojo: las rutas de `AppRoutes.routes` son `MaterialPageRoute<dynamic>`. Para
leer lo que devuelve una pantalla usa `pushNamed(...)` y comprueba el tipo
(`if (result is SwipeDecision)`); `pushNamed<SwipeDecision>` truena.

## Qué le toca al backend

Busca `TODO(backend)` en el proyecto. Resumen:

| Dónde                        | Qué falta                                                  |
| ---------------------------- | ---------------------------------------------------------- |
| `login_screen.dart`          | Login con correo/contraseña, login social, recuperar clave  |
| `create_account_screen.dart` | Guardar el paso 2 del registro y avanzar al paso 3          |
| `explore_screen.dart`        | Cargar perfiles, aplicar el filtro, enviar like / pasar     |
| `profile_card.dart`          | Pintar la foto real cuando llegue `profile.photoUrl`        |
| `avatar_circle.dart`         | Igual para todos los avatares de la app                     |
| `chats_screen.dart`          | Listar conversaciones, búsqueda real y abrir el detalle     |
| `profile_screen.dart`        | Datos del usuario, contadores, ajustes y cerrar sesión      |
| `likes_screen.dart`          | Listar a quienes dieron like                                |
| `routes/app_routes.dart`     | Ruta inicial según haya o no sesión guardada                |
| `data/mock/mock_data.dart`   | Sustituir por la respuesta del API                          |

Los modelos de `lib/data/models/` (`Profile`, `NearbyProfile`, `Conversation`)
ya tienen la forma que consumen las pantallas: basta con añadirles un `fromJson`
y devolverlos desde el repositorio real en lugar de `MockData`.

## Notas de implementación

- **Barra de estado y home indicator**: el mockup los dibuja porque es una
  maqueta. `MockStatusBar` / `HomeIndicator` solo los pintan en web (donde no
  existen); en Android e iOS reservan el área segura real.
- **Ancho del diseño**: el mockup es de 390 px. En pantallas anchas (web o
  tablet) `main.dart` centra el contenido a 430 px como máximo para que se vea
  igual que en Figma.
- **Tipografía**: se usa la fuente del sistema. Si quieres el mismo tipo que
  Figma (Inter), añade `google_fonts` y asigna `AppTextStyles.fontFamily`.
- **Avatares**: el mockup usa ilustraciones; aquí se reproducen con emoji sobre
  círculos de color (registro) y con el hueco de foto (resto). Si diseño
  exporta los PNG/SVG, se cambian en `_KindCard` y en `AvatarCircle`.
- Las fotos de perfil no existen en el mockup: se muestra el marcador
  "Pon aquí la foto del perfil" hasta que el backend devuelva imágenes.
