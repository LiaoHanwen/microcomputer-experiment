;Test_EC.asm

sybdiv	equ 2fh		;/
sybequ	equ 3dh		;=

;macro for output
optstr	macro	ostr
		push dx
		push ax
		mov dx,offset ostr
		mov ah,09h
		int 21h
		pop ax
		pop dx
		endm

optnum	macro	onum
		push dx
		push ax
		mov dl,onum
		mov ah,02h
		int 21h
		pop ax
		pop dx
		endm

data	segment
buff	db	80h
		db	0
		db	80h dup(0)

flag 	db	0

divid	dd 	0	;dividend
divis	dw 	0	;divisor

hint	db	'input equations: ',0dh,0ah,0dh,0ah,'$'
errstr	db	0dh,0ah,'Error: Invalid input!','$'
ovfstr	db	0dh,0ah,'Error: Overflow!','$'
newl	db	0dh,0ah,'$'
div0str db  0dh,0ah,'Error: Can not div 0! ','$'

orgip	dw	0
orgcs	dw	0
data	ends

stack	segment stack'stack'
		db 	100h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,es:data,ss:stack

start:	mov ax,0			;change int 0
		mov ds,ax
		mov si,ax
		mov ax,[si]
		mov [orgip],ax		;store ip
		mov ax,[si+2]
		mov [orgcs],ax		;store cs
		mov ax,code
		mov [si+2],ax
		mov ax,offset newint
		mov [si],ax			;change over
		mov ax,data
		mov ds,ax			;ds=data
		mov es,ax			;es=data
		optstr hint			;output hint
malp:	mov dx,offset buff
		mov ah,0ah
		int 21h				;input equation
		add dx,2			;buff+2
		mov si,dx			;set str-begin addr
		mov dx,offset divid
		mov di,dx			;set divid addr
		xor ax,ax			;ax=0	low
		xor cx,cx			;cx=0	high
inlp:	mov bl,[si]
		cmp bl,sybdiv
		jz	sdiv 			;bl is / (outloop)
		cmp bl,71h			;bl is q (quit)
		jz 	quit
		cmp bl,30h
		jb	inverr			;not a number
		cmp bl,39h
		ja 	inverr			;not a number
		sub bl,30h			;sub offset
		mov byte ptr [flag],1
		call multi			;cx&ax*10
		add ax,bx			;ax+bl
		jnc	noovf
		add cx,1			;overflow cx+1
		jc 	ovferr
noovf:	add si,1
		jmp inlp

sdiv:	mov bl,[flag]
		cmp bl,0
		jz 	inverr
		mov byte ptr [flag],0
		mov [di],ax
		mov [di+2],cx		;store divid
		add di,4			;di ->divis
		xor ax,ax			;ax=0
		add si,1			
inlp2:	mov bl,[si]
		cmp bl,sybequ
		jz	sequ 			;bl is = (outloop)
		cmp bl,30h
		jb	inverr			;not a number
		cmp bl,39h
		ja 	inverr			;not a number
		sub bl,30h			;sub offset
		mov byte ptr [flag],1
		call multi2			;ax*10
		add ax,bx			;ax+bl
		jc 	ovferr
		add si,1
		jmp inlp2

sequ:	mov bl,[flag]
		cmp bl,0
		jz 	inverr
		mov [di],ax			;store divis
		mov di,offset divid
		mov ax,[di]
		mov dx,[di+2]
		xor bx,bx			;bx=0
		mov cx,[di+4]
		div cx				;div answer in bx&ax...dx
		push dx
		call otlp1 			;output bx&ax
		pop dx
		cmp dx,0
		jz 	reload
		optnum 2eh			;output .
		optnum 2eh			;output .
		optnum 2eh			;output .
		xor bx,bx 			;bx=0
		mov ax,dx
		call otlp1 			;output dx
		jmp reload

;output bx&ax
otlp1:	call divi 			;bx&ax/10...cx
		push cx
		cmp bx,0
		jnz	bxaxnz
		cmp ax,0
		jnz bxaxnz
outstak:pop dx
		add dx,30h
		optnum dl
		ret
bxaxnz:	call otlp1
		jmp	 outstak

;cx&ax=cx&ax*10
multi:	push ax
		mov ax,cx
		push bx
		mov bx,10
		mul bx
		pop bx
		cmp dx,0;
		jnz	ovferr
		mov cx,ax
		pop ax
		push bx
		mov bx,10
		mul bx
		pop bx
		add cx,dx
		jo	ovferr
		ret

;ax=ax*10
multi2:	push bx
		mov bx,10
		mul bx
		pop bx
		cmp dx,0
		jnz ovferr
		ret

;bx&ax/10...cx
divi:	push dx
		mov dx,bx
		xor bx,bx  		;bx=0
		mov cx,10
		div cx
		mov cx,dx
		pop dx
		ret

;invalid input error
inverr:	call reint
		optstr errstr
		mov ax,4c00h
		int 21h

;overflow error
ovferr:	call reint
		optstr ovfstr
		mov ax,4c00h
		int 21h

;div 0 error
div0err:optstr div0str
		call reint
		mov ax,4c00h
		int 21h

;recover int 0
reint: 	push ds
		mov ax,0
		mov ds,ax
		mov si,ax
		mov ax,[orgip]		;recover ip
		mov [si],ax
		mov ax,[orgcs]		;recover cs
		mov [si+2],ax
		pop ds
		ret

reload:	optstr newl
		optstr newl
		jmp malp

quit:	call reint
		mov ax,4c00h
		int 21h

;new int 0
newint:	cmp cx,0
		jz 	div0err			;div 0 error
		;dx&ax/cx=bx&ax...dx
		push ax
		mov ax,dx
		xor dx,dx 			;dx=0
		div cx
		mov bx,ax
		pop ax
		div cx
		iret

code	ends
		end start