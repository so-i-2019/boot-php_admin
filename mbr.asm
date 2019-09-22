	;; mbr.asm - A simple x86 bootloader example.
	;;
	;; In worship to the seven hacker gods and for the honor 
	;; of source code realm, we hereby humbly offer our sacred 
	;; "Hello World" sacrifice. May our code remain bugless.


	
	org 0x7c00		; Our load address

	mov ah, 0xe		; Configure BIOS teletype mode

	mov bx, 0		; May be 0 because org directive.

loop:				; Write a 0x0-terminated ascii string
	mov al, [here + bx]	
	int 0x10
	cmp al, 0x0
	je end
	add bx, 0x1		
	jmp loop

end:				; Jump forever (same as jmp end)
	jmp $

here:				; C-like NULL terminated string

	db 'Aperte um dos numeros de 1 a 9 para selecionar a posicao desejada do tabuleiro', 0xd, 0xa, 0x0
	
	times 510 - ($-$$) db 0	; Pad with zeros
	dw 0xaa55		; Boot signature

section .data
	posicoes times 9 db 0 
