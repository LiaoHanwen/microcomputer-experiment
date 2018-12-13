data	segment
number	db 3fh,4fh,06h,4fh		;segment code for 0313
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ax,data
		mov ds,ax
		mov dx,28bh
		mov al,80h				;10000000b    mode 0
		out dx,al				;set mode of operation
outbin:	mov ax,offset number
		mov si,ax
		mov bl,08h				;00001000b	for segment choose
lp:		mov dx,28ah
		mov al,0				;off leds
		out dx,al 				;segment choose -> port c
		mov al,[si]
		mov dx,288h
		out dx,al				;led display -> port a
		mov dx,28ah
		mov al,bl
		out dx,al 				;segment choose -> port c
		add si,1				;mov si to next
		shr bl,1				;right shift bl
		call delay				;delay
		cmp bl,0
		jnz lp 					;4 times for lp
		jmp outbin				;reset

delay	proc near
		push bx
		push cx
		mov bx,002fh
inloop:	mov cx,0fffh
stop:	loop stop
		sub bx,1
		jnz inloop
		pop cx
		pop bx
		ret
delay	endp

code	ends
		end start