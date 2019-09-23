[bits 16]    ; use 16 bits
[org 0x7c00] ; sets the start address

menu: 
	mov bx, msg_instrucao
	call func_imprime_str
	mov bx, msg_opcao_1
	call func_imprime_str
	mov bx, msg_opcao_2
	call func_imprime_str
	mov bx, msg_opcao_3
	call func_imprime_str
	mov bx, msg_opcao_4
	call func_imprime_str
	mov bx, msg_opcao_0
	call func_imprime_str

	mov ah, 0x0
	int 0x16

	cmp al, 48	 ;('0') Se fim do programa
	je end

op_soma:
	cmp al, 49   ;('1') Se funcao desejada soma
	jne op_subtracao
	call soma
	jmp menu
op_subtracao:
	cmp al, 50
	jne op_multiplicacao
	call subtracao
	jmp menu
op_multiplicacao:
	cmp al, 51
	jne op_divisao
	call multiplicacao
	jmp menu
op_divisao:
	cmp al, 52
	jne menu
	call divisao
	jmp menu
end:				; Jump forever 
	jmp $



func_imprime_str:			; Sub rotina responsavel pela impressao da mensagem desejada -> parametros em bx: endereco da string desejada
	push ax 

	mov ah, 0x0e

	func_imprime_str_loop:	; Loop da funcao de imprime string (enquanto nao achar o caracter \0)
		
		mov al, [bx]
		int 0x10
		cmp al, 0x0
		je func_imprime_str_exit 		
		inc bx
		jmp func_imprime_str_loop

func_imprime_str_exit:	; Desempilha e retorna da funcao
		
	pop ax
	ret

soma:

	ret

subtracao:

	push bx

	mov bx, msg_debug
	call func_imprime_str

	pop bx

	ret

multiplicacao:
	ret

divisao:
	ret




;;Mensagens da calculadora
msg_instrucao: db 'Aperte um dos numeros de 0 a 9 para selecionar a operacao desejada', 0xd, 0xa, 0x0
msg_opcao_1: db '1 - Soma', 0xd, 0xa, 0x0
msg_opcao_2: db '2 - Subtracao', 0xd, 0xa, 0x0
msg_opcao_3: db '3 - Multiplicacao', 0xd, 0xa, 0x0
msg_opcao_4: db '4 - Divisao', 0xd, 0xa, 0x0
msg_opcao_0: db '0 - Sair', 0xd, 0xa, 0x0

msg_debug: db 'Its a me', 0xd, 0xa, 0x0

times 510-($-$$) db 0           ; fill the output file with zeroes until 510 bytes are full
dw 0xaa55                       ; magic number that tells the BIOS this is bootable
