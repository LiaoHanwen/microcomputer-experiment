data	segment
number	db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh	;segment code for 0->9
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ax,data
		mov ds,ax
		mov ax,offset number
		mov bx,ax			;base register
		mov dx,28bh
		mov al,80h			;10000000b    mode 0
		out dx,al			;set mode of operation
		mov dx,283h
		mov al,16h			;00010110b
							;counter 0 / low 8 bits / mode 3 / 16-bit
		out dx,al			;set mode of 8253
		call delay
		mov dx,280h
		mov al,34h			;52
		out dx,al			;set counter value 
		mov dx,2b9h
		mov al,40h
		out dx,al			;reset 8251
		call delay
		mov al,5eh			;01011110b
		out dx,al			;set mode instruction
		call delay
		mov al,37h			;00110111b
		out dx,al			;set command instruction
		call delay
sdtest:	mov dx,2b8h
		in  al,dx			;read al
		cmp al,01h
		jz  sdtest			;send unable	
		mov	ah,01h
		int 21h				;input
		cmp al,1bh
		jz 	return			;input esc
		mov dx,2b8h
		out dx,al			;send al
		call delay
rvtest:	mov dx,2b8h
		in 	al,dx			;read al
		cmp al,02h
		jz  rvtest 			;read unable
		mov dx,2b8h
		in  al,dx			;read
		mov dl,al
		mov ah,02h
		int 21h				;output
		cmp al,30h
		jb	sdtest			;not a number
		cmp al,39h
		ja 	sdtest			;not a number
		sub al,30h			;remove offset
		xor ah,ah
		mov si,ax
		mov al,[bx+si]
		mov dx,288h
		out dx,al			;led display -> port a
		jmp	sdtest

return:	mov ax,4c00h
		int 21h				;exit

delay	proc near
		push bx
		push cx
		mov bx,00ffh
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
