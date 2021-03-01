if !exists('g:vscode')
  let g:firenvim_config = {
      \ 'globalSettings': {
          \ 'alt': 'all',
      \  },
      \ 'localSettings': {
          \ '.*': {
              \ 'cmdline': 'neovim',
              \ 'priority': 0,
              \ 'selector': 'textarea',
              \ 'takeover': 'always',
          \ },
      \ }
  \ }
  let fc = g:firenvim_config['localSettings']
  let fc['https://studio.youtube.com.*'] = { 'takeover': 'never', 'priority': 1 }
  let fc['https?://instagram.com.*'] = { 'takeover': 'never', 'priority': 1 }
  let fc['https?://twitter.com.*'] = { 'takeover': 'never', 'priority': 1 }
  let fc['https://.*gmail.com.*'] = { 'takeover': 'never', 'priority': 1 }
  let fc['https?://.*twitch.tv.*'] = { 'takeover': 'never', 'priority': 1 }

  function! s:IsFirenvimActive(event) abort
    if !exists('*nvim_get_chan_info')
      return 0
    endif
    let l:ui = nvim_get_chan_info(a:event.chan)
    return has_key(l:ui, 'client') && has_key(l:ui.client, 'name') &&
        \ l:ui.client.name =~? 'Firenvim'
  endfunction

  function! OnUIEnter(event) abort
    if s:IsFirenvimActive(a:event)
      set laststatus=0
    endif
  endfunction

  augroup THE_PRIMEAGEN
    autocmd!
    au BufEnter github.com_*.txt set filetype=markdown
    au BufEnter txti.es_*.txt set filetype=typescript
    au BufEnter stackoverflow_*.txt filetype=markdown
    autocmd UIEnter * call OnUIEnter(deepcopy(v:event))
  augroup END
end
