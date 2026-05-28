# LAST RUNNER

## Proyecto de Realidad Virtual y Aumentada

Este proyecto presenta un videojuego de realidad virtual en primera persona desarrollado con **Godot 4** y **OpenXR**. La propuesta consiste en un juego de carreras de obstáculos donde el objetivo principal es completar un recorrido dinámico en el menor tiempo posible. Desarrollado por un grupo de tres personas como trabajo de la asignatura de Realidad Virtual y Aumentada.

Para el desarrollo del juego se ha utilizado el addon `godot-xr-tools`.

---

## Tecnologías

- [Godot Engine 4](https://godotengine.org/) — Motor de juego principal.
- [OpenXR](https://www.khronos.org/openxr/) — Estándar abierto para la compatibilidad con dispositivos XR.
- [godot-xr-tools](https://github.com/GodotVR/godot-xr-tools) — Addon con utilidades y componentes esenciales para VR en Godot.
- [GodotOpenXRVendors](https://github.com/GodotVR/GodotOpenXRVendors) — Soporte de hardware para visores de diferentes fabricantes (Meta, Pico, etc.).
- **GDScript** — Lenguaje de programación principal del proyecto.

---

## Mecánicas Principales y Sistema del Jugador

El juego combina la velocidad de un juego contrarreloj con la dificultad de superar obstáculos en un entorno virtual.

### Flujo de Juego y Reglas

**Contrarreloj:** El cronómetro se activa en cuanto termina la cuenta atrás inicial. El objetivo es llegar a la plataforma de meta en el menor tiempo posible.

**Sistema de Vidas y Respawn:** El jugador cuenta con 6 vidas indicadas en el HUD. Caer al vacío o tocar una zona de muerte resta una vida y teletransporta al jugador al último checkpoint activo.

**Checkpoints:** Cilindros holográficos distribuidos por el circuito. Al atravesarlos cambian de color (de amarillo a verde) y guardan la posición del jugador para el próximo respawn.

**Fin de Partida:** Si se agotan todas las vidas se muestra una pantalla de game over y el nivel se reinicia.

### Controles del Jugador

El sistema de control utiliza los componentes de `godot-xr-tools`.

Controlador izquierdo:
- **Movimiento** — `MovementDirect`: desplazamiento mediante joystick.
- **Sprint** — `MovementSprint`: gatillo izquierdo para aumentar la velocidad.

Controlador derecho:
- **Rotación** — `MovementTurn`: joystick para rotación horizontal continua.
- **Salto** — `MovementJump`: botón A para saltar.

En ausencia de hardware XR el juego activa automáticamente un modo de escritorio con teclado y ratón a través del nodo `PlayerFlat`.

---

## Estructura del Proyecto

```
project/
├── addons/
│   ├── godot-xr-tools/
│   └── godotopenxrvendors/
├── assets/
│   ├── audio/
│   ├── shaders/
│   └── splash/
│   └── splash/
└── scenes/
├── levels/
├── objects/
└── staging/
```

**`addons/`** — Plugins externos necesarios para el funcionamiento en VR.

**`assets/`** — Recursos visuales y sonoros. La carpeta `shaders/` contiene dos efectos GLSL: uno para los checkpoints holográficos y otro para el efecto de onda de luz del HUD. La carpeta `splash/` incluye las texturas de cuadrícula del suelo, que proporcionan referencias espaciales para reducir el cybersickness.

**`scenes/levels/`** — Una escena por nivel. Todos heredan de `XRToolsSceneBase` y siguen el ciclo de vida del staging: `scene_loaded` → `scene_visible` → `scene_exiting`.

**`scenes/objects/`** — Componentes reutilizables instanciados en los niveles: HUD, checkpoints, zonas de muerte y victoria, y todos los obstáculos.

**`scenes/staging/`** — Escena principal `main_staging.tscn`, que permanece en memoria durante toda la ejecución y gestiona la carga y descarga de niveles con fundidos a negro.

---

## Arquitectura e Implementación

### Sistema de Staging

`main_staging.tscn` usa `staging.gd` de godot-xr-tools como controlador central. Cuando un nivel termina emite la señal `request_load_scene` con la ruta del siguiente nivel, y el staging ejecuta la transición: fundido a negro, descarga de la escena actual, carga e instanciación de la nueva, y fundido de entrada. La propiedad `main_scene` del nodo raíz define el primer nivel que se carga al arrancar.

### Ciclo de Vida de un Nivel

Cada nivel sobreescribe tres métodos de `XRToolsSceneBase`:

`scene_loaded` — se llama antes de que la escena sea visible. Conecta las señales de las zonas de victoria y muerte, inicializa los checkpoints y coloca al jugador en el spawn point mediante `center_player_on`.

`scene_visible` — se llama cuando la escena ya es visible. Arranca la cuenta atrás del HUD y activa los sistemas dinámicos del nivel (timers de obstáculos, etc.).

`scene_exiting` — se llama antes de descargar la escena. Detiene timers y limpia instancias dinámicas si es necesario.

### HUD

El HUD es un `Node3D` con un `SubViewport` que renderiza la interfaz 2D sobre un plano 3D anclado a la cámara activa. Gestiona el cronómetro, el sistema de vidas con animaciones de rotura de corazón mediante `Tween`, la cuenta atrás inicial, los paneles de victoria y game over, y el efecto de onda de luz al activar un checkpoint. Se comunica con el nivel a través de dos señales: `countdown_finished` y `game_finished`.

### Detección VR / Escritorio

En `_ready`, cada nivel consulta `XRServer.primary_interface` para determinar si hay un visor inicializado. Si lo hay, desactiva `PlayerFlat` y activa `XROrigin3D`. Si no, hace lo contrario y reasigna el HUD como hijo de la cámara del `PlayerFlat`.

### Obstáculos

Todos los obstáculos están en `scenes/objects/obstacles/` como escenas independientes instanciables.

`moving_platform.gd` — oscilación sinusoidal configurable mediante `movement_offset`, `cycle_time` y `phase`.

`falling_platform.gd` — se derrumba tras `collapse_delay` segundos al ser pisada y reaparece tras `respawn_delay`.

`tilted_platform.gd` — rampa estática inclinada visualmente que usa wall walk de XRTools para permitir al jugador caminar sobre superficies con pendiente.


`rotating_obstacle.gd` — rota sobre un eje configurable y aplica velocidad tangencial al jugador calculada como producto vectorial entre el eje y el vector radial.

`swinging_hammer.gd` — péndulo cuya fuerza de empuje es proporcional a la velocidad angular en el momento del impacto.

`elevator_platform.gd` — sube al detectar al jugador en su área y baja al salir, con retardo configurable.

`door.gd` / `doors_row.gd` — fila de tres puertas donde una es correcta al azar. Las incorrectas devuelven al jugador con feedback visual y sonoro.

`log.gd` — tronco generado proceduralmente en tiempo de ejecución con malla, colisión y material creados por código. Cae por gravedad desde una posición elevada.

`log_spawner.gd` — spawner procedural de troncos con intervalo aleatorio configurable entre `min_interval` y `max_interval`. Instancia troncos en tiempo de ejecución, los lanza con impulso físico y los elimina automáticamente tras 10 segundos. Se activa y desactiva mediante `start()` y `stop()`.

`globo.gd` — objeto físico que reproduce un sonido de rebote aleatorio al contacto con el jugador.

`checkpoint.gd` — cilindro holográfico que al ser atravesado emite la señal `checkpoint_reached` con su `Transform3D`, cambia de color mediante un shader y notifica al HUD.

---

## Cómo Ejecutar el Proyecto

1. Clonar el repositorio: `git clone https://github.com/Irene3013/vr-project`
2. Abrir el proyecto en Godot 4.
3. Asegurarse de que los plugins `godot-xr-tools` y `godotopenxrvendors` están activados en `Proyecto > Ajustes del Proyecto > Plugins`.
4. Para ejecutar en escritorio: establecer `PlayerFlat` como visible en la escena del nivel deseado y pulsar Play.
5. Para ejecutar en VR: conectar el visor, asegurarse de que SteamVR u OpenXR está activo, y pulsar Play con `PlayerFlat` oculto.
