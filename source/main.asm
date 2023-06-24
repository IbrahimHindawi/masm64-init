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
;----------[types modules constants procedure prototypes]---------------------------------------------------------------------------;
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

vector                                          struct
x                                               real4                                           ?
y                                               real4                                           ?
z                                               real4                                           ?
vector                                          ends

;----------[const section]----------------------------------------------------------------------------------------------------------;
.const
N                                               equ                                             256

tensorN                                         equ                                             3 * 3

outputmessage                                   byte                                            'hello, world!'
                                                byte                                            0ah, 0dh
                                                byte                                            'from masm64!'
                                                byte                                            0ah, 0dh
outputmessagelength                             equ                                             $ - outputmessage
;----------[data section]-----------------------------------------------------------------------------------------------------------;
.data
arr                                             dword                                           N dup(?)

tensor_cube                                     vector                                          tensorN dup(<>)
tensor_cube_len                                 = ($ - tensor_cube) / sizeof vector
;----------[code section]-----------------------------------------------------------------------------------------------------------;
.code
main                                            proc
                                                ;-----[print hello]-----------------------------------------------------------------;
                                                ; print something to the console using writefile then write to std out.             ;
                                                ; this procedure also shows the win64 calling convention.                           ;
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

                                                ;-----[call procs]------------------------------------------------------------------;
                                                ; these are the procedures that represent the various chapters that explain x64     ;
                                                ; assembly programming. Read each chapter in order.                                 ;
                                                ;-----------------------------------------------------------------------------------;
                                                call                                            move
                                                call                                            flow
                                                call                                            addressing
                                                call                                            strings
                                                call                                            procs
                                                call                                            math
                                                
                                                ;-----[array init]------------------------------------------------------------------;
                                                ; these instructions show how to manipulate data in an array using looping          ;
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx
                                                lea                                             rdx, arr

                                                arr_loop:
                                                mov                                             dword ptr [rdx], ecx

                                                inc                                             ecx
                                                add                                             rdx, sizeof dword
                                                cmp                                             ecx, N
                                                jl                                              arr_loop

                                                ;-----[tensor math]-----------------------------------------------------------------;
                                                ; these instructions show how to manipulate data in a tensor pre allocated in memory;
                                                ; using this formula x * n^0 + y * n^1 + z * n^2                                    ;
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rax, rax
                                                xor                                             rcx, rcx
                                                lea                                             rdx, tensor_cube

                                                tensor_cube_fill:
                                                mov                                             real4 ptr [tensor_cube + rcx].vector.x, 03f800000h
                                                mov                                             real4 ptr [tensor_cube + rcx].vector.y, 0
                                                mov                                             real4 ptr [tensor_cube + rcx].vector.z, 0bF800000h

                                                add                                             rcx, sizeof vector
                                                cmp                                             rcx, tensor_cube_len * sizeof vector
                                                jl                                              tensor_cube_fill


                                                ;-----[terminate program]-----------------------------------------------------------;
                                                ; these instructions show how to cleanly exit the program.                          ;
                                                ;-----------------------------------------------------------------------------------;
                                                xor                                             rcx, rcx                            ; set termination code 0 for clean exit
                                                call                                            ExitProcess                         ; terminate process
                                                ret                                             0                                   ; return code
main                                            endp                                                                                ; end proc
                                                end                                                                                 ; end module
