IDEAL
MODEL small
STACK 100h
DATASEG
procRet dw ? ; used in functions to store function stack data
number dd 200000000
CODESEG
proc printNewLine
    mov dl, 10
    mov ah, 2
    int 21h
    ret
ENDP printNewLine

;param: S1 digit
proc printDigit
    pop [procRet]
    pop ax
    mov dl, al
    add dl, 48 ; ascii
    mov ah, 2
    int 21h
    push [procRet]
    ret
ENDP printDigit

;param: S1 divisible, S2 divider
;return: S1 result, S2 remainder  
PROC div8Bit
    pop [procRet]

    pop bx ; divisible into bx
    pop ax ; divider into ax
    div bl ; al / bl
    ; result in al, bl

    ; reset bh, ah for any case
    xor bx, bx
    mov bl, ah
    xor ah, ah

    ; return "result, remainder"
    
    push bx
    push ax

    push [procRet]
    ret
ENDP div8Bit

;param: S1 divisible, S2 divider
;return: S1 result, S2 remainder  
PROC div16Bit
    pop [procRet]
    pop bx
    pop ax
    xor dx, dx
    div bx

    push dx
    push ax
    ; return result, remainder
    push [procRet]
    ret
ENDP div16Bit

PROC idiv32

;Divides a signed 32-bit value by a signed 16-bit value.

;alters ax
;alters bx
;alters dx

;expects the signed 32-bit dividend in dx:ax
;expects the signed 16-bit divisor in bx

;returns the signed 32-bit quotient in dx:ax

push cx
push di
push si

    mov ch, dh      ;ch <- sign of dividend
    xor ch, bh      ;ch <- resulting sign of dividend/divisor

    test dh, dh     ;Is sign bit of dividend set?  
    jns chk_divisor ;If not, check the divisors sign.
    xor di, di      ;If so, negate dividend.  
    xor si, si      ;clear di and si   
    sub di, ax      ;subtract low word from 0, cf set if underflow occurs
    sbb si, dx      ;subtract hi word + cf from 0, di:si <- negated dividend
    mov ax, di      
    mov dx, si      ;copy the now negated dividend into dx:ax

chk_divisor:
    xor di, di
    sbb di, bx      ;di <- negated divisor by default
    test bh, bh     ;Is sign bit of divisor set?
    jns uint_div    ;If not, bx is already unsigned. Begin unsigned division.
    mov bx, di      ;If so, copy negated divisor into bx.

uint_div:
    mov di, ax      ;di <- copy of LSW of given dividend
    mov ax, dx      ;ax <- MSW of given dividend
    xor dx, dx      ;dx:ax <- 0:MSW  
    div bx          ;ax:dx <- ax=MSW of final quotient, dx=remainder

    mov si, ax      ;si <- MSW of final quotient
    mov ax, di      ;dx:ax <- dx=previous remainder, ax=LSW of given dividend
    div bx          ;ax:dx <- ax=LSW of final quotient, dx=final remainder
    mov dx, si      ;dx:ax <- final quotient

    test ch, ch     ;Should the quotient be negative?
    js neg_quot     ;If so, negate the quotient.
pop si              ;If not, return. 
pop di
pop cx
    ret

neg_quot:
    xor di, di      
    xor si, si
    sub di, ax
    sbb si, dx
    mov ax, di
    mov dx, si      ;quotient negated
pop si
pop di
pop cx
    ret

ENDP idiv32

start:
    mov ax, @data
    mov ds, ax
    ; code here
	mov bx, offset number
	mov dx, [bx]
	mov ax, [bx + 2]
	mov bx, 16
	call idiv32

exit:
    call printNewLine
    mov ax, 4c00h
    int 21h
END start
