" let g:deoplete#omni#functions = {}
" let g:deoplete#sources = {}
" let g:deoplete#sources._ = ['file', 'neosnippet']
" let g:deoplete#omni#input_patterns = {}
" 
" let g:deoplete#omni#functions.elm = ['elm#Complete']
" let g:deoplete#omni#input_patterns.elm = '[^ \t]+'
" let g:deoplete#sources.elm = ['omni'] + g:deoplete#sources._

" define elm-make maker
let g:neomake_elm_elmmake_maker = {
  \ 'exe': 'elm-make',
  \ 'buffer_output': 1,
  \ 'errorformat':
    \ '%E%.%#--\ %m\ -%# %f' . ',' .
    \ '%C%l\\|' . ',' .
    \ '%C%.%#'
\ }

" enable elm-make on elm
let g:neomake_elm_enabled_makers = [ 'elmmake' ]

" use neomake to build different files
augroup neomake_neomake_build
  autocmd! BufRead,BufWritePost *.elm Neomake elmmake
augroup end

