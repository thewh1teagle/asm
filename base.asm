IDEAL
MODEL small
STACK 100h
DATASEG
procRet dw ?
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
    pop ax
    pop bx
    xor dx, dx
    div bx

    push ax
    push dx

    push [procRet]
    ret
ENDP div16Bit

start:
    mov ax, @data
    mov ds, ax
    ; code here
    
    
    push 20
    push 10
    call div8Bit

    ; param in stack
    call printDigit

    push 20
    push 10
    call div16Bit
    call printDigit

exit:
    call printNewLine
    mov ax, 4c00h
    int 21h
END start
