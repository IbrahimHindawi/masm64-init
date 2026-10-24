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
sete setne bswap cdq cqo xchg nop
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


def introduction():
    cards = "".join(
        f'<a class="chapter-card" href="{path}.html"><strong>{title}</strong><span>{SUMMARIES[title]}</span></a>'
        for title, path, source in PAGES[1:9]
    )
    return f"""<h1 id="content-title">MASM64 init</h1>
<p class="lede">A small, executable introduction to x86-64 assembly on Windows. Start with a program that prints to the console, then read one focused module at a time.</p>
<note>The project uses Microsoft Macro Assembler, the Windows x64 calling convention, and the MASM64 SDK. It stays close to the machine while keeping each example runnable.</note>
<h2>Build and run</h2>
<ol class="steps">
  <li>Open the <def>x64 Native Tools Command Prompt for Visual Studio 2022</def>.</li>
  <li>Run <code>scripts/build.bat</code> from the repository root.</li>
  <li>Run <code>build/main.exe</code>, or open it under Visual Studio with <code>devenv build/main.exe</code>.</li>
</ol>
<h2>Read it in order</h2>
<p>Each chapter is a real <code>.asm</code> module included by <a href="Program.html">the full program</a>. The prose here gives you the route; the annotated source is the lesson.</p>
<div class="chapter-grid">{cards}</div>
<h2>What you will learn</h2>
<ul>
  <li>the register families and the difference between volatile and preserved registers;</li>
  <li>how values move between immediates, registers, memory, arrays, and structures;</li>
  <li>how flags, comparisons, branches, loops, procedures, and macros fit together;</li>
  <li>how a Windows x64 program passes arguments, reserves stack space, calls Win32, and returns.</li>
</ul>
<author>Source: <a href="{GITHUB}">IbrahimHindawi/masm64-init</a>. The guide is generated directly from the repository's annotated assembly modules.</author>"""


def source_page(title, source):
    file = REPO / source
    text = file.read_text(encoding="utf-8", errors="replace")
    lines = text.rstrip("\n").count("\n") + 1
    numbers = "\n".join(str(i) for i in range(1, lines + 1))
    return f"""<h1 id="content-title">{html.escape(title)}</h1>
<p class="lede">{html.escape(SUMMARIES[title])}</p>
<p class="code-path"><a href="{GITHUB}/blob/main/{source}">{source}</a> &middot; {lines} lines</p>
<div class="code-view"><pre class="lines" aria-hidden="true">{numbers}</pre><pre><code class="asm">{highlight(text)}</code></pre></div>
<author>This is the repository source, presented as the lesson. Build and run <a href="Program.html">the full program</a> to exercise the chapter modules together.</author>"""


def main():
    missing = [source for _, _, source in PAGES if source and not (REPO / source).exists()]
    if missing:
        raise SystemExit("missing source files: " + ", ".join(missing))
    OUT.mkdir(parents=True, exist_ok=True)
    shutil.copy(HERE / "style.css", OUT / "style.css")
    shutil.copy(HERE / "theme.js", OUT / "theme.js")
    for title, path, source in PAGES:
        body = introduction() if source is None else source_page(title, source)
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
