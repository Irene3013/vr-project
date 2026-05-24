# Proyecto de Realidad Virtual y Aumentada

Proyecto de realidad virtual desarrollado con **Godot 4.5** y **OpenXR**, con soporte para visores de VR mediante el addon `godot-xr-tools`.

## Tecnologías

- [Godot Engine 4.5](https://godotengine.org/) — Motor de juego
- [OpenXR](https://www.khronos.org/openxr/) — Estándar abierto para XR
- [godot-xr-tools](https://github.com/GodotVR/godot-xr-tools) — Addon con utilidades para VR en Godot
- [GodotOpenXRVendors](https://github.com/GodotVR/GodotOpenXRVendors) — Soporte para vendors específicos (Meta, Pico, etc.)
- **GDScript** — Lenguaje de scripting principal

## Estructura del proyecto

```
vr-project/
├── addons/
│   ├── godot-xr-tools/         # Utilidades y componentes para VR
│   └── godotopenxrvendors/     # Soporte para hardware de distintos fabricantes
├── assets/
│   └── splash/                 # Imágenes y texturas (iconos de vidas, splash screen)
│   └── audio/                  # Efectos de sonido y música
└── scenes/
    ├── levels/                 # Escenas de niveles completos
    ├── objects/                # Objetos reutilizables (obstáculos, HUD, etc.)
    └── staging/                # Sistema de inicio y carga de niveles
```

### `addons/`
Plugins necesarios para el funcionamiento del proyecto. Actualmente contiene solo los addons requeridos para usar OpenXR.

### `assets/`
Imágenes, audio y otros recursos estáticos del proyecto.
- `splash/` — Imagen de la pantalla de inicio e iconos de vidas (corazón entero y roto).
- `audio/` — Efectos de sonido del juego: countdown, aplausos, trompeta de derrota y reacciones de la multitud.
- *(Previsto)* `blender/` — Para modelos `.blend` si se incorporan assets 3D propios.

### `scenes/`
Todas las escenas `.tscn` del proyecto, organizadas en tres subcarpetas:

- **`levels/`** — Escenas de niveles completos ya desarrollados.
- **`objects/`** — Escenas de objetos individuales que se instancian en los niveles (obstáculos, etc.).
- **`staging/`** — Gestiona el flujo de inicio: arranca en la pantalla de inicio y carga el nivel indicado.

> **Importante:** Dentro de `staging/` se encuentra `scene_base.tscn`, que debe añadirse como nodo en **todos los niveles**. Es aquí donde se define el *player* con todas sus funcionalidades, así como el **HUD**, una pantalla transparente anclada frente a la cámara del jugador que muestra información como el tiempo transcurrido y mensajes de estado como "YOU WIN" y"YOU FAIL".