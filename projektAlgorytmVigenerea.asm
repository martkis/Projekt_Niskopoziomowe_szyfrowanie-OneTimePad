.386
.MODEL FLAT, STDCALL

includelib masm32.lib

GetStdHandle PROTO :DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleA  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
wsprintfA PROTO C :VARARG						; prototyp procedury w masm32
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetTickCount PROTO ;random
nseed PROTO :DWORD ;random
nrandom PROTO :DWORD ;random


.data
 OUTPUT_HANDLE equ -11
 INPUT_HANDLE equ -10

 hout DD 0										; output
 hin DD 0										; input
 rout DD 0										; output to offset
 rin DD 0										; input to offset

rinp DWORD 0 

 pierwszaWiadomosc DB "Tablica Vigenere'a", 0Ah, 0Dh ,0 	
 rozmiar1 DD $ - pierwszaWiadomosc
 
   tab1 DB "abcdefghijklmnoprstuvwxyz", 0Ah, 0Dh ,0 	
 rtab1 DD $ - tab1
  tab2 DB "bcdefghijklmnoprstuvwxyza", 0Ah, 0Dh ,0 	
 rtab2 DD $ - tab2
   tab3 DB "cdefghijklmnoprstuvwxyzab", 0Ah, 0Dh ,0 	
 rtab3 DD $ - tab3

  drugaWiadomosc DB "Podaj wiadomosc do zakodowania, max 255 malych liter bez znakow specjalnych", 0Ah, 0Dh ,0 
  rozmiar2 DD $ - drugaWiadomosc
  
  solutionText	BYTE "Wylosuje klucz, minimum %i znakow", 0Ah, 0Dh ,0 
  rozmiar3 DD $ - solutionText
  solutionBuffer BYTE 255 dup ( 0 )

  wiadomosc DD 255 dup ( 0 )
  rozWiad DD $ -wiadomosc
  klucz DD 255 dup ( 0 )
  rozKlucz DD $ - klucz

  solutionBuffer2 BYTE 255 dup ( 0 )
  nOfChars DWORD 0
  zakodowane BYTE 255 dup ( 0 )
  rozZak DD $ -zakodowane

  temp BYTE 10 dup ( 0 )
  tempr DD $-temp
  pom DD 0
  pom2 DD 0
  pom3 DD 0


  path BYTE "C:\Users\IEUser\Desktop\haslo.txt" ,0 
  path2 BYTE "C:\Users\IEUser\Desktop\zaszyfrowanaWiadomosc.txt" ,0 


GENERICREAD equ 80000000h 
GENERICWRITE equ 40000000h 
CREATEALWAYS equ 2
dataWritten DWORD 0 
fileHandle DWORD 0

range DWORD 25 ;do randomu
wylosowanaLiczba DWORD 100 ;do randomu


.code
main proc

	push OUTPUT_HANDLE
	call GetStdHandle	
	mov	hout, EAX	
	
	push INPUT_HANDLE
	call GetStdHandle
	mov	hin, EAX


INVOKE WriteConsoleA, hout, OFFSET pierwszaWiadomosc, rozmiar1, OFFSET rout, 0
INVOKE WriteConsoleA, hout, OFFSET tab1, rtab1, OFFSET rout, 0
INVOKE WriteConsoleA, hout, OFFSET tab2, rtab2, OFFSET rout, 0
INVOKE WriteConsoleA, hout, OFFSET tab3, rtab3, OFFSET rout, 0
	
	INVOKE WriteConsoleA, hout, OFFSET drugaWiadomosc, rozmiar2, OFFSET rout,0

	INVOKE ReadConsoleA, hin, OFFSET wiadomosc, rozWiad, OFFSET rin, 0

	
	mov EAX, rin
	sub EAX, 2
	INVOKE wsprintfA, OFFSET solutionBuffer, OFFSET solutionText, EAX
	add ESP, 12
	mov rinp, EAX
	INVOKE WriteConsoleA, hout, OFFSET solutionBuffer, rozmiar3, OFFSET rout,0


	; LOSOWANIE KLUCZA

		mov EBX, rin
		sub EBX, 2
		mov pom3, EBX
		mov EBX, 0
	
	.WHILE EBX < pom3 ; losowanie tyle liter ile ma wiadomosc do zakodowania

			call GetTickCount
			push EAX
			call nseed
			push range
			call nrandom
			add EAX, 97
			mov klucz[EBX], EAX
		
			INC EBX
	.ENDW

	;zapisanie do pliku
	INVOKE CreateFileA, OFFSET path, GENERICREAD OR GENERICWRITE, 0, 0, CREATEALWAYS, 0, 0
	mov fileHandle, EAX
	INVOKE WriteFile, fileHandle, OFFSET klucz, 255, OFFSET dataWritten,0

		mov EBX, rin
		sub EBX, 2
		mov pom, EBX
		mov EBX, 0
		mov EDX, 0
		mov EAX, 0
			.WHILE EBX < pom
				
				mov EAX, 0
				mov EAX, wiadomosc[EBX]
				mov EDX, 0d
				mov EDX, klucz[EBX]
				sub EDX, 97d
				add EAX, EDX
					.IF AL > 7Ah

						sub EAX, 7Ah
						add EAX, 61h
						mov pom2, EAX ; w pom mam zakodowany kod ascii
						mov zakodowane[EBX], AL
					
					.ENDIF

 				mov zakodowane[EBX], AL
				inc EBX
			.ENDW
	INVOKE CreateFileA, OFFSET path2, GENERICWRITE, 0, 0, CREATEALWAYS, 0, 0
	mov fileHandle, EAX
	INVOKE WriteFile, fileHandle, OFFSET zakodowane, 255, OFFSET dataWritten,0

	push 0
	call ExitProcess
main endp



atoi proc uses esi edx inputBuffAddr:DWORD
	mov esi, inputBuffAddr
	xor edx, edx
	xor EAX, EAX
	mov AL, BYTE PTR [esi]
	cmp eax, 2dh
	je parseNegative

	.Repeat
		lodsb
		.Break .if !eax
		imul edx, edx, 10
		sub eax, "0"
		add edx, eax
	.Until 0
	mov EAX, EDX
	jmp endatoi

	parseNegative:
	inc esi
	.Repeat
		lodsb
		.Break .if !eax
		imul edx, edx, 10
		sub eax, "0"
		add edx, eax
	.Until 0

	xor EAX,EAX
	sub EAX, EDX
	jmp endatoi

	endatoi:
	ret
atoi endp

END