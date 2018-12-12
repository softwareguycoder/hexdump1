; Executable name : hexdump1
; Version         : 1.0
; Created date    : 12 Dec 2018
; Last update     : 12 Dec 2018
; Author          : Brian Hart
; Description     : A simple program in assembly for Linux, using NASM, demonstrating
;                   the conversion of binary values to hexadecimal strings.  It acts as
;                   a very simple hex dump utility for files, though without the ASCII
;                   equivalent column.
;
;   Run it this way:
;      hexdump1 < (input file)
;   
;   Build using these commands:
;       nasm -f elf64 -g -F stabs hexdump1.asm
;       ld -o hexdump1 hexdump1.o
;

BUFFLEN     EQU 16                  ; We read the file BUFFLEN bytes at a time

SYS_EXIT    EQU 1                   ; Syscall number for sys_exit
SYS_READ    EQU 3                   ; Syscall number for sys_read
SYS_WRITE   EQU 4                   ; Syscall number for sys_write

OK          EQU 0                   ; Operation completed without errors
ERROR       EQU -1                  ; Operation failed to complete; error flag

STDIN       EQU 0                   ; File Descriptor 0: Standard Input
STDOUT      EQU 1                   ; File Descriptor 1: Standard Output
STDERR      EQU 2                   ; File Descriptor 2: Standard Error

EOF         EQU 0                   ; End-of-file reached

SECTION .bss                        ; Section containing uninitialized data
   
    Buff:   resb    BUFFLEN         ; Text buffer itself
    
SECTION .data                       ; Section containing initialized data

    HexStr: db  " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN  EQU $-HexStr
    
    Digits: db  "0123456789ABCDEF"
    
SECTION .text                       ; Section containing code

global _start                       ; Linker needs this to find the entry point!

_start:
    nop                             ; This no-op keeps gdb happy...
    
; Read a buffer full of text from stdin
Read:
    mov eax, SYS_READ               ; Specify sys_read call
    mov ebx, STDIN                  ; Specify File Descriptor 0: Standard Input
    mov ecx, Buff                   ; Pass offset of the buffer to read to
    mov edx, BUFFLEN                ; Pass number of bytes to read at one pass
    int 80h                         ; Call sys_read to fill the buffer
    
    mov ebp, eax                    ; Save # of bytes read from file for later
    cmp eax, EOF                    ; If eax=0, sys_read reached EOF on STDIN
    je  Done                        ; Jump If Equal (to 0, from compare)
    
; Set up the registers for the process buffer step:
    mov esi, Buff                   ; Place address of file buffer into ESI
    mov edi, HexStr                 ; Place address of line string into EDI
    xor ecx, ecx                    ; Clear line string pointer to 0
    
; Go through the buffer and convert binary values to hex digits
Scan:
    xor eax, eax                    ; Clear EAX to 0
    
; Here we calculate the offset into HexStr, which is the value in ecx, multiplied by 3
    mov edx, ecx                    ; Copy the character counter into edx
    shl edx, 1                      ; Multiply pointer by 2 using left shift
    add edx, ecx                    ; Complete the multiplication by 3
    
; Get a character from the buffer and put it into both EAX and EBX:
    mov al, BYTE [esi+ecx]          ; Put a byte from the input buffer into AL
    mov ebx, eax                    ; Duplicate the byte in BL for second nybble
    
; Look up low nybble character and insert it into the string:
    and al, 0Fh                     ; Mask out all but the low nybble
    mov al, BYTE [Digits+eax]       ; Look up the char equivalent of nybble
    mov BYTE [HexStr+edx+2], al    ; Write LSB char digit to line string
    
; Look up high nybble character and insert it into the string:
    shr bl, 4                       ; Shift high 4 bits of char into low 4 bits
    mov bl, BYTE [Digits+ebx]       ; Look up char equivalent of nybble
    mov BYTE [HexStr+edx+1], bl     ; Write MSB char digit to line string
    
; Bump the buffer pointer to the next character and see if we're done:
    inc ecx                         ; Increment line string pointer
    cmp ecx, ebp                    ; Compare to the number of chars in the buffer
    jna Scan                        ; Loop back if ecx <= number of chars in buffer
    
; Write the line of hexadecimal values to STDOUT:
Write:
    mov eax, SYS_WRITE              ; Specify sys_write call
    mov ebx, STDOUT                 ; Specify File Descriptor 1: Standard output
    mov ecx, HexStr                 ; Pass offset of line string
    mov edx, HEXLEN                 ; Pass size of the line string
    int 80h                         ; Make kernel call to display line string
    jmp Read                        ; Loop back and load file buffer again
    
; All done!  Let's end this party:
Done:
    mov eax, SYS_EXIT               ; Code for Exit Syscall
    mov ebx, OK                     ; Return a code of success
    int 80h                         ; Make kernel call
