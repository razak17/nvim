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
    set colorcolumn=105
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

function! Buffers()
  let l:buffers = filter(range(1, bufnr('$')), 'bufexists(v:val)')
  return l:buffers
endfunction

function SimpleFoldText()
  let line = getline(v:foldstart)
  let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
  return sub . ' >>>>>>'
endfunction

set nonumber
set norelativenumber
set noruler
set nocursorline
set laststatus=0
set showtabline=0
set wrap
set textwidth=105
set colorcolumn=""
set noshowmode
set foldlevelstart=20
set foldmethod=expr
set foldexpr=ListFolds()
set foldtext=SimpleFoldText()
set fillchars=fold:\
set sidescrolloff=8
set scrolloff=8
set hidden
set spell
filetype off
syntax on

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
nmap <F3> :call FindExecuteCommand()<CR>

" background
nnoremap <leader>Bl :highlight Normal guibg=#c3eeff guifg=#030303<CR>
nnoremap <leader>Bd :highlight Normal guibg=#282a36 guifg=default<CR>

" shows all open buffers and their status
nmap <leader>bl :ls<CR>

" toggles the paste mode
" nmap <C-p> :set paste!<CR>

" toggles word wrap
nmap <C-w> :set wrap! linebreak<CR>

" toggles spell checking
nmap <C-]> :set spell! spelllang=en_us<CR>

" execute command
nmap <leader><Enter> !!zsh<CR>

" AsciiDoc preview
nmap <leader>Av :!asciidoc-view %<CR><CR>

" adds a line of <
nmap <leader>AA :normal 20i<<CR>

" makes Ascii art font
nmap <leader>Ab :.!toilet -w 200 -f term -F border<CR>
nmap <leader>AB :.!toilet -w 200 -f bfraktur<CR>
nmap <leader>Ae :.!toilet -w 200 -f emboss<CR>
nmap <leader>AE :.!toilet -w 200 -f emboss2<CR>
nmap <leader>Af :.!toilet -w 200 -f bigascii12<CR>
nmap <leader>AF :.!toilet -w 200 -f letter<CR>
nmap <leader>Am :.!toilet -w 200 -f bigmono12<CR>
nmap <leader>Aw :.!toilet -w 200 -f wideterm<CR>

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
