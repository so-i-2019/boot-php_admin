
	org 0x7c00		; Our load address

	mov ah, 0xe		; Configure BIOS teletype mode

	mov bx, 0		; May be 0 because org directive.

loop_principal:				; Logica principal do jogo



func_verifica:				; Sub rotina responsavel pela verificacao de fim de jogo, se houve vencedor e qual tambem
	

func_imprime_str:			; Sub rotina responsavel pela impressao da mensagem desejada -> parametros na stack: endereco da string desejada
	
	pop endereco
	push al
	push bx 

	func_imprime_str_loop:	; Loop da funcao de imprime string (enquanto nao achar o caracter \0)

		mov al, [endereco + bx]	
		int 0x10
		cmp al, 0x0
		je func_imprime_str_exit 
		add bx, 0x1		
		jmp func_imprime_str_loop

	func_imprime_str_exit:	; Desempilha e retorna da funcao
		
		pop bx
		pop al
		;;nao sei como retornar (;-;)

end:				; Jump forever (same as jmp end)
	jmp $


;; Mensagens do jogo (Strings semelhantes as em C);;
msg_instrucao: db 'Aperte um dos numeros de 1 a 9 para selecionar a posicao desejada do tabuleiro', 0xd, 0xa, 0x0
msg_vezx: db 'Vez de X', 0xd, 0xa, 0x0
msg_vezo: db 'Vez de O', 0xd, 0xa, 0x0
msg_empate: db 'Empate: deu velha...', 0xd, 0xa, 0x0
msg_vencedorx: db 'X venceu!' 0xd, 0xa, 0x0
msg_vencedoro: db 'Y venceu!' 0xd, 0xa, 0x0
	
	times 510 - ($-$$) db 0	; Pad with zeros
	dw 0xaa55		; Boot signature

;; Vetor de posicoes: tabuleiro do jogo, armazena as pecas
section .data
	posicoes times 9 db 0
	endereco dw 0x0

;; VALORES DAS POSICOES DO VETOR:
;; ' ': posicao vazia
;; 'X': preenchido por X
;; 'O': preenchido por O
