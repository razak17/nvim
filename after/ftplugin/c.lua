require("user.lsp.manager").setup "clangd"

vim.cmd [[iabbrev cc /*<CR><CR>/<Up>]]
vim.cmd [[iabbrev #i #include]]
vim.cmd [[iabbrev #d #define]]

vim.cmd [[iabbrev start #include <stdio.h>
                            \<CR>
                            \#include <stdlib.h>
                            \<CR>
                            \#include <stdbool.h>
                            \<CR>
                            \<CR>
                            \int main() {
                            \<CR>
                            \  printf("hello\n");
                            \<CR>
                            \  return 0;
                            \<CR>]]
