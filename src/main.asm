org 0x7C00 		; assume code loaded at standard boot sector loading address
bits 16			; 16 bit required for boot loading cause back compat

%define ENDL 0x0D, 0x0A 	; carriage return and EOL stuff


start: 			; jumps to main to start to make code nicer
	jmp main

;
; Prints a string to the screen.
; Params:
; 	- ds:si points to a string
;
puts:
	; save registers we will modify to stack
	push si
	push ax

.loop: 		; char-by-char print loop
	lodsb				; puts next si char into al and increment si
	
	or al, al			; jump to .done if al or al != True
	jz .done			;		(al == 0 --> EOL finished (zero terminated))

	mov ah, 0x0e 		; set type of interrupt
	mov bh, 0
	int 0x10			; call interrupt
	
	jmp .loop

.done: 			; cleans up used registers and returns
	pop ax
	pop si
	ret



main:

	; setup data segments
	mov ax, 0   		; can't write to ds/es directly, use ax as intermediary
	mov ds, ax
	mov es, ax

	; setup stack
	mov ss, ax			
	mov sp, 0x7C00 		; stack grown downwards from where we are loaded

	;print message
	mov si, msg_hello 	; moves address of msg_hello to si
	call puts 			; calls printing function

	hlt					; kills OS

.halt: 					; makes sure OS is killed with infinite loop
	jmp .halt


msg_hello: db 'Hello world!', ENDL, 0


times 510-($-$$) db 0 	; pads with zeroes
dw 0AA55h 				; places boot signature (required by BIOS)
