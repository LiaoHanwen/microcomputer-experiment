data	segment
fenpin  dw 0001h,3906,3472,3125,2932,2604,2344,2083,1953;frequent
digital db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh
music   db 0,1,2,3,1,1,2,3,1,0,3,4,5,0,3,4,5,0,5,6,5,4,3,1,0,5,6,5,4,3,1,0,1,5,1,0,1,5,1,0 
num		db 00h,070h,0b0h,0d0h,0e0h 
data	ends

stack	segment  stack 'stack'
        db 100 dup(0)
stack   ends

code   	segment
assume  cs:code,ds:data,es:data,ss:stack

delay 	proc near
        push cx
        mov	cx,100h 
stop:   loop  stop
        pop   cx
        ret
delay   endp

delay1  proc   near
        push   cx
        mov    cx,0ffffh 
wait1:  loop   wait1
        pop    cx
        ret
delay1  endp

key     proc  near
        push ax
        push bx
        push dx
inputl: mov dx,28ah
        mov bl,7fh                      ;01111111b      scan reset
ininl:  mov al,bl
        out dx,al                       ;choose a row
        in  al,dx                       ;read columns
               and al,0fh
                cmp al,0fh
                jnz intest                      ;columns find
                ror     bl,1                    ;right shift bl
                cmp bl,0f7h                     ;11110111b
                jnz ininl                       ;4 times for ininl
                jmp inputl                      ;scan reset

intest: mov ah,al
                ;call delay                     ;delay
                in  al,dx                       ;read again
                and al,0fh
                cmp al,ah
                jz  bling                       ;read the same input
                jmp inputl                      ;scan again

bling:  push ax
                xor bl,0ffh             ;reverse bl
                xor al,0fh                      ;reverse low 4 bits of al
                mov cl,4
                shr bl,cl                       ;right shift bl 4 times
                change bl
                change al
                sub bl,1                        ;bl=bl-1  (0-3)
                xchg al,bl
                mul cl                          ;bl=bl*4
                add al,bl               ;al is offset
                pop dx
                pop bx
                xor ah,ah
                mov bx,ax
                pop ax
        ret         
key     endp

start:  mov  ax,data
        mov  ds,ax
        mov  dx,283h 
        mov  al,36h
        out  dx,al
        mov  dx,28bh  
        mov  al,81h 
        out  dx,al

loop1:  call key  
        cmp  bx,0
        jz   play0
        cmp  bx,9  
        jz   exit
        mov  cx,bx   
        mov  bx,offset digital
        add  bx,cx
        mov  al,[bx]
        mov  dx,288h
        out  dx,al
        mov  bx,offset fenpin
        mov  ax,cx
        add  ax,ax
        add  bx,ax
        mov  ax,[bx]
        mov  dx,280h
        out  dx,al
        mov  al,ah
        out  dx,al
        call delay1
        call delay1

        mov  dx,28ah 
        in   al,dx

        mov  ah,al
loop2:  call delay
        in   al,dx
        cmp  al,ah
        jz   loop2
        mov  ax,0h
        mov  dx,283h
        mov  al,36h
        out  dx,al         
        jmp  loop1                              


play0:  mov  cx,01h
play:   push cx   
        mov  bx,offset music
        add  bx,cx
        mov  al,[bx]
        mov  cl,al
        mov  ch,0h
        mov  bx,offset digital
        add  bx,cx
        mov  al,[bx]
        mov  dx,288h
        out  dx,al
        mov  bx,offset fenpin
        mov  ax,cx
        add  ax,ax
        add  bx,ax
        mov  ax,[bx]
        mov  dx,280h
        out  dx,al
        mov  al,ah
        out  dx,al
        pop  cx
        mov  ax,90h
loop3:  call delay1
        dec  ax
        jnz  loop3  
                     
        inc  cx
        cmp  cx,28h
        jnz  jum
        jmp  loop1
jum:    jmp  play

exit:   mov  al,0
        mov  dx,288h
        out  dx,al
        mov  ax,4c00h
        int  21h     
code    ends
        end  start
