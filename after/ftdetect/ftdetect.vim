" csv
au BufNewFile,BufRead *.csv,*.dat,*.tsv,*.tab set ft=csv

" dockerfile
au BufNewFile,BufRead [Dd]ockerfile set ft=Dockerfile
au BufNewFile,BufRead Dockerfile* set ft=Dockerfile
au BufNewFile,BufRead [Dd]ockerfile.vim set ft=vim
au BufNewFile,BufRead *.dock set ft=Dockerfile
au BufNewFile,BufRead *.[Dd]ockerfile set ft=Dockerfile
au BufNewFile,BufRead docker-compose*.{yaml,yml}* set ft=yaml.docker-compose

" elixir
au BufNewFile,BufRead *.ex,*.exs set ft=elixir
au BufNewFile,BufRead *.eex,*.leex set ft=elixir
au BufNewFile,BufRead mix.lock set ft=elixir

" erlang
au BufNewFile,BufRead *.erl,*.hrl,rebar.config,*.app,*.app.src,*.yaws,*.xrl,*.escript set ft=erlang
au BufNewFile         *.escript 0put =\"#!/usr/bin/env escript\<nl>\<nl>\"|$

" git
au BufNewFile,BufRead *.git/{,modules/**/,worktrees/*/}{COMMIT_EDIT,TAG_EDIT,MERGE_,}MSG set ft=gitcommit
au BufNewFile,BufRead *.git/config,.gitconfig,gitconfig,.gitmodules set ft=gitconfig
au BufNewFile,BufRead */.config/git/config set ft=gitconfig
au BufNewFile,BufRead *.git/modules/**/config set ft=gitconfig
au BufNewFile,BufRead git-rebase-todo set ft=gitrebase
au BufNewFile,BufRead .gitsendemail.* set ft=gitsendemail

" graphql
au BufNewFile,BufRead *.graphql,*.graphqls,*.gql set ft=graphql

" handlebars
au  BufNewFile,BufRead *.mustache,*.hogan,*.hulk,*.hjs set ft=html.mustache syn=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim indent/handlebars.vim
au  BufNewFile,BufRead *.handlebars,*.hdbs,*.hbs,*.hb set ft=html.handlebars syn=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim

" haproxy
au BufNewFile,BufRead haproxy*.c* set ft=haproxy

" haskell
au BufNewFile,BufRead *.hsc set ft=haskell
au BufNewFile,BufRead *.bpk set ft=haskell
au BufNewFile,BufRead *.hsig set ft=haskell

" Info
au BufRead,BufNewFile *.info set ft=info

" javascript
au BufNewFile,BufRead yarn.lock set ft=yaml
au BufNewFile,BufRead *.js.map set ft=json
au BufNewFile,BufRead .eslintrc set ft=json
au BufNewFile,BufRead .prettierrc set ft=json
au BufNewFile,BufRead .jscsrc set ft=json
au BufNewFile,BufRead .babelrc set ft=json
au BufNewFile,BufRead .watchmanconfig set ft=json
au BufNewFile,BufRead *.{js,mjs,cjs,jsm,es,es6},Jakefile set ft=javascript
au BufNewFile,BufRead .tern-{project,port} set ft=json

" json
au BufNewFile,BufRead *.json set ft=json
au BufNewFile,BufRead *.jsonl set ft=json
au BufNewFile,BufRead *.jsonp set ft=json
au BufNewFile,BufRead *.geojson set ft=json
au BufNewFile,BufRead *.template set ft=json

" jsx
au BufNewFile,BufRead *.jsx set ft=javascriptreact

" julia
au BufNewFile,BufRead *.jl set ft=julia
au BufNewFile         *.jl       0put =\"#!/usr/bin/env julia\<nl>\<nl>\"|$

" log
au BufNewFile,BufRead *.log set ft=log
au BufNewFile,BufRead *_log set ft=log
" nginx
au BufNewFile,BufRead *.nginx set ft=nginx
au BufNewFile,BufRead nginx*.conf set ft=nginx
au BufNewFile,BufRead *nginx.conf set ft=nginx
au BufNewFile,BufRead */etc/nginx/* set ft=nginx
au BufNewFile,BufRead */usr/local/nginx/conf/* set ft=nginx
au BufNewFile,BufRead */nginx/*.conf set ft=nginx

" PostgreSQL
au BufNewFile,BufRead *.pgsql let b:sql_type_override='pgsql' | set ft=sql

" Python
au BufNewFile *.py     0put =\"#!/usr/bin/env python3\<nl>\<nl>\"|$

" rust
au BufNewFile,BufRead *.rs set ft=rust

" solidity
au BufNewFile,BufRead *.sol set ft=solidity

" svelte
au BufNewFile,BufRead *.svelte set ft=svelte

" tmux
au BufNewFile,BufRead {.,}tmux.conf set ft=tmux

" TOML
au BufNewFile,BufRead *.toml,Gopkg.lock,Cargo.lock,*/.cargo/config,*/.cargo/credentials,Pipfile set ft=toml

" Cargo Make
au BufRead,BufNewFile Makefile.toml set ft=cargo-make

" typescript
au BufNewFile,BufRead *.ts set ft=typescript
au BufNewFile,BufRead *.tsx set ft=typescriptreact

" vue
au BufNewFile,BufRead *.vue,*.wpy set ft=vue

" Shebang
" Auto Detection
function! s:detect_filetype(line, patterns) " {{{ try to detect current filetype
    for pattern in keys(a:patterns)
        if a:line =~# pattern
            return a:patterns[pattern]
        endif
    endfor
endfunction

" internal shebang store
let s:shebangs = {}
let g:shebang_enable_debug = 0
command! -nargs=* -bang AddShebangPattern
    \ call s:add_shebang_pattern(<f-args>, <bang>0)
function! s:add_shebang_pattern(filetype, pattern, ...) " {{{ add shebang pattern to filetype
    if a:0 == 2
        let [pre_hook, force] = [a:1, a:2]
    else
        let [pre_hook, force] = ['', a:000[-1]]
    endif
    try
        if !force && has_key(s:shebangs, a:pattern)
            throw string(a:pattern) . " is already defined, use ! to overwrite."
        endif
        let s:shebangs[a:pattern] = {
            \ 'filetype': a:filetype,
            \ 'pre_hook': pre_hook
            \ }
    catch
        echohl ErrorMsg
        echomsg "Add shebang pattern: " . v:exception
        echohl None
    endtry
endfunction

function! s:shebang() " {{{ set valid filetype based on shebang line
    try
        let line = getline(1)
        if empty(line)
            return
        endif

        let match = s:detect_filetype(line, s:shebangs)
        if empty(match)
            throw "Filetype detection failed for line: '" . line . "'"
        endif
        exe match.pre_hook
        exe 'setfiletype ' . match.filetype
    catch
        if g:shebang_enable_debug
            echohl ErrorMsg
            echomsg v:exception
            echohl None
        endif
    endtry
endfunction

" escript
AddShebangPattern! erlang        ^#!.*\s\+escript\>
AddShebangPattern! erlang        ^#!.*[s]\?bin/escript\>
" js
AddShebangPattern! javascript    ^#!.*\s\+node\>
" python
AddShebangPattern! python        ^#!.*\s\+python\>
AddShebangPattern! python        ^#!.*[s]\?bin/python\>
AddShebangPattern! python        ^#!.*\s\+pypy\>
AddShebangPattern! python        ^#!.*[s]\?bin/pypy\>
AddShebangPattern! python        ^#!.*\s\+jython\>
AddShebangPattern! python        ^#!.*[s]\?bin/jython\>
" support most of shells: bash, zsh
AddShebangPattern! sh            ^#!.*[s]\?bin/sh\>    let\ b:is_sh=1|if\ exists('b:is_bash')|unlet\ b:is_bash|endif
AddShebangPattern! sh            ^#!.*[s]\?bin/bash\>  let\ b:is_bash=1|if\ exists('b:is_sh')|unlet\ b:is_sh|endif
AddShebangPattern! sh            ^#!.*\s\+\(c\|a\|da\|k\|pdk\|mk\|tc\)\?sh\>
AddShebangPattern! zsh           ^#!.*\s\+zsh\>
AddShebangPattern! zsh           ^#!.*[s]\?bin/zsh\>

augroup shebang
    au!
    " try to detect filetype after enter to buffer
    au BufEnter * if !did_filetype() | call s:shebang() | endif
augroup END




