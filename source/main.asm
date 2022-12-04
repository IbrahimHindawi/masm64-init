;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           MASM64 Starter Project.                                                                                                 ;
;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Writes to the StdOut, then exits safely.                                                                                ;
;-----------------------------------------------------------------------------------------------------------------------------------;
                                                include                                         chapters/move.asm
                                                include                                         chapters/flow.asm
                                                include                                         chapters/addr.asm
                                                include                                         chapters/strings.asm
                                                include                                         chapters/procs.asm

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

                                                call                                            move
                                                call                                            flow
                                                call                                            addressing
                                                call                                            strings
                                                call                                            procks


                                                xor                                             rcx, rcx                        ; set termination code 0 for clean exit
                                                call                                            ExitProcess                     ; terminate process
                                                ret                                             0                               ; return code
main                                            endp                                                                            ; end proc
                                                end                                                                             ; end module
