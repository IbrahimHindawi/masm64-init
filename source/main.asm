;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           MASM64 Starter Project.                                                                                                 ;
;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Writes to the StdOut, then exits safely.                                                                                ;
;-----------------------------------------------------------------------------------------------------------------------------------;
                                                GetStdHandle                                    proto
                                                WriteFile                                       proto
                                                ExitProcess                                     proto
std_output_handle                               equ                                             -11
;----------[const section]----------------------------------------------------------------------------------------------------------;
.const
outputmessage                                   byte                                            'hello, world!'
                                                byte                                            0ah, 0dh
                                                byte                                            'from masm64!'
                                                byte                                            0ah, 0dh
outputmessagelength                             equ                                             $ - outputmessage
constval                                        equ                                             12
;----------[data section]-----------------------------------------------------------------------------------------------------------;
.data
var                                             qword                                           0ffffh
x                                               real4                                           3.15
a                                               byte                                            10
b                                               byte                                            20
c                                               byte                                            30
d                                               byte                                            40

seqa                                            byte                                            1, 2, 3
seqb                                            word                                            10, 20, 30
seqc                                            dword                                           100, 200, 300
seqd                                            qword                                           1000, 2000, 3000

seqe                                            byte                                            1, 2, 3, 4
                                                byte                                            4, 5, 6, 7
                                                byte                                            3, 1, 8, 9

seqf                                            qword                                           176, 269, 368, 476
                                                qword                                           437, 593, 672, 722
                                                qword                                           334, 122, 387, 872

seqg                                            qword                                           0, 0, 0
seqh                                            qword                                           3 dup(0)
                                                
strsrc_00                                       byte                                            'abc'
strdst_00                                       byte                                            3 dup(?)
strdst_01                                       byte                                            3 dup(?)
strsrc_02                                       byte                                            'low'

                                                
;----------[code section]-----------------------------------------------------------------------------------------------------------;
.code
main                                            proc
                                                ;-----[data output]-----------------------------------------------------------------;
                                                ; print something to the console using writefile
                                                ; write to std out
                                                ;-----------------------------------------------------------------------------------;
                                                sub                                             rsp, 40                             ; writefile(5 parms) * 8 = 40 bytes
                                                mov                                             rcx, std_output_handle
                                                call                                            GetStdHandle

                                                mov                                             rcx, rax
                                                lea                                             rdx, outputmessage
                                                mov                                             r8, outputmessagelength
                                                xor                                             r9, r9
                                                mov                                             [rsp + 32], r9                      ; nth parm - 1 = (5 - 4) * 8 = 32 bytes
                                                call                                            WriteFile
                                                add                                             rsp, 40

                                                ;----[chapter 01]-------------------------------------------------------------------;
                                                ; moving variables around
                                                ;-----------------------------------------------------------------------------------;
                                                ; 64  | 32   | 16    | 8      |
                                                ; rax | eax  | ax    | ah/al  | accumulator     |
                                                ; rbx | ebx  | bx    | bh/bl  | base            |
                                                ; rcx | ecx  | cx    | ch/cl  | counter         |
                                                ; rdx | edx  | dx    | dh/dl  | data            |
                                                ; rsi | esi  | si    | sil    | source_idx      |
                                                ; rdi | edi  | di    | dil    | destination_idx |
                                                ; rbp | ebp  | bp    | bpl    | base_pointer    |
                                                ; rsp | esp  | sp    | spl    | stack_pointer   |
                                                ; r8  | r8d  | r8w   | r8b    | general_purpose |
                                                ; r9  | r9d  | r9w   | r9b    | general_purpose |
                                                ; r10 | r10d | r10w  | r10b   | general_purpose |
                                                ; r11 | r11d | r11w  | r11b   | general_purpose |
                                                ; r12 | r12d | r12w  | r12b   | general_purpose |
                                                ; r13 | r13d | r13w  | r13b   | general_purpose |
                                                ; r14 | r14d | r14w  | r14b   | general_purpose |
                                                ; r15 | r15d | r15w  | r15b   | general_purpose |
                                                ;-----------------------------------------------------------------------------------;
                                                ; move
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                mov                                             rcx, 33
                                                mov                                             rdx, rcx
                                                mov                                             rcx, var
                                                mov                                             var, rdx
                                                ; constants
                                                ;-----------------------------------------------------------------------------------;
                                                mov                                             rcx, constval
                                                mov                                             rdx, constval + 8
                                                ; exchange data
                                                ;-----------------------------------------------------------------------------------;
                                                xchg                                            rcx, rdx
                                                xchg                                            rcx, var

                                                ;----[chapter 02]-------------------------------------------------------------------;
                                                ; arithmetic
                                                ;-----------------------------------------------------------------------------------;
                                                add                                             rcx, rdx
                                                sub                                             rdx, rcx
                                                ; inc dec neg
                                                ;-----------------------------------------------------------------------------------;
                                                inc                                             rcx
                                                dec                                             rdx
                                                neg                                             rcx
                                                ; unsigned mul div
                                                ;-----------------------------------------------------------------------------------;
                                                mov                                             rax, 8                              ; multiplicand is rax
                                                mul                                             rcx                                 ; multiplier can be any reg, result [rdx, rax] [upper, lower]
                                                mov                                             rax, 8                              ; dividend is rax
                                                div                                             rcx                                 ; divisor can be any reg, result [rdx, rax] [remainder, quotient]
                                                ; signed mul
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rax, rax
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                xor                                             r8, r8
                                                xor                                             r9, r9
                                                mov                                             rax, 100
                                                mov                                             rcx, 200
                                                mov                                             rdx, 4
                                                mov                                             r8, 8
                                                imul                                            rcx                                 ; multiplicand is rax
                                                mov                                             rdx, 8
                                                imul                                            rcx, rdx                            ; multiplicand, multiplier
                                                imul                                            r8, rcx, 16                         ; destination, multiplicand, multiplier
                                                ; signed div
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rax, rax
                                                xor                                             rbx, rbx
                                                xor                                             rdx, rdx
                                                mov                                             rax, 100                            ; dividend is rax
                                                mov                                             rbx, 3
                                                idiv                                            rbx                                 ; divisor can be any reg, result [rdx, rax] [remainder, quotient], -100
                                                mov                                             rax, -100
                                                cqo                                                                                 ; sign extension must be used with negative numbers
                                                idiv                                            rbx
                                                ; bit manipulati                                on
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                mov                                             rcx, 00F0Fh
                                                mov                                             rdx, 0F0F0h
                                                and                                             rcx, rdx
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                mov                                             rcx, 00F0Fh
                                                mov                                             rdx, 0F0F0h
                                                or                                              rcx, rdx
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                mov                                             rcx, 00F0Fh
                                                mov                                             rdx, 0F0F0h
                                                xor                                             rcx, rdx
                                                xor                                             rcx, rcx
                                                xor                                             rdx, rdx
                                                mov                                             rcx, 00F0Fh
                                                mov                                             rdx, 0F0F0h
                                                not                                             rcx
                                                ; shifting bits
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                mov                                             rcx, 00F0Fh
                                                shl                                             rcx, 2                          ; shift n bits to the left
                                                shr                                             rcx, 2                          ; shift n bits to the right
                                                sal                                             rcx, 2                          ; shift n bits to the left while adding 1s to the right
                                                sar                                             rcx, 2                          ; shift n bits to the right while adding 1s to the left
                                                ; rotating bits
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                mov                                             rcx, 00F0Fh
                                                rol                                             rcx, 2                          ; rotate n bits to the left
                                                ror                                             rcx, 2                          ; rotate n bits to the right
                                                rcl                                             rcx, 2                          ; rotate n bits to the left while adding 1s to the left
                                                rcr                                             rcx, 2                          ; rotate n bits to the right while adding 1s to the right
                                                ;----[chapter 03]---------------------------------------------------------------;
                                                ; directing flow                                
                                                ;-------------------------------------------------------------------------------;
                                                ; AC auxiliary carry
                                                ; CY carry
                                                ; EI enable interrupt
                                                ; OV overflow
                                                ; PE parity even                                
                                                ; PL sign polarity
                                                ; UP direction
                                                ; ZR Zero
                                                ;-------------------------------------------------------------------------------;
                                                ; jump
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rax, rax
                                                jmp                                             next
                                                mov                                             rax, 2
                                                next:
                                                mov                                             rax, 8
                                                ; test
                                                ;-------------------------------------------------------------------------------;
                                                mov                                             rcx, 0FFFFh
                                                test                                            rcx, 00001h                     ; jump if odd
                                                ; flag based jumps
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rdx, rdx
                                                mov                                             cl, 255
                                                add                                             cl, 1
                                                jc                                              carry                           ; jump if carry
                                                mov                                             rdx, 1
                                                carry:
                                                mov                                             cl, -128
                                                sub                                             cl, 1
                                                jo                                              overflow                        ; jump if overflow
                                                mov                                             rdx, 2
                                                overflow:
                                                mov                                             cl, 255
                                                and                                             cl, 10000000b
                                                js                                              sign                            ; jump if sign
                                                mov                                             rdx, 3
                                                sign:
                                                jnz                                             notZero                         ; jump if not zero
                                                mov                                             rdx, 4
                                                notZero:
                                                ; compare
                                                ;-------------------------------------------------------------------------------;
                                                ; comparing left op to right op
                                                ; je jne                                        
                                                ; ja jnbe                                       
                                                ; jae jnb
                                                ; jb jnae
                                                ; jbe jna
                                                ;
                                                ; jg jnle
                                                ; jge jnl
                                                ; jl jnge
                                                ; jle jng
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rdx, rdx
                                                mov                                             rbx, 100
                                                mov                                             rcx, 200
                                                cmp                                             rcx, rbx
                                                ja                                              above                           ; jump if lop above rop
                                                mov                                             rdx, 1
                                                above:
                                                mov                                             rcx, 50
                                                cmp                                             rcx, rbx
                                                jb                                              below                           ; jump if lop below rop
                                                mov                                             rdx, 2
                                                below:
                                                mov                                             rcx, 100
                                                cmp                                             rcx, rbx
                                                jbe                                             equal                           ; jump if lop below or equal rop
                                                mov                                             rdx, 3
                                                equal:
                                                ; loop
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                xor                                             rax, rax
                                                inc                                             rax
                                                acc_entry:
                                                add                                             rax, rax
                                                inc                                             rcx
                                                cmp                                             rcx, 10
                                                je                                              acc_end
                                                jmp                                             acc_entry
                                                acc_end:
                                                ;----[chapter 04]---------------------------------------------------------------;
                                                ; addressing
                                                ;-------------------------------------------------------------------------------;
                                                ; 1d array:                                     addr + ( index * sizeof( element ))
                                                xor                                             rdx, rdx
                                                mov                                             al, a
                                                mov                                             ah, a + 3

                                                lea                                             rcx, b
                                                mov                                             dl, [rcx]
                                                mov                                             dh, [rcx + 1]

                                                mov                                             cl, seqa
                                                mov                                             dx, seqb
                                                mov                                             r8d, seqc
                                                mov                                             r9, seqd

                                                mov                                             cl, seqa + 1
                                                mov                                             dx, seqb + 2
                                                mov                                             r8d, seqc + 4
                                                mov                                             r9, seqd + 8

                                                mov                                             cl, seqa + (2 * 1)
                                                mov                                             dx, seqb + (2 * 2)
                                                mov                                             r8d, seqc + (2 * 4)
                                                mov                                             r9, seqd + (2 * 8)

                                                ; 2d array:                                     addr + ( x + y * width ) * sizeof( element )
                                                xor                                             r9, r9
                                                mov                                             r9b, seqe + (1 + 2 * 4) * 1
                                                mov                                             r9, seqf + (1 + 2 * 4) * 8

                                                ; addressing source index (RSI):     
                                                ;-------------------------------------------------------------------------------;
                                                ; traversal:                                    base + index * scale + displacement
                                                ; base:                                         reg with memory addr of array
                                                ; index:                                        reg or immediate value
                                                ; scale:                                        size of element (byte word dword qword)
                                                ; displacement:                                 immediate value to denote row or col 
                                                ;                                               offsets in 2d arrays
                                                lea                                             rsi, seqd
                                                xor                                             rcx, rcx
                                                start:
                                                mov                                             rdx, [rsi + rcx * 8]
                                                inc                                             rcx
                                                cmp                                             rcx, lengthof seqd
                                                jne                                             start

                                                ; addressing destination index (RDI):     
                                                ;-------------------------------------------------------------------------------;
                                                lea                                             rdi, seqg
                                                mov                                             rcx, 0
                                                mov                                             rdx, 10

                                                start2:
                                                mov                                             [rdi + rcx * 8], rdx
                                                inc                                             rcx
                                                cmp                                             rcx, lengthof seqg
                                                jne                                             start2
                                                
                                                mov                                             r10, seqg[0 * 8]
                                                mov                                             r11, seqg[1 * 8]
                                                mov                                             r12, seqg[2 * 8]

                                                lea                                             rsi, seqg
                                                lea                                             rdi, seqh
                                                mov                                             rcx, lengthof seqg
                                                cld                                                                             ; clear diretion flag
                                                rep                                             movsq

                                                mov                                             r13, seqh[0 * 8]
                                                mov                                             r14, seqh[1 * 8]
                                                mov                                             r15, seqh[2 * 8]
                                                ;----[chapter 05]---------------------------------------------------------------;
                                                ; strings
                                                ;-------------------------------------------------------------------------------;
                                                ; moving characters from location to location
                                                ; rep 
                                                ; movsb
                                                ; movsw
                                                ; movsd
                                                ; movsq
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rdx, rdx
                                                xor                                             r8, r8
                                                xor                                             r9, r9
                                                lea                                             rsi, strsrc_00
                                                lea                                             rdi, strdst_00
                                                mov                                             rcx, sizeof strsrc_00
                                                cld
                                                rep                                             movsb
                                                mov                                             dl, strdst_00[0]
                                                mov                                             r8b, strdst_00[1]
                                                mov                                             r9b, strdst_00[0]

                                                ;-------------------------------------------------------------------------------;
                                                ; storing characters to location (from reg)
                                                ; rep 
                                                ; stosb
                                                ; stosw
                                                ; stosd
                                                ; stosq
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rdx, rdx
                                                xor                                             r8, r8
                                                xor                                             r9, r9
                                                mov                                             al, 'A'
                                                lea                                             rdi, strdst_01
                                                mov                                             rcx, lengthof strdst_01
                                                cld 
                                                rep                                             stosb
                                                mov                                             dl, strdst_01[0]
                                                mov                                             r8b, strdst_01[1]
                                                mov                                             r9b, strdst_01[2]

                                                ;-------------------------------------------------------------------------------;
                                                ; loading characters to reg
                                                ; rep 
                                                ; lodsb
                                                ; lodsw
                                                ; lodsd
                                                ; lodsq
                                                ;-------------------------------------------------------------------------------;
                                                xor                                             rdx, rdx
                                                xor                                             r8, r8
                                                xor                                             r9, r9
                                                lea                                             rsi, strsrc_02
                                                mov                                             rdi, rsi
                                                mov                                             rcx, lengthof strsrc_02
                                                cld 
                                                start3:
                                                lodsb
                                                sub                                             al, 32
                                                stosb
                                                dec                                             rcx
                                                jnz                                             start3
                                                mov                                             dl, strsrc_02[0]
                                                mov                                             r8b, strsrc_02[1]
                                                mov                                             r9b, strsrc_02[2]

                                                xor                                             rcx, rcx                        ; set termination code 0 for clean exit
                                                call                                            ExitProcess
                                                ret                                             0
main                                            endp
end
