;change	1000 -> 0100
;		0100 -> 0011
change	macro seg
		local conti,endmac
		cmp seg,08h
		jnz conti
		mov seg,04h
		jmp endmac
conti:	cmp seg,04h
		jnz endmac
		mov seg,03h
endmac:	
		endm


data	segment
number 	db	71h,79h,5eh,39h,7ch,77h,6fh,7fh,07h,7dh,6dh,66h,4fh,5bh,06h,3fh
			;F->A->9->0
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ax,data
		mov ds,ax
		mov ax,offset number
		mov si,ax
		mov dx,28bh
		mov al,81h			;10000001b	mode 0 for port a/cu
							;			mode 1 for port cl
		out dx,al			;set mode of operation
inputl:	mov dx,28ah
		mov bl,7fh			;01111111b	scan reset
ininl:	mov al,bl
		out dx,al			;choose a row
		in  al,dx			;read columns
		and al,0fh
		cmp al,0fh
		jnz intest			;columns find
		ror	bl,1			;right shift bl
		cmp bl,0f7h			;11110111b
		jnz ininl 			;4 times for ininl
		jmp inputl			;scan reset

intest:	mov ah,al
		;call delay			;delay
		in  al,dx			;read again
		and al,0fh
		cmp al,ah
		jz  bling			;read the same input
		jmp inputl			;scan again

bling:	push ax
		xor bl,0ffh 		;reverse bl
		xor al,0fh 			;reverse low 4 bits of al
		mov cl,4
		shr bl,cl 			;right shift bl 4 times
		change bl
		change al
		sub bl,1			;bl=bl-1  (0-3)
		xchg al,bl
		mul cl 				;bl=bl*4
		add al,bl    		;al is offset
		xor ah,ah			;ah=0
		mov bx,ax
		sub bx,1
		mov al,[bx+si]		;get number
		mov dx,288h
		out dx,al			;led display -> port a
		pop ax
unptes:	mov dx,28bh
		in  al,dx
		cmp ah,al			;test release
		jz 	unptes			;not release
		call delay			;delay
		in  al,dx
		cmp ah,al			;test again
		jz  unptes 			;not release
		jmp inputl			;release 	scan input again

delay	proc near
		push bx
		push cx
		mov bx,004fh
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