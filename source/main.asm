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
;----------[data section]-----------------------------------------------------------------------;
.data
var                                             qword           0ffffh

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

                                                xor             rcx, rcx                        ; set termination code 0 for clean exit
                                                call            ExitProcess
                                                ret             0
main                                            endp
end
