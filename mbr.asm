;; Copyright (c) 2019 - Marcelo Isaias de Moraes Junior - marcelo.junior@usp.br e Witor Matheus Alves de Oliveira - witor.mao@usp.br	
	;;
	;; This is free software and distributed under GNU GPL vr.3. Please 
	;; refer to the companion file LICENSING or to the online documentation
	;; at https://www.gnu.org/licenses/gpl-3.0.txt for further information.
	
[bits 16]    ; use 16 bits
[org 0x7c00] ; sets the start address

menu: 
	;mov sp, 0x8000
	;;mov ss, 0


	mov si, msg_instrucao
	call func_imprime_str
	mov si, msg_opcao_1
	call func_imprime_str
	mov si, msg_opcao_2
	call func_imprime_str
	mov si, msg_opcao_0
	call func_imprime_str

	; leitura  da opçao
	mov ah, 0x0
	int 0x16

	cmp al, 48	 ;('0') Se fim do programa
	je end

	mov bx, ax

	mov si, msg_entrada1
	call func_imprime_str

	call funcLeituraNum
	mov [oper1], ax ; numero lido tá em ax dps da função
	call printNum

	mov si, msg_newline
	call func_imprime_str

	mov si, msg_entrada2
	call func_imprime_str

	call funcLeituraNum
	mov [oper2], ax 
	call printNum

	mov si, msg_newline
	call func_imprime_str

    mov ax, bx

;;;;;;;;;;;;;;;;;;; OPCOES DE OPERACOES;;;;;;;;;;;;;;;;
	

op_soma:
	cmp al, 49   ;('1') Se funcao desejada soma
	jne op_subtracao
	call soma
	jmp menu
op_subtracao:
	cmp al, 50
	jne menu
	call subtracao
	jmp menu

end:				; Jump forever 
	jmp $



func_imprime_str:			; Sub rotina responsavel pela impressao da mensagem desejada -> parametros em si: endereco da string desejada
	push ax 

	mov ah, 0x0e

	func_imprime_str_loop:	; Loop da funcao de imprime string (enquanto nao achar o caracter \0)
		
		mov al, [si]
		int 0x10
		cmp al, 0x0
		je func_imprime_str_exit 		
		inc si
		jmp func_imprime_str_loop

func_imprime_str_exit:	; Desempilha e retorna da funcao
		
	pop ax
	ret


funcLeituraNum:
  push bx
  push cx
  push dx

  mov bx, 0

  leituraNum:
  mov ah, 0x00   ; lê caractere da entrada 
  int 0x16

  cmp al, 0x0d  ; se for enter termina a leitura
  je fimLeitura

  sub al, 48  
  mov ah, 0   

  imul bx, 10 ; mutiplicando pela  potência de 10 correspondente ao algarismo
  add bx, ax 

  jmp leituraNum

	fimLeitura:
	   mov ax, bx ; guarda o valor em operando1

	   pop dx
	   pop cx
	   pop bx 

	   ret


printNum: ; ax chega com o valor a ser mostrado
	push ax
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

			add al, 48
			mov ah, 0x0e
			int 0x10
			
			cmp cx, 0x00
			jnz loop2PrintNum

			pop dx
			pop cx
			pop bx
			pop ax
	
			ret



soma:
	push ax
	push bx
	push si

	mov ax, [oper1] 
	mov bx, [oper2]

	add ax, bx

	mov si, msg_soma
	call func_imprime_str 		; Imprime mensagem de resultado da operacao

	call printNum 				; Imprime resultado

	mov si, msg_newline
	call func_imprime_str 		; Pula a linha

	pop si
	pop bx
	pop ax
	ret

subtracao:
	push ax
	push bx
	push si

	mov ax, [oper1]
	mov bx, [oper2]

	sub ax, bx

	mov si, msg_sub
	call func_imprime_str 		; Imprime mensagem de resultado da operacao

	call printNum  				; Imprime resultado

	mov si, msg_newline
	call func_imprime_str 		; Pula a linha


	pop si
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
