;Test B

;macro for output
output	macro	ostr,onum
		mov dx,offset ostr
		mov ah,09h
		int 21h
		mov dl,onum
		mov ah,02h
		int 21h
		endm

data	segment
orgin	dw  1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,-1,-2,-3,-4,-5,-6,-7	;test numbers
count	equ $-orgin	;size of numbers
poev	db	'0'
pood	db 	'0'
neev	db	'0'
neod	db	'0'
zero	db	'0'

poevstr	db 'Positive and even: ','$'
poodstr	db 0dh,0ah,'Positive and odd: ','$'
neevstr	db 0dh,0ah,'Negative and even: ','$'
neodstr	db 0dh,0ah,'Negative and odd: ','$'
zerostr	db 0dh,0ah,'Equal to 0: ','$'
data	ends

code	segment
assume	cs:code,ds:data

start:	mov ax,data
		mov	ds,ax		;ds=data
		lea ax,orgin
		mov si,ax		;si=orgin
		mov ax,count
		mov bl,2		;bx=2
		div	bl
		mov cx,ax

malp:	mov ax,[si]
		cmp ax,0
		jz	fzero		;lower than 0
		jg	posi		;greater than 0
		jl	nega		;is 0
edlp:	add si,2
		loop malp
		jmp otpt

fzero:	add [zero],1	;zero+1
		jmp	edlp		;return

posi:	idiv bl			;positive
		cmp ah,0
		jz	fpoev
		jmp	fpood

fpoev:	add poev,1		;positive & even
		jmp edlp

fpood:	add pood,1		;positive & odd
		jmp edlp

nega:	idiv bl			;negative
		cmp ah,0
		jz	fneev
		jmp	fneod

fneev:	add neev,1		;negative & even
		jmp edlp

fneod:	add neod,1		;negative & odd
		jmp edlp

otpt:	output poevstr,poev
		output poodstr,pood
		output neevstr,neev
		output neodstr,neod
		output zerostr,zero

		mov ax,4c00h
		int 21h

code	ends
		end start