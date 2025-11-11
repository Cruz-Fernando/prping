; ===========================================================
; ************  PROYECTO PING-PONG - Jhojan Cruz *************
; ===========================================================
;
; ************  LISTA DE BUGS ***************
;
; 1. La paleta derecha no se mueve
; 2. Movimiento de las paletas algo lento
; 3. Mostrar puntaje en pantalla correctamente
; 4. No se reinicia automáticamente tras el GAME OVER
; 5. Falta mejorar detección de colisiones en bordes
; 6. Falta agregar mas velocidad a la bola con el tiempo
; 7. Falta agregar un menú inicial
;
; ********************************************

ORG 100H
.MODEL SMALL
.STACK 100H

.DATA
     ; ===================== DATOS DEL JUEGO =====================
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

     VEL_PALETA        DW 05h

     JUEGO_ACTIVO      DB 1
     TEXTO_GAME_OVER   DB "FIN DEL JUEGO $"
     TEXTO_JUGADOR     DB "JUGADOR $"
     GANADOR_UNO       DB 00h
     GANADOR_DOS       DB 00h
     TEXTO_JUGADOR_UNO DB "UNO GANO EL JUEGO $"
     TEXTO_JUGADOR_DOS DB "DOS GANO EL JUEGO $"

     TEXTO_TITULO_PING DB 'PING $'
     TEXTO_TITULO_PONG DB 'PONG $'

     ; ===========================================================
.CODE
PRINCIPAL PROC

                             MOV  AX, @DATA
                             MOV  DS, AX

                             CALL LIMPIAR_PANTALLA
                             CALL INTRO_PROYECTO
                             CALL LIMPIAR_PANTALLA

     BUCLE_TIEMPO:           
                             CMP  JUEGO_ACTIVO, 00h
                             JE   MOSTRAR_FIN_JUEGO

                             MOV  AH, 2Ch
                             INT  21h
                             CMP  DL, TIEMPO_AUX
                             JE   BUCLE_TIEMPO
                             MOV  TIEMPO_AUX, DL

                             CALL LIMPIAR_PANTALLA
                             CALL MOVER_BOLA
                             CALL COLISION
                             CALL DIBUJAR_BOLA
                             CALL MOVER_PALETAS
                             CALL DIBUJAR_PALETAS
                             CALL DIBUJAR_UI
                             JMP  BUCLE_TIEMPO

     MOSTRAR_FIN_JUEGO:      
                             CALL MENU_FIN_JUEGO
                             JMP  BUCLE_TIEMPO

                             RET
PRINCIPAL ENDP

     ; ===========================================================
     ; INTRODUCCIÓN DEL JUEGO
     ; ===========================================================
INTRO_PROYECTO PROC
                             MOV  AH, 00h
                             MOV  AL, 03h
                             INT  10h

                             MOV  AH, 02h
                             MOV  BH, 00h
                             MOV  DH, 12
                             MOV  DL, 34
                             INT  10h

                             MOV  AH, 09h
                             LEA  DX, TEXTO_TITULO_PING
                             INT  21h

                             MOV  AH, 02h
                             MOV  DL, 39
                             INT  10h

                             MOV  AH, 09h
                             LEA  DX, TEXTO_TITULO_PONG
                             INT  21h

                             MOV  AH, 2Ch
                             INT  21h
                             MOV  BL, DH
                             MOV  BH, CL

     ESPERA:                 
                             MOV  AH, 2Ch
                             INT  21h
                             MOV  AL, DH
                             SUB  AL, BL
                             CBW
                             MOV  CX, 100
                             MUL  CX
                             MOV  CL, CL
                             SUB  CL, BH
                             ADD  AX, CX
                             CMP  AX, 300
                             JB   ESPERA
                             RET
INTRO_PROYECTO ENDP

     ; ===========================================================
     ; LIMPIAR PANTALLA
     ; ===========================================================
LIMPIAR_PANTALLA PROC
                             MOV  AH, 00h
                             MOV  AL, 13h
                             INT  10h

                             MOV  AH, 0Bh
                             MOV  BH, 00h
                             MOV  BL, 00h
                             INT  10h
                             RET
LIMPIAR_PANTALLA ENDP

     ; ===========================================================
     ; MOVIMIENTO DE PALETAS
     ; ===========================================================
MOVER_PALETAS PROC
                             MOV  AH, 01h
                             INT  16h
                             JZ   SALIR_MOVIMIENTO

                             MOV  AH, 00h
                             INT  16h

                             CMP  AL, 77h
                             JE   MOVER_PALETA_IZQ_ARRIBA
                             CMP  AL, 57h
                             JE   MOVER_PALETA_IZQ_ARRIBA
                             CMP  AL, 73h
                             JE   MOVER_PALETA_IZQ_ABAJO
                             CMP  AL, 53h
                             JE   MOVER_PALETA_IZQ_ABAJO

     ; === Paleta derecha no funciona (BUG registrado) ===
                             JMP  SALIR_MOVIMIENTO

     MOVER_PALETA_IZQ_ARRIBA:
                             MOV  AX, VEL_PALETA
                             SUB  PALETA_IZQ_Y, AX
                             MOV  AX, LIMITE_VENTANA
                             CMP  PALETA_IZQ_Y, AX
                             JL   FIJAR_PALETA_IZQ_SUP
                             JMP  SALIR_MOVIMIENTO

     FIJAR_PALETA_IZQ_SUP:   
                             MOV  AX, LIMITE_VENTANA
                             MOV  PALETA_IZQ_Y, AX
                             JMP  SALIR_MOVIMIENTO

     MOVER_PALETA_IZQ_ABAJO: 
                             MOV  AX, VEL_PALETA
                             ADD  PALETA_IZQ_Y, AX
                             MOV  AX, ALTO_VENTANA
                             SUB  AX, LIMITE_VENTANA
                             SUB  AX, ALTO_PALETA
                             CMP  PALETA_IZQ_Y, AX
                             JG   FIJAR_PALETA_IZQ_INF
                             JMP  SALIR_MOVIMIENTO

     FIJAR_PALETA_IZQ_INF:   
                             MOV  PALETA_IZQ_Y, AX
                             JMP  SALIR_MOVIMIENTO

     SALIR_MOVIMIENTO:       
                             RET
MOVER_PALETAS ENDP

     ; ===========================================================
     ; DIBUJAR PALETAS
     ; ===========================================================

DIBUJAR_PALETAS PROC
                             MOV  CX, PALETA_IZQ_X
                             MOV  DX, PALETA_IZQ_Y

     DIBUJAR_PALETA_IZQ:     
                             MOV  AH, 0Ch
                             MOV  AL, 0Fh
                             MOV  BH, 00h
                             INT  10h
                             INC  CX
                             MOV  AX, CX
                             SUB  AX, PALETA_IZQ_X
                             CMP  AX, ANCHO_PALETA
                             JNG  DIBUJAR_PALETA_IZQ

                             MOV  CX, PALETA_IZQ_X
                             INC  DX
                             MOV  AX, DX
                             SUB  AX, PALETA_IZQ_Y
                             CMP  AX, ALTO_PALETA
                             JNG  DIBUJAR_PALETA_IZQ

                             MOV  CX, PALETA_DER_X
                             MOV  DX, PALETA_DER_Y

     DIBUJAR_PALETA_DER:     
                             MOV  AH, 0Ch
                             MOV  AL, 0Fh
                             MOV  BH, 00h
                             INT  10h
                             INC  CX
                             MOV  AX, CX
                             SUB  AX, PALETA_DER_X
                             CMP  AX, ANCHO_PALETA
                             JNG  DIBUJAR_PALETA_DER

                             MOV  CX, PALETA_DER_X
                             INC  DX
                             MOV  AX, DX
                             SUB  AX, PALETA_DER_Y
                             CMP  AX, ALTO_PALETA
                             JNG  DIBUJAR_PALETA_DER
                             RET
DIBUJAR_PALETAS ENDP

     ; ===========================================================
     ; MOVER BOLA
     ; ===========================================================

MOVER_BOLA PROC
                             MOV  AX, VEL_BOLA_X
                             ADD  BOLA_X, AX
                             CMP  BOLA_X, 05h
                             JL   PUNTO_JUGADOR_DOS

                             MOV  AX, ANCHO_VENTANA
                             SUB  AX, TAM_BOLA
                             SUB  AX, 05h
                             CMP  BOLA_X, AX
                             JG   PUNTO_JUGADOR_UNO

                             MOV  AX, VEL_BOLA_Y
                             ADD  BOLA_Y, AX
                             CMP  BOLA_Y, 05h
                             JL   INVERTIR_Y

                             MOV  AX, ALTO_VENTANA
                             SUB  AX, TAM_BOLA
                             SUB  AX, 05h
                             CMP  BOLA_Y, AX
                             JG   INVERTIR_Y
                             RET

     PUNTO_JUGADOR_UNO:      
                             INC  PUNTOS_IZQ
                             CALL REINICIAR_BOLA
                             CMP  PUNTOS_IZQ, 05h
                             MOV  GANADOR_UNO, 01h
                             JGE  FIN_JUEGO
                             RET

     PUNTO_JUGADOR_DOS:      
                             INC  PUNTOS_DER
                             CALL REINICIAR_BOLA
                             CMP  PUNTOS_DER, 05h
                             MOV  GANADOR_DOS, 01h
                             JGE  FIN_JUEGO
                             RET

     FIN_JUEGO:              
                             MOV  PUNTOS_IZQ, 00h
                             MOV  PUNTOS_DER, 00h
                             MOV  JUEGO_ACTIVO, 00h
                             RET

     INVERTIR_Y:             
                             NEG  VEL_BOLA_Y
                             RET
MOVER_BOLA ENDP

     ; ===========================================================
     ; DETECCIÓN DE COLISIÓN
     ; ===========================================================

COLISION PROC
                             MOV  AX, BOLA_X
                             ADD  AX, TAM_BOLA
                             CMP  AX, PALETA_DER_X
                             JNG  VERIFICAR_IZQ

                             MOV  AX, BOLA_X
                             MOV  BX, PALETA_DER_X
                             ADD  BX, ANCHO_PALETA
                             CMP  AX, BX
                             JG   VERIFICAR_IZQ

                             MOV  AX, BOLA_Y
                             ADD  AX, TAM_BOLA
                             CMP  AX, PALETA_DER_Y
                             JNG  VERIFICAR_IZQ

                             MOV  AX, BOLA_Y
                             MOV  BX, PALETA_DER_Y
                             ADD  BX, ALTO_PALETA
                             CMP  AX, BX
                             JG   VERIFICAR_IZQ
                             NEG  VEL_BOLA_X
                             RET

     VERIFICAR_IZQ:          
                             MOV  AX, BOLA_X
                             ADD  AX, TAM_BOLA
                             CMP  AX, PALETA_IZQ_X
                             JNG  SALIR_COLISION

                             MOV  AX, BOLA_X
                             MOV  BX, PALETA_IZQ_X
                             ADD  BX, ANCHO_PALETA
                             CMP  AX, BX
                             JG   SALIR_COLISION

                             MOV  AX, BOLA_Y
                             ADD  AX, TAM_BOLA
                             CMP  AX, PALETA_IZQ_Y
                             JNG  SALIR_COLISION

                             MOV  AX, BOLA_Y
                             MOV  BX, PALETA_IZQ_Y
                             ADD  BX, ALTO_PALETA
                             CMP  AX, BX
                             JG   SALIR_COLISION

                             NEG  VEL_BOLA_X

     SALIR_COLISION:         
                             RET
COLISION ENDP

     ; ===========================================================
     ; REINICIAR POSICIÓN DE LA BOLA
     ; ===========================================================
REINICIAR_BOLA PROC
                             MOV  AX, BOLA_ORIGINAL_X
                             MOV  BOLA_X, AX
                             MOV  AX, BOLA_ORIGINAL_Y
                             MOV  BOLA_Y, AX
                             NEG  VEL_BOLA_X
                             NEG  VEL_BOLA_Y
                             RET
REINICIAR_BOLA ENDP

     ; ===========================================================
     ; DIBUJAR BOLA
     ; ===========================================================
DIBUJAR_BOLA PROC
                             MOV  CX, BOLA_X
                             MOV  DX, BOLA_Y
     DIBUJAR:                
                             MOV  AH, 0Ch
                             MOV  AL, 0Fh
                             MOV  BH, 00h
                             INT  10h
                             INC  CX
                             MOV  AX, CX
                             SUB  AX, BOLA_X
                             CMP  AX, TAM_BOLA
                             JNG  DIBUJAR
                             MOV  CX, BOLA_X
                             INC  DX
                             MOV  AX, DX
                             SUB  AX, BOLA_Y
                             CMP  AX, TAM_BOLA
                             JNG  DIBUJAR
                             RET
DIBUJAR_BOLA ENDP

     ; ===========================================================
     ; INTERFAZ DE USUARIO
     ; ===========================================================

DIBUJAR_UI PROC
                             MOV  AH, 02h
                             MOV  BH, 00h
                             MOV  DH, 03h
                             MOV  DL, 06h
                             INT  10h

                             MOV  AH, 02h
                             MOV  DX, PUNTOS_IZQ
                             ADD  DX, 48
                             INT  21h

                             MOV  AH, 02h
                             MOV  BH, 00h
                             MOV  DH, 03h
                             MOV  DL, 20h
                             INT  10h

                             MOV  AH, 02h
                             MOV  DX, PUNTOS_DER
                             ADD  DX, 48
                             INT  21h
                             RET
DIBUJAR_UI ENDP

     ; ===========================================================
     ; MENÚ DE FIN DE JUEGO
     ; ===========================================================
MENU_FIN_JUEGO PROC
                             CALL LIMPIAR_PANTALLA

                             MOV  AH, 02h
                             MOV  BH, 00h
                             MOV  DH, 04h
                             MOV  DL, 0Dh
                             INT  10h

                             MOV  AH, 09h
                             LEA  DX, TEXTO_GAME_OVER
                             INT  21h

                             MOV  AH, 02h
                             MOV  BH, 00h
                             MOV  DH, 08h
                             MOV  DL, 0Dh
                             INT  10h

                             MOV  AH, 09h
                             LEA  DX, TEXTO_JUGADOR
                             INT  21h

                             CMP  GANADOR_UNO, 01h
                             JE   MOSTRAR_UNO
                             CMP  GANADOR_DOS, 01h
                             JE   MOSTRAR_DOS

                             MOV  GANADOR_UNO, 00h
                             MOV  GANADOR_DOS, 00h
                             RET

     MOSTRAR_UNO:            
                             MOV  AH, 09h
                             LEA  DX, TEXTO_JUGADOR_UNO
                             INT  21h
                             MOV  AH, 00h
                             INT  16h
                             RET

     MOSTRAR_DOS:            
                             MOV  AH, 09h
                             LEA  DX, TEXTO_JUGADOR_DOS
                             INT  21h
                             MOV  AH, 00h
                             INT  16h
                             RET
MENU_FIN_JUEGO ENDP

END PRINCIPAL
