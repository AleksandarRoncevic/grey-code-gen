data segment
; Definicija podataka
    arr dw 100 dup(?)
    
    X dw 0
    strX db "        "
    
    N db 0
    strN db "        "
    
    msg1 db "Unesite broj bitova : $"
    msgR db "Magicna sekvenca za dat broj bitova: $"
    msgkp db "press any key...$"
ends
; Deficija stek segmenta
stek segment stack
    dw 128 dup(0)
ends
; Ucitavanje znaka bez prikaza i cuvanja     
keypress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Isis stringa na ekran
writeString macro s
    push ax
    push dx  
    mov dx, offset s
    mov ah, 09
    int 21h
    pop dx
    pop ax
endm
; Kraj programa           
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm

writeChar macro c
    push ax
    push dx
    mov ah, 02
    mov dl, c
    int 21h
    pop dx
    pop ax
endm
           
code segment
; Novi red
novired proc
    push ax
    push bx
    push cx
    push dx
    mov ah,03
    mov bh,0
    int 10h
    inc dh
    mov dl,0
    mov ah,02
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
novired endp
; Ucitavanje stringa sa tastature
; Adresa stringa je parametar na steku
readString proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov dx, [bp+12]
    mov bx, dx
    mov ax, [bp+14]
    mov byte [bx] ,al
    mov ah, 0Ah
    int 21h
    mov si, dx     
    mov cl, [si+1] 
    mov ch, 0
kopiraj:
    mov al, [si+2]
    mov [si], al
    inc si
    loop kopiraj     
    mov [si], '$'
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
readString endp
; Konvertuje string u broj
strtoint proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov bx, [bp+14]
    mov ax, 0
    mov cx, 0
    mov si, 10
petlja1:
    mov cl, [bx]
    cmp cl, '$'
    je kraj1
    mul si
    sub cx, 48
    add ax, cx
    inc bx  
    jmp petlja1
kraj1:
    mov bx, [bp+12] 
    mov [bx], ax 
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
strtoint endp
; Konvertuje broj u string
inttostr proc
   push ax
   push bx
   push cx
   push dx
   push si
   mov bp, sp
   mov ax, [bp+14] 
   mov dl, '$'
   push dx
   mov si, 10
petlja2:
   mov dx, 0
   div si
   add dx, 48
   push dx
   cmp ax, 0
   jne petlja2
   
   mov bx, [bp+12]
petlja2a:      
   pop dx
   mov [bx], dl
   inc bx
   cmp dl, '$'
   jne petlja2a
   pop si  
   pop dx
   pop cx
   pop bx
   pop ax 
   ret 4
inttostr endp  

start:
    ; postavljanje segmentnih registara       
    ASSUME cs: code, ss:stek
    mov ax, data
    mov ds, ax
	
    ; Mesto za kod studenata
unos:
    call novired
    writeString msg1
    push 4
    lea dx, strN
    push dx
    call readString
    push dx
    lea dx, N
    push dx
    call strtoint
    
; Racunanje duzine niza za dati broj bitova
; je length = 2^n, gde je n broj bitova
    mov ax, 01h
    mov cl,N
    shl ax,cl
    mov cx,ax
    
    mov ax,0
    xor si,si
; Generisanje magicne sekvence brojeva se svodi
; na prolazak kroz petlju 2^n puta, gde se u
; svakoj iteraciji generise naredni element sekvence.
; I-ti po redu element se dobija tako sto
; izvrsimo operaciju XOR nad brojem I i njegovom 
; right-shift vrednoscu
main_loop:
    mov X, ax
    shr ax,1
    xor ax,X
    mov arr[si],ax
    
    mov ax,X
    inc ax
    add si,2 
    
    loop main_loop
    
    
    call novired
;Ispis niza    
    mov ax, 01h
    mov cl,N
    shl ax,cl
    mov cx,ax
    
    mov ax,0
    xor si,si
    writeString msgR
ispis:
    mov ax, arr[si]
    push ax
    lea dx, strX
    push dx
    call inttostr
    writeString strX
    writeChar ' '
    add si,2
    loop ispis 
    
    call novired
kraj:
    writeString msgkp    
    keypress  
    krajPrograma 
ends
end start
