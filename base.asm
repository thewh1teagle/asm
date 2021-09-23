IDEAL
MODEL small
STACK 100h
DATASEG
procRet dw ? ; used in functions to store function stack data
number dd ?
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

; divide 32 bit number with 16 bit divider
; params: S1: divisible, S2: divider
PROC div32Bit
    pop [procRet]

    pop [number] ; 32 bit variable
    pop cx ; divider
    ; 32 bit div
    mov ax, [word offset number + 2] ; numberL
    mov dx, [word offset number] ; numberH
    div cx
    ; ax > result,  dx > remainder
    
    push [procRet]
    ret
ENDP div32Bit

start:
    mov ax, @data
    mov ds, ax
    ; code here

    push 10
    push 3
    call div32Bit

exit:
    call printNewLine
    mov ax, 4c00h
    int 21h
END start
