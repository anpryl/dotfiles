let g:go_fmt_command = "goimports"
let g:go_list_type = "quickfix"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_types = 1
let g:go_fmt_autosave = 1
let g:go_test_timeout = "30s"

" let g:go_metalinter_enabled = ['go','govet','vet','deadcode','golint','varcheck','aligncheck','errcheck','dupl','ineffassign','unconvert','goconst','gosimple','staticcheck', 'misspell']
let g:go_metalinter_enabled = ['go','govet','vet','deadcode','golint','varcheck','aligncheck','errcheck','dupl','ineffassign','unconvert','goconst','gosimple','staticcheck', 'misspell']

let g:neomake_go_enabled_makers = ['gometalinter']

" autocmd! BufWritePost *.go Neomake

let g:easytags_languages = {
\   'go': {
\     'cmd': 'gotags',
\       'args': ['-sort'],
\       'fileoutput_opt': '-f',
\       'recurse_flag': '-R'
\   }
\}

set wildignore+=*\\vendor\\**

au FileType go let $GOPATH = go#path#Detect()

au FileType go nmap <silent> gi :GoSameIdsAutoToggle<CR>
au FileType go nmap gs <Plug>(go-def-vertical)

au FileType go nmap gl <Plug>(go-metalinter)
au FileType go nmap gw <Plug>(go-rename)
au FileType go nmap gr <Plug>(go-run)
au FileType go nmap gq :GoAlternate<CR>
au FileType go nmap gr :GolangRun<CR>
au FileType go nmap gt :call GolangTestCurrentPackageIntegration()<CR>
au FileType go nmap gf :call GolangTestFocusedIntegration()<CR>

function! GolangTestCurrentPackageIntegration()
  call VimuxRunCommand("cd " . GolangCwd() . " " . ShellCommandSeperator() . " clear " . ShellCommandSeperator() . " go test -v --cover --tags=integration -timeout 25h " . GolangCurrentPackage())
endfunction

function! GolangTestFocusedIntegration()
  let test_line = search("func Test", "bs")
  ''

  if test_line > 0
    let line = getline(test_line)
    let test_name_raw = split(line, " ")[1]
    let test_name = split(test_name_raw, "(")[0]

    call VimuxRunCommand("cd " . GolangCwd() . " " . ShellCommandSeperator() . " clear " . ShellCommandSeperator() . " go test " . GolangFocusedCommand(test_name) . " -v --cover --tags=integration -timeout 24h " . GolangCurrentPackage())
  else
    echo "No test found"
  endif
endfunction
