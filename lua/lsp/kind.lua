local M = {}

function M.init()
  -- symbols for autocomplete
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
