; 
; FILENAME:     hexdump1.asm
; CREATED BY:   Brian Hart
; DATE:         11 Dec 2018
; PURPOSE:      Demonstrates dumping hex values to the console in Linux
;
; Run it this way:
;
; hexdump1 < (input file)
;
; Build using these commands:
;   nasm -f elf64 -g -F stabs hexdump1.asm
;   ld -o hexdump1 hexdump1.o
;

BUFFLEN     EQU 16                      ; We read the file 16 bytes at a time.
SYS_EXIT    EQU 1                       ; INT 80h code for the sys_exit syscall
SYS_READ    EQU 3                       ; INT 80h code for the sys_read syscall
OK          EQU 0                       ; Exit code meaning program terminated normally
STDIN       EQU 0                       ; File Descriptor for standard input
EOF         EQU 0                       ; Value meaning end-of-file reached by sys_read

SECTION .bss                            ; Section containing uninitialized data
    Buff:   resb    BUFFLEN             ; Text buffer itself
    
SECTION .data                           ; Section containing initialized data
    HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN: equ $-HexStr
    
    Digits: db  "0123456789ABCDEF"
    
SECTION .text                           ; Section containing code

global  _start                          ; Linker needs this to find the entry point!

_start:
    nop                                 ; This no-op keeps gdb happy
    
; Read a buffer-full of text from stdin:
Read:
    mov eax, SYS_READ                   ; Specify sys_read call
    mov ebx, STDIN                      ; Specify File Descriptor 0: Standard Input
    mov ecx, Buff                       ; Pass offset of the buffer to read to
    mov edx, BUFFLEN                    ; Pass number of bytes to read at one pass
    int 80h                             ; Call sys_read to fill the buffer
    
    mov ebp, eax                        ; Save # of bytes read from the file for later
    cmp eax, EOF                        ; Does EAX contain the value EOF meaning the end of the file has been reached?
    je  Done                            ; Jump If Equal (to 0, from compare)
    
; Set up the registers for the process-buffer step:
    mov esi, Buff                       ; Place address of the file buffer into esi
    mov edi, HexStr                     ; Place address of the line string into edi
    xor ecx, ecx                        ; Clear line string pointer, in ECX, to 0
    
; Go through the buffer and convert binary values to hex digits
Scan:
    xor eax, eax                        ; Clear out the value of EAX
    
; Here we calculate the offset into HexStr, which is the value in ECX, multiplied by 3
; Let ECX be the offset into the input buffer, and let EDX be the corresponding offset into
; HexStr (the output)
    mov edx, ecx                        ; Copy the value of the character counter into EDX    
    shl edx, 1                          ; Multiply pointer by 2 using left shift
    add edx, ecx                        ; Complete the multiplication by 3
    
; Get a character from the buffer and put it into both EAX and EBX:
    mov al, BYTE [esi+ecx]              ; ESI holds the address of Buff, and ECX the pointer to the current char
    mov ebx, eax                        ; Copy the current char value into EBX
    
; Look up low nybble character and insert it into the string:
    and al, 0Fh                         ; Mask out all but the low nybble
    mov al, BYTE [Digits+eax]           ; Look up the ASCII character code equivalent to the nybble
    mov BYTE [HexStr+edx+2]             ; Write the LSB char digit to the line string      

; Write the line of hexadecimal values to stdout:
Write:

; All done!  Let's end this party:
Done:
    mov eax, SYS_EXIT                   ; Code for Exit Syscall
    mov ebx, OK                         ; Return code indicating successful completion
    int 80h                             ; Make kernel call