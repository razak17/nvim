function! ListFolds()
  let thisline = getline(v:lnum)
  if match(thisline, '^- ') >= 0
    return ">1"
  elseif match(thisline, '^  - ') >= 0
    return ">2"
  elseif match(thisline, '^    - ') >= 0
    return ">3"
  elseif match(thisline, '^      - ') >= 0
    return ">4"
  elseif match(thisline, '^        - ') >= 0
    return ">5"
  endif
  return "0"
endfunction

let g:presentationBoundsDisplayed = 0
function! DisplayPresentationBoundaries()
  if g:presentationBoundsDisplayed
    match
    set colorcolumn=0
    let g:presentationBoundsDisplayed = 0
  else
    highlight lastoflines ctermbg=darkred guibg=darkred
    match lastoflines /\%23l/
    set colorcolumn=80
    let g:presentationBoundsDisplayed = 1
  endif
endfunction

function! FindExecuteCommand()
  let line = search('\S*!'.'!:.*')
  if line > 0
    let command = substitute(getline(line), "\S*!"."!:*", "", "")
    execute "silent !". command
    execute "normal gg0"
    redraw
  endif
endfunction

function! JumpFirstBuffer()
  execute "buffer 1"
endfunction

function! JumpSecondToLastBuffer()
  execute "buffer " . (len(Buffers()) - 1)
endfunction

function! JumpLastBuffer()
  execute "buffer " . len(Buffers())
endfunction

function! Buffers()
  let l:buffers = filter(range(1, bufnr('$')), 'bufexists(v:val)')
  return l:buffers
endfunction

set foldtext=SimpleFoldText()
set fillchars=fold:\ 
function SimpleFoldText()
  let line = getline(v:foldstart)
  let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
  return sub . ' >>>>>>'
endfunction

set titlestring=%(%F%)%a\ -\ VIM%(\ %M%)
set nocursorline
set foldlevelstart=20
set foldmethod=expr
set foldexpr=ListFolds()
filetype off
syntax on
set hidden

nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
noremap <Up> <NOP>
noremap <Down> <NOP>

" presentation mode
noremap <Left> :silent bp<CR> :redraw!<CR>
noremap <Right> :silent bn<CR> :redraw!<CR>
nmap <F5> :set relativenumber! number! nocursorline ruler!<CR>
nmap <F2> :call DisplayPresentationBoundaries()<CR>
" nmap <F3> :call FindExecuteCommand()<CR>

" jump to slides
" nmap <F9> :call JumpFirstBuffer()<CR> :redraw!<CR>
" nmap <F10> :call JumpSecondToLastBuffer()<CR> :redraw!<CR>
" nmap <F11> :call JumpLastBuffer()<CR> :redraw!<CR>

" shows all open buffers and their status
nmap <leader>bl :ls<CR>
" toggles the paste mode
" nmap <C-p> :set paste!<CR>
" toggles word wrap
nmap <C-w> :set wrap! linebreak<CR>
" toggles spell checking
nmap <C-]> :set spell! spelllang=en_us<CR>
" opens the last buffer
" nnoremap Al <C-^>
" adds a line of <
" nmap <leader>AA :normal 20i<<CR>

" makes Ascii art font
nmap <leader>AF :.!toilet -w 200 -f standard<CR>
nmap <leader>Af :.!toilet -w 200 -f small<CR>
" makes Ascii border
nmap <leader>Ab :.!toilet -w 200 -f term -F border<CR>

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" execute command
nmap <leader><Enter> !!zsh<CR>

" AsciiDoc preview
nmap <leader>Av :!asciidoc-view %<CR><CR>

" Transparent editing of gpg encrypted files.
" By Wouter Hanegraaff
augroup encrypted
  au!
 
  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  " We don't want a swap file, as it writes unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile
 
  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null
 
  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")
 
  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END
