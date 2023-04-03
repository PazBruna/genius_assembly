ORG 0000h

;tela LCD 
    RS      equ     P1.3   
    EN      equ     P1.2   

LJMP CONFIG 

; Inicia Jogo
INT_EXT0:
	AJMP INICIAR_GAME
	RETI


ORG 000Bh
INT_TEMP0:	
	MOV TH0, #0 
	MOV TL0, #0 
	RETI

ORG 0080h

RETORNA_MSG_ERROU:
	acall lcd_inicio
	MOV A, #0
	ACALL posicionaCursor 
	MOV A, #'E'
	ACALL sendCharacter
	MOV A, #'R'
	ACALL sendCharacter
	MOV A, #'R'
	ACALL sendCharacter
	MOV A, #'O'
	ACALL sendCharacter
	MOV A, #'U'
	ACALL sendCharacter
	MOV A, #'!'
	ACALL sendCharacter
	ACALL retornaCursor
	MOV P1, #11111111b
	
	;reinicia jogo
	CPL P0.1 
	MOV R1, #80 
	MOV R0, #96

	JNB P3.2, $ 
	LJMP INICIAR_GAME

RETORNA_MSG_GANHOU:
	acall lcd_inicio
	MOV A, #0
	ACALL posicionaCursor 
	MOV A, #'G'
	ACALL sendCharacter
	MOV A, #'A'
	ACALL sendCharacter
	MOV A, #'N'
	ACALL sendCharacter
	MOV A, #'H'
	ACALL sendCharacter
	MOV A, #'O'
	ACALL sendCharacter
	MOV A, #'U'
	ACALL sendCharacter
	ACALL retornaCursor
	MOV P1, #11111111b

	;Reinicia novamente 
	CPL P0.1 
	MOV R1, #80 
	MOV R0, #96 

	JNB P3.2, $ 
	LJMP ENTRADA_PRA_INICIAR



DELAY_ARMAZENAMENTO:
	DJNZ R6, DELAY_ARMAZENAMENTO
	MOV R6,#60
	RET

ROTATE:
	RR A 
	DJNZ B, ROTATE
	MOV P1, A
	RET

SALVA_SEQ:
	MOV @R1, P1
	INC R1
	RET

SALVA_USR:
	MOV @R0, P2
	INC R0
	CALL DELAY_ARMAZENAMENTO ;Torna led mais lento - delay
	MOV P1, #11111111b ;Desliga led
	LJMP INICIAR_GAME ;inicia o jogo

GERA_SEED:
	MOV A, TL0
	MOV B, #17
	MUL AB
	RLC A 
	ADD A, B
	MOV TL0, A
	RET

;Gera numero aleatorio
RANDOM:
    CALL GERA_SEED
	MOV P1, #11111111b
	MOV A, TL0
	MOV B, #6h
	DIV AB

	MOV A, #01111111b
	MOV R2,B
	
	CJNE R2,#0h,ROTATE
	LJMP INICIAR_GAME


;Salva o led aceso no P1
SALVA_RANDOM:
	CJNE R1, #84, SALVA_SEQ 
	MOV @R1, P1
	CPL P0.0 
	RET


;Aqui armazena os numeros digitados
ARMAZENA_ENTRADA:
	MOV P1, P2 ;Mostra qual o botão o usuário apertou
	
	CJNE R0, #100, SALVA_USR
	MOV @R0, P2
	CPL P0.0 
	CPL P0.1 ;Flag 
	LJMP INICIAR_GAME

; Aqui Armazena qual entrada o usuario colocou - Lorena
LOOP_INSERT:
	MOV P1, #01111111b
	MOV P1, #11111111b
	JNB P2.7, ARMAZENA_ENTRADA
	JNB P2.6, ARMAZENA_ENTRADA
	JNB P2.5, ARMAZENA_ENTRADA
	JNB P2.4, ARMAZENA_ENTRADA
	JNB P2.3, ARMAZENA_ENTRADA
	JNB P2.2, ARMAZENA_ENTRADA
	SJMP LOOP_INSERT

; R; aqui compara os dados armazenados
COMPARA_JOGO:
	MOV P1, #11111111b
	MOV A, 80
	CJNE A, 96, ERRO
	MOV A, 81
	CJNE A, 97, ERRO
	MOV A, 82
	CJNE A, 98, ERRO
	MOV A, 83
	CJNE A, 99, ERRO
	MOV A, 84
	CJNE A, 100, ERRO
	LJMP RETORNA_MSG_GANHOU

ERRO:
	LJMP RETORNA_MSG_ERROU


CONFIG:
	MOV R6, #60
	MOV R1, #80 
	MOV R0, #96 

	SETB IT0 
	SETB EX0 
	SETB IT1 
	SETB EX1 

	MOV TMOD,#2 
	MOV TH0, #0 ;Move para o valor de recarga do contador o valor 0.
	MOV TL0, #0 
	SETB ET0 
	SETB TR0 ;Contador 0

;espera entrada pra comecar o jogo
ENTRADA_PRA_INICIAR:
	JB P3.2, ENTRADA_PRA_INICIAR

INICIAR_GAME:
	JNB P0.0, LOOP_INSERT
	JNB P0.1, COMPARA_JOGO
	CALL RANDOM
	CALL SALVA_RANDOM
	SJMP INICIAR_GAME

lcd_inicio:

	CLR RS	

	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	CLR P1.4	

	SETB EN	
	CLR EN	

	CALL delay		

	SETB EN		
	CLR EN		

	SETB P1.7	

	SETB EN	
	CLR EN		
				
	CALL delay		

	CLR P1.7	
	CLR P1.6	
	CLR P1.5	
	CLR P1.4	

	SETB EN	
	CLR EN	

	SETB P1.6	
	SETB P1.5		

	SETB EN	
	CLR EN	

	CALL delay		

	CLR P1.7		
	CLR P1.6	
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	SETB P1.7		
	SETB P1.6		
	SETB P1.5	
	SETB P1.4		

	SETB EN	
	CLR EN	

	CALL delay		
	RET


sendCharacter:
	SETB RS  		
	MOV C, ACC.7		
	MOV P1.7, C			
	MOV C, ACC.6	
	MOV P1.6, C			
	MOV C, ACC.5		
	MOV P1.5, C		
	MOV C, ACC.4		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	MOV C, ACC.3		
	MOV P1.7, C			
	MOV C, ACC.2	
	MOV P1.6, C			
	MOV C, ACC.1	
	MOV P1.5, C			
	MOV C, ACC.0		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	CALL delay		
	RET


posicionaCursor:
	CLR RS	         
	SETB P1.7		    
	MOV C, ACC.6		
	MOV P1.6, C			
	MOV C, ACC.5	
	MOV P1.5, C		
	MOV C, ACC.4	
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	MOV C, ACC.3		
	MOV P1.7, C			
	MOV C, ACC.2	
	MOV P1.6, C			
	MOV C, ACC.1		
	MOV P1.5, C		
	MOV C, ACC.0	
	MOV P1.4, C		

	SETB EN		
	CLR EN			

	CALL delay		
	RET


;reinicia o display
retornaCursor:
	CLR RS	      
	CLR P1.7		
	CLR P1.6		
	CLR P1.5	
	CLR P1.4	

	SETB EN		
	CLR EN	

	CLR P1.7	
	CLR P1.6	
	SETB P1.5		
	SETB P1.4		

	SETB EN	
	CLR EN		

	CALL delay	
	RET

;Limpa o display
clearDisplay:
	CLR RS	     
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN	

	CLR P1.7	
	CLR P1.6	
	CLR P1.5	
	SETB P1.4	

	SETB EN	
	CLR EN		

	CALL delay
	RET


delay:
	MOV R3, #50
	DJNZ R3, $
	RET