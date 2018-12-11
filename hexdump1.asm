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
OK          EQU 0                       ; Exit code meaning program terminated normally

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
    
; Read a buffer full of text from stdin:
Read:

; Go through the buffer and convert binary values to hex digits
Scan:

; Write the line of hexadecimal values to stdout:
Write:

; All done!  Let's end this party:
Done:
    mov eax, SYS_EXIT                   ; Code for Exit Syscall
    mov ebx, OK                         ; Return code indicating successful completion
    int 80h                             ; Make kernel call