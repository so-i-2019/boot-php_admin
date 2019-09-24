
;; Copyright (c) 2019 - Marcelo Isaias de Moraes Junior - marcelo.junior@usp.br e Witor Matheus Alves de Oliveira - witor.mao@usp.br	
	;;
	;; This is free software and distributed under GNU GPL vr.3. Please 
	;; refer to the companion file LICENSING or to the online documentation
	;; at https://www.gnu.org/licenses/gpl-3.0.txt for further information.
	
[bits 16]    ; usar modo de 16 bits
[org 0x7c00] ; diz o endereco de comeco do programa

menu: 
	;mov sp, 0x8000
	;;mov ss, 0


	mov si, msg_instrucao	;; Printa as strings de menu do programa
	call func_imprime_str   
	mov si, msg_opcao_1     ;; Move o endereco da string para o registrador si
	call func_imprime_str   ;; Chamada da subrotina de impressao de strings
	mov si, msg_opcao_2
	call func_imprime_str
	mov si, msg_opcao_0
	call func_imprime_str

	; leitura da opçao desejada
	mov ah, 0x0   ; Modo de leitura de char
	int 0x16      ; Interrupcao de servicos de teclado

	cmp al, 48	 ;('0') Se fim do programa
	je end       ; Pula para o fim do programa

	mov bx, ax   ; Guarda a opcao lida no registrador bx, para tal dado ser usado novamente, pois ax sera usado

	mov si, msg_entrada1   ; Impressao da string para digitar o operando 1
	call func_imprime_str

	call funcLeituraNum    ; Chamada do procedimento de leitura de um numero inteiro para ler o operando 1
	mov [oper1], ax        ; Numero lido tá em ax depois da função, move para o endereco na memoria do operando 1
	call printNum          ; Imprime o numero lido (operando 1)

	mov si, msg_newline    ; Imprime a string de newline (\r\n)
	call func_imprime_str

	mov si, msg_entrada2   ; Impressao da string para digitar o operando 2
	call func_imprime_str

	call funcLeituraNum    ; Chamada do procedimento de leitura de um numero inteiro para ler o operando 2
	mov [oper2], ax        ; Numero lido tá em ax depois da função, move para o endereco na memoria do operando 2
	call printNum          ; Imprime o numero lido (operando 2)

	mov si, msg_newline    ; Imprime a string de newline (\r\n)
	call func_imprime_str

    mov ax, bx			   ; Devolve a ax o valor da opcao escolhida

;;;;;;;;;;;;;;;;;;; OPCOES DE OPERACOES;;;;;;;;;;;;;;;;
	

op_soma:
	cmp al, 49   ;('1') Se funcao desejada soma
	jne op_subtracao   ; senao, (else if) opcao de subtracao
	call soma          ; Chamada do procedimento responsavel pelo calculo da soma entre oper1 e oper2
	jmp menu           ; Volta ao menu
op_subtracao:
	cmp al, 50   ;('2') Se funcao desejada subtracao
	jne menu           ; senao, volta ao menu
	call subtracao     ; Chamada do procedimento responsavel pelo calculo da subtracao entre oper1 e oper2
	jmp menu           ; Volta ao menu

end:				; Jump forever, fim do programa
	jmp $



func_imprime_str:			; Sub rotina responsavel pela impressao da mensagem desejada -> parametros em si: endereco da string desejada
	push ax 

	mov ah, 0x0e    ; teletype-mode

	func_imprime_str_loop:	; Loop da funcao de imprime string (enquanto nao achar o caracter \0)
		
		mov al, [si]                       ; move o char atual para al
		int 0x10                           ; interrupcao de impressao
		cmp al, 0x0                        ; se chegou ao final da string '\0'
		je func_imprime_str_exit 		   ; se sim, sai do loop de impressao
		inc si                             ; senao, incrementa o endereco da string em si, proximo char
		jmp func_imprime_str_loop          ; volta ao começo do loop

func_imprime_str_exit:	; Desempilha e retorna da funcao
		
	pop ax
	ret


funcLeituraNum: ; Funcao responsavel pela leitura do numero inteiro digitado no teclado -> retorno em ax (numero lido)
  push bx       ; Empilha o valor dos registradores que serao usados
  push cx
  push dx

  mov bx, 0     ; inicializa bx com 0

  leituraNum:    ; loop de leitura (leitura e conversao do digito em decimal)
  mov ah, 0x00   ; lê caractere da entrada 
  int 0x16

  cmp al, 0x0d  ; se for enter termina a leitura
  je fimLeitura

  sub al, 48     ; Transforma o ascii do digito em um decimal (Ex: '0' == 48, 48 - 48 = 0; '1' == 49, 49 - 48 = 1)
  mov ah, 0      ; Protege o valor da parte alta (deixa em zero para valor de ax depender so de al)

  imul bx, 10    ; mutiplicando pela potência de 10
  add bx, ax     

  jmp leituraNum  ; volta para o comeco do loop proximo digito a ser lido

	fimLeitura:
	   mov ax, bx ; guarda o valor em ax 

	   pop dx     ; desempilha e retorna
	   pop cx
	   pop bx 

	   ret


printNum: ; ax chega com o valor a ser mostrado
	push ax  ; empilha registradores a serem usados
	push bx
	push cx
	push dx

	mov cx, 0x00
	mov bx, 0x0a

	loop1PrintNum:
		mov dx, 0x00 ; o número pra ser dividido tá com a parte high em dx e a low em ax, por isso tem q resetar dx
		div bx ; dividindo ax/bx

		inc cx ; pra saber quantos números tem dentro do númeor de vdd, pra saber quantas vezes desempilhar

		push dx ; guarda resto na pilha

		cmp ax, 0x0a ; ax tá com o quociente
		jge loop1PrintNum ; se o quociente for maior igual a 10 volta pro loop
		
		;print número mais significativo
	 	add al, 48
	 	mov ah, 0x0e
	 	int 0x10		

		loop2PrintNum:
			pop ax
			dec cx

			add al, 48     ; soma o numero com o corresponde de '0' em ascii para obter o digito em ascii
			mov ah, 0x0e   ; impressao do char
			int 0x10
			
			cmp cx, 0x00       ;Se contador chegou ao fim do numero a ser impresso
			jnz loop2PrintNum  ;Senao, volta ao loop

			pop dx   ;Desempilha e retorna
			pop cx
			pop bx
			pop ax
	
			ret



soma:         ;Funcao responsavel por efetuar a soma dos operandos na memoria oper1 + oper2 e imprime o resultado
	push ax   ;Empilha registradores a serem usados
	push bx
	push si

	mov ax, [oper1]  ; ax contem o operando 1
	mov bx, [oper2]  ; bx contem o operando 2

	add ax, bx       ; ax = ax + bx

	mov si, msg_soma           
	call func_imprime_str 		; Imprime mensagem de resultado da operacao

	call printNum 				; Imprime resultado

	mov si, msg_newline
	call func_imprime_str 		; Pula a linha

	pop si           ; Desempilha e retorna
	pop bx
	pop ax
	ret

subtracao:		;Funcao responsavel por efetuar a sub dos operandos na memoria oper1 - oper2 e imprime o resultado
	push ax		;Empilha registradores a serem usados
	push bx
	push si

	mov ax, [oper1]  ; ax contem o operando 1
	mov bx, [oper2]  ; bx contem o operando 2

	sub ax, bx       ; ax = ax - bx

	mov si, msg_sub
	call func_imprime_str 		; Imprime mensagem de resultado da operacao

	call printNum  				; Imprime resultado

	mov si, msg_newline
	call func_imprime_str 		; Pula a linha


	pop si           ; Desempilha e retorna
	pop bx
	pop ax
	ret


;;Mensagens da calculadora
msg_instrucao: db 'Aperte um dos numeros de 0 a 2 para selecionar a operacao desejada',0xd, 0xa, 0x0
msg_entrada1: db 'Digite o operando 1, depois aperte enter', 0xd, 0xa, 0x0
msg_entrada2: db 'Digite o operando 2, depois aperte enter', 0xd, 0xa, 0x0
msg_opcao_1: db '1 - Soma', 0xd, 0xa, 0x0
msg_opcao_2: db '2 - Subtracao', 0xd, 0xa, 0x0
msg_opcao_0: db '0 - Sair', 0xd, 0xa, 0x0

msg_soma: db 'Resultado da soma: ', 0x0
msg_sub: db 'Resultado da subtracao: ', 0x0

msg_newline: db 0xd, 0xa, 0x0

oper1: dw 0x0
oper2: dw 0x0

times 510-($-$$) db 0           ; fill the output file with zeroes until 510 bytes are full
dw 0xaa55                       ; magic number that tells the BIOS this is bootable
