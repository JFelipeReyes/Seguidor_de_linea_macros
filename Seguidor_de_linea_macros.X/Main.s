PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

;///////////////////////////////////////////////////////////////////////////////
   
#define MI	PORTD,1 ;SALIDA AVANZAR MOTOR IZQUIERDO
#define MD	PORTD,2 ;SALIDA AVANZAR MOTOR DERECHO 
#define RI	PORTD,3 ;SALIDA RETROCEDER MOTOR IZQUIERDO
#define BKR	PORTD,4 ;SALIDA RETROCEDER MOTOR DERECHO
#define RIGHT	PORTD,5 ;SALIDA LED DERECHO
#define STOP	PORTD,6 ;SALIDA LED STOP
#define LEFT	PORTD,7 ;SALIDA LED IZQUIERDO 

#define S0	PORTC,1 ;ENTRADA S0 (IZQUIERDO)
#define S1	PORTC,2 ;ENTRADA S1 (CENTRAL)
#define S2	PORTC,3 ;ENTRADA S2 (DERECHO)
   
PSECT code

;///////////////////////////////////////////////////////////////////////////////
 
AVANZAR:
BSF  MI
BSF  MD
BCF  RI
BCF  BKR
BCF  RIGHT
BCF  STOP
BCF  LEFT
GOTO MAIN
 
DETENER:
BCF  MI
BCF  MD
BCF  RI
BCF  BKR
BCF  RIGHT
BSF  STOP
BCF  LEFT
GOTO MAIN

DERECHA:
BCF  MD
BSF  MI
BCF  RI
BCF  BKR
BSF  RIGHT
BCF  STOP
BCF  LEFT
GOTO MAIN

IZQUIERDA:
BSF  MD
BCF  MI
BCF  RI
BCF  BKR
BCF  RIGHT
BCF  STOP
BSF  LEFT
GOTO MAIN

;///////////////////////////////////////////////////////////////////////////////

INISYS:
    BCF STATUS,6 ;BK1
    BSF STATUS,5
   
    BSF TRISC, 1	;PORT (C1) S0 ENTRADA
    BSF TRISC, 2	;PORT (C2) S2 ENTRADA
    BSF TRISC, 3	;PORT (C3) S1 ENTRADA
   
    BCF TRISD, 1	;PORT (D0) MI SALIDA
    BCF TRISD, 2	;PORT (D1) MD SALIDA
    BCF TRISD, 3	;PORT (D2) RI SALIDA
    BCF TRISD, 4	;PORT (D3) RD SALIDA
    BCF TRISD, 5	;PORT (D4) RIGHT SALIDA
    BCF TRISD, 6	;PORT (D5) STOP SALIDA
    BCF TRISD, 7	;PORT (D6) LEFT SALIDA
   
;///////////////////////////////////////////////////////////////////////////////
    
    BCF STATUS, 5 ; BK0
   
    MAIN:
    BTFSS S0
    GOTO  STEP_1
    GOTO  STEP_2
 
    STEP_1:
    BTFSS S2
    GOTO  STEP_3
    GOTO  STEP_4

    STEP_2:
    BTFSS S2
    GOTO  STEP_5
    GOTO  STEP_6
   
    STEP_3:
    BTFSS S1
    CALL  DETENER
    CALL  DERECHA
   
    STEP_4:
    BTFSS S1
    CALL  AVANZAR
    CALL  DERECHA
   
    STEP_5:
    BTFSS S1
    CALL  IZQUIERDA
    GOTO  MAIN
   
    STEP_6:
    BTFSS S1
    CALL  IZQUIERDA
    CALL  DETENER

    END resetVec