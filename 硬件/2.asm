data	segment
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ah,01h
		int 21h			;input ascii -> al
		cmp al,1bh
		jz exit			;exit when input esc
		mov dx,2a8h
		out dx,al		;output al to leds
		jmp start

exit:	mov al,0
		mov dx,2a8h
		out dx,al		;turn off leds
		mov ax,4c00h
		int 21h			;return

code	ends
		end start