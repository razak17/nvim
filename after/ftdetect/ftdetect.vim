" csv
au BufNewFile,BufRead *.csv,*.dat,*.tsv,*.tab set ft=csv

" dockerfile
au BufNewFile,BufRead [Dd]ockerfile set ft=false
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
au BufNewFile,BufRead .babelrc set ft=json
au BufNewFile,BufRead *.{js,mjs,cjs,jsm,es,es6},Jakefile set ft=javascript

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

" tmp, bak
au BufWritePre *.bak,*.tmp,COMMIT_EDITMSG,MERGE_MSG setlocal noundofile
au BufNewFile,BufReadPre /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim, setlocal noswapfile noundofile nobackup nowritebackup viminfo= shada="
