# 🏓 Ping-Pong en MASM

Un clásico juego de **Ping-Pong** implementado en **ensamblador x86 (MASM)** para DOS.

## 📋 Descripción

Este proyecto es un juego interactivo de Ping-Pong donde dos jugadores compiten usando paletas para evitar que la bola salga de la pantalla. El primer jugador en alcanzar 5 puntos gana.

## 🎮 Controles

### Jugador Izquierdo (Paleta Izquierda)
- **W** o **4** - Mover paleta hacia **arriba**
- **S** o **6** - Mover paleta hacia **abajo**

### Jugador Derecho (Paleta Derecha)
- *(Actualmente no funciona debido a un bug conocido)*

## 🚀 Características

✅ Interfaz gráfica en modo 13h (320x200 píxeles)
✅ Paletas controlables por teclado
✅ Física de bola con colisiones
✅ Sistema de puntuación
✅ Menú de fin de juego
✅ Pantalla introductoria

## 🐛 Bugs Conocidos

1. ❌ La paleta derecha no se mueve
2. ⚠️ Movimiento de las paletas algo lento
3. ❌ Puntaje en pantalla no se muestra correctamente
4. ❌ No se reinicia automáticamente después del GAME OVER
5. ⚠️ Detección de colisiones en bordes podría mejorarse
6. 📈 Falta agregar más velocidad a la bola con el tiempo
7. 📝 Falta agregar un menú inicial
8. 🔧 Falta agregar reinicio después del juego

## 📁 Estructura del Código

### Procedimientos Principales

| Procedimiento | Descripción |
|---|---|
| `PRINCIPAL` | Loop principal del juego |
| `INTRO_PROYECTO` | Pantalla introductoria |
| `LIMPIAR_PANTALLA` | Limpia la pantalla |
| `MOVER_PALETAS` | Maneja la entrada del teclado |
| `DIBUJAR_PALETAS` | Renderiza las paletas |
| `MOVER_BOLA` | Actualiza posición de la bola |
| `COLISION` | Detecta colisiones paleta-bola |
| `DIBUJAR_BOLA` | Renderiza la bola |
| `DIBUJAR_UI` | Muestra la puntuación |
| `MENU_FIN_JUEGO` | Pantalla de final del juego |

### Variables Principales

```assembly
BOLA_X, BOLA_Y        - Posición de la bola
VEL_BOLA_X, VEL_BOLA_Y - Velocidad de la bola
PALETA_IZQ_X, PALETA_IZQ_Y - Posición paleta izquierda
PALETA_DER_X, PALETA_DER_Y - Posición paleta derecha
PUNTOS_IZQ, PUNTOS_DER - Puntuación de cada jugador
JUEGO_ACTIVO - Indica si el juego está en curso
```

## 🛠️ Requisitos

- **MASM (Microsoft Macro Assembler)** versión 6.11 o compatible
- Emulador de DOS o máquina virtual con DOS
- Conocimientos básicos de ensamblador x86

## 📦 Compilación

```bash
masm pingpong.asm
link pingpong.obj
pingpong.exe
```

## 🎯 Cómo Jugar

1. Ejecuta el programa: `pingpong.exe`
2. Ve la introducción "PING PONG"
3. El jugador izquierdo controla la paleta con **W** (arriba) y **S** (abajo)
4. Defiende tu lado de la pantalla
5. El primer jugador en alcanzar **5 puntos** gana
6. Se mostrará el ganador en la pantalla

## 📊 Parámetros de Juego

| Parámetro | Valor | Descripción |
|---|---|---|
| Ancho ventana | 320 px (0x140) | Resolución horizontal |
| Alto ventana | 200 px (0xC8) | Resolución vertical |
| Tamaño bola | 4 px | Dimensión de la bola |
| Velocidad bola X | 5 px/frame | Movimiento horizontal |
| Velocidad bola Y | 2 px/frame | Movimiento vertical |
| Velocidad paleta | 5 px/frame | Movimiento paleta |
| Ancho paleta | 5 px | Dimensión horizontal |
| Alto paleta | 31 px | Dimensión vertical |
| Puntos para ganar | 5 | Puntuación máxima |

## 🔄 Flujo del Juego

```
Inicio
  ↓
Intro (PING PONG)
  ↓
Loop Principal
  ├─ Limpiar pantalla
  ├─ Mover bola
  ├─ Detectar colisiones
  ├─ Procesar entrada
  ├─ Dibujar elementos
  ├─ Actualizar UI
  └─ ¿Game Over? → Menú Final
                 → Presionar tecla
                 ↓
                 Inicio
```

## 👨‍💻 Autor

**Jhojan Cruz**

## 🔗 Repositorio

[GitHub - prping](https://github.com/Cruz-Fernando/prping.git)

## 📝 Notas

- Este proyecto fue desarrollado con propósitos educativos
- El código está optimizado para MASM 6.11
- Compatible con sistemas DOS en modo gráfico 13h (VGA)
- Se recomienda usar DOSBox o QEMU para emulación moderna

---

⚠️ **Próximas mejoras planificadas:**
- Corregir el movimiento de la paleta derecha
- Implementar reinicio automático
- Mejorar detección de colisiones
- Agregar aceleración progresiva
- Crear menú inicial
