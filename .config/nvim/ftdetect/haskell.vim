" hasktags ghc-mod hlint pointfree pointful stylish-haskell hindent
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
let g:haskell_indent_if = 3
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_before_where = -2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do = 3
let g:haskell_indent_in = 1
let g:haskell_indent_guard = 2
let g:haskell_classic_highlighting = 1

let g:haskell_tabular = 1

let g:hlintRefactor#disableDefaultKeybindings = 1

let g:neomake_haskell_enabled_makers = ['hlint','ghcmod']

let g:hoogle_search_count = 20

set tags+=/,.codex.tags;/

autocmd BufWritePost *.hs Neomake hlint

au FileType haskell vmap g=     :Tabularize /=<CR>
au FileType haskell vmap g;     :Tabularize /::<CR>
au FileType haskell vmap g.     :Tabularize /-><CR>
au FileType haskell vmap g,     :Tabularize /<-<CR>
au FileType haskell vmap g<bar> :Tabularize /<bar><CR>

let g:easytags_languages = {
            \   'haskell': {
            \     'cmd': 'hasktags -c -x -R',
            \     'fileoutput_opt': '-f',
            \   }
            \}

" au FileType haskell nmap gi :GhcModTypeInsert<CR>
" au FileType haskell nmap gf :GhcModSplitFunCase<CR>
" au FileType haskell nmap gq :GhcModType<CR>
" au FileType haskell nmap gc :GhcModTypeClear<CR>
" au FileType haskell nmap gs :GhcModSigCodegen<CR>

" au FileType haskell nmap gh :Hindent<CR>

" au FileType haskell nmap <leader>go :call ApplyOneSuggestion()<CR>
" au FileType haskell nmap <leader>ga :call ApplyAllSuggestions()<CR>

" au FileType haskell nnoremap S :Ghcid<CR>

" au BufNewFile,BufRead *.hs map <buffer> <F7> :Hoogle 
" au BufNewFile,BufRead *.hs map <buffer> <C-F7> :HoogleClose<CR>
" au BufNewFile,BufRead *.hs map <buffer> <S-F7> :HoogleLine<CR>


" au FileType haskell nnoremap <A-s> :InsertHaskellModuleName<CR>

" function! Pointfree()
    " call setline('.', split(system('pointfree '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" 
" au FileType haskell vnoremap <silent> <leader>h' :call Pointfree()<CR>
" 
" function! Pointful()
    " call setline('.', split(system('pointful '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" 
" au FileType haskell vnoremap <silent> <leader>h" :call Pointful()<CR>

" let &l:statusline = '%{empty(getqflist()) ? "[No Errors]" : "[Errors Found]"}' . (empty(&l:statusline) ? &statusline : &l:statusline)



" Install notes
"ghc-mod hlint hasktags codex hscope pointfree pointful hoogle hindent apply-refact"
"  msg "Configuring codex to search in stack..."
"  cat > $HOME/.codex <<EOF
"hackagePath: $STACK_GLOBAL_DIR/indices/Hackage/
"tagsFileHeader: false
"tagsFileSorted: false
"tagsCmd: hasktags --extendedctag --ignore-close-implementation --ctags --tags-absolute --output='\$TAGS' '\$SOURCES'
"EOF
"

" Bindings
" <leader>hh - formatting with hindent
" <leader>h. - pointfree
" <leader>h> - pointful
" <leader>tg - generate tags in project
"


"
" au FileType haskell nmap <silent> <leader>hi :GhcModTypeInsert<CR>
" au FileType haskell nmap <silent> <leader>hf :GhcModSplitFunCase<CR>
" au FileType haskell nmap <silent> <leader>ht :GhcModType<CR>
" au FileType haskell nmap <silent> <leader>hc :GhcModTypeClear<CR>
"
" au FileType haskell map S :SyntasticCheck<CR>
" "au FileType haskell map S :GhcModCheck<CR>:SyntasticCheck<CR>
"
" " hlint-refactor-vim keybindings
" au FileType haskell map <silent> <leader>hr :call ApplyOneSuggestion()<CR>
" au FileType haskell map <silent> <leader>hR :call ApplyAllSuggestions()<CR>
"
" au FileType haskell vmap a= :Tabularize /=<CR>
" au FileType haskell vmap a; :Tabularize /::<CR>
" au FileType haskell vmap a- :Tabularize /-><CR>
" au FileType haskell vmap a<bar> :Tabularize /<bar><CR>
"
" "autocmd BufWritePost *.hs GhcModCheck
"
" function! Hindent()
" if !executable("hindent")
" echom "Hindent not found in $PATH, did you installed it? (stack install hindent)"
" return
" endif
"
" silent! silent exec "!cat % | hindent"
" exec ':redraw!'
"
" if v:shell_error
" echom "Hindent: Parsing error"
" else
" silent! exec "%!hindent"
" endif
" endfunction
"
" au FileType haskell nmap <silent> <leader>hh :call Hindent()<CR>
"
" " Disable hlint-refactor-vim's default keybindings
" let g:hlintRefactor#disableDefaultKeybindings = 1
"
" let g:haskellmode_completion_ghc = 1
" autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
"
" let g:haskell_tabular = 1
"
" function! Pointfree()
" call setline('.', split(system('pointfree '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" au FileType haskell vnoremap <silent> <leader>h. :call Pointfree()<CR>
"
" function! Pointful()
" call setline('.', split(system('pointful '.shellescape(join(getline(a:firstline, a:lastline), "\n"))), "\n"))
" endfunction
" au FileType haskell vnoremap <silent> <leader>h> :call Pointful()<CR>
"
"
" set tags+=tags;/,codex.tags;/
"
" "autocmd FileType haskell let &formatprg="hindent"
"
" " Generate haskell tags with codex and hscope
" map <leader>tg :!codex update --force<CR>:call system("git-hscope -X TemplateHaskell")<CR><CR>:call LoadHscope()<CR>
"
" set csprg=hscope
" set csto=1 " search codex tags first
"
" nnoremap <silent> <C-\> :cs find c <C-R>=expand("<cword>")<CR><CR>
" " Automatically make cscope connections
" function! LoadHscope()
" let db = findfile("hscope.out", ".;")
" if (!empty(db))
" let path = strpart(db, 0, match(db, "/hscope.out$"))
" set nocscopeverbose " suppress 'duplicate connection' error
" exe "cs add " . db . " " . path
" set cscopeverbose
" endif
" endfunction
" au BufEnter /*.hs call LoadHscope()
"
" "let g:syntastic_haskell_hdevtools_args = '-g -isrc -g -Wall -g -hide-package -g transformers'
"
" let &l:statusline = '%{empty(getqflist()) ? "[No Errors]" : "[Errors Found]"}' . (empty(&l:statusline) ? &statusline : &l:statusline)
"

