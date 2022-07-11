vim.cmd([[
" dockerfile
au BufNewFile,BufRead [Dd]ockerfile set ft=false
au BufNewFile,BufRead docker-compose*.{yaml,yml}* set ft=yaml.docker-compose
" erlang
au BufNewFile         *.escript 0put =\"#!/usr/bin/env escript\<nl>\<nl>\"|$
" git
au BufNewFile,BufRead *.git/{,modules/**/,worktrees/*/}{COMMIT_EDIT,TAG_EDIT,MERGE_,}MSG set ft=gitcommit
au BufNewFile,BufRead *.git/config,.gitconfig,gitconfig,.gitmodules set ft=gitconfig
au BufNewFile,BufRead */.config/git/config set ft=gitconfig
au BufNewFile,BufRead *.git/modules/**/config set ft=gitconfig
au BufNewFile,BufRead git-rebase-todo set ft=gitrebase
" handlebars
au  BufNewFile,BufRead *.mustache,*.hogan,*.hulk,*.hjs set ft=html.mustache syn=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim indent/handlebars.vim
au  BufNewFile,BufRead *.handlebars,*.hdbs,*.hbs,*.hb set ft=html.handlebars syn=mustache | runtime! ftplugin/mustache.vim ftplugin/mustache*.vim ftplugin/mustache/*.vim
" haproxy
au BufNewFile,BufRead haproxy*.c* set ft=haproxy
" javascript
au BufNewFile,BufRead *.{js,mjs,cjs,jsm,es,es6},Jakefile set ft=javascript
" nginx
au BufNewFile,BufRead */etc/nginx/* set ft=nginx
au BufNewFile,BufRead */usr/local/nginx/conf/* set ft=nginx
au BufNewFile,BufRead */nginx/*.conf set ft=nginx
" PostgreSQL
au BufNewFile,BufRead *.pgsql let b:sql_type_override='pgsql' | set ft=sql
" TOML
au BufNewFile,BufRead *.toml,Gopkg.lock,Cargo.lock,*/.cargo/config,*/.cargo/credentials,Pipfile set ft=toml
" tmp, bak
au BufWritePre *.bak,*.tmp,COMMIT_EDITMSG,MERGE_MSG setlocal noundofile
au BufNewFile,BufReadPre /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim, setlocal noswapfile noundofile nobackup nowritebackup viminfo= shada="
]])
