# masm64-init
Starter project for MASM64:  
- Launch `x64 Native Tools Command Prompt for VS 2022`.  
- Run `scripts\build.bat`
- Run with `build\main.exe` or `devenv build\main.exe`
## Learning Resources:
If you are new to x86-64 Assembly I suggest:
- [The Art of 64-Bit Assembly, Volume 1: x86-64 Machine Organization and Programming](https://nostarch.com/art-64-bit-assembly-volume-1)
- [Assembly x64 Programming in easy steps](https://ineasysteps.com/products-page/assembly-x64-programming-in-easy-steps/)
## x86-64 Registers Cheat Sheet
### Registers:
| 64  | 32   | 16    | 8      | name            |
|-----|------|-------|--------|-----------------|
| rax | eax  | ax    | ah/al  | accumulator     |
| rbx | ebx  | bx    | bh/bl  | base            |
| rcx | ecx  | cx    | ch/cl  | counter         |
| rdx | edx  | dx    | dh/dl  | data            |
| rsi | esi  | si    | sil    | source_idx      |
| rdi | edi  | di    | dil    | destination_idx |
| rbp | ebp  | bp    | bpl    | base_pointer    |
| rsp | esp  | sp    | spl    | stack_pointer   |
| r8  | r8d  | r8w   | r8b    | general_purpose |
| r9  | r9d  | r9w   | r9b    | general_purpose |
| r10 | r10d | r10w  | r10b   | general_purpose |
| r11 | r11d | r11w  | r11b   | general_purpose |
| r12 | r12d | r12w  | r12b   | general_purpose |
| r13 | r13d | r13w  | r13b   | general_purpose |
| r14 | r14d | r14w  | r14b   | general_purpose |
| r15 | r15d | r15w  | r15b   | general_purpose |
### Volatile vs Non-Volatile
| Type         | Registers                                          | Responsibility               |
| ------------ | ---------------------------------------------------| ---------------------------- |
| Volatile     | rax, rcx, rdx, r8,  r9,  r10, r11, rsp, xmm0–xmm5  | **Caller** must save         |
| Non-Volatile | rbx, rbp, rsi, rdi, r12, r13, r14, r15, xmm6–xmm15 | **Callee** must save/restore |

