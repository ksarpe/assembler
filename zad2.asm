INCLUDE Irvine32.inc

.data
    string db 81 dup(?)   
    counts db 256 dup(?)

.code
main PROC
    lea edx, string
    mov ecx, 80
    call ReadString ;uses edx,ecx
    
    lea esi, string
countLoop:
    mov al, [esi]
    cmp al, 0
    je doneCounting
    inc counts[eax]
    inc esi
    jmp countLoop
doneCounting:
    mov esi, 0 ;ascii code check from 0

printLoop:
    cmp esi, 256 ;finish condition
    jge donePrinting
    mov al, counts[esi]
    cmp al, 0
    je nextChar
    movzx eax, al
    call WriteDec
    mov al, '-'
    call WriteChar
    mov eax, esi
    call WriteChar
    mov al,' '
    call WriteChar

nextChar:
    inc esi
    jmp printLoop
donePrinting:
    call Crlf
    invoke ExitProcess, 0

main ENDP
END main
