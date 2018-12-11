; 
; FILENAME:     hexdump1.asm
; CREATED BY:   ENS Brian Hart
; DATE:         11 Dec 2018
; PURPOSE:      Demonstrates dumping hex values to the console in Linux
;

section .text
    global _start                       ; must be declared for linker (ld)
   
_start:
    ; TODO: Add the program's code here

    mov eax,1                           ; system call number (sys_exit)
    mov ebx,0                           ; process exit code
    int 0x80                            ; call kernel
    
section .data                           ; static data
    ; TODO: Add the program's static data here
    
section .bss                            ; dynamically-changed variables
    ; TODO: Add dynamically-changed variables here