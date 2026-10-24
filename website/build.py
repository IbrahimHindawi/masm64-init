"""Build the MASM64-init learning site.

Repository copy:
    python website/build.py [output-directory]

psite fallback copy:
    python scripts/masm64-init/build.py [repository] [output-directory]
"""

import html
import pathlib
import re
import shutil
import sys

HERE = pathlib.Path(__file__).resolve().parent
if HERE.parent.name.lower() == "masm64-init":
    REPO = HERE.parent
    OUT = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else HERE / "dist"
else:
    PSITE = HERE.parent.parent
    REPO = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else PSITE.parent / "masm64-init"
    OUT = pathlib.Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else PSITE / "site-static" / "masm64-init"

GITHUB = "https://github.com/IbrahimHindawi/masm64-init"
THEME_KEY = "masm64-init-theme"

PAGES = [
    ("Introduction", "Introduction", None),
    ("Moving data", "Moving-data", "source/chapters/move.asm"),
    ("Arithmetic", "Arithmetic", "source/chapters/arith.asm"),
    ("Control flow", "Control-flow", "source/chapters/flow.asm"),
    ("Addressing", "Addressing", "source/chapters/addr.asm"),
    ("Strings", "Strings", "source/chapters/strings.asm"),
    ("Procedures", "Procedures", "source/chapters/procs.asm"),
    ("Macros", "Macros", "source/chapters/macros.asm"),
    ("Math", "Math", "source/chapters/math.asm"),
    ("Full program", "Program", "source/main.asm"),
    ("Module template", "Template", "source/template.asm"),
]

SUMMARIES = {
    "Moving data": "Registers, memory operands, immediates, sizes, extension, and the MOV family.",
    "Arithmetic": "Integer arithmetic, flags, multiplication, division, and practical numeric patterns.",
    "Control flow": "Comparisons, condition flags, branches, loops, and readable labels.",
    "Addressing": "Addresses, pointers, arrays, structures, LEA, and scaled-index operands.",
    "Strings": "Byte strings, lengths, terminators, buffers, and the string instructions.",
    "Procedures": "The Windows x64 calling convention, stack frames, arguments, results, and preserved registers.",
    "Macros": "MASM macros, parameters, expansion, and small abstractions that still show the machine.",
    "Math": "Floating-point work, vectors, and SIMD-oriented examples with XMM registers.",
    "Full program": "The starter program that wires the chapters together and demonstrates Win32 output.",
    "Module template": "A small guarded module skeleton for adding another chapter or reusable procedure.",
}

LESSONS = {}

LESSONS.update({
    "Moving data": {
        "intro": "Assembly becomes much less mysterious once you see every instruction as a small transfer between registers, memory, and literal values. This chapter starts with those three places and the register widths that connect them.",
        "sections": [
            (
                "One register, several widths",
                "<p>The general-purpose registers are 64 bits wide, but you can address their smaller pieces. <code>rax</code> is the full register, <code>eax</code> is its low 32 bits, <code>ax</code> is the low 16, and <code>al</code> is the low byte. The operand size decides how much data an instruction reads or writes.</p><p>Structures make those sizes explicit. Here every field is a 32-bit <code>real4</code>, so the complete vector occupies 12 bytes.</p>",
                ("source/main.asm", "vector struct", "vector ends", 1),
                "The type next to a field or memory operand is part of the program's contract.",
            ),
            (
                "Immediate, register, and memory",
                "<p><code>mov</code> copies a value; it does not erase the source. A literal such as <code>33</code> is an immediate, <code>rcx</code> is a register, and <code>var</code> names memory. MASM writes the destination first and the source second.</p><p><code>xchg</code> is different: it swaps its two operands in one instruction.</p>",
                ("source/chapters/move.asm", "xor rcx, rcx", "xchg rcx, var", 1),
                "Read <code>mov rdx, rcx</code> as “copy rcx into rdx.”",
            ),
            (
                "Keep preserved registers balanced",
                "<p>Windows x64 lets a procedure freely change volatile registers such as <code>rax</code>, <code>rcx</code>, and <code>rdx</code>. A preserved register such as <code>rbx</code> must be restored before returning. The unwind directives describe that stack change to Windows.</p>",
                ("source/chapters/move.asm", "move proc frame", ".endprolog", 1),
                "Every <code>push rbx</code> in a procedure needs a matching <code>pop rbx</code> on every return path.",
            ),
        ],
        "takeaways": [
            "Operand width matters: byte, word, dword, and qword are different operations.",
            "MASM uses destination-first syntax.",
            "Registers are fast working storage; named variables live in memory.",
        ],
    },
    "Arithmetic": {
        "intro": "Integer arithmetic is mostly ordinary two-operand work, with two important exceptions: multiply and divide can use the paired <code>rdx:rax</code> result, and signed division needs the dividend extended correctly first.",
        "sections": [
            (
                "The everyday instructions",
                "<p><code>add</code> and <code>sub</code> update their destination. <code>inc</code> and <code>dec</code> change it by one, while <code>neg</code> flips the sign using two's complement. All of them update status flags that later branches can inspect.</p>",
                ("source/chapters/arith.asm", "mov x, 100", "neg rax", 1),
                "The source operand is unchanged; the destination receives the result.",
            ),
            (
                "Multiply has useful forms",
                "<p>The one-operand <code>mul</code>/<code>imul</code> forms use <code>rax</code> implicitly and can produce a double-width result in <code>rdx:rax</code>. The two- and three-operand <code>imul</code> forms are often easier when you only need the low half.</p>",
                ("source/chapters/arith.asm", "mov rax, 100", "imul rdx, rax, 8", 2),
                "Use the explicit destination forms when you do not need the high half in rdx.",
            ),
            (
                "Division needs a prepared dividend",
                "<p><code>div</code> and <code>idiv</code> divide the combined <code>rdx:rax</code> value. Clear <code>rdx</code> for a positive unsigned-sized dividend; use <code>cqo</code> before signed 64-bit division when <code>rax</code> may be negative.</p>",
                ("source/chapters/arith.asm", "xor rdx, rdx", "idiv rcx", 1),
                "After division, rax holds the quotient and rdx holds the remainder.",
            ),
            (
                "Bits are data too",
                "<p><code>and</code> masks bits, <code>or</code> sets them, and <code>xor</code> toggles them. XORing a register with itself is the standard compact way to produce zero.</p>",
                ("source/chapters/arith.asm", "xor rcx, rcx", "or rcx, rdx", 1),
                "Think of masks as small yes/no filters applied independently to every bit.",
            ),
        ],
        "takeaways": [
            "Arithmetic writes the destination and updates flags.",
            "Multiply and divide have implicit rax/rdx conventions.",
            "Prepare the high half of a dividend before div or idiv.",
        ],
    },
    "Control flow": {
        "intro": "The CPU does not have high-level <code>if</code> or <code>while</code> statements. It sets flags while doing arithmetic or comparisons, then a conditional jump chooses the next label.",
        "sections": [
            (
                "Test without changing the value",
                "<p><code>test</code> performs an AND only for its flags; it throws the numeric result away. Testing bit zero is a quick way to distinguish odd and even integers.</p>",
                ("source/chapters/flow.asm", "mov rcx, 0FFFFh", "test rcx, 00001h    ; jump if odd", 1),
                "Use test when you care about zero or a bit mask but want to keep the original operand.",
            ),
            (
                "Compare, then choose the right jump",
                "<p><code>cmp left, right</code> sets flags as if it had calculated <code>left - right</code>. Use <code>ja/jb</code> for unsigned values and <code>jg/jl</code> for signed values. Equality uses <code>je</code> or <code>jne</code> either way.</p>",
                ("source/chapters/flow.asm", "mov rbx, 100", "equal:", 1),
                "Signedness changes how ordering flags are interpreted; it does not change the bits themselves.",
            ),
            (
                "A loop is a label plus a branch",
                "<p>There is no hidden loop machinery here. Initialize state, place a label, update the state, compare it with the limit, and jump back while more work remains.</p>",
                ("source/chapters/flow.asm", "xor rcx, rcx", "acc_end:", 1),
                "Keep the loop counter, exit condition, and back edge visually close.",
            ),
        ],
        "takeaways": [
            "cmp and test set flags; conditional jumps consume them.",
            "Choose signed or unsigned ordering jumps deliberately.",
            "Readable labels are the structure of assembly control flow.",
        ],
    },
})

LESSONS.update({
    "Macros": {
        "intro": "MASM macros run while the assembler is building the program. They can remove repetitive source code, but they expand into real instructions—so a good macro stays small enough that you can still predict the output.",
        "sections": [
            (
                "Text aliases and instruction macros",
                "<p><code>textequ</code> is a textual substitution. A named <code>macro</code> can emit one or more instructions. Neither one is a runtime function call.</p>",
                ("source/chapters/macros.asm", "constantmacro textequ <1911>", "endm", 1),
                "Use a procedure when you want one shared runtime implementation; use a macro when expansion is the point.",
            ),
            (
                "Parameters make expansion reusable",
                "<p><code>:req</code> makes an argument mandatory. A <code>:=</code> value provides a default when the caller leaves that parameter out. The assembler substitutes the chosen operands directly into the emitted instructions.</p>",
                ("source/chapters/macros.asm", "macrowparams macro p0:req, p1:=<1911>", "endm", 1),
                "Name macro parameters by their role, not by a register you happen to pass today.",
            ),
            (
                "Assembly-time branching",
                "<p>Macro conditionals choose what source to emit. They are evaluated during assembly, so this <code>if</code> is not a CPU branch and produces no conditional jump by itself.</p>",
                ("source/chapters/macros.asm", "macrobranching macro num:req", "endm", 1),
                "Compile-time conditions need values the assembler can know before the program runs.",
            ),
            (
                "Call sites should remain readable",
                "<p>The payoff is visible where the macros are used: repeated setup becomes a descriptive line, while ordinary instructions remain ordinary instructions. If a macro call hides too much state, it has grown too large.</p>",
                ("source/chapters/macros.asm", "mov rax, constantmacro", "mov rax, sumargs(1, 2, 3, 4, 5, 6, 7, 8)", 1),
                "Treat macro expansion as code you will eventually debug in a disassembler.",
            ),
        ],
        "takeaways": [
            "Macros expand at assembly time; procedures execute at runtime.",
            "Required and default parameters make macro contracts explicit.",
            "Prefer small macros whose emitted instructions remain obvious.",
        ],
    },
    "Math": {
        "intro": "XMM registers let one instruction work on several values at once. The important ideas are alignment, lane width, and the suffix that tells you whether an operation is scalar or packed.",
        "sections": [
            (
                "Lay out aligned vectors",
                "<p>An XMM register is 128 bits, or 16 bytes. These declarations arrange four 32-bit integers, four 32-bit floats, or two 64-bit doubles in exactly that space. The aligned move instructions expect the address to be 16-byte aligned.</p>",
                ("source/chapters/math.asm", "align 16    ; misalignment will cause access violation", "dnum1 real8 1.5, 3.1415926535897932    ; 128 bit aligned 2 x f64 vector", 1),
                "Match the data declaration, alignment, and instruction suffix.",
            ),
            (
                "Packed integer lanes",
                "<p><code>movdqa</code> loads an aligned 128-bit integer vector. <code>paddd</code> and <code>psubd</code> then perform four independent 32-bit operations in parallel.</p>",
                ("source/chapters/math.asm", "movdqa xmm0, xmmword ptr [nums0]    ; type coalescing data into xmm reg", "psubd xmm0, xmm1    ; packed integer subtract dword", 1),
                "Packed arithmetic does not carry from one lane into the next.",
            ),
            (
                "Scalar floating-point operations",
                "<p>The <code>ss</code> suffix means scalar single precision: only the low 32-bit float participates. This is useful when you want SSE arithmetic without treating the register as a four-value vector.</p>",
                ("source/chapters/math.asm", "movss xmm0, fnum0", "divss xmm0, xmm1", 1),
                "Scalar SSE instructions leave the upper lanes outside the calculation.",
            ),
            (
                "Packed float and double operations",
                "<p><code>ps</code> means packed single precision and operates on four floats. <code>pd</code> means packed double precision and operates on two doubles.</p>",
                ("source/chapters/math.asm", "movaps xmm0, xmmword ptr [fnum0]", "divpd xmm2, xmm3", 1),
                "Read suffixes as part of the instruction: ps, pd, ss, and sd describe the lanes.",
            ),
        ],
        "takeaways": [
            "XMM registers hold 128 bits divided into typed lanes.",
            "Aligned moves require aligned storage.",
            "Instruction suffixes distinguish scalar from packed work.",
        ],
    },
    "Full program": {
        "intro": "The entry point is deliberately small: include the lesson modules, print a greeting through Win32, call each chapter, run two compact data loops, and terminate cleanly.",
        "sections": [
            (
                "Modules assemble into one program",
                "<p>MASM's <code>include</code> is source inclusion, not dynamic linking. Each guarded chapter becomes part of this translation unit and contributes its procedure.</p>",
                ("source/main.asm", "include chapters/move.asm", "include chapters/math.asm", 1),
                "The header guards prevent an accidental second inclusion from defining the same symbols twice.",
            ),
            (
                "Call Win32 with the platform ABI",
                "<p>The program obtains the console output handle, places the first four <code>WriteFile</code> arguments in registers, writes the fifth in stack space, and calls the operating system.</p>",
                ("source/main.asm", "mov rcx, std_output_handle    ; output handle arg", "call WriteFile    ; print", 1),
                "API calls are ordinary procedure calls once the arguments and stack obey the ABI.",
            ),
            (
                "Walk the course in executable order",
                "<p>Each lesson is also a procedure. Keeping the call list in learning order makes the repository useful both as a runnable program and as a table of contents.</p>",
                ("source/main.asm", "call move", "call math", 1),
                "Set a debugger breakpoint on one call and step into the chapter you are reading.",
            ),
            (
                "Write an array with a pointer loop",
                "<p>The loop stores the counter through <code>rdx</code>, advances the pointer by one dword, and branches until all <code>N</code> elements have been initialized.</p>",
                ("source/main.asm", "xor rcx, rcx", "jl arr_loop", 1),
                "The pointer advances in bytes; the loop count advances in elements.",
            ),
        ],
        "takeaways": [
            "The main module is wiring, not a second copy of every lesson.",
            "Win32 APIs follow the same x64 procedure contract as your own code.",
            "Small executable examples are easiest to inspect in a debugger.",
        ],
    },
    "Module template": {
        "intro": "A chapter module needs very little ceremony: a guard, the sections it uses, and one or more procedures with valid unwind information.",
        "sections": [
            (
                "Guard the module",
                "<p>The <code>ifndef</code> guard prevents duplicate definitions if the file is included more than once. Give every real module a unique guard symbol.</p>",
                ("source/template.asm", "ifndef NAME_asm    ; header guard", "NAME_asm = 0    ; header guard variable", 1),
                "Rename both NAME and the guard before adding the module to main.asm.",
            ),
            (
                "Keep declarations in their sections",
                "<p>Constants belong in <code>.const</code>, writable storage in <code>.data</code>, and instructions in <code>.code</code>. Empty sections can be removed when a module does not use them.</p>",
                ("source/template.asm", "; --- const section ---", ".code", 1),
                "A predictable file shape makes small modules easy to scan.",
            ),
            (
                "Start with a valid leaf procedure",
                "<p>This skeleton creates a frame-aware leaf procedure, returns zero through <code>rax</code>, and ends without touching the stack. Add saved registers or stack allocation only when the implementation needs them.</p>",
                ("source/template.asm", "procedure proc frame", "procedure endp    ; end proc", 1),
                "Keep prologue directives adjacent to the instructions they describe.",
            ),
        ],
        "takeaways": [
            "Use one unique include guard per module.",
            "Separate constants, data, and code.",
            "Begin with the smallest correct procedure frame.",
        ],
    },
})

LESSONS.update({
    "Addressing": {
        "intro": "Memory operands are address calculations. Once you can see a base address, an index, a scale, and a displacement, arrays and structures stop looking like special features.",
        "sections": [
            (
                "Element size sets the stride",
                "<p>Adjacent bytes are one address apart, words are two, dwords are four, and qwords are eight. MASM's declarations make that layout visible before any instruction runs.</p>",
                ("source/chapters/addr.asm", "seqa byte 1, 2, 3", "seqd qword 1000, 2000, 3000", 1),
                "Array address = base + index × element size.",
            ),
            (
                "Use a scaled index for traversal",
                "<p>The x64 addressing form <code>[base + index * scale + displacement]</code> performs the common array calculation directly. Here <code>rsi</code> is the base, <code>rcx</code> is the index, and eight is the qword stride.</p>",
                ("source/chapters/addr.asm", "lea rsi, seqd", "jne start", 1),
                "The legal hardware scales are 1, 2, 4, and 8—the common element sizes.",
            ),
            (
                "Copy a run of elements",
                "<p>The string instructions also work for numeric arrays. <code>rep movsq</code> copies <code>rcx</code> qwords from <code>rsi</code> to <code>rdi</code>. <code>cld</code> selects forward traversal.</p>",
                ("source/chapters/addr.asm", "lea rsi, seqg", "mov r15, seqh[2 * 8]", 1),
                "rsi is the source pointer, rdi is the destination pointer, and rcx is the count.",
            ),
        ],
        "takeaways": [
            "Addresses are arithmetic, not opaque handles.",
            "Scale an index by the size of one element.",
            "lea computes an address; mov reads or writes the value at an address.",
        ],
    },
    "Strings": {
        "intro": "x86 string instructions are tiny pointer loops built into the instruction set. They use <code>rsi</code>, <code>rdi</code>, and <code>rcx</code> by convention, with the direction flag deciding which way the pointers move.",
        "sections": [
            (
                "Copy bytes with rep movsb",
                "<p>Load the source address into <code>rsi</code>, the destination into <code>rdi</code>, and the byte count into <code>rcx</code>. <code>rep</code> repeats <code>movsb</code> until the count reaches zero.</p>",
                ("source/chapters/strings.asm", "lea rsi, strsrc_00", "rep movsb", 1),
                "Use cld before string work unless your calling context explicitly guarantees the direction flag.",
            ),
            (
                "Load, transform, store",
                "<p><code>lodsb</code> loads one source byte into <code>al</code> and advances <code>rsi</code>. <code>stosb</code> writes <code>al</code> to the destination and advances <code>rdi</code>. The loop below turns the lowercase ASCII bytes into uppercase in place.</p>",
                ("source/chapters/strings.asm", "lea rsi, strsrc_02", "jnz start3", 1),
                "The subtraction by 32 relies on ASCII's fixed gap between lowercase and uppercase letters.",
            ),
            (
                "Search with repne scasb",
                "<p><code>scasb</code> compares <code>al</code> with the byte at <code>rdi</code>. The <code>repne</code> prefix keeps scanning while bytes differ and the count remains nonzero.</p>",
                ("source/chapters/strings.asm", "mov al, 'b'", "finish:", 1),
                "After the scan, the zero flag tells you whether a matching byte was found.",
            ),
            (
                "Compare two buffers",
                "<p><code>cmpsb</code> compares the bytes addressed by <code>rsi</code> and <code>rdi</code>. With <code>repe</code>, comparison stops on the first mismatch or when the count reaches zero.</p>",
                ("source/chapters/strings.asm", "lea rsi, strsrc_04", "finish_01:", 1),
                "Always pair a buffer comparison with an explicit length; raw bytes have no automatic terminator.",
            ),
        ],
        "takeaways": [
            "String instructions use implicit pointer and count registers.",
            "cld makes traversal move toward higher addresses.",
            "rep, repe, and repne express different repetition conditions.",
        ],
    },
    "Procedures": {
        "intro": "A procedure is a contract between caller and callee. Windows x64 fixes where the first arguments arrive, which registers survive a call, how the stack is aligned, and where a return value goes.",
        "sections": [
            (
                "Reserve stack space before calls",
                "<p>The caller reserves 32 bytes of shadow space for every call. The extra eight bytes in this prologue keep <code>rsp</code> 16-byte aligned at call sites. MASM's frame directives describe the allocation for Windows unwind support.</p>",
                ("source/main.asm", "main proc frame", ".endprolog", 1),
                "In this entry point, sub rsp, 40 means 32 bytes of shadow space plus 8 bytes for alignment.",
            ),
            (
                "Arguments go in registers first",
                "<p>The first four integer or pointer arguments use <code>rcx</code>, <code>rdx</code>, <code>r8</code>, and <code>r9</code>. A fifth argument goes on the stack after the shadow space. Return values normally come back in <code>rax</code>.</p>",
                ("source/main.asm", "mov rcx, rax    ; [0] hFile", "call WriteFile    ; print", 1),
                "Write the argument setup in call order; it makes the ABI visible during review.",
            ),
            (
                "Preserve the nonvolatile set",
                "<p>If a procedure uses <code>rbx</code>, <code>rbp</code>, <code>rsi</code>, <code>rdi</code>, or <code>r12</code> through <code>r15</code>, it must restore the original values. This larger chapter saves each preserved register it needs.</p>",
                ("source/chapters/addr.asm", "addressing proc frame", ".endprolog", 1),
                "Pushes in the prologue are popped in reverse order before ret.",
            ),
            (
                "A small leaf procedure",
                "<p>A leaf procedure calls nothing else, so it may need no stack allocation at all. This chapter routine simply places zero in the return register and returns.</p>",
                ("source/chapters/procs.asm", "procs proc frame", "procs endp    ; end proc", 1),
                "Start with the smallest valid frame; add stack work only when the procedure needs it.",
            ),
        ],
        "takeaways": [
            "rcx, rdx, r8, and r9 carry the first four integer arguments.",
            "rax carries an integer or pointer return value.",
            "The caller reserves shadow space; the callee restores preserved registers.",
        ],
    },
})

REGISTERS = set(
    "rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 "
    "eax ebx ecx edx esi edi ebp esp r8d r9d r10d r11d r12d r13d r14d r15d "
    "ax bx cx dx si di bp sp r8w r9w r10w r11w r12w r13w r14w r15w "
    "al bl cl dl sil dil bpl spl ah bh ch dh r8b r9b r10b r11b r12b r13b r14b r15b st".split()
    + [f"xmm{i}" for i in range(16)]
)
INSTRUCTIONS = set("""
mov movzx movsx movsxd lea add sub imul mul div idiv inc dec neg and or xor not shl shr sar rol ror
test cmp jmp je jne jz jnz ja jae jb jbe jg jge jl jle js jns jc jnc call ret retn push pop
cvtsi2ss cvtsi2sd cvtsd2ss cvttss2si cvtdq2ps movss movsd movaps movups movd movq addss subss mulss
divss addps subps mulps divps addsd mulsd divsd sqrtss sqrtps maxss minss andps xorps orps shufps
unpcklps unpckhps movlhps movhlps insertps extractps dpps haddps comiss fld fstp fsin fcos enter leave
sete setne bswap cbw cwd cdq cqo xchg nop cld std rep repe repne movsb movsw movsq stosb stosw stosd
stosq lodsb lodsw lodsd lodsq scasb scasw scasd scasq cmpsb cmpsw cmpsd cmpsq movdqa paddd psubd
movapd addpd subpd mulpd divpd loop
""".split())
DIRECTIVES = set("""
proc endp local uses struct ends union macro endm exitm include includelib equ textequ align byte word
dword qword real4 real8 xmmword ptr offset addr sizeof lengthof type dup if ifdef ifndef else elseif endif
ifb ifnb ifidn ifidni ifdif ifdifi for forc irp externdef extern public label end option proto typedef
allocstack endprolog const data code
""".split())
TOKEN = re.compile(
    r";[^\n]*|\"[^\"\n]*\"|'[^'\n]*'|"
    r"\b(?:[0-9][0-9A-Fa-f]*[hH]|\d+\.\d+(?:[eE][-+]?\d+)?|\d+)\b|"
    r"^[ \t]*[A-Za-z_@?$][\w@?$]*:(?!:)|\.?[A-Za-z_@?$][\w@?$]*|.",
    re.M | re.S,
)


def highlight(code):
    out = []
    for match in TOKEN.finditer(code):
        token = match.group(0)
        word = token.lower()
        cls = None
        if token.startswith(";"):
            cls = "c"
        elif token[0] in "\"'":
            cls = "s"
        elif token[0].isdigit():
            cls = "n"
        elif len(token.strip()) > 1 and token.rstrip().endswith(":"):
            cls = "l"
        elif word in REGISTERS:
            cls = "r"
        elif word in INSTRUCTIONS:
            cls = "k"
        elif word in DIRECTIVES or (token.startswith(".") and len(token) > 1):
            cls = "d"
        elif re.match(r"[ \t]+(?:proc|endp)\b", code[match.end():match.end() + 8], re.I):
            cls = "f"
        escaped = html.escape(token)
        out.append(f'<span class="{cls}">{escaped}</span>' if cls else escaped)
    return "".join(out)


def menu(current):
    rows = []
    for title, path, _ in PAGES:
        selected = ' class="selected" aria-current="page"' if path == current else ""
        rows.append(f'<li><a{selected} href="{path}.html">{title}</a></li>')
    return "<ol>" + "".join(rows) + "</ol>"


def frame(path, title, body):
    theme_boot = (
        f"<script>try{{var t=localStorage.getItem('{THEME_KEY}');"
        "if(t)document.documentElement.dataset.theme=t}catch(e){}</script>"
    )
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MASM64 init - {html.escape(title)}</title>
<meta name="description" content="A practical introduction to Microsoft Macro Assembler for Windows x64: {html.escape(title)}.">
<meta name="color-scheme" content="light dark">
{theme_boot}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:ital,wght@0,400;0,600;0,700;1,400&family=JetBrains+Mono:wght@400;600&display=swap">
<link rel="stylesheet" href="style.css">
<script defer src="theme.js"></script>
</head>
<body>
<header id="header">
  <a class="logo" href="Introduction.html"><span class="logo-main">MASM64 init</span><span class="logo-sub">; assembly from zero</span></a>
  <nav class="site-links"><a href="../index.html">ibrahimhindawi.com</a><a href="../articles.html">articles</a><a href="{GITHUB}">source</a>
    <button class="theme-toggle" type="button" aria-label="Switch between light and dark" title="Light / dark"><span class="sun">&#9728;</span><span class="moon">&#9790;</span></button></nav>
</header>
<div id="supercontainer">
<nav id="nav" aria-label="Guide">
<details class="menu-toggle"><summary>Guide</summary></details>
{menu(path)}
</nav>
<main id="content">
{body}
</main>
</div>
</body>
</html>
"""


SOURCE_CACHE = {}


def source_text(source):
    if source not in SOURCE_CACHE:
        SOURCE_CACHE[source] = (REPO / source).read_text(encoding="utf-8", errors="replace")
    return SOURCE_CACHE[source]


def excerpt(source, start, end, occurrence=1):
    lines = source_text(source).rstrip("\n").splitlines()
    matches = [i for i, line in enumerate(lines) if line.strip() == start]
    if len(matches) < occurrence:
        raise ValueError(f"{source}: could not find occurrence {occurrence} of {start!r}")
    first = matches[occurrence - 1]
    last = next((i for i in range(first, len(lines)) if lines[i].strip() == end), None)
    if last is None:
        raise ValueError(f"{source}: could not find ending line {end!r} after {start!r}")
    return "\n".join(lines[first:last + 1])


def code_sample(spec, caption):
    source, start, end, occurrence = spec
    code = excerpt(source, start, end, occurrence)
    source_url = f"{GITHUB}/blob/main/{source}"
    return f"""<figure class="code-sample">
<figcaption>{html.escape(caption)} <a href="{source_url}">{html.escape(source)}</a></figcaption>
<pre><code class="asm">{highlight(code)}</code></pre>
</figure>"""


def pager(current):
    index = next(i for i, (_, path, _) in enumerate(PAGES) if path == current)
    links = []
    if index > 0:
        title, path, _ = PAGES[index - 1]
        links.append(f'<a class="prev" href="{path}.html">&larr; {html.escape(title)}</a>')
    if index + 1 < len(PAGES):
        title, path, _ = PAGES[index + 1]
        links.append(f'<a class="next" href="{path}.html">{html.escape(title)} &rarr;</a>')
    return '<nav class="pager" aria-label="Lesson navigation">' + "".join(links) + "</nav>"


def introduction():
    cards = "".join(
        f'<a class="chapter-card" href="{path}.html"><strong>{title}</strong><span>{SUMMARIES[title]}</span></a>'
        for title, path, source in PAGES[1:]
    )
    sample = code_sample(
        ("source/main.asm", "main proc frame", "call WriteFile    ; print", 1),
        "The entry point reserves stack space, prepares Win32 arguments, and makes the call.",
    )
    return f"""<h1 id="content-title">MASM64 init</h1>
<p class="lede">Learn Windows x86-64 assembly from one small program you can build, run, single-step, and take apart. Each lesson introduces one machine-level idea, explains the rule, and then shows only the source needed to make it concrete.</p>
<note>This guide uses Microsoft Macro Assembler, the Windows x64 ABI, and the MASM64 SDK. It assumes you can read simple code, but it does not assume previous assembly experience.</note>
<div class="concept-grid" aria-label="Course mental model">
  <div class="concept"><strong>Registers</strong><span>Small, named pieces of working storage inside the CPU.</span></div>
  <div class="concept"><strong>Memory</strong><span>Bytes reached through an address and interpreted with an explicit size.</span></div>
  <div class="concept"><strong>Flags</strong><span>One-bit results that connect arithmetic to branches and loops.</span></div>
  <div class="concept"><strong>The stack</strong><span>Call space, saved state, local storage, and the boundary between procedures.</span></div>
</div>
<h2>Read an instruction left to right</h2>
<p>MASM uses <def>destination, source</def> order. In <code>mov rdx, rcx</code>, the value in <code>rcx</code> is copied into <code>rdx</code>. Registers are not variables with fixed types: the instruction and operand spelling decide the width. A <code>mov eax, 1</code> writes 32 bits; <code>mov rax, 1</code> writes 64.</p>
<p>Comments begin with <code>;</code>. Labels end with <code>:</code> and name places a jump can reach. Brackets such as <code>[rsi + rcx * 8]</code> mean “the memory at this calculated address.” Those few rules are enough to start reading real code.</p>
<h2>From entry point to operating system</h2>
<p>The program begins with a normal procedure frame. It reserves the call space required by Windows, obtains the console output handle, places four arguments in registers and one on the stack, then calls <code>WriteFile</code>.</p>
{sample}
<h2>Build and run</h2>
<ol class="steps">
  <li>Open the <def>x64 Native Tools Command Prompt for Visual Studio 2022</def>.</li>
  <li>Run <code>scripts/build.bat</code> from the repository root.</li>
  <li>Run <code>build/main.exe</code>, or open it under Visual Studio with <code>devenv build/main.exe</code>.</li>
</ol>
<h2>Follow the learning path</h2>
<p>Read the chapters in order the first time. Each one explains a small idea, shows a focused excerpt from the actual repository, and ends with rules worth remembering. The complete modules remain linked when you want to inspect them in context.</p>
<div class="chapter-grid">{cards}</div>
<author>Every example comes from <a href="{GITHUB}">IbrahimHindawi/masm64-init</a>. The website is generated from the same formatted source that builds the executable.</author>
{pager("Introduction")}"""


def lesson_page(path, title, source):
    lesson = LESSONS[title]
    sections = []
    for section_title, prose, spec, note in lesson["sections"]:
        sections.append(f"""<section class="lesson-section">
<h2>{html.escape(section_title)}</h2>
{prose}
{code_sample(spec, section_title)}
<p class="code-note"><strong>Keep in mind:</strong> {note}</p>
</section>""")
    takeaways = "".join(f"<li>{item}</li>" for item in lesson["takeaways"])
    source_url = f"{GITHUB}/blob/main/{source}"
    return f"""<h1 id="content-title">{html.escape(title)}</h1>
<p class="lede">{html.escape(SUMMARIES[title])}</p>
<p class="lesson-intro">{lesson["intro"]}</p>
{"".join(sections)}
<section class="takeaways"><h2>Keep these rules</h2><ul>{takeaways}</ul></section>
<p class="source-footer">Continue into the <a href="{source_url}">complete formatted module</a>, or run <a href="Program.html">the full program</a> under a debugger.</p>
{pager(path)}"""


def main():
    missing = [source for _, _, source in PAGES if source and not (REPO / source).exists()]
    if missing:
        raise SystemExit("missing source files: " + ", ".join(missing))
    OUT.mkdir(parents=True, exist_ok=True)
    shutil.copy(HERE / "style.css", OUT / "style.css")
    shutil.copy(HERE / "theme.js", OUT / "theme.js")
    for title, path, source in PAGES:
        body = introduction() if source is None else lesson_page(path, title, source)
        (OUT / f"{path}.html").write_text(frame(path, title, body), encoding="utf-8", newline="\n")
    (OUT / "index.html").write_text(
        '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=Introduction.html">'
        '<title>MASM64 init</title><a href="Introduction.html">MASM64 init</a>\n',
        encoding="utf-8",
        newline="\n",
    )
    print(f"{len(PAGES)} pages -> {OUT}")


if __name__ == "__main__":
    main()
