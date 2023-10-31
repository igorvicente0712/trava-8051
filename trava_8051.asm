; PROBLEMAS
; Se o primeiro valor for 1, ele nao aceita


; Mapeamento hardware
RS EQU P1.3 ; Reg Select em P1.3
EN EQU P1.2 ; Enable em P1.2

ORG 00H
LJMP START

ORG 40H
STRINGINICIO:
	DB "TRAVA DIGITAL"
	DB 0

STRINGINSTRUCAO1:
	DB "Para redefinir"
	DB 0

STRINGINSTRUCAO2:
	DB "a senha..."
	DB 0

STRINGINSTRUCAO3:
	DB "Pressionar"
	DB 0

STRINGINSTRUCAO4:
	DB "* ou #"
	DB 0

STRINGINPUT:
	DB "Digite a senha"
	DB 0

STRINGERRO:
	DB "Senha errada"
	DB 0

STRINGACERTO:
	DB "Liberado"
	DB 0

STRINGNOVASENHA:
	DB "Nova senha"
	DB 0

STRINGINVALIDA:
	DB "Senha invalida"
	DB 0

START:
	MOV 40H, #'#' 
	MOV 41H, #'0'
	MOV 42H, #'*'
	MOV 43H, #'9'
	MOV 44H, #'8'
	MOV 45H, #'7'
	MOV 46H, #'6'
	MOV 47H, #'5'
	MOV 48H, #'4'
	MOV 49H, #'3'
	MOV 4AH, #'2'
	MOV 4BH, #'1'
	ACALL SENHAPADRAO
	ACALL FECHA
	ACALL LCD_INIT
ACALL REDEFINIR
	ACALL MENSAGEMINIDISPLAY
	ACALL MENSAGEMINSTRUCAO
	MOV R7, #03H ; numero de tentativas
	CALL DELAY50 ;
MAIN:
	ACALL LIMPADISPLAY
	ACALL MENSAGEMINPUT
	MOV R5, #00H
	MOV R1, #70H
LOOP:
	ACALL LETECLADO
	JNB F0, LOOP
;	Caso tenha pressionado algo
;	Pega o valor e joga na memoria


	MOV A, #40h
	ADD A, R0
	MOV R0, A
	MOV A, @R0
	MOV @R1, A
	INC R1
;	Mostra um asterisco na tela
	MOV A, R5
	ADD A, #46H
	ACALL POSCURSOR
	CALL DELAY50
	MOV A, #'*'
	ACALL MOSTRACHAR
	CLR F0
	INC R5
	CALL DELAY50
;	Ainda nao pegou 5 digitos, volta
	CJNE R5, #05H, LOOP
;	Caso tenha pego 5 digitos
	ACALL CHECASENHA

CHECASENHA:
	MOV R0, #60H
	MOV R1, #70H
	MOV R5, #00H
	LOOPCHECK:
	CLR A
	CLR C
	MOV A, @R0
	SUBB A, @R1
	JNZ ERROU
	INC R0
	INC R1
	INC R5
	CJNE R5, #05H, LOOPCHECK
	ACALL ACERTOU
	RET

ACERTOU:
	MOV R7, #03H ; numero de tentativas reseta
	ACALL LIMPADISPLAY
	ACALL MENSAGEMACERTO
	ACALL ABRE
	JMP $

ERROU:
	ACALL LIMPADISPLAY
	ACALL MENSAGEMERRO
	ACALL DELAY3000
	DJNZ R7, MAIN
	ACALL OOPS

REDEFINIR:
	ACALL LIMPADISPLAY
	ACALL MENSAGENOVASENHA
	MOV R5, #00H
	MOV R1, #60H
	LOOPRED:
	ACALL LETECLADO
	JNB F0, LOOPRED

	; Move para a memoria
	MOV A, #40h
	ADD A, R0
	MOV R0, A
	MOV A, @R0
	MOV @R1, A

;	Mostra um asterisco na tela
	MOV A, R5
	ADD A, #46H
	ACALL POSCURSOR
	CALL DELAY50
	MOV A, #'*'
	ACALL MOSTRACHAR

	INC R1
	INC R5
	CLR F0
	CJNE R5, #05H, LOOPRED
	ACALL CHECASENHAVALIDA
	MOV R7, #03H ; Reseta as tentativas
	LJMP MAIN

CHECASENHAVALIDA:
	MOV R5, #00H
	MOV R1, #60H
	LOOPVALIDA:
	; Verfica se eh um digito valido
	CLR A
	CLR C
	MOV A, #00H ; Nao pode #
	SUBB A, @R1
	JZ CHAMAMENSAGEMINVALIDO
	CLR A
	CLR C
	MOV A, #02H ; Nao pode *
	SUBB A, @R1
	JZ CHAMAMENSAGEMINVALIDO
	INC R5
	CJNE R5, #05H, LOOPVALIDA
	LJMP MAIN

CHAMAMENSAGEMINVALIDO:
	ACALL LIMPADISPLAY
	ACALL MENSAGEMINVALIDA
	ACALL LIMPADISPLAY
	LJMP REDEFINIR

; Teclado
LETECLADO:
	MOV R0, #0			

	; row0
	MOV P0, #0FFh	
	CLR P0.0
	CALL LECOLUNA
	JB F0, TERMINO
						
	; row1
	SETB P0.0
	CLR P0.1
	CALL LECOLUNA
	JB F0, TERMINO

	; row2
	SETB P0.1
	CLR P0.2
	CALL LECOLUNA
	JB F0, TERMINO	

	; row3
	SETB P0.2
	CLR P0.3
	CALL LECOLUNA
	JB F0, TERMINO			
TERMINO:
	RET

LECOLUNA:
	JNB P0.4, PRESSIONADO
	INC R0			
	JNB P0.5, PRESSIONADO
	INC R0			
	JNB P0.6, PRESSIONADO
	INC R0			
	RET				
PRESSIONADO:
	SETB F0			
	RET			


; LCD
LCD_INIT:
	CLR RS
	CLR P1.7
	CLR P1.6
	SETB P1.5
	CLR P1.4
	SETB EN
	CLR EN
	CALL DELAY50	

	SETB EN
	CLR EN
	SETB P1.7
	SETB EN
	CLR EN
	CALL DELAY50

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
	CALL DELAY50

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
	CALL DELAY50
	RET

MOSTRACHAR:
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

	CALL DELAY50
	RET

POSCURSOR:
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

	CALL DELAY50
	RET

CURSORINICIO:
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

	CALL DELAY50
	RET

LIMPADISPLAY:
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
	
	ACALL DELAY1500
	RET

ESCREVESTRING:
  MOV R1, #00h
LOOPSTRING:
	MOV A, R1
	MOVC A,@A+DPTR 
	JZ FIMSTRING	
	ACALL MOSTRACHAR
	INC R1		
	MOV A, R1
	JMP LOOPSTRING		
FIMSTRING:
	RET

; Mensagem inicial
MENSAGEMINIDISPLAY:
	MOV A, #02h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINICIO
	ACALL ESCREVESTRING
	CALL DELAY1500
	RET

MENSAGEMINSTRUCAO:
	ACALL LIMPADISPLAY
	MOV A, #01H
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINSTRUCAO1
	ACALL ESCREVESTRING
	MOV A, #43H
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINSTRUCAO2
	ACALL ESCREVESTRING
	CALL DELAY1500
	ACALL LIMPADISPLAY
	MOV A, #03H
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINSTRUCAO3
	ACALL ESCREVESTRING
	MOV A, #45H
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINSTRUCAO4
	ACALL ESCREVESTRING
	CALL DELAY1500
	RET

MENSAGEMINPUT:
	MOV A, #01h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINPUT
	ACALL ESCREVESTRING
	RET

MENSAGEMACERTO:
	MOV A, #04h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGACERTO
	ACALL ESCREVESTRING
	RET

MENSAGEMERRO:
	MOV A, #02h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGERRO
	ACALL ESCREVESTRING
	RET

MENSAGENOVASENHA:
	MOV A, #03h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGNOVASENHA
	ACALL ESCREVESTRING
	RET

MENSAGEMINVALIDA:
	MOV A, #01h
	ACALL POSCURSOR 
	MOV DPTR, #STRINGINVALIDA
	ACALL ESCREVESTRING
	CLR F0
	RET

; Motor
ABRE:
	CLR P3.0
	SETB P3.1
	CALL DELAYMOTOR
	CLR P3.1
	RET

FECHA:
	SETB P3.0
	CLR P3.1
	CALL DELAYMOTOR
	CLR P3.0
	RET

DELAY50:
	MOV R6, #50
	DJNZ R6, $
	RET

DELAY1500:
	MOV R5, #30
	LOOPCLEAR1500:
	CALL DELAY50
	DJNZ R5, LOOPCLEAR1500
	RET

DELAY3000:
	MOV R5, #60
	LOOPCLEAR3000:
	CALL DELAY50
	DJNZ R5, LOOPCLEAR3000
	RET

DELAYMOTOR:
	MOV R0, #13 ; Delay para fechar e abrir
	DJNZ R0, $
	RET

; Senha
SENHAPADRAO:
; 34, 33, 32, 31, 30, 0
; vulgo 4 3 2 1 0
	MOV R0, #05H
	MOV R1, #60H
	MOV A, #34H
	LOOPSENHA:
	MOV @R1, A
	INC R1
	DEC A
	DJNZ R0, LOOPSENHA
	MOV @R1, #0H
	RET

OOPS:
	ACALL OOPS
