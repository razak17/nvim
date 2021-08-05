local M = {}

function M.setup()
  for _, sign in ipairs(rvim.lsp.diagnostics.signs.values) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  vim.lsp.protocol.CompletionItemKind = {
    "   (Text) ",
    "   (Method)",
    " ƒ  (Function)",
    "   (Constructor)",
    " ﴲ  (Field)",
    "   (Variable)",
    "   (Class)",
    " ﰮ  (Interface)",
    "   (Module)",
    " 襁 (Property)",
    "   (Unit)",
    "   (Value)",
    " 了 (Enum)",
    "   (Keyword)",
    "   (Snippet)",
    "   (Color)",
    "   (File)",
    "   (Reference)",
    "   (Folder)",
    "   (EnumMember)",
    "   (Constant)",
    " ﳤ  (Struct)",
    " 鬒 (Event)",
    "   (Operator)",
    "   (TypeParameter)",
  }
end

return M
