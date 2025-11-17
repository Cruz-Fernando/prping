# 🎮 PING PONG — Juego en Assembly x86

<div align="center">

         P I N G   P O N G          
                                

**Un homenaje al Pong original, recreado con la austeridad y la fuerza del ensamblador x86 (TASM).**

[Características](#características) • [Instalación](#instalación) • [Controles](#controles) • [Modos-de-Juego](#modos-de-juego) • [Futuras-Mejoras](#futuras-mejoras)

</div>

---

## 📋 Descripción

Este proyecto revive el espíritu del Pong clásico, escrito desde cero en **Assembly x86 con TASM**. Incluye dos modos de juego, sistema de puntuación, temporizador en tiempo real y menús adornados con ASCII art. Un juego sencillo, directo y honesto, como los viejos tiempos.

---

## ✨ Características

### 🎯 Funcionalidades Principales
- **Dos modos de juego**: Clásico y Supervivencia  
- **Puntuación funcional** y estable  
- **Temporizador** en formato MM:SS  
- **Menú principal** y **Game Over** con arte ASCII  
- **Colisiones precisas**  
- **Física de rebote** tradicional  
- **Modo 13h** (320×200, 256 colores)

### 🎨 Visuales
- Paleta izquierda: **Azul**  
- Paleta derecha: **Roja**  
- Pelota: **Verde**  
- Menús decorados con arte ASCII clásico

---

## 🕹️ Controles

### Jugador 1 (Izquierda — Azul)
| Tecla | Acción |
|-------|--------|
| `Y` | Arriba |
| `H` | Abajo |

### Jugador 2 (Derecha — Rojo)
| Tecla | Acción |
|-------|--------|
| `O` | Arriba |
| `L` | Abajo |

### Menú Principal
| Tecla | Acción |
|-------|--------|
| `G` | Modo Clásico |
| `B` | Modo Supervivencia |
| `N` | Salir |

### Pantalla Game Over
| Tecla | Acción |
|-------|--------|
| `R` | Reiniciar |
| `N` | Salir |

---

## 🎲 Modos de Juego

### 🏆 Modo Clásico
- Objetivo: alcanzar **5 puntos**  
- Cada error del oponente suma un punto  
- Dificultad equilibrada

### ⚔️ Modo Supervivencia
- Cada error **reduce la paleta en 5 píxeles**  
- Gana quien conserve su paleta por más tiempo  
- Dificultad elevada, tensión constante

---

## 🛠️ Instalación y Compilación

### Requisitos
- **TASM**
- **TLINK**
- **DOSBox** o emulador compatible

### Compilación

```bash
TASM pong3.asm
TLINK pong3.obj
pong3.exe
mount c: C:\ruta\al\proyecto
c:
TASM pong3.asm
TLINK pong3.obj
pong3.exe
pong3.asm
├── .DATA: variables de juego, interfaz y temporizador
├── PRINCIPAL: inicialización, bucle del juego, cierre
├── Menús: ASCII art y pantallas finales
├── Juego: movimiento, colisiones, rebotes, puntuación
├── Dibujo: paletas, pelota, HUD
└── Utilidades: limpiar pantalla, temporizador, helpers
| # | Bug                          | Estado       |
| - | ---------------------------- | ------------ |
| 1 | Paletas lentas               | ⚠️ Pendiente |
| 2 | Puntaje no visible           | ✅ Resuelto   |
| 3 | Reinicio tras Game Over      | ✅ Resuelto   |
| 4 | Colisiones en bordes         | ⚠️ Pendiente |
| 5 | Velocidad baja de la pelota  | ⚠️ Pendiente |
| 6 | Falta el menú inicial        | ✅ Resuelto   |
| 7 | Temporizador inactivo        | ✅ Resuelto   |
| 8 | Modo supervivencia invertido | ✅ Resuelto   |
🚀 Futuras Mejoras
🎯 Corto Plazo

Mayor velocidad de paletas

Aceleración progresiva de la pelota

Mejor física en rebotes y ángulos

🎨 Efectos Visuales

Estelas, destellos y partículas

Animaciones al anotar

Explosiones simbólicas al finalizar

🛑 Pausa y Configuración

Pausar con P o ESC

Ajustar puntos, velocidad y tamaño de paletas

🎮 Nuevos Modos de Juego

Turbo, Práctica, Arcade, vs CPU

🔊 Sonido

Beeps del PC Speaker

Efectos básicos para golpes y victorias

📊 Estadísticas

Historial de partidas

Velocidad actual de pelota

Rally más largo
📝 Notas Técnicas
Interrupciones

INT 10h: video

INT 16h: teclado

INT 21h: DOS y tiempo

Modo 13h

320×200, 256 colores

Escritura directa a memoria de video

Optimizaciones

Saltos cortos

Procedimientos NEAR

Segmentación clara por módulos

👨‍💻 Autor

Jhojan Cruz

📄 Licencia

Uso libre con fines educativos.

🙏 Agradecimientos

Comunidad de Assembly x86

Creadores del Pong original (Atari, 1972)

Colaboradores y entusiastas

Si el proyecto te acompañó un rato, deja una estrella ⭐