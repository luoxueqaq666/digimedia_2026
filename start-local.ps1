$ErrorActionPreference = 'Stop'
$runtime = 'C:\Users\zheye\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
if (-not (Test-Path -LiteralPath $runtime)) {
    $runtime = (Get-Command node -ErrorAction Stop).Source
}
Set-Location -LiteralPath $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'dist\index.html'))) {
    throw 'Build first: pnpm install; pnpm build'
}
& $runtime 'server/index.mjs'
