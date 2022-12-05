;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           MASM64 Starter Project.                                                                                                 ;
;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           This project teaches how to use Microsoft Macro Assembler 64-bit                                                        ;
;           First it prints hello world and then calls different procedures                                                         ;
;           that explain different aspects of assembley programming.                                                                ;
;           Each chapter is a different module included into this file.                                                             ;
;                                                                                                                                   ;
;-----------------------------------------------------------------------------------------------------------------------------------;
                                                include                                         chapters/move.asm
                                                include                                         chapters/flow.asm
                                                include                                         chapters/addr.asm
                                                include                                         chapters/strings.asm
                                                include                                         chapters/procs.asm                  
                                                include                                         chapters/math.asm                  

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
;----------[data section]-----------------------------------------------------------------------------------------------------------;
.data
x                                               real4                                           3.15
;----------[code section]-----------------------------------------------------------------------------------------------------------;
.code
main                                            proc
                                                ;-----[data output]-----------------------------------------------------------------;
                                                ; print something to the console using writefile                                    ;
                                                ; write to std out                                                                  ;
                                                ;-----------------------------------------------------------------------------------;
                                                sub                                             rsp, 40                             ; writefile(5 parms) * 8 = 40 bytes
                                                mov                                             rcx, std_output_handle              ; output handle arg
                                                call                                            GetStdHandle                        ; get handle from os

                                                mov                                             rcx, rax                            ; pass result into rcx
                                                lea                                             rdx, outputmessage                  ; address of string
                                                mov                                             r8, outputmessagelength             ; len of string
                                                xor                                             r9, r9                              ; zero
                                                mov                                             [rsp + 32], r9                      ; nth parm - 1 = (5 - 4) * 8 = 32 bytes
                                                call                                            WriteFile                           ; print
                                                add                                             rsp, 40                             ; balance the stack

                                                call                                            move
                                                call                                            flow
                                                call                                            addressing
                                                call                                            strings
                                                call                                            procs
                                                call                                            math


                                                xor                                             rcx, rcx                            ; set termination code 0 for clean exit
                                                call                                            ExitProcess                         ; terminate process
                                                ret                                             0                                   ; return code
main                                            endp                                                                                ; end proc
                                                end                                                                                 ; end module
