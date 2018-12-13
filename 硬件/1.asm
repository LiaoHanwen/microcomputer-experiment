data	segment
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov al,0
		mov dx,2a0h
		out dx,al		;turn on
		call delay
		mov dx,2a8h
		out dx,al		;turn off
		call delay		;delay
		jmp start		;loop

;delay
delay	proc near
		mov bx,04ffh
inloop:	mov cx,0fffh
stop:	loop stop
		sub bx,1
		jnz inloop
		ret
delay	endp

code	ends
		end start