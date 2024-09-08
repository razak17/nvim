local filetypes = {
	"javascript",
	"javascriptreact",
	"javascript.jsx",
	"typescript",
	"typescriptreact",
	"typescript.tsx",
}

return {
	"yioneko/nvim-vtsls",
	cond = ar.lsp.typescript_lsp == 'vtsls',
	ft = filetypes,
}

