;Test D

;separator is spa 20h
;terminator is cret 0dh

mscore	equ 100

;macro for output
optstr	macro	ostr
		push ax
		mov dx,offset ostr
		mov ah,09h
		int 21h
		pop ax
		endm

optnum	macro	onum
		push ax
		mov dl,onum
		mov ah,02h
		int 21h
		pop ax
		endm

data	segment
buff	db	80h
		db	0
		db	80h dup(0)
flag	db	0

count	db	0	;count for score
score 	db	20h dup(0)

hint	db	'input a sequence of scores: ',0dh,0ah,'$'
errstr	db	0dh,0ah,'Error: Invalid input!','$'
ovfstr	db	0dh,0ah,'Error: Overflow!','$'
head	db	0dh,0ah,0dh,0ah,'Rank',09h,'ID',09h,'Score','$'
newl	db	0dh,0ah,'$'
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ax,data
		mov ds,ax			;ds=data
		mov es,ax			;es=data
		optstr hint			;output hint
		mov dx,offset buff
		mov ah,0ah
		int 21h				;input numbers
		add dx,2			;buff+2
		mov si,dx			;set str-begin addr
		mov dx,offset score
		mov di,dx			;set score addr
		mov al,0
		;move scores to score
inlp:	mov ah,[si]
		cmp ah,20h
		jz	space			;space
		cmp ah,0dh
		jz	ined			;end input (out loop)
		cmp ah,30h
		jb	inverr			;not a number
		cmp ah,39h
		ja 	inverr			;not a number
		sub ah,30h			;sub offset
		mov [flag],1		;flag=1
		call multi			;al*10
		add al,ah
		cmp al,mscore
		ja	ovferr			;al>mscore
		add si,1
		jmp inlp

		;if flag=1 write
		;else ignore
space:	mov ah,[flag]
		cmp ah,0
		jz	spaed		;flag=0 not a number
		mov [di],al
		add [count],1
		add di,1
		mov al,0
		mov [flag],0
spaed:	add si,1
		jmp inlp


ined:	mov [di],al
		add [count],1	;the last score
		xor cx,cx
		optstr head		
		optstr newl		;output head
		mov cl,[count]
		mov bh,1		;rank
otlp:	call fdmax		;ah=score 	al=index
		push ax
		mov al,bh
		call optal
		pop ax
		optnum 09h
		push ax
		call optal
		pop ax
		optnum 09h
		mov al,ah
		call optal

		optstr newl
		add bh,1
		loop otlp
		mov ax,4c00h
		int 21h



;multiply 10
;al=al*10
multi:	push bx
		push ax
		mov bl,10
		mul bl
		cmp ah,0
		jnz	ovferr
		mov bl,al
		pop ax
		mov al,bl
		pop bx
		ret

;find maximum score
;ah=score 	al=index
fdmax:	push cx
		push bx
		mov cl,[count]
		mov ax,0
		mov si,offset score
		mov bl,0
fdlop:	mov bh,[si]
		add bl,1
		cmp ah,bh
		ja	fdel	;ah>bh ->end loop
		cmp bh,0ffh
		jz	fdel 	;bh=ffh ->end loop
		mov ax,bx	;ah<=bh
fdel:	add si,1
		loop fdlop
		mov si,offset score
		push ax
		mov ah,0
		add si,ax
		sub si,1
		pop ax
		mov byte ptr [si],0ffh	;maximum=0
		pop bx
		pop cx
		ret

;output al
optal:	mov ah,0
		mov dl,10
		div dl
		push ax
		cmp al,0
		jz	optahr
		call optal
optahr:	pop ax
		add ah,30h
		optnum ah
		ret

;invalid input error
inverr:	optstr errstr
		mov ax,4c00h
		int 21h

;overflow error
ovferr:	optstr ovfstr
		mov ax,4c00h
		int 21h

code	ends
		end start