;------------------------------------------------------------------------------------------------
;                                                                                               -
;           start project                                                                       -
;------------------------------------------------------------------------------------------------
;                                                                                               -
;                                                                                               -
;                                                                                               -
;------------------------------------------------------------------------------------------------
                                                ExitProcess     proto
												GetStdHandle	proto
												WriteFile		proto
STD_OUTPUT_HANDLE								equ				-11
;----------[const section]-----------------------------------------------------------------------
.const
;outputmessagelength							qword			sizeof outputmessage
outputmessage									byte			'Hello, World!'
												byte			0AH, 0DH
outputmessagelength								equ		 		$ - outputmessage
;----------[data section]-------------------------------------------------------------------------
.data
var                                             qword           0FFFFh

;----------[code section]-------------------------------------------------------------------------
.code
main                                            proc
                                                ;-----[multiplication]---------------------------
                                                ; 64-bit multiplication results in 128-bit result
                                                ; therefore rax and rdx are used
                                                ;------------------------------------------------
                                                xor             rax, rax                        ; clear rax
                                                xor             rcx, rcx                        ; clear rcx
                                                
                                                mov             rax, 3
                                                mov             rcx, var
                                                
                                                mul             rcx
                                                mov             var, rax

												xor				rax, rax
												xor				rcx, rcx

												mov				rax, 1911
												mov				rcx, var

												mul				rcx 
												mov				var, rax
                                                ;-----[data output]------------------------------
                                                ; print something to the console using WriteFile
                                                ; write to std out
                                                ;------------------------------------------------
												sub				rsp, 40							; WriteFile(5 parms) * 8 = 40 bytes
												mov				rcx, STD_OUTPUT_HANDLE
												call			GetStdHandle

												mov				rcx, rax
												lea				rdx, outputmessage
												mov				r8, outputmessagelength
												xor				r9, r9
												mov				[rsp + 32], r9					; nth parm - 1 = (5 - 4) * 8 = 32 bytes
												call			WriteFile
                                                
												xor				rcx, rcx						; set termination code 0 for clean exit
                                                call            ExitProcess
                                                ret             0
main                                            endp
end

