; ===========================================================
; ************  PROYECTO PING-PONG - Jhojan Cruz *************
; ===========================================================
; ************  LISTA DE BUGS ***************
; 1. Movimiento de paletas algo lento
; 2. Mostrar puntaje correctamente - ✓ RESUELTO
; 3. No se reinicia automáticamente tras GAME OVER - ✓ RESUELTO
; 4. Falta mejorar colisiones en bordes
; 5. Falta agregar más velocidad a la bola
; 6. Falta menú inicial - ✓ RESUELTO
; 7. Bug del temporizador - ✓ RESUELTO
; 8. ASCII Art en menús - ✓ RESUELTO
; 9. Modo Supervivencia - ✓ RESUELTO
;
; ********************************************
;V1.0 - Versión inicial del proyecto
ORG 100H
.MODEL SMALL
.STACK 100H

.DATA
     TIEMPO_AUX        DB 0

     BOLA_X            DW 0A0h
     BOLA_Y            DW 64h
     TAM_BOLA          DW 04h
     VEL_BOLA_X        DW 05h
     VEL_BOLA_Y        DW 02h

     ANCHO_VENTANA     DW 140h
     ALTO_VENTANA      DW 0C8h
     LIMITE_VENTANA    DW 06h

     BOLA_ORIGINAL_X   DW 0A0h
     BOLA_ORIGINAL_Y   DW 64h

     PALETA_IZQ_X      DW 0Ah
     PALETA_IZQ_Y      DW 60h
     PUNTOS_IZQ        DW 0

     PALETA_DER_X      DW 136h
     PALETA_DER_Y      DW 60h
     PUNTOS_DER        DW 0

     ANCHO_PALETA      DW 05h
     ALTO_PALETA       DW 1Fh
     ALTO_PALETA_IZQ   DW 1Fh
     ALTO_PALETA_DER   DW 1Fh
     VEL_PALETA        DW 05h

     JUEGO_ACTIVO      DB 1
     MODO_JUEGO        DB 0

     MINUTOS           DB 0
     SEGUNDOS          DB 0
     TICKS_CONTADOR    DW 0
     ULTIMO_TICK       DB 0

     TEXTO_GAME_OVER   DB "FIN DEL JUEGO $"
     TEXTO_JUGADOR     DB "JUGADOR $"
     GANADOR_UNO       DB 00h
     GANADOR_DOS       DB 00h
     TEXTO_JUGADOR_UNO DB "1 GANO EL JUEGO $"
     TEXTO_JUGADOR_DOS DB "2 GANO EL JUEGO $"

     TEXTO_TITULO_PING DB 'PING $'
     TEXTO_TITULO_PONG DB 'PONG $'

     TEXTO_MENU_1      DB 'G - MODO CLASICO (5 PUNTOS) $'
     TEXTO_MENU_2      DB 'B - MODO SUPERVIVENCIA      $'
     TEXTO_MENU_3      DB 'N - SALIR                   $'
     
     TEXTO_REINICIAR   DB 'PRESIONE R PARA REPETIR $'
     TEXTO_SALIR       DB 'PRESIONE N PARA SALIR   $'
     TEXTO_TIEMPO      DB 'TIEMPO: $'
     TEXTO_DOS_PUNTOS  DB ':$'
     TEXTO_J1          DB 'J1: $'
     TEXTO_J2          DB 'J2: $'

.CODE

PRINCIPAL PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL LIMPIAR_PANTALLA
    CALL MENU_INICIAL
    CALL LIMPIAR_PANTALLA
    CALL INICIAR_TEMPORIZADOR

BUCLE_TIEMPO:
    CMP JUEGO_ACTIVO, 00h
    JE MOSTRAR_FIN_JUEGO

    MOV AH, 2Ch
    INT 21h
    CMP DL, TIEMPO_AUX
    JE BUCLE_TIEMPO
    MOV TIEMPO_AUX, DL

    CALL LIMPIAR_PANTALLA
    CALL MOVER_BOLA
    CALL COLISION
    CALL DIBUJAR_BOLA
    CALL MOVER_PALETAS
    CALL DIBUJAR_PALETAS
    CALL ACTUALIZAR_TEMPORIZADOR
    CALL DIBUJAR_UI
    JMP BUCLE_TIEMPO

MOSTRAR_FIN_JUEGO:
    CALL MENU_FIN_JUEGO
    
    CMP AL, 72h
    JE REINICIAR_TODO
    CMP AL, 52h
    JE REINICIAR_TODO
    
    CMP AL, 6Eh
    JE SALIR_PROGRAMA
    CMP AL, 4Eh
    JE SALIR_PROGRAMA
    
    JMP MOSTRAR_FIN_JUEGO

REINICIAR_TODO:
    MOV JUEGO_ACTIVO, 1
    MOV PUNTOS_IZQ, 0
    MOV PUNTOS_DER, 0
    MOV GANADOR_UNO, 0
    MOV GANADOR_DOS, 0
    MOV AX, 1Fh
    MOV ALTO_PALETA_IZQ, AX
    MOV ALTO_PALETA_DER, AX
    CALL REINICIAR_BOLA
    CALL LIMPIAR_PANTALLA
    CALL MENU_INICIAL
    CALL LIMPIAR_PANTALLA
    CALL INICIAR_TEMPORIZADOR
    JMP BUCLE_TIEMPO

SALIR_PROGRAMA:
    MOV AH, 4Ch
    INT 21h

    RET
PRINCIPAL ENDP

MENU_INICIAL PROC
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 06h
    MOV DL, 05h
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    MOV BH, 00h
    MOV BL, 09h
    MOV CX, 1
    INT 10h
    
    MOV DH, 07h
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 07h
    MOV DL, 04h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 06h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 08h
    MOV DL, 04h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 06h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 06h
    MOV DL, 0Ch
    INT 10h
    MOV AH, 09h
    MOV AL, 'P'
    MOV BH, 00h
    MOV BL, 0Eh
    MOV CX, 1
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Dh
    INT 10h
    MOV AH, 09h
    MOV AL, 'I'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Eh
    INT 10h
    MOV AH, 09h
    MOV AL, 'N'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Fh
    INT 10h
    MOV AH, 09h
    MOV AL, 'G'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 11h
    INT 10h
    MOV AH, 09h
    MOV AL, 'P'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 12h
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 13h
    INT 10h
    MOV AH, 09h
    MOV AL, 'N'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 14h
    INT 10h
    MOV AH, 09h
    MOV AL, 'G'
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 06h
    MOV DL, 1Ah
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    MOV BH, 00h
    MOV BL, 0Ch
    MOV CX, 1
    INT 10h
    
    MOV DH, 07h
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 07h
    MOV DL, 19h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 1Bh
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 08h
    MOV DL, 19h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 1Bh
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h

    MOV AH, 02h
    MOV DH, 07h
    MOV DL, 10h
    INT 10h
    MOV AH, 09h
    MOV AL, 'o'
    MOV BH, 00h
    MOV BL, 0Ah
    MOV CX, 1
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 10h
    MOV DL, 04h
    INT 10h
    
    MOV AH, 09h
    MOV AL, '='
    MOV BH, 00h
    MOV BL, 0Fh
    MOV CX, 24
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 12
    MOV DL, 06h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_MENU_1
    INT 21h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 14
    MOV DL, 06h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_MENU_2
    INT 21h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 16
    MOV DL, 06h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_MENU_3
    INT 21h

ESPERAR_TECLA:
    MOV AH, 00h
    INT 16h

    CMP AL, 67h
    JE MODO_CLASICO
    CMP AL, 47h
    JE MODO_CLASICO

    CMP AL, 62h
    JE MODO_SUPER
    CMP AL, 42h
    JE MODO_SUPER

    CMP AL, 6Eh
    JE SALIR_JUEGO
    CMP AL, 4Eh
    JE SALIR_JUEGO

    JMP ESPERAR_TECLA

MODO_CLASICO:
    MOV MODO_JUEGO, 0
    CALL INTRO_PROYECTO
    RET

MODO_SUPER:
    MOV MODO_JUEGO, 1
    CALL INTRO_PROYECTO
    RET

SALIR_JUEGO:
    MOV AH, 4Ch
    INT 21h
    RET

MENU_INICIAL ENDP

INICIAR_TEMPORIZADOR PROC
    MOV MINUTOS, 0
    MOV SEGUNDOS, 0
    MOV TICKS_CONTADOR, 0
    
    MOV AH, 2Ch
    INT 21h
    MOV ULTIMO_TICK, DL
    RET
INICIAR_TEMPORIZADOR ENDP

ACTUALIZAR_TEMPORIZADOR PROC
    PUSH AX
    PUSH BX
    PUSH DX
    
    MOV AH, 2Ch
    INT 21h
    
    MOV AL, DL
    MOV BL, ULTIMO_TICK
    SUB AL, BL
    
    JNS TICK_POSITIVO
    ADD AL, 100
    
TICK_POSITIVO:
    CMP AL, 18
    JL NO_INCREMENTAR
    
    MOV ULTIMO_TICK, DL
    
    INC SEGUNDOS
    
    CMP SEGUNDOS, 60
    JL NO_INCREMENTAR
    
    MOV SEGUNDOS, 0
    INC MINUTOS
    
NO_INCREMENTAR:
    POP DX
    POP BX
    POP AX
    RET
ACTUALIZAR_TEMPORIZADOR ENDP

INTRO_PROYECTO PROC
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 12
    MOV DL, 34
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_TITULO_PING
    INT 21h

    MOV AH, 02h
    MOV DL, 39
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_TITULO_PONG
    INT 21h

    MOV AH, 2Ch
    INT 21h
    MOV BL, DH
    MOV BH, CL

ESPERA:
    MOV AH, 2Ch
    INT 21h
    MOV AL, DH
    SUB AL, BL
    CBW
    MOV CX, 100
    MUL CX
    MOV CL, CL
    SUB CL, BH
    ADD AX, CX
    CMP AX, 300
    JB ESPERA
    RET
INTRO_PROYECTO ENDP

LIMPIAR_PANTALLA PROC
    MOV AH, 00h
    MOV AL, 13h
    INT 10h

    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 00h
    INT 10h
    RET
LIMPIAR_PANTALLA ENDP

MOVER_PALETAS PROC
    MOV AH, 01h
    INT 16h
    JZ  MOVER_PALETAS_SALIR

    MOV AH, 00h
    INT 16h

    MOV BL, AL

    PUSH BX
    CALL MOVER_IZQUIERDA
    POP BX

    MOV AL, BL
    CALL MOVER_DERECHA

MOVER_PALETAS_SALIR:
    RET
MOVER_PALETAS ENDP

MOVER_IZQUIERDA PROC
    CMP AL, 59h
    JE  MOVER_I_UP
    CMP AL, 79h
    JE  MOVER_I_UP

    CMP AL, 48h
    JE  MOVER_I_DOWN
    CMP AL, 68h
    JE  MOVER_I_DOWN

    RET

MOVER_I_UP:
    MOV AX, VEL_PALETA
    SUB PALETA_IZQ_Y, AX
    MOV AX, LIMITE_VENTANA
    CMP PALETA_IZQ_Y, AX
    JL  MOVER_I_FIX_UP
    RET

MOVER_I_FIX_UP:
    MOV PALETA_IZQ_Y, AX
    RET

MOVER_I_DOWN:
    MOV AX, VEL_PALETA
    ADD PALETA_IZQ_Y, AX
    MOV AX, ALTO_VENTANA
    SUB AX, LIMITE_VENTANA
    SUB AX, ALTO_PALETA_IZQ
    CMP PALETA_IZQ_Y, AX
    JG  MOVER_I_FIX_DN
    RET

MOVER_I_FIX_DN:
    MOV PALETA_IZQ_Y, AX
    RET
MOVER_IZQUIERDA ENDP

MOVER_DERECHA PROC
    CMP AL, 4Fh
    JE  MOVER_D_UP
    CMP AL, 6Fh
    JE  MOVER_D_UP

    CMP AL, 4Ch
    JE  MOVER_D_DOWN
    CMP AL, 6Ch
    JE  MOVER_D_DOWN

    RET

MOVER_D_UP:
    MOV AX, VEL_PALETA
    SUB PALETA_DER_Y, AX
    MOV AX, LIMITE_VENTANA
    CMP PALETA_DER_Y, AX
    JL  MOVER_D_FIX_UP
    RET

MOVER_D_FIX_UP:
    MOV PALETA_DER_Y, AX
    RET

MOVER_D_DOWN:
    MOV AX, VEL_PALETA
    ADD PALETA_DER_Y, AX
    MOV AX, ALTO_VENTANA
    SUB AX, LIMITE_VENTANA
    SUB AX, ALTO_PALETA_DER
    CMP PALETA_DER_Y, AX
    JG  MOVER_D_FIX_DN
    RET

MOVER_D_FIX_DN:
    MOV PALETA_DER_Y, AX
    RET
MOVER_DERECHA ENDP

DIBUJAR_PALETAS PROC
    MOV CX, PALETA_IZQ_X
    MOV DX, PALETA_IZQ_Y

DIB_IZQ:
    MOV AH, 0Ch
    MOV AL, 09h
    MOV BH, 00h
    INT 10h
    INC CX
    MOV AX, CX
    SUB AX, PALETA_IZQ_X
    CMP AX, ANCHO_PALETA
    JNG DIB_IZQ

    MOV CX, PALETA_IZQ_X
    INC DX
    MOV AX, DX
    SUB AX, PALETA_IZQ_Y
    CMP AX, ALTO_PALETA_IZQ
    JNG DIB_IZQ

    MOV CX, PALETA_DER_X
    MOV DX, PALETA_DER_Y

DIB_DER:
    MOV AH, 0Ch
    MOV AL, 0Ch
    MOV BH, 00h
    INT 10h
    INC CX
    MOV AX, CX
    SUB AX, PALETA_DER_X
    CMP AX, ANCHO_PALETA
    JNG DIB_DER

    MOV CX, PALETA_DER_X
    INC DX
    MOV AX, DX
    SUB AX, PALETA_DER_Y
    CMP AX, ALTO_PALETA_DER
    JNG DIB_DER
    RET
DIBUJAR_PALETAS ENDP

MOVER_BOLA PROC
    MOV AX, VEL_BOLA_X
    ADD BOLA_X, AX
    CMP BOLA_X, 05h
    JL LLAMAR_PUNTO_DER

    MOV AX, ANCHO_VENTANA
    SUB AX, TAM_BOLA
    SUB AX, 05h
    CMP BOLA_X, AX
    JG LLAMAR_PUNTO_IZQ

    MOV AX, VEL_BOLA_Y
    ADD BOLA_Y, AX
    CMP BOLA_Y, 05h
    JL INV_Y

    MOV AX, ALTO_VENTANA
    SUB AX, TAM_BOLA
    SUB AX, 05h
    CMP BOLA_Y, AX
    JG INV_Y
    RET

LLAMAR_PUNTO_IZQ:
    CALL PUNTO_IZQ
    RET

LLAMAR_PUNTO_DER:
    CALL PUNTO_DER
    RET

INV_Y:
    NEG VEL_BOLA_Y
    RET
MOVER_BOLA ENDP

PUNTO_IZQ PROC NEAR
    CMP MODO_JUEGO, 1
    JE REDUCIR_DER
    
    INC PUNTOS_IZQ
    CALL REINICIAR_BOLA
    CMP PUNTOS_IZQ, 05h
    JL FIN_PUNTO_IZQ
    MOV GANADOR_UNO, 01h
    CALL TERMINAR_JUEGO
    
FIN_PUNTO_IZQ:
    RET
    
REDUCIR_DER:
    MOV AX, ALTO_PALETA_DER
    SUB AX, 05h
    MOV ALTO_PALETA_DER, AX
    CALL REINICIAR_BOLA
    CMP ALTO_PALETA_DER, 05h
    JG FIN_PUNTO_IZQ
    MOV GANADOR_UNO, 01h
    CALL TERMINAR_JUEGO
    RET
PUNTO_IZQ ENDP

PUNTO_DER PROC NEAR
    CMP MODO_JUEGO, 1
    JE REDUCIR_IZQ
    
    INC PUNTOS_DER
    CALL REINICIAR_BOLA
    CMP PUNTOS_DER, 05h
    JL FIN_PUNTO_DER
    MOV GANADOR_DOS, 01h
    CALL TERMINAR_JUEGO
    
FIN_PUNTO_DER:
    RET
    
REDUCIR_IZQ:
    MOV AX, ALTO_PALETA_IZQ
    SUB AX, 05h
    MOV ALTO_PALETA_IZQ, AX
    CALL REINICIAR_BOLA
    CMP ALTO_PALETA_IZQ, 05h
    JG FIN_PUNTO_DER
    MOV GANADOR_DOS, 01h
    CALL TERMINAR_JUEGO
    RET
PUNTO_DER ENDP

TERMINAR_JUEGO PROC NEAR
    MOV PUNTOS_IZQ, 00h
    MOV PUNTOS_DER, 00h
    MOV JUEGO_ACTIVO, 00h
    RET
TERMINAR_JUEGO ENDP

COLISION PROC
    MOV AX, BOLA_X
    ADD AX, TAM_BOLA
    CMP AX, PALETA_DER_X
    JNG VER_IZQ

    MOV AX, BOLA_X
    MOV BX, PALETA_DER_X
    ADD BX, ANCHO_PALETA
    CMP AX, BX
    JG VER_IZQ

    MOV AX, BOLA_Y
    ADD AX, TAM_BOLA
    CMP AX, PALETA_DER_Y
    JNG VER_IZQ

    MOV AX, BOLA_Y
    MOV BX, PALETA_DER_Y
    ADD BX, ALTO_PALETA_DER
    CMP AX, BX
    JG VER_IZQ

    NEG VEL_BOLA_X
    RET

VER_IZQ:
    MOV AX, BOLA_X
    ADD AX, TAM_BOLA
    CMP AX, PALETA_IZQ_X
    JNG SALIR_COL

    MOV AX, BOLA_X
    MOV BX, PALETA_IZQ_X
    ADD BX, ANCHO_PALETA
    CMP AX, BX
    JG SALIR_COL

    MOV AX, BOLA_Y
    ADD AX, TAM_BOLA
    CMP AX, PALETA_IZQ_Y
    JNG SALIR_COL

    MOV AX, BOLA_Y
    MOV BX, PALETA_IZQ_Y
    ADD BX, ALTO_PALETA_IZQ
    CMP AX, BX
    JG SALIR_COL

    NEG VEL_BOLA_X

SALIR_COL:
    RET
COLISION ENDP

REINICIAR_BOLA PROC
    MOV AX, BOLA_ORIGINAL_X
    MOV BOLA_X, AX
    MOV AX, BOLA_ORIGINAL_Y
    MOV BOLA_Y, AX
    NEG VEL_BOLA_X
    NEG VEL_BOLA_Y
    RET
REINICIAR_BOLA ENDP

DIBUJAR_BOLA PROC
    MOV CX, BOLA_X
    MOV DX, BOLA_Y

DIB_BOLA:
    MOV AH, 0Ch
    MOV AL, 0Ah
    MOV BH, 00h
    INT 10h

    INC CX
    MOV AX, CX
    SUB AX, BOLA_X
    CMP AX, TAM_BOLA
    JNG DIB_BOLA

    MOV CX, BOLA_X
    INC DX
    MOV AX, DX
    SUB AX, BOLA_Y
    CMP AX, TAM_BOLA
    JNG DIB_BOLA

    RET
DIBUJAR_BOLA ENDP

DIBUJAR_UI PROC
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 03h
    MOV DL, 04h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_J1
    INT 21h

    CMP MODO_JUEGO, 1
    JE MOSTRAR_PALETA_IZQ
    
    MOV AH, 02h
    MOV DX, PUNTOS_IZQ
    ADD DX, 48
    INT 21h
    JMP ETIQUETA_J2
    
MOSTRAR_PALETA_IZQ:
    MOV AX, ALTO_PALETA_IZQ
    MOV BL, 10
    DIV BL
    
    MOV DL, AL
    ADD DL, 48
    MOV AH, 02h
    INT 21h
    
    MOV DL, AH
    ADD DL, 48
    MOV AH, 02h
    INT 21h

ETIQUETA_J2:
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 03h
    MOV DL, 1Ch
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_J2
    INT 21h

    CMP MODO_JUEGO, 1
    JE MOSTRAR_PALETA_DER
    
    MOV AH, 02h
    MOV DX, PUNTOS_DER
    ADD DX, 48
    INT 21h
    JMP MOSTRAR_TIMER
    
MOSTRAR_PALETA_DER:
    MOV AX, ALTO_PALETA_DER
    MOV BL, 10
    DIV BL
    
    MOV DL, AL
    ADD DL, 48
    MOV AH, 02h
    INT 21h
    
    MOV DL, AH
    ADD DL, 48
    MOV AH, 02h
    INT 21h
    
MOSTRAR_TIMER:
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 01h
    MOV DL, 0Ch
    INT 10h
    
    MOV AH, 09h
    LEA DX, TEXTO_TIEMPO
    INT 21h
    
    MOV AH, 02h
    MOV DL, MINUTOS
    ADD DL, 48
    INT 21h
    
    MOV AH, 09h
    LEA DX, TEXTO_DOS_PUNTOS
    INT 21h
    
    MOV AL, SEGUNDOS
    MOV AH, 0
    MOV BL, 10
    DIV BL
    MOV DL, AL
    ADD DL, 48
    MOV AH, 02h
    INT 21h
    
    MOV DL, AH
    ADD DL, 48
    MOV AH, 02h
    INT 21h
    
    RET
DIBUJAR_UI ENDP

MENU_FIN_JUEGO PROC
    CALL LIMPIAR_PANTALLA

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 03h
    MOV DL, 0Eh
    INT 10h
    MOV AH, 09h
    MOV AL, '_'
    MOV BH, 00h
    MOV BL, 0Eh
    MOV CX, 5
    INT 10h
    
    MOV DH, 04h
    MOV DL, 0Dh
    INT 10h
    MOV AL, '/'
    MOV CX, 1
    MOV AH, 09h
    INT 10h
    
    MOV DL, 12h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 05h
    MOV DL, 0Ch
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 0Eh
    INT 10h
    MOV AL, '_'
    MOV CX, 3
    MOV AH, 09h
    INT 10h
    
    MOV DL, 11h
    INT 10h
    MOV AL, '|'
    MOV CX, 1
    MOV AH, 09h
    INT 10h
    
    MOV DH, 06h
    MOV DL, 0Dh
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 0Eh
    INT 10h
    MOV AL, '_'
    MOV CX, 3
    MOV AH, 09h
    INT 10h
    
    MOV DL, 11h
    INT 10h
    MOV AL, '/'
    MOV CX, 1
    MOV AH, 09h
    INT 10h
    
    MOV DH, 07h
    MOV DL, 0Fh
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 08h
    MOV DL, 0Eh
    INT 10h
    MOV AL, '|'
    MOV CX, 3
    MOV AH, 09h
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Ah
    MOV DL, 0Bh
    INT 10h
    MOV AH, 09h
    MOV AL, 'G'
    MOV BH, 00h
    MOV BL, 0Ch
    MOV CX, 1
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Ch
    INT 10h
    MOV AH, 09h
    MOV AL, 'A'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Dh
    INT 10h
    MOV AH, 09h
    MOV AL, 'M'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 0Eh
    INT 10h
    MOV AH, 09h
    MOV AL, 'E'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 10h
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 11h
    INT 10h
    MOV AH, 09h
    MOV AL, 'V'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 12h
    INT 10h
    MOV AH, 09h
    MOV AL, 'E'
    INT 10h
    
    MOV AH, 02h
    MOV DL, 13h
    INT 10h
    MOV AH, 09h
    MOV AL, 'R'
    INT 10h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Ch
    MOV DL, 09h
    INT 10h
    
    MOV AH, 09h
    MOV AL, '='
    MOV BH, 00h
    MOV BL, 0Fh
    MOV CX, 18
    INT 10h

    CMP GANADOR_UNO, 01h
    JE DIBUJAR_GANADOR_IZQ
    
    CMP GANADOR_DOS, 01h
    JE DIBUJAR_GANADOR_DER
    
    JMP MOSTRAR_OPCIONES

DIBUJAR_GANADOR_IZQ:
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Eh
    MOV DL, 08h
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    MOV BH, 00h
    MOV BL, 09h
    MOV CX, 1
    INT 10h
    
    MOV DH, 0Fh
    MOV DL, 07h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 08h
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 09h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 10h
    MOV DL, 07h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 09h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Eh
    MOV DL, 0Ch
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_JUGADOR
    INT 21h
    
    MOV AH, 09h
    LEA DX, TEXTO_JUGADOR_UNO
    INT 21h
    
    JMP MOSTRAR_OPCIONES

DIBUJAR_GANADOR_DER:
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Eh
    MOV DL, 17h
    INT 10h
    MOV AH, 09h
    MOV AL, 'O'
    MOV BH, 00h
    MOV BL, 0Ch
    MOV CX, 1
    INT 10h
    
    MOV DH, 0Fh
    MOV DL, 16h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 17h
    INT 10h
    MOV AL, '|'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 18h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DH, 10h
    MOV DL, 16h
    INT 10h
    MOV AL, '/'
    MOV AH, 09h
    INT 10h
    
    MOV DL, 18h
    INT 10h
    MOV AL, '\'
    MOV AH, 09h
    INT 10h
    
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 0Eh
    MOV DL, 08h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_JUGADOR
    INT 21h
    
    MOV AH, 09h
    LEA DX, TEXTO_JUGADOR_DOS
    INT 21h

MOSTRAR_OPCIONES:
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 13h
    MOV DL, 07h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_REINICIAR
    INT 21h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 15h
    MOV DL, 07h
    INT 10h

    MOV AH, 09h
    LEA DX, TEXTO_SALIR
    INT 21h

    MOV AH, 00h
    INT 16h
    
    RET

MENU_FIN_JUEGO ENDP

END PRINCIPAL