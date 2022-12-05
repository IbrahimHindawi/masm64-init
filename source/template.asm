;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Name                                                                                                                    ;
;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Module that contains Name chapter                                                                                       ;
;-----------------------------------------------------------------------------------------------------------------------------------;
                                                ifndef NAME_asm                                                                     ; header guard
                                                NAME_asm = 0                                                                        ; header guard variable

;----------[const section]----------------------------------------------------------------------------------------------------------;
.const
;----------[data section]-----------------------------------------------------------------------------------------------------------;
.data
;----------[code section]-----------------------------------------------------------------------------------------------------------;
.code

procedure                                       proc
                                                xor                                             rax, rax                        ; return zero
                                                ret                                                                             ; return
procedure                                       endp                                                                            ; end proc

                                                endif                                                                           ; header guard end

