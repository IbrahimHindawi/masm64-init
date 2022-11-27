;-----------------------------------------------------------------------------------------------;
;                                                                                               ;
;           MASM64 Starter Project.                                                             ;
;-----------------------------------------------------------------------------------------------;
;                                                                                               ;
;           Writes to the StdOut, then exits safely.                                            ;
;-----------------------------------------------------------------------------------------------;
                                                GetStdHandle    proto
                                                WriteFile       proto
                                                ExitProcess     proto
std_output_handle                               equ             -11
;----------[const section]----------------------------------------------------------------------;
.const
outputmessage                                   byte            'hello, world!'
                                                byte            0ah, 0dh
                                                byte            'from masm64!'
                                                byte            0ah, 0dh
outputmessagelength                             equ             $ - outputmessage
constval                                        equ             12
;----------[data section]-----------------------------------------------------------------------;
.data
                                                ; create a 64-bit variable
var                                             qword           0ffffh
x                                               real4           3.15

;----------[code section]-----------------------------------------------------------------------;
.code
main                                            proc
                                                ;-----[data output]-----------------------------;
                                                ; print something to the console using writefile
                                                ; write to std out
                                                ;-----------------------------------------------;
                                                sub             rsp, 40                         ; writefile(5 parms) * 8 = 40 bytes
                                                mov             rcx, std_output_handle
                                                call            GetStdHandle

                                                mov             rcx, rax
                                                lea             rdx, outputmessage
                                                mov             r8, outputmessagelength
                                                xor             r9, r9
                                                mov             [rsp + 32], r9                  ; nth parm - 1 = (5 - 4) * 8 = 32 bytes
                                                call            WriteFile
                                                add             rsp, 40

                                                ;----[chapter 01]-------------------------------;
                                                ; moving variables around
                                                ;-----------------------------------------------;
                                                ; move
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                mov             rcx, 33
                                                mov             rdx, rcx
                                                mov             rcx, var
                                                mov             var, rdx
                                                ; constants
                                                mov             rcx, constval
                                                mov             rdx, constval + 8
                                                ; exchange data
                                                xchg            rcx, rdx
                                                xchg            rcx, var

                                                ;----[chapter 02]-------------------------------;
                                                ; arithmetic
                                                ;-----------------------------------------------;
                                                add             rcx, rdx
                                                sub             rdx, rcx
                                                ; inc dec neg
                                                inc             rcx
                                                dec             rdx
                                                neg             rcx
                                                ; unsigned mul div
                                                mov             rax, 8                          ; multiplicand is rax
                                                mul             rcx                             ; multiplier can be any reg, result [rdx, rax] [upper, lower]
                                                mov             rax, 8                          ; dividend is rax
                                                div             rcx                             ; divisor can be any reg, result [rdx, rax] [remainder, quotient]
                                                ; signed mul
                                                xor             rax, rax
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                xor             r8, r8
                                                xor             r9, r9
                                                mov             rax, 100
                                                mov             rcx, 200
                                                mov             rdx, 4
                                                mov             r8, 8
                                                imul            rcx                             ; multiplicand is rax
                                                mov             rdx, 8
                                                imul            rcx, rdx                        ; multiplicand, multiplier
                                                imul            r8, rcx, 16                     ; destination, multiplicand, multiplier
                                                ; signed div
                                                xor             rax, rax
                                                xor             rbx, rbx
                                                xor             rdx, rdx
                                                mov             rax, 100                        ; dividend is rax
                                                mov             rbx, 3
                                                idiv            rbx                             ; divisor can be any reg, result [rdx, rax] [remainder, quotient], -100
                                                mov             rax, -100
                                                cqo                                             ; sign extension must be used with negative numbers
                                                idiv            rbx
                                                ; bit manipulation
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                mov             rcx, 00F0Fh
                                                mov             rdx, 0F0F0h
                                                and             rcx, rdx
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                mov             rcx, 00F0Fh
                                                mov             rdx, 0F0F0h
                                                or              rcx, rdx
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                mov             rcx, 00F0Fh
                                                mov             rdx, 0F0F0h
                                                xor             rcx, rdx
                                                xor             rcx, rcx
                                                xor             rdx, rdx
                                                mov             rcx, 00F0Fh
                                                mov             rdx, 0F0F0h
                                                not             rcx
                                                ; shifting bits
                                                xor             rcx, rcx
                                                mov             rcx, 00F0Fh
                                                shl             rcx, 2                          ; shift n bits to the left
                                                shr             rcx, 2                          ; shift n bits to the right
                                                sal             rcx, 2                          ; shift n bits to the left while adding 1s to the right
                                                sar             rcx, 2                          ; shift n bits to the right while adding 1s to the left
                                                ; rotating bits
                                                xor             rcx, rcx
                                                mov             rcx, 00F0Fh
                                                rol             rcx, 2                          ; rotate n bits to the left
                                                ror             rcx, 2                          ; rotate n bits to the right
                                                rcl             rcx, 2                          ; rotate n bits to the left while adding 1s to the left
                                                rcr             rcx, 2                          ; rotate n bits to the right while adding 1s to the right
                                                ;----[chapter 03]-------------------------------;
                                                ; directing flow
                                                ; AC auxiliary carry
                                                ; CY carry
                                                ; EI enable interrupt
                                                ; OV overflow
                                                ; PE parity even
                                                ; PL sign polarity
                                                ; UP direction
                                                ; ZR Zero
                                                ;-----------------------------------------------;
                                                ; jump
                                                xor             rax, rax
                                                jmp             next
                                                mov             rax, 2
                                                next:
                                                mov             rax, 8
                                                ; test
                                                mov             rcx, 0FFFFh
                                                test            rcx, 00001h                     ; jump if odd
                                                ; flag based jumps
                                                xor             rdx, rdx
                                                mov             cl, 255
                                                add             cl, 1
                                                jc              carry                           ; jump if carry
                                                mov             rdx, 1
                                                carry:
                                                mov             cl, -128
                                                sub             cl, 1
                                                jo              overflow                        ; jump if overflow
                                                mov             rdx, 2
                                                overflow:
                                                mov             cl, 255
                                                and             cl, 10000000b
                                                js              sign                            ; jump if sign
                                                mov             rdx, 3
                                                sign:
                                                jnz             notZero                         ; jump if not zero
                                                mov             rdx, 4
                                                notZero:
                                                ; compare
                                                ; comparing left op to right op
                                                ; je jne
                                                ; ja jnbe
                                                ; jae jnb
                                                ; jb jnae
                                                ; jbe jna
                                                xor             rdx, rdx
                                                mov             rbx, 100
                                                mov             rcx, 200
                                                cmp             rcx, rbx
                                                ja              above                           ; jump if lop above rop
                                                mov             rdx, 1
                                                above:
                                                mov             rcx, 50
                                                cmp             rcx, rbx
                                                jb              below                           ; jump if lop below rop
                                                mov             rdx, 2
                                                below:
                                                mov             rcx, 100
                                                cmp             rcx, rbx
                                                jbe             equal                           ; jump if lop below or equal rop
                                                mov             rdx, 3
                                                equal:
                                                ; compare
                                                ; jg jnle
                                                ; jge jnl
                                                ; jl jnge
                                                ; jle jng


                                                xor             rcx, rcx                        ; set termination code 0 for clean exit
                                                call            ExitProcess
                                                ret             0
main                                            endp
end
