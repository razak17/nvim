if !exists('g:vscode')
  " Helping nvim detect filetype
  let s:additional_filetypes = {
  \   'zsh': '*.zsh*',
  \   'sh': '.env.*',
  \   'bnf': '*.bnf',
  \   'json': '*.webmanifest',
  \   'rest': '*.http',
  \   'elixir': ['*.exs', '*.ex'],
  \ }

  augroup file_types
  autocmd!
  for kv in items(s:additional_filetypes)
    if type(kv[1]) == v:t_list
      for ext in kv[1]
        execute 'autocmd BufNewFile,BufRead ' . ext
          \ . ' setlocal filetype=' . kv[0]
      endfor
    else
      execute 'autocmd BufNewFile,BufRead ' . kv[1]
        \ . ' setlocal filetype=' . kv[0]
    endif
  endfor

  " json 5 comment
  autocmd FileType json
                 \ syntax region Comment start="//" end="$" |
                 \ syntax region Comment start="/\*" end="\*/" |
                 \ setlocal commentstring=//\ %s
  augroup END

  " Filetypes names where q does :q<CR>
  let g:q_close_ft = ['help', 'list', 'fugitive']
  let g:esc_close_ft = ['NvimTree']
  let g:disable_line_numbers = [
  \   'nerdtree', 'NvimTree', 'help',
  \   'list', 'clap_input', 'TelescopePrompt',
  \ ]

  if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  endif

  " Binds
  vnoremap <Leader>rev :s/\%V.\+\%V./\=RevStr(submatch(0))<CR>gv

  " shake_case -> camelCase
  nnoremap <silent> <Leader>Cc viw<Leader>cc
  vnoremap <silent> <Leader>Cc :s/\%V_\(.\)/\U\1/g<CR>

  " snake_case -> PascalCase
  nnoremap <silent> <Leader>CP viw<Leader>CP
  vnoremap <silent> <Leader>CP <Leader>cc`<vU

  " camelCase/PascalCase -> snake_case
  nmap <silent> <Leader>Cs viw<Leader>Cs
  vnoremap <silent> <Leader>Cs :s/\%V\(\l\)\(\u\)/\1_\l\2/g<CR>`<vu

  " snake_case -> kebab-case
  " TODO: implement

  command! -nargs=0 RestartLsp lua require 'utils.funcs'.restart_lsp()
  command! -nargs=0 LspLog execute 'edit ' . luaeval('vim.lsp.get_log_path()')

  augroup Razak_Mo
    autocmd!
    autocmd! FileType which_key
    autocmd  FileType which_key set laststatus=0 noshowmode noruler
     \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler
  augroup END
endif
