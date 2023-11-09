.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

INCLUDE Irvine32.inc

.data
string db 81 dup(0)   ; Tablica na 80 znaków + znak koñca linii
counts db 256 dup(0)  ; Tablica na zliczanie wyst¹pieñ ka¿dego z 256 mo¿liwych znaków

.code
main PROC
    ; Wczytaj napis
    mov edx, OFFSET string
    mov ecx, 80
    call ReadString ; ReadString bierze EDX jako pointer na bufor a ECX jakos max numer znaków do przeczytania
    
    ; Zlicz wyst¹pienia ka¿dego znaku
    mov esi, OFFSET string
countLoop:
    mov al, [esi] ; przerzuc znak z esi (naszego stringa)
    cmp al, 0 ; sprawdz czy jest cokolwiek czy juz koniec
    je  doneCounting ; jak koniec to skoncz
    inc counts[eax] ; jak nie to zwieksz tablice pod wartoscia tego znaku w ascii
    inc esi ; zwieksz wskaznik na znak w tablicy string
    jmp countLoop ; wroc do naszej petli zliczajacej
doneCounting:
    ; Wypisz wyniki
    mov esi, 0 ; sprawdzamy od znaku 0 (ascii)

printLoop:
    cmp esi, 256 ; jak tablica ascii sie skonczyla to zakoncz program
    jge donePrinting
    mov al, counts[esi] ; przerzuc ilosc z counts
    cmp al, 0 ; jak al jest zero (czyli nic)
    je nextChar ; to przeskocz literke
    movzx eax, al ; jak nie przeskoczy³o, to rozszerz to do 32 bitow aby wypisac (chyba nie trzeba)
    call WriteDec ; wypisz ilosc z EAX
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
