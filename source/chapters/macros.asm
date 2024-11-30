;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                                                                                   
;           MASM64 Starter Project.                                                                                                 
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                                                                                   
;           This project teaches how to use Microsoft Macro Assembler 64-bit                                                        
;           First it prints hello world and then calls different procedures                                                         
;           that explain different aspects of assembley programming.                                                                
;           Each chapter is a different module included into this file.                                                             
;                                                                                                                                   
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;----------[macros]---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                ifndef macros_asm                                                                    
                                                macros_asm = 0                                                                       

;----------[macro section]--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
constantmacro                                   textequ                                         <1911>

clearrax                                        textequ                                         <xor rax, rax>

clearrcx                                        macro
                                                xor                                             rcx, rcx
endm

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; macros can take parameters:
; - adding `:req` enforces parameter at macro call site 
; - adding `:=` enforces a default value
; - adding `<>` is reqired for numeric values
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrowparams                                    macro                                           p0:req, p1:=<1911>
                                                xor                                             p0, p0
                                                add                                             p0, p1
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; macros can branch:
; eq ==
; ne !=
; gt >
; lt <
; ge >=
; le <=
; if        test
;           ...
; elseif    test
;           ...
; else
;           ...
; endif
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrobranching                                  macro                                           num:req
                                                if                                              num gt 10
                                                mov                                             rax, 10
                                                elseif                                          num lt 0
                                                mov                                             rax, -1
                                                else
                                                xor                                             rax, rax
                                                endif
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; repeat macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrorepeat                                     macro                                           reg:req, count:req
                                                repeat                                          count
                                                inc                                             reg
                                                endm
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; while macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrowhile                                      macro                                           reg:req, max:req
                                                count                                           =  0
                                                while                                           count lt max
                                                count                                           = count + 1
                                                inc                                             reg
                                                endm
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; for macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrofor                                        macro                                           arg0, arg1, arg2
                                                for                                             argiter, <arg0, arg1, arg2>
                                                push                                            argiter
                                                endm
                                                pop                                             rax
                                                pop                                             rbx
                                                pop                                             rcx
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; labels macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macrolabels                                     macro                                           base:req, exponent:req
                                                local                                           start, finish
                                                mov                                             rax, 1
                                                mov                                             rcx, exponent
                                                cmp                                             rcx, 0
                                                je                                              finish
                                                mov                                             rbx, base
                                                start:
                                                mul                                             rbx
                                                loop                                            start
                                                finish:
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; return macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
factorial                                       macro                                           num:req
                                                factor                                          = num
                                                i                                               = 1
                                                while                                           factor gt 1
                                                i                                               = i * factor
                                                factor                                          = factor - 1
                                                endm
exitm <i>
endm
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; vararg macro
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sumargs                                         macro                                           arglist:vararg
                                                sum                                             = 0
                                                i                                               = 0
                                                for                                             arg, <arglist>
                                                i                                               = i + 1
                                                sum                                             = sum + arg
                                                endm
                                                mov                                             rcx, i
                                                exitm                                           <sum>
endm


;----------[const section]--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.const
;----------[data section]---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.data
;----------[code section]---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.code
macros                                          proc
                                                ;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                ; 
                                                ;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                mov                                             rax, constantmacro
                                                clearrax
                                                clearrcx
                                                macrowparams                                    rax, 8
                                                mov                                             rcx, 2
                                                macrobranching                                  1
                                                macrowhile                                      rax, 100
                                                macrofor                                        1, 2, 3
                                                macrolabels                                     4, 3
                                                mov                                             rax, factorial(4)
                                                mov                                             rbx, factorial(5)
                                                mov                                             rax, sumargs(1, 2, 3, 4)
                                                mov                                             rax, sumargs(1, 2, 3, 4, 5, 6, 7, 8)
                                                ;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                ret
macros                                          endp
                                                endif
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
