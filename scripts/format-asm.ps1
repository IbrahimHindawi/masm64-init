[CmdletBinding()]
param(
    [switch] $Check
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repoRoot 'source'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Split-MasmLine {
    param([string] $Line)

    $quote = [char]0
    for ($i = 0; $i -lt $Line.Length; $i++) {
        $char = $Line[$i]
        if ($quote -ne [char]0) {
            if ($char -eq $quote) { $quote = [char]0 }
            continue
        }
        if ($char -eq '"' -or $char -eq "'") {
            $quote = $char
            continue
        }
        if ($char -eq ';') {
            return @($Line.Substring(0, $i), $Line.Substring($i + 1))
        }
    }
    return @($Line, $null)
}

function Normalize-Code {
    param([string] $Code)

    $builder = [System.Text.StringBuilder]::new()
    $quote = [char]0
    $pendingSpace = $false

    foreach ($char in $Code.Trim().ToCharArray()) {
        if ($quote -ne [char]0) {
            [void] $builder.Append($char)
            if ($char -eq $quote) { $quote = [char]0 }
            continue
        }
        if ($char -eq '"' -or $char -eq "'") {
            if ($pendingSpace -and $builder.Length -gt 0) { [void] $builder.Append(' ') }
            $pendingSpace = $false
            $quote = $char
            [void] $builder.Append($char)
            continue
        }
        if ([char]::IsWhiteSpace($char)) {
            $pendingSpace = $true
            continue
        }
        if ($char -eq ',') {
            while ($builder.Length -gt 0 -and $builder[$builder.Length - 1] -eq ' ') {
                $builder.Length--
            }
            [void] $builder.Append(',')
            $pendingSpace = $true
            continue
        }
        if ($pendingSpace -and $builder.Length -gt 0) { [void] $builder.Append(' ') }
        $pendingSpace = $false
        [void] $builder.Append($char)
    }
    return $builder.ToString()
}

function Normalize-Comment {
    param([AllowNull()] $Comment)

    if ($null -eq $Comment) { return $null }
    $text = $Comment.Trim()
    if ($text.EndsWith(';')) { $text = $text.Substring(0, $text.Length - 1).TrimEnd() }
    if (-not $text) { return ';' }
    if ($text -match '^-{8,}$') { return '; -----------------------------------------------------------------------------' }
    if ($text -match '^-+\[(.+?)\]-+$') { return "; --- $($Matches[1].Trim()) ---" }
    return "; $text"
}

function Pop-Block {
    param([System.Collections.Generic.List[string]] $Blocks)
    if ($Blocks.Count -gt 0) { $Blocks.RemoveAt($Blocks.Count - 1) }
}

$changed = [System.Collections.Generic.List[string]]::new()
$files = Get-ChildItem -LiteralPath $sourceRoot -Recurse -Filter '*.asm' | Sort-Object FullName

foreach ($file in $files) {
    $blocks = [System.Collections.Generic.List[string]]::new()
    $formatted = [System.Collections.Generic.List[string]]::new()

    foreach ($line in [IO.File]::ReadAllLines($file.FullName)) {
        if (-not $line.Trim()) {
            $formatted.Add('')
            continue
        }

        $parts = Split-MasmLine $line
        $code = Normalize-Code $parts[0]
        $comment = Normalize-Comment $parts[1]
        if ($code -and $comment -eq ';') { $comment = $null }
        $lower = $code.ToLowerInvariant()

        $isEndProc = $lower -match '^\S+\s+endp\b'
        $isEndStruct = $lower -match '^\S+\s+ends\b'
        $isEndMacro = $lower -eq 'endm'
        $isEndIf = $lower -eq 'endif'
        if ($isEndProc -or $isEndStruct -or $isEndMacro) {
            Pop-Block $blocks
        } elseif ($isEndIf -and $blocks.Count -gt 0 -and $blocks[$blocks.Count - 1] -eq 'if') {
            Pop-Block $blocks
        }

        $depth = $blocks.Count
        if ($lower -match '^(else|elseif)\b' -and $depth -gt 1) { $depth-- }
        $indent = ' ' * (4 * $depth)

        if (-not $code) {
            $formatted.Add($indent + $comment)
        } else {
            if ($depth -eq 0 -and $lower -match '^(byte|word|dword|qword|real4|real8|xmmword)\b') {
                $indent = '    '
            }
            $output = $indent + $code
            if ($comment) { $output += '    ' + $comment }
            $formatted.Add($output.TrimEnd())
        }

        if ($lower -match '^\S+\s+proc\b') {
            $blocks.Add('proc')
        } elseif ($lower -match '^\S+\s+struct\b') {
            $blocks.Add('struct')
        } elseif ($lower -match '^\S+\s+macro\b') {
            $blocks.Add('macro')
        } elseif ($blocks.Count -gt 0 -and $lower -match '^(repeat|while|for|forc|irp|irpc)\b') {
            $blocks.Add('macro-block')
        } elseif ($blocks.Count -gt 0 -and $lower -match '^if(?:b|nb|def|ndef|idn|idni|dif|difi)?\b') {
            $blocks.Add('if')
        }
    }

    $newText = ($formatted -join "`n") + "`n"
    $oldText = [IO.File]::ReadAllText($file.FullName).Replace("`r`n", "`n")
    if ($newText -ne $oldText) {
        $relative = [IO.Path]::GetRelativePath($repoRoot, $file.FullName)
        $changed.Add($relative)
        if (-not $Check) { [IO.File]::WriteAllText($file.FullName, $newText, $utf8NoBom) }
    }
}

if ($changed.Count -eq 0) {
    Write-Output 'MASM source formatting is current.'
    exit 0
}

$verb = if ($Check) { 'would reformat' } else { 'reformatted' }
foreach ($file in $changed) { Write-Output "$verb $file" }
if ($Check) { exit 1 }
