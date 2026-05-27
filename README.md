# [NOMBRE DEL JUEGO]

## Proyecto de Realidad Virtual y Aumentada

Este proyecto presenta un videojuego de realidad virtual en primera persona desarrollado con **Godot 4.5** y **OpenXR**. La propuesta consiste en un juego de carreras de obstáculos donde el objetivo principal es completar un recorrido dinámico en el menor tiempo posible.

Para el desarrollo del juego se ha utilizado el addon `godot-xr-tools`.

---

## Tecnologías

- [Godot Engine 4.5](https://godotengine.org/) — Motor de juego principal.
- [OpenXR](https://www.khronos.org/openxr/) — Estándar abierto para la compatibilidad con dispositivos XR.
- [godot-xr-tools](https://github.com/GodotVR/godot-xr-tools) — Addon con utilidades y componentes esenciales para VR en Godot.
- [GodotOpenXRVendors](https://github.com/GodotVR/GodotOpenXRVendors) — Soporte de hardware para visores de diferentes fabricantes (Meta, Pico, etc.).
- **GDScript** — Lenguaje de programación principal del proyecto.

---

## Mecánicas Principales y Sistema del Jugador

El juego combina la velocidad de un juego contrarreloj con la dificultad para superar obstáculos en un entorno virtual.

### Flujo de Juego y Reglas
* **Contrarreloj:** El cronómetro global se activa en cuanto termina la cuenta atrás inicial. El objetivo es llegar a la plataforma de meta n el menor tiempo posible.
* **Sistema de Vidas y Respawn:** El jugador cuenta con 6 vidas indicadas en el HUD (Head-Up Display). Caer al vacío o tocar un obstáculo peligroso resta una vida y teletransporta al jugador al último checkpoint activo.
* **Checkpoints:** Cilindros holográficos distribuidos por el circuito. Al atravesarlos, cambian de color (de amarillo a verde) y guardan la posición del jugador para el próximo respawn.
* **Fin de Partida (Game Over):** Si se agotan todas las vidas, se muestra una pantalla de derrota. Tras unos segundos el jugador vuelve al staging. 

### Controles del Jugador
El sistema de control del jugador utiliza las funcionalidades incluidas en `godot-xr-tools`. Las acciones del jugador son las siguientes:

#### Controlador izquierdo

* **Movimiento Horizontal** — `MovementDirect`: El desplazamiento principal del jugador se realiza mediante el joystick. 
* **Sprint** — `MovementSprint`: Manteniendo pulsado el gatillo (trigger), el jugador aumenta temporalmente su velocidad de movimiento

#### Controlador derecho

* **Rotación Artificial** — `MovementTurn`: El joystick controla la rotación horizontal del jugador mediante un sistema de rotacion continua (smooth). 
* **Salto** — `MovementJump`: El botón A/X del permite realizar saltos. 

## Estructura del Proyecto

```
project/
├── addons/
│   ├── godot-xr-tools/             # Utilidades y componentes para VR
│   └── godotopenxrvendors/         # Soporte para hardware de distintos fabricantes
├── assets/
│   ├── audio/                      # Efectos sonoros y música de fondo
│   ├── shaders/                    # Efectos visuales y materiales programados
│   ├── splash/                     # Recursos gráficos para interfaces
│   └── wahooney.itch.io/           # Texturas de referencia visual para el entorno
└── scenes/
├── levels/                         # Escenas correspondientes a los mapas de juego
├── objects/
│   ├── obstacles/                  # Obstáculos instanciables (plataformas dinámicas, etc.)
│   └── (otros objetos)             # Elementos instanciables (HUD, checkpoints, etc.)
└── staging/                        # Gestión de pantallas de carga y ciclo de vida del juego
```

### Descripción de los Directorios

#### `addons/`
Plugins necesarios para el funcionamiento del proyecto en VR. 

#### `assets/`
Almacena todos los recursos visuales y sonoros que complementan la experiencia de juego:
* **`audio/`:** Clips de sonido que ofrecen feedback al jugador durante la partida.
* **`shaders/`:** Efectos visuales dinámicos que se aplican sobre el HUD o sobre los elementos del escenario.
* **`splash/`:** Gráficos utilizados en los menús principales y en los indicadores visuales de la interfaz (como los iconos de vidas).
* **`wahooney.itch.io/`:** Texturas con patrones de cuadrícula aplicadas en las superficies del suelo. Estas proporcionan referencias espaciales al cerebro del jugador mientras se desplaza, reduciendo así el *cybersickness*.

#### `scenes/`
Agrupa los archivos de escena (`.tscn`) y sus correspondientes scripts de lógica (`.gd`), organizados según su función:
* **`staging/`:** Controla el flujo principal de la aplicación. Utiliza una escena principal que permanece siempre en memoria y se encarga de cargar, instanciar y liberar los niveles de fondo de manera fluida mediante transiciones visuales. También contiene la plantilla base del jugador.
* **`levels/`:** Escenas de niveles completos. Cada nivel hereda de scene_base.tscn y añade únicamente los elementos propios de ese nivel: geometría, obstáculos, checkpoints, zona de muerte y zona de victoria.
* **`objects/`:** Componentes modulares que se diseñan una sola vez y se instancian en los niveles, divididos entre los obstáculos del recorrido y los elementos de soporte del sistema de juego.
