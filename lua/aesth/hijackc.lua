local vim = vim
local cmd = vim.cmd

cmd("highlight! LSPCurlyUnderline gui=undercurl")
cmd("highlight! LSPUnderline gui=underline")
cmd("highlight! LspDiagnosticsUnderlineHint gui=undercurl")
cmd("highlight! LspDiagnosticsUnderlineInformation gui=undercurl")
cmd("highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow")
cmd("highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red")
cmd("highlight! LspDiagnosticsSignHint guifg=yellow")
cmd("highlight! LspDiagnosticsSignInformation guifg=lightblue")
cmd("highlight! LspDiagnosticsSignWarning guifg=darkyellow")
cmd("highlight! LspDiagnosticsSignError guifg=red")

