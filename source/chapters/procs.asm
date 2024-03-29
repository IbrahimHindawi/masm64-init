;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Procs                                                                                                                   ;
;-----------------------------------------------------------------------------------------------------------------------------------;
;                                                                                                                                   ;
;           Module that contains procs chapter.                                                                                     ;
;-----------------------------------------------------------------------------------------------------------------------------------;
                                                ifndef procs_asm                                                                    ; header guard
                                                procs_asm = 0                                                                       ; header guard variable

;----------[const section]----------------------------------------------------------------------------------------------------------;
.const
constval                                        equ                                             12
;----------[data section]-----------------------------------------------------------------------------------------------------------;
.data
func_var                                        qword                                           ?
;----------[code section]-----------------------------------------------------------------------------------------------------------;
.code

procs                                           proc
                                                ;-------[procedure]-----------------------------------------------------------------;
                                                ;       procedure example                                                           ;
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rax, rax                            ; return zero
                                                ret                                                                                 ; return
procs                                           endp                                                                                ; end proc

                                                endif                                                                               ; header guard end


