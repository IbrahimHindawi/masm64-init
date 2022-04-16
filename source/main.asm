;------------------------------------------------------------------------------------------------
;                                                                                               -
;           start project                                                                       -
;------------------------------------------------------------------------------------------------
;                                                                                               -
;                                                                                               -
;                                                                                               -
;------------------------------------------------------------------------------------------------
                                                includelib      kernel32.lib
                                                ExitProcess     proto
;----------[data section]------------------------------------------------------------------------
.data
var                                             qword           0FFFFh

;----------[code section]-------------------------------------------------------------------------
.code
main                                            proc
                                                ;-----[multiplication]---------------------------
                                                ; 64-bit multiplication results in 128-bit result
                                                ; therefore rax and rdx are used
                                                xor             rax, rax                        ; clear rax
                                                xor             rcx, rcx                        ; clear rcx
                                                
                                                mov             rax, 3
                                                mov             rcx, var
                                                
                                                mul             rcx
                                                mov             var, rax
                                                
                                                call            ExitProcess
                                                ret             0
main                                            endp
end
