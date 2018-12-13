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
        mov  cx,100h 
stop:   loop stop
        pop  cx
        ret
delay   endp

delay1  proc   near
        push   cx
        mov    cx,0ffffh 
stop1:  loop   stop1
        pop    cx
        ret
delay1  endp

input	proc  near
        push  ax
        push  cx
        push  dx
        mov   cx,01h
check:  mov   dx,28ah     ;portc
        mov   bx,offset num
        add   bx,cx
        mov   al,[bx]
        out   dx,al
        in    al,dx   
        mov   ah,al
        call  delay
        in    al,dx
        cmp   al,ah
        jnz   check   
        and   al,0fh
        cmp   al,0fh
        jz    next
        cmp   al,0eh
        jz    next1
        cmp   al,0dh
        jz    next2
        cmp   al,0bh
        jz    next3 
        mov   bx,01h
        jmp   got
next:   inc   cx    
        cmp   cx,05h
        jnz   jump1 
        mov   cx,01h
jump1:  jmp   check
next1:  mov   bx,04h
        jmp   got
next2:  mov   bx,03h
        jmp   got
next3:  mov   bx,02h
got:    sub   cx,01h
        mov   al,cl
        mov   dl,04h
        mul   dl
        add   bl,al
        sub   bl,01h  
        pop   dx      
        pop   cx
        pop   ax 
        ret         
input	endp

start:  mov  ax,data
        mov  ds,ax
        mov  dx,283h 
        mov  al,36h
        out  dx,al
        mov  dx,28bh  
        mov  al,81h 
        out  dx,al

loop1:  call input  
        cmp  bx,0
        jz   music
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


music:  mov  cx,01h
inmus:   push cx   
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
jum:    jmp  inmus

exit:   mov  al,0
        mov  dx,288h
        out  dx,al
        mov  ax,4c00h
        int  21h     
code    ends
        end  start
