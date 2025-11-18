;                        -------------------------------------------
;                        |        P O N G   S E R V I C E          |
;                        |                                         |
;                        |  P1: 0                           P2: 0  |
;                        |                                         |
;                        ; | |                                 | | ;
;                        ; | |                                 | | ;
;                        ; | |               ( o )             | | ;
;                        ; | |                                 | | ;
;                        ; | |                                 | | ;
;                        |                                         |
;                        -------------------------------------------
;                            ************  LISTA DE BUGS ***************
; 1. Movimiento de paletas algo lento
; 2. Mostrar puntaje correctamente - ✓ RESUELTO
; 3. No se reinicia automáticamente tras GAME OVER - ✓ RESUELTO
; 4. Falta mejorar colisiones en bordes
; 5. Falta agregar más velocidad a la bola
; 6. Falta menú inicial - ✓ RESUELTO
; 7. Bug del temporizador - ✓ RESUELTO
; 8. ASCII Art en menús - ✓ RESUELTO
; 9. Modo Supervivencia - ✓ RESUELTO
;                           ********************************************
;                                      ===========================================================
;                                       Jhojan Cruz - Proyecto Ping-Pong en Assembly x86
;                                       Modo de Video: 13h (320x200, 256 colores)
;                                      ===========================================================

; Directivas del ensamblador
ORG 100H                    ; El programa comienza en 100h (formato .COM)
.MODEL SMALL                ; Modelo de memoria pequeño (código y datos en 64KB)
.STACK 100H                 ; Reservar 256 bytes para la pila

; =================================================================================================================================
; SECCIÓN DE DATOS .Data 
; =================================================================================================================================

.DATA
    ; === VARIABLES DE SINCRONIZACIÓN ===
    TIEMPO_AUX            DB 0                                               ; Variable auxiliar para controlar el tiempo de actualización

    ; === VARIABLES DE LA BOLA ===
    BOLA_X                DW 0A0h                                            ; Posición X de la bola
    BOLA_Y                DW 64h                                             ; Posición Y de la bola
    TAMANIO_BOLA          DW 04h                                             ; Tamaño de la bola en píxeles
    VELOCIDAD_BOLA_X      DW 06h                                             ; Velocidad horizontal
    VELOCIDAD_BOLA_Y      DW 03h                                             ; Velocidad vertical


    ; === DIMENSIONES DE LA VENTANA ===
    ANCHO_VENTANA         DW 140h                                            ; Ancho de la pantalla: 320 píxeles
    ALTO_VENTANA          DW 0C8h                                            ; Alto de la pantalla: 200 píxeles
    LIMITE_VENTANA        DW 07h                                             ; Margen de seguridad para bordes

    ; === POSICIÓN INICIAL DE LA BOLA ===
    BOLA_ORIGINAL_X       DW 0A0h                                            ; Posición X inicial
    BOLA_ORIGINAL_Y       DW 64h                                             ; Posición Y inicial

    ; === PALETA IZQUIERDA (JUGADOR 1 - AZUL) ===
    PALETA_IZQUIERDA_X    DW 0Ah                                             ; Posición X: 10 píxeles desde el borde izquierdo
    PALETA_IZQUIERDA_Y    DW 60h                                             ; Posición Y: 96 píxeles desde arriba
    PUNTOS_IZQUIERDA      DW 0                                               ; Puntaje del jugador izquierdo

    ; === PALETA DERECHA (JUGADOR 2 - ROJO) ===
    PALETA_DERECHA_X      DW 136h                                            ; Posición X: 310 píxeles desde el borde izquierdo
    PALETA_DERECHA_Y      DW 60h                                             ; Posición Y: 96 píxeles desde arriba
    PUNTOS_DERECHA        DW 0                                               ; Puntaje del jugador derecho

    ; === DIMENSIONES DE LAS PALETAS ===
    ANCHO_PALETA          DW 07h                                             ; Ancho de ambas paletas
    ALTO_PALETA           DW 1Fh                                             ; Alto estándar: 31 píxeles

    ALTO_PALETA_IZQUIERDA DW 1Fh                                             ; Alto actual de paleta izquierda (variable en modo supervivencia)
    ALTO_PALETA_DERECHA   DW 1Fh                                             ; Alto actual de paleta derecha (variable en modo supervivencia)

    VELOCIDAD_PALETA      DW 07h                                             ; Velocidad de movimiento: 5 píxeles por frame

    ; === VARIABLES DE CONTROL DEL JUEGO ===
    JUEGO_ACTIVO          DB 1                                               ; Estado del juego: 1=jugando, 0=terminado
    MODO_JUEGO            DB 0                                               ; Modo actual: 0=Clásico (5 puntos), 1=Supervivencia (reducir paleta)

    ; === VARIABLES DEL TEMPORIZADOR ===
    MINUTOS               DB 0                                               ; Contador de minutos transcurridos
    SEGUNDOS              DB 0                                               ; Contador de segundos (0-59)
    TICKS_CONTADOR        DW 0                                               ; Contador auxiliar de ticks (no usado actualmente)
    ULTIMO_TICK           DB 0                                               ; Último tick registrado para calcular diferencias

    ; === TEXTOS DEL JUEGO ===
    TEXTO_GAME_OVER       DB "FIN DEL JUEGO $"
    TEXTO_JUGADOR         DB "JUGADOR $"
    GANADOR_UNO           DB 00h                                             ; Flag: 1 si ganó jugador 1, 0 si no
    GANADOR_DOS           DB 00h                                             ; Flag: 1 si ganó jugador 2, 0 si no
    TEXTO_JUGADOR_UNO     DB "1 GANO EL JUEGO $"
    TEXTO_JUGADOR_DOS     DB "2 GANO EL JUEGO $"

    ; === TEXTOS DEL MENÚ ===
    TEXTO_TITULO          DB 'PING PONG $'
    TEXTO_MENU_1          DB 'Presiona - "G" - MODO CLASICO (5 PUNTOS) $'
    TEXTO_MENU_2          DB 'Presiona - "B" - MODO SUPERVIVENCIA      $'
    TEXTO_MENU_3          DB 'Presiona - "N" - SALIR                   $'
    
    ; === TEXTOS DE LA INTERFAZ ===
    TEXTO_REINICIAR       DB 'PRESIONE R PARA REPETIR $'
    TEXTO_SALIR           DB 'PRESIONE N PARA SALIR   $'
    TEXTO_TIEMPO          DB 'TIEMPO: $'
    TEXTO_DOS_PUNTOS      DB ':$'
    TEXTO_J1              DB 'J_Azul: $'                                     ; Etiqueta Jugador 1
    TEXTO_J2              DB 'J_Rojo: $'                                     ; Etiqueta Jugador 2

    ; ===========================================================
    ; SECCIÓN DE CÓDIGO .code
    ; ===========================================================
.CODE

    ; ===========================================================
    ;                  PROCEDIMIENTO PRINCIPAL
    ; Descripción: Punto de entrada del programa. Controla el
    ;              flujo principal del juego.
    ; ===========================================================

PRINCIPAL PROC
                            MOV  AX, @DATA
                            MOV  DS, AX

    ; === SECUENCIA DE INICIO ===
                            CALL LIMPIAR_PANTALLA              ; Cambiar a modo gráfico 13h (320x200)
                            CALL MENU_INICIAL                  ; Mostrar menú de selección de modo
                            CALL LIMPIAR_PANTALLA              ; Limpiar pantalla antes de empezar
                            CALL INICIAR_TEMPORIZADOR          ; Resetear cronómetro a 0:00

    ; --- BUCLE PRINCIPAL DEL JUEGO ---
    ; Este bucle se ejecuta continuamente mientras el juego está activo
    BUCLE_TIEMPO:           
                            CMP  JUEGO_ACTIVO, 00h             ; ¿El juego sigue activo?
                            JE   MOSTRAR_FIN_JUEGO             ; Si es igual a 0, mostrar pantalla de Game Over

    ; === SINCRONIZACIÓN DEL FRAME RATE ===
    ; Limitar la velocidad del juego usando el reloj del sistema
                            MOV  AH, 2Ch                       ; Función 2Ch de INT 21h: obtener hora del sistema
                            INT  21h                           ; Retorna: DL = centésimas de segundo (0-99)
                            CMP  DL, TIEMPO_AUX                ; ¿El tiempo cambió desde la última iteración?
                            JE   BUCLE_TIEMPO                  ; Si no cambió, esperar (no actualizar frame)
                            MOV  TIEMPO_AUX, DL                ; Actualizar referencia de tiempo

    ; === ACTUALIZACIÓN DEL FRAME ===
    ; Orden de operaciones: Limpiar → Actualizar lógica → Dibujar
                            CALL LIMPIAR_PANTALLA              ; Borrar el frame anterior (pantalla negra)
                            CALL MOVER_BOLA                    ; Actualizar posición de la bola
                            CALL COLISION                      ; Verificar rebotes con paletas
                            CALL DIBUJAR_BOLA                  ; Renderizar la bola en nueva posición
                            CALL MOVER_PALETAS                 ; Leer input del teclado y mover paletas
                            CALL DIBUJAR_PALETAS               ; Renderizar ambas paletas
                            CALL ACTUALIZAR_TEMPORIZADOR       ; Actualizar el cronómetro
                            CALL DIBUJAR_UI                    ; Mostrar HUD (puntajes, tiempo)
                            JMP  BUCLE_TIEMPO                  ; Repetir el ciclo

    ; --- PANTALLA DE GAME OVER ---
    MOSTRAR_FIN_JUEGO:      
                            CALL MENU_FIN_JUEGO                ; Mostrar menú de Game Over con opciones
    
    ; Verificar si presionó 'R' para reiniciar
                            CMP  AL, 72h                       ; ¿Es 'r' minúscula?
                            JE   REINICIAR_TODO                ; Sí, reiniciar juego
                            CMP  AL, 52h                       ; ¿Es 'R' mayúscula?
                            JE   REINICIAR_TODO                ; Sí, reiniciar juego
    
    ; Verificar si presionó 'N' para salir
                            CMP  AL, 6Eh                       ; ¿Es 'n' minúscula?
                            JE   SALIR_PROGRAMA                ; Sí, terminar programa
                            CMP  AL, 4Eh                       ; ¿Es 'N' mayúscula?
                            JE   SALIR_PROGRAMA                ; Sí, terminar programa
    
                            JMP  MOSTRAR_FIN_JUEGO             ; Tecla inválida, seguir esperando

    ; --- REINICIAR EL JUEGO ---
    REINICIAR_TODO:         
    ; Resetear todas las variables a sus valores iniciales
                            MOV  JUEGO_ACTIVO, 1               ; Activar el juego
                            MOV  PUNTOS_IZQUIERDA, 0           ; Resetear puntaje jugador 1
                            MOV  PUNTOS_DERECHA, 0             ; Resetear puntaje jugador 2
                            MOV  GANADOR_UNO, 0                ; Limpiar flag de ganador 1
                            MOV  GANADOR_DOS, 0                ; Limpiar flag de ganador 2
    
    ; Restaurar tamaño original de las paletas
                            MOV  AX, 1Fh                       ; AX = 31 píxeles
                            MOV  ALTO_PALETA_IZQUIERDA, AX     ; Restaurar paleta izquierda
                            MOV  ALTO_PALETA_DERECHA, AX       ; Restaurar paleta derecha
    
    ; Reiniciar posición de la bola y mostrar menú
                            CALL REINICIAR_BOLA                ; Centrar la bola
                            CALL LIMPIAR_PANTALLA              ; Limpiar pantalla
                            CALL MENU_INICIAL                  ; Volver al menú de selección
                            CALL LIMPIAR_PANTALLA              ; Limpiar antes de empezar
                            CALL INICIAR_TEMPORIZADOR          ; Resetear cronómetro
                            JMP  BUCLE_TIEMPO                  ; Comenzar nuevo juego

    ; --- SALIR DEL PROGRAMA ---
    SALIR_PROGRAMA:         
                            MOV  AH, 4Ch                       ; Función 4Ch de INT 21h: terminar programa
                            INT  21h                           ; Retornar al DOS con código de salida 0
                            RET                                ; Fin del procedimiento
PRINCIPAL ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MENU_INICIAL
    ; Descripción: Muestra el menú principal simplificado
    ; Entradas: Ninguna
    ; Salidas: MODO_JUEGO configurado (0 o 1)
    ; ===========================================================
MENU_INICIAL PROC
    ; === CAMBIAR A MODO TEXTO ===
                            MOV  AH, 00h                       ; Función: establecer modo de video
                            MOV  AL, 03h                       ; Modo 03h: texto 80x25 colores
                            INT  10h                           ; Ejecutar interrupción de video

    ; ====================================================
    ; TÍTULO "PING PONG"
    ; ====================================================
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 08h                       ; Fila 8
                            MOV  DL, 11h                       ; Columna 17 (centrado)
                            INT  10h

                            MOV  AH, 09h                       ; Función: imprimir string
                            LEA  DX, TEXTO_TITULO
                            INT  21h

    ; ====================================================
    ; OPCIONES DEL MENÚ
    ; ====================================================
    ; Opción 1: Modo Clásico
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 12                        ; Fila 18
                            MOV  DL, 06h                       ; Columna 6
                            INT  10h

                            MOV  AH, 09h                       ; Función: imprimir string
                            LEA  DX, TEXTO_MENU_1              ; Cargar dirección del texto
                            INT  21h                           ; Imprimir hasta '$'

    ; Opción 2: Modo Supervivencia
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 14                        ; Fila 20
                            MOV  DL, 06h
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_MENU_2
                            INT  21h

    ; Opción 3: Salir
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 16                        ; Fila 22
                            MOV  DL, 06h
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_MENU_3
                            INT  21h

    ; --- ESPERAR SELECCIÓN DEL USUARIO ---
    ESPERAR_TECLA:          
                            MOV  AH, 00h                       ; Función: leer tecla (bloqueante)
                            INT  16h                           ; AL = código ASCII de la tecla presionada

    ; Verificar si seleccionó Modo Clásico (G/g)
                            CMP  AL, 67h                       ; ¿Es 'g' minúscula?
                            JE   MODO_CLASICO
                            CMP  AL, 47h                       ; ¿Es 'G' mayúscula?
                            JE   MODO_CLASICO

    ; Verificar si seleccionó Modo Supervivencia (B/b)
                            CMP  AL, 62h                       ; ¿Es 'b' minúscula?
                            JE   MODO_SUPER
                            CMP  AL, 42h                       ; ¿Es 'B' mayúscula?
                            JE   MODO_SUPER

    ; Verificar si seleccionó Salir (N/n)
                            CMP  AL, 6Eh                       ; ¿Es 'n' minúscula?
                            JE   SALIR_JUEGO
                            CMP  AL, 4Eh                       ; ¿Es 'N' mayúscula?
                            JE   SALIR_JUEGO

                            JMP  ESPERAR_TECLA                 ; Tecla inválida, seguir esperando

    ; --- CONFIGURAR MODO CLÁSICO ---
    MODO_CLASICO:           
                            MOV  MODO_JUEGO, 0                 ; 0 = Modo clásico (primero en llegar a 5 puntos)
                            RET                                ; Volver al programa principal

    ; --- CONFIGURAR MODO SUPERVIVENCIA ---
    MODO_SUPER:             
                            MOV  MODO_JUEGO, 1                 ; 1 = Modo supervivencia (reducir paletas)
                            RET

    ; --- SALIR DEL JUEGO ---
    SALIR_JUEGO:            
                            MOV  AH, 4Ch                       ; Función: terminar programa
                            INT  21h
                            RET
MENU_INICIAL ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: INICIAR_TEMPORIZADOR
    ; Descripción: Resetea el cronómetro a 0:00 y guarda el
    ;              tick inicial del sistema.
    ; Entradas: Ninguna
    ; Salidas: MINUTOS=0, SEGUNDOS=0, ULTIMO_TICK actualizado
    ; ===========================================================
INICIAR_TEMPORIZADOR PROC
    ; Resetear contadores
                            MOV  MINUTOS, 0                    ; Minutos = 0
                            MOV  SEGUNDOS, 0                   ; Segundos = 0
                            MOV  TICKS_CONTADOR, 0             ; Contador auxiliar = 0

    ; Obtener tick inicial del sistema
                            MOV  AH, 2Ch                       ; Función: obtener hora del sistema
                            INT  21h                           ; DL = centésimas de segundo (0-99)
                            MOV  ULTIMO_TICK, DL               ; Guardar tick inicial
                            RET
INICIAR_TEMPORIZADOR ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: ACTUALIZAR_TEMPORIZADOR
    ; Descripción: Incrementa el cronómetro cada ~1 segundo
    ;              comparando los ticks del sistema.
    ; Algoritmo: Compara centésimas actuales con las anteriores.
    ;            Si pasaron ≥18 ticks (~1 seg), incrementa segundos.
    ; ===========================================================
ACTUALIZAR_TEMPORIZADOR PROC
    ; Guardar registros (buena práctica)
                            PUSH AX
                            PUSH BX
                            PUSH DX

    ; Obtener tick actual del sistema
                            MOV  AH, 2Ch                       ; Función: obtener hora
                            INT  21h                           ; DL = centésimas actuales

    ; Calcular diferencia de ticks
                            MOV  AL, DL                        ; AL = tick actual
                            MOV  BL, ULTIMO_TICK               ; BL = tick anterior
                            SUB  AL, BL                        ; AL = diferencia

    ; Manejar wrap-around (cuando el reloj pasa de 99 a 0)
                            JNS  TICK_POSITIVO                 ; Si no es negativo, continuar
                            ADD  AL, 100                       ; Ajustar: agregar 100 si hubo wrap

    TICK_POSITIVO:          
    ; Verificar si pasó ~1 segundo (18 ticks)
                            CMP  AL, 18                        ; ¿Pasaron al menos 18 ticks?
                            JL   NO_INCREMENTAR                ; No, salir sin incrementar

    ; Actualizar referencia de tick
                            MOV  ULTIMO_TICK, DL               ; Guardar nuevo tick como referencia

    ; Incrementar segundos
                            INC  SEGUNDOS                      ; SEGUNDOS = SEGUNDOS + 1

    ; Verificar si llegó a 60 segundos
                            CMP  SEGUNDOS, 60                  ; ¿SEGUNDOS == 60?
                            JL   NO_INCREMENTAR                ; No, continuar

    ; Reiniciar segundos e incrementar minutos
                            MOV  SEGUNDOS, 0                   ; Resetear segundos a 0
                            INC  MINUTOS                       ; MINUTOS = MINUTOS + 1

    NO_INCREMENTAR:         
    ; Restaurar registros
                            POP  DX
                            POP  BX
                            POP  AX
                            RET
ACTUALIZAR_TEMPORIZADOR ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: LIMPIAR_PANTALLA
    ; Descripción: Cambia al modo gráfico 13h (320x200, 256 colores)
    ;              y establece el fondo negro.
    ; ===========================================================
LIMPIAR_PANTALLA PROC
    ; Cambiar a modo gráfico 13h
                            MOV  AH, 00h                       ; Función: establecer modo de video
                            MOV  AL, 13h                       ; Modo 13h: gráfico 320x200, 256 colores
                            INT  10h                           ; Ejecutar

    ; Establecer color de fondo negro
                            MOV  AH, 0Bh                       ; Función: establecer paleta de colores
                            MOV  BH, 00h                       ; Paleta de fondo
                            MOV  BL, 00h                       ; Color negro (índice 0)
                            INT  10h
                            RET
LIMPIAR_PANTALLA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MOVER_PALETAS
    ; Descripción: Lee el teclado y llama a los procedimientos
    ;              de movimiento de cada paleta.
    ; Controles:
    ;   Jugador 1 (Izquierda): Y=arriba, H=abajo
    ;   Jugador 2 (Derecha):   O=arriba, L=abajo
    ; ===========================================================
MOVER_PALETAS PROC
    ; Verificar si hay tecla presionada (sin bloquear)
                            MOV  AH, 01h                       ; Función: verificar buffer del teclado
                            INT  16h                           ; ZF=1 si no hay tecla, ZF=0 si hay
                            JZ   MOVER_PALETAS_SALIR           ; No hay tecla, salir

    ; Leer la tecla presionada
                            MOV  AH, 00h                       ; Función: leer tecla
                            INT  16h                           ; AL = código ASCII

    ; Guardar tecla para procesarla dos veces
                            MOV  BL, AL                        ; BL = copia de la tecla

    ; Procesar movimiento del jugador 1 (izquierda)
                            PUSH BX                            ; Guardar BX en la pila
                            CALL MOVER_IZQUIERDA               ; Procesar teclas Y/H
                            POP  BX                            ; Recuperar BX

    ; Procesar movimiento del jugador 2 (derecha)
                            MOV  AL, BL                        ; Restaurar tecla en AL
                            CALL MOVER_DERECHA                 ; Procesar teclas O/L

    MOVER_PALETAS_SALIR:    
                            RET
MOVER_PALETAS ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MOVER_IZQUIERDA
    ; Descripción: Mueve la paleta izquierda según la tecla presionada.
    ; Entradas: AL = código ASCII de la tecla
    ; Controles: Y/y = arriba, H/h = abajo
    ; ===========================================================
MOVER_IZQUIERDA PROC
    ; Verificar si es tecla para mover arriba
                            CMP  AL, 59h                       ; ¿Es 'Y' mayúscula?
                            JE   MOVER_I_UP
                            CMP  AL, 79h                       ; ¿Es 'y' minúscula?
                            JE   MOVER_I_UP

    ; Verificar si es tecla para mover abajo
                            CMP  AL, 48h                       ; ¿Es 'H' mayúscula?
                            JE   MOVER_I_DOWN
                            CMP  AL, 68h                       ; ¿Es 'h' minúscula?
                            JE   MOVER_I_DOWN

                            RET                                ; Otra tecla, ignorar

    ; --- MOVER PALETA IZQUIERDA HACIA ARRIBA ---
    MOVER_I_UP:             
                            MOV  AX, VELOCIDAD_PALETA          ; AX = 5 píxeles
                            SUB  PALETA_IZQUIERDA_Y, AX        ; Y = Y - 5 (moverse arriba)
    
    ; Verificar límite superior
                            MOV  AX, LIMITE_VENTANA            ; AX = 6 (margen superior)
                            CMP  PALETA_IZQUIERDA_Y, AX        ; ¿Y < 6?
                            JL   MOVER_I_FIX_UP                ; Sí, se pasó del límite
                            RET                                ; No, movimiento válido

    MOVER_I_FIX_UP:         
                            MOV  PALETA_IZQUIERDA_Y, AX        ; Fijar en el límite (Y = 6)
                            RET

    ; --- MOVER PALETA IZQUIERDA HACIA ABAJO ---
    MOVER_I_DOWN:           
                            MOV  AX, VELOCIDAD_PALETA          ; AX = 5 píxeles
                            ADD  PALETA_IZQUIERDA_Y, AX        ; Y = Y + 5 (moverse abajo)
    
    ; Calcular límite inferior (200 - 6 - alto_paleta)
                            MOV  AX, ALTO_VENTANA              ; AX = 200
                            SUB  AX, LIMITE_VENTANA            ; AX = 194
                            SUB  AX, ALTO_PALETA_IZQUIERDA     ; AX = 194 - altura_actual
    
    ; Verificar límite inferior
                            CMP  PALETA_IZQUIERDA_Y, AX        ; ¿Y > límite?
                            JG   MOVER_I_FIX_DN                ; Sí, se pasó
                            RET                                ; No, movimiento válido

    MOVER_I_FIX_DN:         
                            MOV  PALETA_IZQUIERDA_Y, AX        ; Fijar en el límite inferior
                            RET
MOVER_IZQUIERDA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MOVER_DERECHA
    ; Descripción: Mueve la paleta derecha según la tecla presionada.
    ; Entradas: AL = código ASCII de la tecla
    ; Controles: O/o = arriba, L/l = abajo
    ; ===========================================================
MOVER_DERECHA PROC
    ; Verificar si es tecla para mover arriba
                            CMP  AL, 4Fh                       ; ¿Es 'O' mayúscula?
                            JE   MOVER_D_UP
                            CMP  AL, 6Fh                       ; ¿Es 'o' minúscula?
                            JE   MOVER_D_UP

    ; Verificar si es tecla para mover abajo
                            CMP  AL, 4Ch                       ; ¿Es 'L' mayúscula?
                            JE   MOVER_D_DOWN
                            CMP  AL, 6Ch                       ; ¿Es 'l' minúscula?
                            JE   MOVER_D_DOWN

                            RET                                ; Otra tecla, ignorar

    ; --- MOVER PALETA DERECHA HACIA ARRIBA ---
    MOVER_D_UP:             
                            MOV  AX, VELOCIDAD_PALETA          ; AX = 5 píxeles
                            SUB  PALETA_DERECHA_Y, AX          ; Y = Y - 5
    
                            MOV  AX, LIMITE_VENTANA            ; AX = 6
                            CMP  PALETA_DERECHA_Y, AX          ; ¿Y < 6?
                            JL   MOVER_D_FIX_UP                ; Sí, corregir
                            RET

    MOVER_D_FIX_UP:         
                            MOV  PALETA_DERECHA_Y, AX          ; Fijar en Y = 6
                            RET

    ; --- MOVER PALETA DERECHA HACIA ABAJO ---
    MOVER_D_DOWN:           
                            MOV  AX, VELOCIDAD_PALETA          ; AX = 5 píxeles
                            ADD  PALETA_DERECHA_Y, AX          ; Y = Y + 5
    
    ; Calcular límite inferior
                            MOV  AX, ALTO_VENTANA              ; AX = 200
                            SUB  AX, LIMITE_VENTANA            ; AX = 194
                            SUB  AX, ALTO_PALETA_DERECHA       ; AX = 194 - altura_actual
    
                            CMP  PALETA_DERECHA_Y, AX          ; ¿Y > límite?
                            JG   MOVER_D_FIX_DN                ; Sí, corregir
                            RET

    MOVER_D_FIX_DN:         
                            MOV  PALETA_DERECHA_Y, AX          ; Fijar en límite
                            RET
MOVER_DERECHA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: DIBUJAR_PALETAS
    ; Descripción: Dibuja ambas paletas píxel por píxel en la pantalla.
    ; Algoritmo: Doble bucle (X e Y) para cada paleta.
    ; Colores: Izquierda=Azul (09h), Derecha=Rojo (0Ch)
    ; ===========================================================
DIBUJAR_PALETAS PROC
    ; === DIBUJAR PALETA IZQUIERDA ===
                            MOV  CX, PALETA_IZQUIERDA_X        ; CX = coordenada X inicial
                            MOV  DX, PALETA_IZQUIERDA_Y        ; DX = coordenada Y inicial

    ; Bucle para dibujar la paleta izquierda
    DIB_IZQ:                
                            MOV  AH, 0Ch                       ; Función: escribir píxel
                            MOV  AL, 09h                       ; Color: azul claro
                            MOV  BH, 00h                       ; Página 0
                            INT  10h                           ; Dibujar píxel en (CX, DX)
    
                            INC  CX                            ; Siguiente columna (X++)
                            MOV  AX, CX                        ; AX = X actual
                            SUB  AX, PALETA_IZQUIERDA_X        ; AX = columnas dibujadas
                            CMP  AX, ANCHO_PALETA              ; ¿Completamos el ancho (5 píxeles)?
                            JNG  DIB_IZQ                       ; No, continuar en la misma fila

    ; Pasar a la siguiente fila
                            MOV  CX, PALETA_IZQUIERDA_X        ; Resetear X al inicio
                            INC  DX                            ; Siguiente fila (Y++)
                            MOV  AX, DX                        ; AX = Y actual
                            SUB  AX, PALETA_IZQUIERDA_Y        ; AX = filas dibujadas
                            CMP  AX, ALTO_PALETA_IZQUIERDA     ; ¿Completamos el alto?
                            JNG  DIB_IZQ                       ; No, continuar

    ; === DIBUJAR PALETA DERECHA ===
                            MOV  CX, PALETA_DERECHA_X          ; CX = coordenada X inicial
                            MOV  DX, PALETA_DERECHA_Y          ; DX = coordenada Y inicial

    ; Bucle para dibujar la paleta derecha
    DIB_DER:                
                            MOV  AH, 0Ch                       ; Función: escribir píxel
                            MOV  AL, 0Ch                       ; Color: rojo claro
                            MOV  BH, 00h                       ; Página 0
                            INT  10h                           ; Dibujar píxel en (CX, DX)
    
                            INC  CX                            ; Siguiente columna
                            MOV  AX, CX
                            SUB  AX, PALETA_DERECHA_X
                            CMP  AX, ANCHO_PALETA              ; ¿Completamos el ancho?
                            JNG  DIB_DER                       ; No, continuar

    ; Pasar a siguiente fila
                            MOV  CX, PALETA_DERECHA_X          ; Resetear X
                            INC  DX                            ; Siguiente fila
                            MOV  AX, DX
                            SUB  AX, PALETA_DERECHA_Y
                            CMP  AX, ALTO_PALETA_DERECHA       ; ¿Completamos el alto?
                            JNG  DIB_DER                       ; No, continuar
    
                            RET                                ; Ambas paletas dibujadas
DIBUJAR_PALETAS ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MOVER_BOLA
    ; Descripción: Actualiza la posición de la bola según su velocidad
    ;              y verifica colisiones con los bordes.
    ; Física: Posición += Velocidad cada frame
    ; ===========================================================
MOVER_BOLA PROC
    ; === MOVIMIENTO HORIZONTAL ===
                            MOV  AX, VELOCIDAD_BOLA_X          ; AX = velocidad X (puede ser +5 o -5)
                            ADD  BOLA_X, AX                    ; BOLA_X = BOLA_X + velocidad

    ; Verificar si salió por el borde IZQUIERDO
                            CMP  BOLA_X, 05h                   ; ¿X < 5?
                            JL   LLAMAR_PUNTO_DER              ; Sí, punto para jugador derecho

    ; Verificar si salió por el borde DERECHO
                            MOV  AX, ANCHO_VENTANA             ; AX = 320
                            SUB  AX, TAMANIO_BOLA              ; AX = 316
                            SUB  AX, 05h                       ; AX = 311 (límite derecho)
                            CMP  BOLA_X, AX                    ; ¿X > 311?
                            JG   LLAMAR_PUNTO_IZQ              ; Sí, punto para jugador izquierdo

    ; === MOVIMIENTO VERTICAL ===
                            MOV  AX, VELOCIDAD_BOLA_Y          ; AX = velocidad Y (puede ser +2 o -2)
                            ADD  BOLA_Y, AX                    ; BOLA_Y = BOLA_Y + velocidad

    ; Verificar si tocó el borde SUPERIOR
                            CMP  BOLA_Y, 05h                   ; ¿Y < 5?
                            JL   INV_Y                         ; Sí, invertir dirección vertical

    ; Verificar si tocó el borde INFERIOR
                            MOV  AX, ALTO_VENTANA              ; AX = 200
                            SUB  AX, TAMANIO_BOLA              ; AX = 196
                            SUB  AX, 05h                       ; AX = 191 (límite inferior)
                            CMP  BOLA_Y, AX                    ; ¿Y > 191?
                            JG   INV_Y                         ; Sí, invertir dirección vertical
    
                            RET                                ; Movimiento completado

    ; --- ETIQUETAS DE SALTO ---
    ; Nota: Estas etiquetas solo llaman a procedimientos porque
    ;       los procedimientos están demasiado lejos para un salto directo
    LLAMAR_PUNTO_IZQ:       
                            CALL PUNTO_IZQ                     ; Procesar punto para jugador izquierdo
                            RET

    LLAMAR_PUNTO_DER:       
                            CALL PUNTO_DER                     ; Procesar punto para jugador derecho
                            RET

    ; --- INVERTIR VELOCIDAD VERTICAL ---
    INV_Y:                  
                            NEG  VELOCIDAD_BOLA_Y              ; Cambiar signo: +2 → -2, o -2 → +2
                            RET                                ; (Rebote vertical)
MOVER_BOLA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: PUNTO_IZQ (NEAR)
    ; Descripción: Se ejecuta cuando la bola sale por el borde DERECHO.
    ;              Significa que el jugador IZQUIERDO anotó un punto.
    ; Modo Clásico: Incrementa puntaje izquierdo
    ; Modo Supervivencia: Reduce paleta DERECHA (quien falló)
    ; ===========================================================
PUNTO_IZQ PROC NEAR
    ; Verificar modo de juego
                            CMP  MODO_JUEGO, 1                 ; ¿Es modo supervivencia?
                            JE   REDUCIR_DER                   ; Sí, reducir paleta derecha
    
    ; === MODO CLÁSICO ===
                            INC  PUNTOS_IZQUIERDA              ; PUNTOS_IZQ++
                            CALL REINICIAR_BOLA                ; Centrar bola
                            CMP  PUNTOS_IZQUIERDA, 05h         ; ¿Llegó a 5 puntos?
                            JL   FIN_PUNTO_IZQ                 ; No, continuar jugando
                            MOV  GANADOR_UNO, 01h              ; Sí, marcar como ganador
                            CALL TERMINAR_JUEGO                ; Finalizar el juego

    FIN_PUNTO_IZQ:          
                            RET

    ; === MODO SUPERVIVENCIA ===
    REDUCIR_DER:            
                            MOV  AX, ALTO_PALETA_DERECHA       ; AX = altura actual
                            SUB  AX, 05h                       ; Reducir 5 píxeles
                            MOV  ALTO_PALETA_DERECHA, AX       ; Guardar nueva altura
                            CALL REINICIAR_BOLA                ; Centrar bola
                            CMP  ALTO_PALETA_DERECHA, 05h      ; ¿Altura <= 5?
                            JG   FIN_PUNTO_IZQ                 ; No, continuar
                            MOV  GANADOR_UNO, 01h              ; Sí, ganó el jugador izquierdo
                            CALL TERMINAR_JUEGO                ; Finalizar
                            RET
PUNTO_IZQ ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: PUNTO_DER (NEAR)
    ; Descripción: Se ejecuta cuando la bola sale por el borde IZQUIERDO.
    ;              Significa que el jugador DERECHO anotó un punto.
    ; Modo Clásico: Incrementa puntaje derecho
    ; Modo Supervivencia: Reduce paleta IZQUIERDA (quien falló)
    ; ===========================================================
PUNTO_DER PROC NEAR
    ; Verificar modo de juego
                            CMP  MODO_JUEGO, 1                 ; ¿Es modo supervivencia?
                            JE   REDUCIR_IZQ                   ; Sí, reducir paleta izquierda
    
    ; === MODO CLÁSICO ===
                            INC  PUNTOS_DERECHA                ; PUNTOS_DER++
                            CALL REINICIAR_BOLA                ; Centrar bola
                            CMP  PUNTOS_DERECHA, 05h           ; ¿Llegó a 5 puntos?
                            JL   FIN_PUNTO_DER                 ; No, continuar
                            MOV  GANADOR_DOS, 01h              ; Sí, marcar como ganador
                            CALL TERMINAR_JUEGO                ; Finalizar

    FIN_PUNTO_DER:          
                            RET

    ; === MODO SUPERVIVENCIA ===
    REDUCIR_IZQ:            
                            MOV  AX, ALTO_PALETA_IZQUIERDA     ; AX = altura actual
                            SUB  AX, 05h                       ; Reducir 5 píxeles
                            MOV  ALTO_PALETA_IZQUIERDA, AX     ; Guardar nueva altura
                            CALL REINICIAR_BOLA                ; Centrar bola
                            CMP  ALTO_PALETA_IZQUIERDA, 05h    ; ¿Altura <= 5?
                            JG   FIN_PUNTO_DER                 ; No, continuar
                            MOV  GANADOR_DOS, 01h              ; Sí, ganó el jugador derecho
                            CALL TERMINAR_JUEGO                ; Finalizar
                            RET
PUNTO_DER ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: TERMINAR_JUEGO (NEAR)
    ; Descripción: Finaliza el juego estableciendo JUEGO_ACTIVO = 0
    ;              y reseteando los puntajes.
    ; ===========================================================
TERMINAR_JUEGO PROC NEAR
                            MOV  PUNTOS_IZQUIERDA, 00h         ; Resetear puntaje izquierdo
                            MOV  PUNTOS_DERECHA, 00h           ; Resetear puntaje derecho
                            MOV  JUEGO_ACTIVO, 00h             ; Desactivar juego (trigger de Game Over)
                            RET
TERMINAR_JUEGO ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: COLISION
    ; Descripción: Detecta si la bola colisiona con alguna paleta
    ;              usando el algoritmo AABB (Axis-Aligned Bounding Box).
    ; Algoritmo: Hay colisión si:
    ;   - Bola.derecha >= Paleta.izquierda AND
    ;   - Bola.izquierda <= Paleta.derecha AND
    ;   - Bola.abajo >= Paleta.arriba AND
    ;   - Bola.arriba <= Paleta.abajo
    ; ===========================================================
COLISION PROC
    ; ====================================================
    ; VERIFICAR COLISIÓN CON PALETA DERECHA
    ; ====================================================
    
    ; Verificar eje X (horizontal)
                            MOV  AX, BOLA_X                    ; AX = borde izquierdo de la bola
                            ADD  AX, TAMANIO_BOLA              ; AX = borde derecho de la bola
                            CMP  AX, PALETA_DERECHA_X          ; ¿Borde derecho >= paleta izquierda?
                            JNG  VER_IZQ                       ; No, no hay colisión horizontal

                            MOV  AX, BOLA_X                    ; AX = borde izquierdo de la bola
                            MOV  BX, PALETA_DERECHA_X          ; BX = borde izquierdo de paleta
                            ADD  BX, ANCHO_PALETA              ; BX = borde derecho de paleta
                            CMP  AX, BX                        ; ¿Borde izquierdo <= paleta derecha?
                            JG   VER_IZQ                       ; No, la bola ya pasó

    ; Verificar eje Y (vertical)
                            MOV  AX, BOLA_Y                    ; AX = borde superior de la bola
                            ADD  AX, TAMANIO_BOLA              ; AX = borde inferior de la bola
                            CMP  AX, PALETA_DERECHA_Y          ; ¿Borde inferior >= paleta arriba?
                            JNG  VER_IZQ                       ; No, está por encima

                            MOV  AX, BOLA_Y                    ; AX = borde superior de la bola
                            MOV  BX, PALETA_DERECHA_Y          ; BX = borde superior de paleta
                            ADD  BX, ALTO_PALETA_DERECHA       ; BX = borde inferior de paleta
                            CMP  AX, BX                        ; ¿Borde superior <= paleta abajo?
                            JG   VER_IZQ                       ; No, está por debajo

    ; ¡HAY COLISIÓN CON PALETA DERECHA!
                            NEG  VELOCIDAD_BOLA_X              ; Invertir velocidad X (rebote)
                            RET                                ; Salir (ya procesamos la colisión)

    ; ====================================================
    ; VERIFICAR COLISIÓN CON PALETA IZQUIERDA
    ; ====================================================
    VER_IZQ:                
    ; Verificar eje X
                            MOV  AX, BOLA_X
                            ADD  AX, TAMANIO_BOLA              ; Borde derecho de la bola
                            CMP  AX, PALETA_IZQUIERDA_X        ; ¿>= paleta izquierda?
                            JNG  SALIR_COL                     ; No, no hay colisión

                            MOV  AX, BOLA_X
                            MOV  BX, PALETA_IZQUIERDA_X
                            ADD  BX, ANCHO_PALETA              ; Borde derecho de paleta
                            CMP  AX, BX                        ; ¿<= paleta derecha?
                            JG   SALIR_COL                     ; No, ya pasó

    ; Verificar eje Y
                            MOV  AX, BOLA_Y
                            ADD  AX, TAMANIO_BOLA              ; Borde inferior de bola
                            CMP  AX, PALETA_IZQUIERDA_Y        ; ¿>= paleta arriba?
                            JNG  SALIR_COL                     ; No, está arriba

                            MOV  AX, BOLA_Y
                            MOV  BX, PALETA_IZQUIERDA_Y
                            ADD  BX, ALTO_PALETA_IZQUIERDA     ; Borde inferior de paleta
                            CMP  AX, BX                        ; ¿<= paleta abajo?
                            JG   SALIR_COL                     ; No, está abajo

    ; ¡HAY COLISIÓN CON PALETA IZQUIERDA!
                            NEG  VELOCIDAD_BOLA_X              ; Invertir velocidad X

    SALIR_COL:              
                            RET                                ; No hubo colisión o ya se procesó
COLISION ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: REINICIAR_BOLA
    ; Descripción: Centra la bola en su posición original e invierte
    ;              ambas velocidades para cambiar la dirección inicial.
    ; ===========================================================
REINICIAR_BOLA PROC
    ; Restaurar posición original
                            MOV  AX, BOLA_ORIGINAL_X           ; AX = 160 (centro horizontal)
                            MOV  BOLA_X, AX                    ; BOLA_X = 160
                            MOV  AX, BOLA_ORIGINAL_Y           ; AX = 100 (centro vertical)
                            MOV  BOLA_Y, AX                    ; BOLA_Y = 100
    
    ; Invertir direcciones para variar el saque
                            NEG  VELOCIDAD_BOLA_X              ; Cambiar dirección horizontal
                            NEG  VELOCIDAD_BOLA_Y              ; Cambiar dirección vertical
                            RET
REINICIAR_BOLA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: DIBUJAR_BOLA
    ; Descripción: Dibuja la bola como un cuadrado de 4x4 píxeles
    ;              de color verde.
    ; ===========================================================
DIBUJAR_BOLA PROC
    ; Posición inicial
                            MOV  CX, BOLA_X                    ; CX = coordenada X
                            MOV  DX, BOLA_Y                    ; DX = coordenada Y

    ; Bucle de dibujo (doble bucle: X e Y)
    DIB_BOLA:               
                            MOV  AH, 0Ch                       ; Función: escribir píxel
                            MOV  AL, 0Ah                       ; Color: verde claro (10)
                            MOV  BH, 00h                       ; Página 0
                            INT  10h                           ; Dibujar píxel en (CX, DX)

    ; Avanzar en X (horizontal)
                            INC  CX                            ; X++
                            MOV  AX, CX
                            SUB  AX, BOLA_X                    ; Columnas dibujadas
                            CMP  AX, TAMANIO_BOLA              ; ¿Dibujamos las 4 columnas?
                            JNG  DIB_BOLA                      ; No, continuar en la misma fila

    ; Pasar a siguiente fila
                            MOV  CX, BOLA_X                    ; Resetear X al inicio
                            INC  DX                            ; Y++
                            MOV  AX, DX
                            SUB  AX, BOLA_Y                    ; Filas dibujadas
                            CMP  AX, TAMANIO_BOLA              ; ¿Dibujamos las 4 filas?
                            JNG  DIB_BOLA                      ; No, continuar

                            RET                                ; Bola completa (4x4 píxeles)
DIBUJAR_BOLA ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: DIBUJAR_UI
    ; Descripción: Dibuja la interfaz de usuario (HUD):
    ;              - Etiquetas J1 y J2
    ;              - Puntajes o tamaños de paletas
    ;              - Temporizador (MM:SS)
    ; ===========================================================
DIBUJAR_UI PROC
    ; ====================================================
    ; JUGADOR 1 (IZQUIERDA)
    ; ====================================================
    
    ; Posicionar cursor para etiqueta "J1:"
                            MOV  AH, 02h                       ; Función: posicionar cursor
                            MOV  BH, 00h                       ; Página 0
                            MOV  DH, 03h                       ; Fila 3
                            MOV  DL, 04h                       ; Columna 4
                            INT  10h

    ; Imprimir "J1:"
                            MOV  AH, 09h                       ; Función: imprimir string
                            LEA  DX, TEXTO_J1                  ; Cargar dirección del texto
                            INT  21h                           ; Imprimir hasta '$'

    ; Decidir qué mostrar según el modo de juego
                            CMP  MODO_JUEGO, 1                 ; ¿Modo supervivencia?
                            JE   MOSTRAR_PALETA_IZQ            ; Sí, mostrar tamaño de paleta
    
    ; === MODO CLÁSICO: Mostrar puntaje ===
                            MOV  AH, 02h                       ; Función: escribir carácter
                            MOV  DX, PUNTOS_IZQUIERDA          ; DX = puntaje (0-9)
                            ADD  DX, 48                        ; Convertir a ASCII ('0' = 48)
                            INT  21h                           ; Imprimir carácter
                            JMP  ETIQUETA_J2                   ; Saltar a jugador 2

    ; === MODO SUPERVIVENCIA: Mostrar tamaño de paleta ===
    MOSTRAR_PALETA_IZQ:     
                            MOV  AX, ALTO_PALETA_IZQUIERDA     ; AX = altura en píxeles (ej: 31)
                            MOV  BL, 10                        ; Divisor = 10
                            DIV  BL                            ; AL = decenas, AH = unidades
    
    ; Mostrar decenas
                            MOV  DL, AL                        ; DL = decenas (ej: 3)
                            ADD  DL, 48                        ; Convertir a ASCII
                            MOV  AH, 02h                       ; Función: escribir carácter
                            INT  21h                           ; Imprimir
    
    ; Mostrar unidades
                            MOV  DL, AH                        ; DL = unidades (ej: 1)
                            ADD  DL, 48                        ; Convertir a ASCII
                            MOV  AH, 02h
                            INT  21h                           ; Imprimir (resultado: "31")

    ; ====================================================
    ; JUGADOR 2 (DERECHA)
    ; ====================================================
    ETIQUETA_J2:            
    ; Posicionar cursor para "J2:"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 03h                       ; Fila 3
                            MOV  DL, 1Ch                       ; Columna 28 (derecha)
                            INT  10h

    ; Imprimir "J2:"
                            MOV  AH, 09h
                            LEA  DX, TEXTO_J2
                            INT  21h

    ; Decidir qué mostrar
                            CMP  MODO_JUEGO, 1                 ; ¿Modo supervivencia?
                            JE   MOSTRAR_PALETA_DER            ; Sí, mostrar tamaño
    
    ; === MODO CLÁSICO: Mostrar puntaje ===
                            MOV  AH, 02h
                            MOV  DX, PUNTOS_DERECHA
                            ADD  DX, 48                        ; Convertir a ASCII
                            INT  21h
                            JMP  MOSTRAR_TIMER                 ; Saltar a temporizador

    ; === MODO SUPERVIVENCIA: Mostrar tamaño de paleta ===
    MOSTRAR_PALETA_DER:     
                            MOV  AX, ALTO_PALETA_DERECHA
                            MOV  BL, 10
                            DIV  BL                            ; AL = decenas, AH = unidades
    
    ; Mostrar decenas
                            MOV  DL, AL
                            ADD  DL, 48
                            MOV  AH, 02h
                            INT  21h
    
    ; Mostrar unidades
                            MOV  DL, AH
                            ADD  DL, 48
                            MOV  AH, 02h
                            INT  21h

    ; ====================================================
    ; TEMPORIZADOR (MINUTOS:SEGUNDOS)
    ; ====================================================
    MOSTRAR_TIMER:          
    ; Posicionar cursor para "TIEMPO:"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 01h                       ; Fila 1 (parte superior)
                            MOV  DL, 0Ch                       ; Columna 12 (centrado)
                            INT  10h
    
    ; Imprimir "TIEMPO: "
                            MOV  AH, 09h
                            LEA  DX, TEXTO_TIEMPO
                            INT  21h
    
    ; Mostrar minutos (un solo dígito)
                            MOV  AH, 02h
                            MOV  DL, MINUTOS                   ; DL = minutos (0-9)
                            ADD  DL, 48                        ; Convertir a ASCII
                            INT  21h                           ; Imprimir (ej: "3")
    
    ; Imprimir dos puntos ":"
                            MOV  AH, 09h
                            LEA  DX, TEXTO_DOS_PUNTOS
                            INT  21h
    
    ; === DIVIDIR SEGUNDOS EN DECENAS Y UNIDADES ===
    ; Ejemplo: 45 segundos → "45" (4 y 5)
                            MOV  AL, SEGUNDOS                  ; AL = segundos totales (0-59)
                            MOV  AH, 0                         ; AH = 0 (preparar para división)
                            MOV  BL, 10                        ; Divisor = 10
                            DIV  BL                            ; AL = decenas (4), AH = unidades (5)
    
    ; Mostrar decenas de segundos
                            MOV  DL, AL                        ; DL = decenas
                            ADD  DL, 48                        ; Convertir a ASCII
                            MOV  AH, 02h                       ; Función: escribir carácter
                            INT  21h                           ; Imprimir
    
    ; Mostrar unidades de segundos
    ; Nota: El residuo quedó en AH, ahora lo movemos a DL
                            MOV  DL, AH                        ; DL = unidades
                            ADD  DL, 48                        ; Convertir a ASCII
                            MOV  AH, 02h                       ; Función: escribir carácter
                            INT  21h                           ; Imprimir
    
                            RET                                ; HUD completo
DIBUJAR_UI ENDP

    ; ===========================================================
    ; PROCEDIMIENTO: MENU_FIN_JUEGO
    ; Descripción: Muestra la pantalla de Game Over simplificada
    ; Retorna: AL = tecla presionada
    ; ===========================================================
MENU_FIN_JUEGO PROC
    ; Cambiar a modo texto
                            MOV  AH, 00h
                            MOV  AL, 03h                       ; Modo texto 80x25
                            INT  10h

    ; ====================================================
    ; TEXTO "GAME OVER"
    ; ====================================================
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 0Ah                       ; Fila 10
                            MOV  DL, 10h                       ; Columna 16 (centrado)
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_GAME_OVER
                            INT  21h

    ; ====================================================
    ; VERIFICAR QUIÉN GANÓ Y MOSTRAR MENSAJE
    ; ====================================================
                            CMP  GANADOR_UNO, 01h              ; ¿Ganó jugador 1?
                            JE   MENSAJE_GANADOR_IZQ           ; Sí, mostrar mensaje jugador 1
    
                            CMP  GANADOR_DOS, 01h              ; ¿Ganó jugador 2?
                            JE   MENSAJE_GANADOR_DER           ; Sí, mostrar mensaje jugador 2
    
                            JMP  MOSTRAR_OPCIONES              ; No hay ganador (no debería pasar)

    ; ====================================================
    ; MENSAJE GANADOR IZQUIERDO
    ; ====================================================
    MENSAJE_GANADOR_IZQ:    
    ; Texto "JUGADOR 1 GANO EL JUEGO"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 0Ch                       ; Fila 12
                            MOV  DL, 0Ch                       ; Columna 12
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_JUGADOR             ; "JUGADOR "
                            INT  21h
    
                            MOV  AH, 09h
                            LEA  DX, TEXTO_JUGADOR_UNO         ; "1 GANO EL JUEGO"
                            INT  21h
    
                            JMP  MOSTRAR_OPCIONES

    ; ====================================================
    ; MENSAJE GANADOR DERECHO
    ; ====================================================
    MENSAJE_GANADOR_DER:    
    ; Texto "JUGADOR 2 GANO EL JUEGO"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 0Ch                       ; Fila 12
                            MOV  DL, 0Ch                       ; Columna 12
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_JUGADOR             ; "JUGADOR "
                            INT  21h
    
                            MOV  AH, 09h
                            LEA  DX, TEXTO_JUGADOR_DOS         ; "2 GANO EL JUEGO"
                            INT  21h

    ; ====================================================
    ; OPCIONES: REINICIAR O SALIR
    ; ====================================================
    MOSTRAR_OPCIONES:       
    ; Opción "PRESIONE R PARA REPETIR"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 10h                       ; Fila 16
                            MOV  DL, 0Ah                       ; Columna 10
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_REINICIAR
                            INT  21h

    ; Opción "PRESIONE N PARA SALIR"
                            MOV  AH, 02h
                            MOV  BH, 00h
                            MOV  DH, 12h                       ; Fila 18
                            MOV  DL, 0Ah                       ; Columna 10
                            INT  10h

                            MOV  AH, 09h
                            LEA  DX, TEXTO_SALIR
                            INT  21h

    ; Esperar tecla del usuario
                            MOV  AH, 00h                       ; Función: leer tecla (bloqueante)
                            INT  16h                           ; AL = tecla presionada
    
                            RET                                ; Retornar con AL = tecla
MENU_FIN_JUEGO ENDP

    ; ===========================================================
    ; FIN DEL PROGRAMA
    ; ===========================================================
END PRINCIPAL

; ===========================================================
; RESUMEN DE VARIABLES PRINCIPALES:
; ===========================================================
; BOLA_X, BOLA_Y           - Posición actual de la bola
; VELOCIDAD_BOLA_X/Y       - Velocidad y dirección de la bola
; PALETA_IZQUIERDA_X/Y     - Posición de la paleta izquierda
; PALETA_DERECHA_X/Y       - Posición de la paleta derecha
; ALTO_PALETA_IZQ/DER      - Altura actual de cada paleta (variable)
; PUNTOS_IZQUIERDA/DERECHA - Puntajes de cada jugador
; MODO_JUEGO               - 0=Clásico, 1=Supervivencia
; JUEGO_ACTIVO             - 1=jugando, 0=terminado
; MINUTOS, SEGUNDOS        - Cronómetro del juego
;
; ===========================================================
; INTERRUPCIONES PRINCIPALES:
; ===========================================================
; INT 10h/00h - Establecer modo de video
; INT 10h/02h - Posicionar cursor
; INT 10h/09h - Escribir carácter con atributo
; INT 10h/0Ch - Escribir píxel en modo gráfico
; INT 16h/00h - Leer tecla (bloqueante)
; INT 16h/01h - Verificar tecla (no bloqueante)
; INT 21h/02h - Escribir carácter en pantalla
; INT 21h/09h - Escribir string terminado en '$'
; INT 21h/2Ch - Obtener hora del sistema
; INT 21h/4Ch - Terminar programa
; ===========================================================