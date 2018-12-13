;Test EB
;Overflow

data	segment

divid	dd 12345678h
divis	dw 1h

data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack
start:	mov ax,data
		mov ds,ax
		mov dx,offset divid
		mov si,dx
		mov ax,[si]
		mov dx,[si+2]
		mov bx,[si+4]
		div bx

		mov ax,4c00h
		int 21h
code	ends
		end start