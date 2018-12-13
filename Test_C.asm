;Test C

;separator is spa 20h
;terminator is cret 0dh

;macro for output
output	macro	ostr
		mov dx,offset ostr
		mov ah,09h
		int 21h
		endm

data	segment
buff	db	80h
		db	0
		db	80h dup(0)
minnum	dw	0ffffh

hint	db	'Input a sequence of numbers: ','$'
minstr	db	0dh,0ah,'The minimum number is: ','$'
errstr	db	0dh,0ah,'Error: Invalid input!','$'

data	ends

stack	segment stack'stack'
		db 	10h dup(0)
stack	ends

code	segment
assume	cs:code,ds:data,ss:stack

start:	mov ax,data
		mov ds,ax			;ds=data
		output hint			;output hint
		mov dx,offset buff
		mov ah,0ah
		int 21h				;input numbers
		add dx,2			;buff+2
		mov si,dx			;set begin addr
malp:	mov ax,[si]			;ax=[si]
		add si,2
		call vanuj			;judge number
		call comp			;compare ax with minnum
		mov al,[si]			;judge separator
		add si,1
		cmp al,20h
		jz	malp 			;20h ->malp
		cmp al,0dh
		jz	otpt 			;0dh end ->otpt
		jmp inverr 			;other ->inverr

otpt:	output minstr		;output str
		mov ax,minnum
		mov dl,ah
		mov ah,02h
		int 21h
		mov ax,minnum
		mov dl,al
		mov ah,02h
		int 21h				;output minnum
		mov ax,4c00h
		int 21h

;valid number judge
;judge if the number is valid
;ax=number si+2 or jmp invalid number error
vanuj:	cmp ah,30h
		jb	innerr
		cmp ah,39h
		ja 	innerr
		cmp al,30h
		jb	innerr
		cmp al,39h
		ja 	innerr
		ret

;compare
;minnum=the min of ax and minnum
comp:	mov bx,ax
		mov al,bh
		mov ah,bl		;exchange ah al
		mov bx,minnum
		cmp ax,bx
		jae edcp
		mov [minnum],ax
edcp:	ret

innerr:	pop ax		;pop ip
		pop ax		;pop cs
inverr:	output errstr
		mov ax,4c00h
		int 21h

code	ends
		end start