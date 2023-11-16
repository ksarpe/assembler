INCLUDE Irvine32.inc

.data
	pesel BYTE 12 DUP(0)
	weights BYTE 1,3,7,9,1,3,7,9,1,3
	msg BYTE "Tell me your PESEL: ", 0
	slash BYTE "/", 0
	birthDateMsg BYTE "Birthday: ", 0
	wrongCharMsg BYTE "Your input should consists only of positive digits! ", 0
	correctCharMsg BYTE "Correct characters! ", 0
	wrongChecksumMsg BYTE "Invalid cheksum! ", 0
	correctChecksumMsg BYTE "Valid cheksum! ", 0
	wrongLengthMsg BYTE "Invalid length of PESEL! Only 11 is correct! ", 0
	correctLengthMsg BYTE "Correct length of PESEL! ", 0
	
.code
main PROC

	lea edx, msg
	call WriteString
	lea edx, pesel
	mov ecx, SIZEOF pesel
	call ReadString

	lea edx, pesel
	call StrLength
	cmp eax, 11
	jne wrongLength ;if eax != 11
	lea edx, correctLengthMsg
	call WriteString

	;digits check
	lea esi, pesel
	mov ecx, 11 ; counter for loop

	checkDigits:
		movzx eax, byte ptr [esi] ;one byte from esi to eax with 0s at the rest 24 bits
		test al, al ;if so, finish, not enough 
		jz invalidChar
		sub al, '0'
		cmp al, 9 ; >= '0' <= '9'
		jbe goodDigit
		jmp invalidChar

		goodDigit:
			inc esi
			loop checkDigits
	
	lea edx, correctCharMsg
	call WriteString		

	; CHECKSUM
	lea esi, pesel
	lea edi, weights
	call Checksum
	mov al, [esi] ; esi is at the end so just grab it
	sub al, '0' ; base 10 for cmp
	cmp al, dl
	jne invalidChecksum

	mov edx, OFFSET correctChecksumMsg
	call WriteString

	;BirthDate call
	call WriteBirthDate
	jmp done

wrongLength:
	mov edx, OFFSET wrongLengthMsg
	call WriteString
	jmp done

invalidChar:
	mov edx, OFFSET wrongCharMsg
	call WriteString
	jmp done

invalidChecksum:
	mov edx, OFFSET wrongChecksumMsg
	call WriteString
	jmp done

WriteBirthDate:
	mov edx, OFFSET birthDateMsg
	call WriteString
	mov esi, OFFSET pesel
	call ExtractDate
	jmp done

done:
	call Crlf
	exit
main ENDP

Checksum PROC
    mov ecx, 10
    xor ebx, ebx ; for sum
calculate:
    mov al, [esi]    ; first digit
    sub al, '0'      ; convert to 10 base
    mov dl, [edi]    ; weight
    imul dl ;(uses al/ax/eax (depends on operand size)
    add ebx, eax     ; checksum increase
    inc esi
    inc edi
    loop calculate

	; CONTROL DIGIT CHECK
	mov eax, ebx ;eax for division
	mov ecx, 10
	xor edx, edx ; edx = 0 for reminder
	div ecx ; eax/ecx , reminder goes to edx
	sub dl, 10 ;dl because it's 10 reminder
	neg dl ; in case of negative number
    ret ; dl has the result
Checksum ENDP

ExtractDate PROC
	;Day
	mov al, [esi+5]
    sub al, '0'
    mov bl, [esi+4]
    sub bl, '0'
	imul ebx, 10
    add eax, ebx
    call WriteDec ;callArg: eax
	mov edx, OFFSET slash
    call WriteString ;callArg edx

	;Month
	mov al, [esi+3]
	sub al, '0'
	mov bl, [esi+2]
	sub bl, '0'
	imul ebx, 10
	cmp ebx, 12
	jg later

	normal:
		add eax, ebx
		cmp eax, 10
		jge skipN
		mov ebx, eax ;temp
		mov eax, 0
		call WriteDec
		mov eax, ebx
	skipN:
		call WriteDec
		call WriteString
		mov eax, 19
		call WriteDec
		jmp restOfYear
	later:
		add eax, ebx
		sub eax, 20
		cmp eax, 20
		jge skipL
		mov ebx, eax ;temp
		mov eax, 0
		call WriteDec
		mov eax, ebx
	skipL:
		call WriteDec
		call WriteString
		mov eax, 20
		call WriteDec

	restOfYear:
		mov al, [esi +1]
		sub al, '0'
		mov bl, [esi]
		sub bl, '0'
		imul ebx, 10
		add eax, ebx
		call WriteDec

	ret
ExtractDate ENDP

END main