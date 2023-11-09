include Irvine32.inc

.data
array DWORD 8 DUP(?) 
arraySize DWORD 8  

.code
main PROC
    mov ecx, arraySize
    lea esi, array
ReadLoop:
    call ReadInt
    mov [esi], eax
    add esi, 4
    loop ReadLoop

    push arraySize         ; Umieœæ rozmiar tablicy na stosie dla sortwoañ
    push OFFSET array      ; Umieœæ adres tablicy na stosie dla sortwoañ
    
    ;call BubbleSort
    ;call InsertionSort
    ;call SelectionSort
    mov esi, OFFSET array
    mov ecx, arraySize
    call QuickSort
    
    mov ecx, arraySize
    lea esi, array
PrintLoop:
    mov eax, [esi]     ; Wczytaj wartoœæ do wypisania
    call WriteInt      ; Wypisz wartoœæ
    call Crlf          ; Wypisz now¹ liniê
    add esi, 4         ; Przesuñ wskaŸnik do nastêpnej wartoœci w tablicy
    loop PrintLoop     ; Kontynuuj pêtlê jeœli ECX nie jest jeszcze zero


    call ExitProcess
main ENDP

BubbleSort PROC
    push ebp             ; Zapisuje na stosie bazowy wskaŸnik stosu poprzedniej funkcji/procedury
    mov ebp, esp         ; Ustawia bazowy wskaŸnik stosu na aktualny wskaŸnik stosu
    sub esp, 4           ; Rezerwuje 4 bajty na stosie dla lokalnej zmiennej/flagi

    mov esi, [ebp+8]     ; Wczytuje do rejestru ESI adres pocz¹tkowy tablicy (parametr przekazany przez stos)
    mov [esp], esi       ; Zapisuje oryginalny adres tablicy na stosie jako punkt odniesienia
    mov ecx, [ebp+12]    ; Wczytuje do rejestru ECX rozmiar tablicy (parametr przekazany przez stos)
    dec ecx              ; Dekrementuje ECX, poniewa¿ w sortowaniu b¹belkowym ostatni element jest ju¿ na miejscu po pierwszym przejœciu

OuterLoop:
    mov esi, [esp]       ; Resetuje ESI do oryginalnego adresu tablicy zapisanego na stosie
    mov edi, ecx         ; Przekopiuje wartoœæ ECX do EDI
    dec edi              ; Dekrementuje EDI, aby EDI by³o mniejsze o jeden od ECX
    lea edi, [esi + 4*edi + 4] ; Ustawia EDI na koniec czêœci tablicy, która bêdzie sortowana (minus jeden element)

InnerLoop:
    mov eax, [esi]       ; Wczytuje bie¿¹cy element tablicy do rejestru EAX
    cmp eax, [esi + 4]   ; Porównuje bie¿¹cy element (EAX) z nastêpnym elementem tablicy
    jle NoSwap           ; Skacze do etykiety NoSwap, jeœli bie¿¹cy element jest mniejszy lub równy nastêpnemu
    xchg eax, [esi + 4]  ; Wymienia miejscami bie¿¹cy element z nastêpnym, jeœli jest wiêkszy
    mov [esi], eax       ; Zapisuje now¹ wartoœæ bie¿¹cego elementu (by³y nastêpny)
NoSwap:
    add esi, 4           ; Inkrementuje wskaŸnik tablicy (przesuwa o element do przodu)
    cmp esi, edi         ; Porównuje aktualn¹ pozycjê wskaŸnika z koñcem sortowanej czêœci tablicy
    jb InnerLoop         ; Jeœli nie doszliœmy do koñca, skacze do pocz¹tku InnerLoop

    dec ecx              ; Dekrementuje ECX, bo ostatni element jest ju¿ posortowany
    jnz OuterLoop        ; Jeœli ECX nie jest zerem, oznacza to, ¿e nie doszliœmy do koñca tablicy i skacze do OuterLoop

    add esp, 4           ; Zwalnia miejsce zarezerwowane na stosie
    pop ebp              ; Przywraca poprzedni¹ wartoœæ EBP
    ret 8                ; Zwraca sterowanie do wywo³uj¹cego, zwalniaj¹c miejsce 8 bajtów (2 parametry * 4 bajty) z stosu
BubbleSort ENDP

InsertionSort PROC
    push ebp                 ; Zapisz na stosie bazowy wskaŸnik stosu
    mov ebp, esp             ; Ustaw bazowy wskaŸnik stosu na bie¿¹cy wskaŸnik stosu
    mov esi, [ebp+8]         ; Za³aduj do rejestru esi adres tablicy (pierwszy argument procedury)
    mov ecx, 1               ; Ustaw licznik pêtli 'i' na 1, poniewa¿ pierwszy element jest ju¿ posortowany

OuterLoop:
    mov edx, [esi + ecx*4]   ; Za³aduj bie¿¹cy element (arr[i]) do rejestru edx jako 'klucz'
    mov ebx, ecx             ; Skopiuj licznik pêtli 'i' do ebx jako 'j'
    dec ebx                  ; Zmniejsz ebx o jeden, aby uzyskaæ 'j = i - 1'
    lea edi, [esi + ebx*4]   ; Za³aduj adres arr[j] do rejestru edi

InnerLoop:
    cmp [edi], edx           ; Porównaj wartoœæ arr[j] z 'kluczem'
    jle InsertFinished       ; Jeœli arr[j] <= 'klucz', zakoñcz wewnêtrzn¹ pêtlê, bo znaleziono pozycjê do wstawienia
    mov eax, [edi]           ; Za³aduj wartoœæ arr[j] do rejestru eax
    mov [edi + 4], eax       ; Przepisz wartoœæ z eax do arr[j+1], przesuwaj¹c arr[j] w górê
    sub edi, 4               ; Aktualizuj edi, aby wskazywa³ na kolejny element w dó³ w tablicy
    dec ebx                  ; Zmniejsz 'j'
    jns InnerLoop            ; Jeœli 'j' wci¹¿ jest nieujemne, kontynuuj wewnêtrzn¹ pêtlê

InsertFinished:
    mov [edi + 4], edx       ; Wstaw 'klucz' do tablicy na pozycji arr[j+1]
    inc ecx                  ; Zwiêksz licznik pêtli 'i' aby przejœæ do nastêpnego elementu
    cmp ecx, [ebp+12]        ; Porównaj licznik pêtli 'i' z rozmiarem tablicy 'n' (drugi argument procedury)
    jl OuterLoop             ; Jeœli 'i' jest mniejsze ni¿ 'n', kontynuuj z kolejn¹ iteracj¹ zewnêtrznej pêtli
    pop ebp                  ; Przywróæ bazowy wskaŸnik stosu
    ret 8                    ; WyjdŸ z procedury i oczyœæ stos z 8 bajtów (2 argumenty po 4 bajty ka¿dy)
InsertionSort ENDP

Swap PROC
    push ebp
    push ecx
    mov ebp, esp
    mov eax, [ebp+16] ; loading address of first item to swap
    mov ecx, [ebp+12] ; loading second item to swap
    mov edx, [eax] ; loading value ot first item to TEMP
    mov ebx, [ecx] ; loading value of second item to TEMP2
    mov [ecx], edx ; store the value of first item in TEMP into address ecx
    mov [eax], ebx ; same for second
    ;now items are swapped
    pop ecx
    pop ebp
    ret
Swap ENDP

SelectionSort PROC
    ; inicializujemy sobie stos
    push ebp
    mov ebp, esp

    ;przygotowywujemy zmienne ze stosu
    mov ecx, [ebp+12] ; n, ecx np = 8
    mov esi, [ebp+8] ; array address, esi np = 0x00F8392D pocz¹tek tablicy 

    xor edi, edi ; ustawiamy tak jakby i na zero
    dec ecx ; counter na 7 do pierwszej petli

OuterLoop:
    cmp edi, ecx
    jge EndOuterLoop
    
    mov ebx, edi ; min_index = i
    inc edi ; i++
    mov edx, edi ; j = i (i+1 po inc)
    dec edi ; wracamy z i bo jest 0 normalnie

InnerLoop:  ; ebx -> min_index, edi -> i, edx -> j
    push ecx
    inc ecx
    cmp edx, ecx
    pop ecx
    jge EndInnerLoop
    mov eax, [esi + 4*edx]
    cmp eax, [esi + 4*ebx]
    jge NoSwap ; jae for unsigned numbers, jge for signed
    
    ; If we swap then
    mov ebx, edx ; min_idx = j

NoSwap:
    inc edx
    jmp InnerLoop

EndInnerLoop:
    cmp ebx, edi
    je NoMinSwap
    lea eax, [esi + edi*4]
    lea edx, [esi + ebx*4]
    push edx
    push eax
    call Swap
    add esp, 8

NoMinSwap:
    inc edi
    jmp OuterLoop

EndOuterLoop:
    pop ebp
    ret 8

SelectionSort ENDP

Partition PROC
    ; Ustawienie pivot na ostatni element tablicy
    mov edx, ecx
    dec edx
    mov eax, [esi + edx*4] ; eax = pivot
    mov ebx, -1            ; Indeks mniejszej czêœci

    ; Przejœcie przez elementy tablicy
    mov edx, 0
    WhileLoop:
        cmp edx, ecx
        jge PartitionEnd  ; Jeœli wszystkie elementy zosta³y sprawdzone

        ; Porównanie elementu z pivotem
        mov edi, [esi + edx*4] ; Wczytanie bie¿¹cego elementu
        cmp edi, eax
        jge IncrementIndex

        ; Zamiana elementów
        inc ebx
        ; Przesuniêcie ebx o 4*ebx do adresu w³aœciwego elementu
        mov edi, [esi + ebx*4]
        xchg edi, [esi + edx*4]
        mov [esi + ebx*4], edi

        IncrementIndex:
        inc edx
        jmp WhileLoop

    PartitionEnd:
    ; Zamiana pivota z pierwszym wiêkszym elementem
    inc ebx
    mov edx, [esi + ebx*4]  ; Adres docelowy dla pivota
    xchg edx, [esi + ecx*4 - 4] ; Zamiana miejscami z pivotem
    mov [esi + ebx*4], edx

    ; Zwracanie nowego indeksu pivota
    mov eax, ebx
    ret
Partition ENDP

QuickSort PROC
    cmp ecx, 1
    jle Done ; jak mamy jeden element w tablicy to konczymy

    call Partition
    push ecx ; zachowujemy ecx na stosie

    ;lewa polowa
    mov ecx, eax ; eax jest z partition (index)
    call QuickSort

    ;prawa polowa
    pop ecx
    sub ecx, eax
    add esi, eax
    add esi, 4
    call QuickSort

    ;stan poczatkowy esi
    sub esi, eax
    sub esi, 4

Done:
    ret
QuickSort ENDP

END main
