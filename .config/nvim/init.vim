set nocompatible

set rtp+=~/.config/nvim/bundle/lightline

let s:editor_root=expand("~/.config/nvim")

"https://github.com/junegunn/vim-plug

call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-easytags'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'neomake/neomake'
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'
Plug 'Shougo/neosnippet'
Plug 'scrooloose/nerdcommenter'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'ryanoasis/vim-devicons'
Plug 'plasticboy/vim-markdown'
Plug 'vim-scripts/Align'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neco-vim'
Plug 'icymind/NeoSolarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mbbill/undotree'
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
Plug 'vim-scripts/BufOnly.vim'
Plug 'hashivim/vim-vagrant'
Plug 'airblade/vim-rooter'
Plug 'takac/vim-hardtime'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler.vim'
Plug 'vim-scripts/nginx.vim'
" Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ericpruitt/tmux.vim', {'rtp': 'vim/'}
Plug 'chase/vim-ansible-yaml'
Plug 'elzr/vim-json'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'terryma/vim-expand-region'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-abolish'
Plug 'wellle/targets.vim'
Plug 'rhysd/clever-f.vim'
Plug 'mhinz/vim-grepper'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'bronson/vim-visual-star-search'
Plug 'LnL7/vim-nix'
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'sbdchd/neoformat'
Plug 'qpkorr/vim-bufkill'
Plug 'sbdchd/vim-shebang'

Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/echodoc.vim'

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'zchee/deoplete-go', { 'do': 'make' }
Plug 'benmills/vimux'
Plug 'benmills/vimux-golang'
Plug 'nsf/gocode', {'rtp': 'vim/'}

Plug 'feuerbach/vim-hs-module-name'
Plug 'neovimhaskell/haskell-vim'
"Plug 'nbouscal/vim-stylish-haskell'
"Plug 'alx741/vim-hindent'

Plug 'ElmCast/elm-vim'
Plug 'pbogut/deoplete-elm'

Plug 'johngrib/vim-game-code-break'

call plug#end()
call deoplete#enable()
call yankstack#setup()

let g:LanguageClient_autoStart=0
let g:LanguageClient_diagnosticsEnable=0
let g:LanguageClient_serverCommands = {
    \ 'haskell': ['hie', '--lsp'],
    \ }

set history=10000
set viewdir=~/.cache/nvim/view
set undofile
set undodir=~/.cache/nvim/undo
set undolevels=1000
set undoreload=10000
set nobackup
set noswapfile
set number
set exrc
set ignorecase
set incsearch
set smartcase
set nomodeline
set showcmd
set ruler
set rnu
set splitbelow
set autoread
set ttyfast
set splitright
set shiftround
set visualbell
set copyindent
set preserveindent
set expandtab
set smarttab
" set autoindent
" set smartindent
set softtabstop=0
set shiftwidth=2
set tabstop=8
set cursorline
set mouse=a
set mousehide
set showbreak=↪
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backspace=indent,eol,start
set completeopt=menuone,menu,longest
set wildignore=*.sw?,*.bak,*.orig
set wildignore+=.hg,.git,.svn
set wildignore+=*.dis,*.sbl
set wildignore+=*.o,*.obj,*.manifest
set wildignore+=*.jpg,*.gif,*.png,*.jpeg,*.ico
set wildignore+=*/patch/prev/**
set wildignore+=*/_Inline/**
set wildignore+=_live/**
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux

set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>

set encoding=utf-8
set laststatus=2
scriptencoding utf-8

" neocomplete like
set completeopt+=noinsert
" deoplete.nvim recommend
set completeopt+=noselect

" haskell lambda % issue fix
setlocal cpoptions+=M

set clipboard+=unnamedplus
" set paste
set t_Co=256 

filetype on
filetype plugin on
filetype indent on
syntax on
set background=dark
colorscheme NeoSolarized

highlight Comment cterm=italic

set colorcolumn=100
autocmd FileType gitcommit set colorcolumn=72

let mapleader = "\<space>"

nnoremap Q <NOP>

nnoremap <leader><F1> :copen<CR>
nnoremap <leader><F4> :cclose<CR>

nnoremap <F1> :lopen<CR>
nnoremap <F2> :lprev<CR>
nnoremap <F3> :lnext<CR>
nnoremap <F4> :lclose<CR>

nnoremap <F5> :%s/\s\+$//<CR>
nnoremap <F6> mzgg=G`z
nnoremap <F7> :%s/\t/  /<CR>
nnoremap <F8> :nohlsearch<CR>

nnoremap <F9> :TagbarToggle<CR>
nnoremap <F10> :Grepper -tool ag<CR> 

nnoremap ы :w<CR>
nnoremap s :w<CR>
nnoremap S :Neomake<CR>
tnoremap <Esc> <C-\><C-n>
nnoremap <leader><Esc> :HardTimeToggle<CR>

nnoremap <leader>fb :FzfBuffers<CR>
nnoremap <leader>fl :FzfLines<CR>
nnoremap <leader>ff :FzfFiles<CR>

nnoremap <leader>l i<CR><ESC>

nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

nmap g/  <plug>(GrepperOperator)
xmap g/  <plug>(GrepperOperator)
vmap g/  <plug>(GrepperOperator)

nnoremap j gj
nnoremap gj j
nnoremap k gk
nnoremap gk k
vnoremap j gj
vnoremap gj j
vnoremap k gk
vnoremap gk k

noremap n nzz
noremap N Nzz

nnoremap <leader>j <C-w><bar><C-w>_
nnoremap <leader>k <C-w>=

nnoremap <leader>R :source ~/.config/nvim/init.vim<CR>

nnoremap <leader><TAB> :tabprevious<CR>
nnoremap <leader><S-TAB> :tabnext<CR>
" nnoremap <S-TAB> :tabprev<CR>
" nnoremap <TAB> :tabnext<CR>

nnoremap <leader>T <C-w>T

nnoremap <leader>t :UpdateTags -R<CR>

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap > >>
nnoremap < <<
vnoremap > >gv
vnoremap < <gv

nnoremap p p`]
nnoremap P P`]

nnoremap <silent> <Up> :exe "resize " . (winheight(0) * 21/20)<CR>
nnoremap <silent> <Down> :exe "resize " . (winheight(0) * 20/21)<CR>
nnoremap <silent> <Right> :exe "vertical resize " . (winwidth(0) * 21/20)<CR>
nnoremap <silent> <Left> :exe "vertical resize " . (winwidth(0) * 20/21)<CR>

let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-J> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-K> :TmuxNavigateDown<cr>
nnoremap <silent> <C-L> :TmuxNavigateUp<cr>
nnoremap <silent> <C-H> :TmuxNavigateRight<cr>
" nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>

" inoremap <Up> <nop>
" vnoremap <Up> <nop>
" inoremap <Down> <nop>
" vnoremap <Down> <nop>
" inoremap <Left> <nop>
" vnoremap <Left> <nop>
" inoremap <Right> <nop>
" vnoremap <Right> <nop>

"C-r in visual mode to replace selected text
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

nnoremap <leader>u :UndotreeToggle<CR>

nnoremap <leader>gl :diffget LO<CR>
nnoremap <leader>gb :diffget BA<CR>
nnoremap <leader>gr :diffget RE<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gd :Git diff<CR>
nnoremap <leader>gg :Git log<CR>
nnoremap <leader>gm :Gblame<CR>
nnoremap <leader>gl :Gpull<CR>
nnoremap <leader>gp :Gpush<CR>

nnoremap <leader>qq :wqa<CR>
nnoremap <leader>q! :qa!<CR>
nnoremap <leader>qs :Obsession!<CR>

" nnoremap <leader>vf :VimFilerSplit<CR>
" nnoremap <leader>tf :VimFilerTab<CR>
" nnoremap <leader>f  :VimFiler<CR>

nnoremap <leader>vc :VimuxCloseRunner<CR>

nnoremap <leader>qb :BufOnly<CR>
nnoremap <leader>qt :tabonly<CR>

nnoremap <leader>b :BuffergatorToggle<CR>
nnoremap <leader>B :BuffergatorTabsToggle<CR>

"Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" highlight last inserted text
nnoremap gV `[v`]

"Delete whitespace commands
"Trailing whitespace
command! Deltrail :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
"Leading whitespace
command! Dellead %le
"Reduce multiple blank lines in a row into singular ones
command! Onelines :10,20g/^/ mo 10

nnoremap <F5> :Deltrail<CR>
nnoremap <F6> :Dellead<CR>
nnoremap <F7> :Onelines<CR>

let g:yankstack_map_keys = 0

let g:grepper               = {}
let g:grepper.tools         = ['git', 'ag', 'rg']
let g:grepper.simple_prompt = 1
let g:grepper.quickfix      = 0

let g:undotree_WindowLayout = 2

let g:hs_module_no_mappings = 1

let g:gundo_preview_bottom  = 1
let g:gundo_preview_height  = 30

let g:rooter_patterns = ['Rakefile', '.git/', '*.cabal','.stack.yaml']

let g:vim_markdown_folding_disabled = 1

let g:hardtime_default_on = 0
let g:hardtime_showmsg = 1
let g:hardtime_ignore_quickfix = 1

let g:ag_working_path_mode="r"

let g:acp_enableAtStartup = 1

let g:deoplete#enable_at_startup = 1
let g:deoplete#max_menu_width = 120

let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1

let vim_markdown_preview_github=1

set tags=.tags,./.tags
set cpoptions+=d
let g:easytags_async = 0
let g:easytags_autorecurse = 0
let g:easytags_always_enabled = 1
let g:easytags_dynamic_files = 2
let g:easytags_events = ['BufWritePost']

let g:SuperTabDefaultCompletionType = '<c-x><c-o>'
if has("gui_running")
    imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
else " no gui
    if has("unix")
        inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
    endif
endif

imap <C-space> <Plug>(neosnippet_expand_or_jump)
smap <C-space> <Plug>(neosnippet_expand_or_jump)
xmap <C-space> <Plug>(neosnippet_expand_target)
imap <C-@> <Plug>(neosnippet_expand_or_jump)
smap <C-@> <Plug>(neosnippet_expand_or_jump)
xmap <C-@> <Plug>(neosnippet_expand_target)

let g:fzf_command_prefix = 'Fzf'

let g:neosnippet#disable_runtime_snippets = {'_' : 1}
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory='~/.config/nvim/snippets'

let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_show_hidden = '1'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn|stack-work)$',
            \ 'file': '\v\.(exe|so|dll|tags|.tags)$',
            \ }

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'

let g:autosess_dir='~/.local/share/nvim/autosess'
let g:prosession_dir='~/.local/share/nvim/autosess'

let g:VimuxOrientation="v"
let g:VimuxHeight="30"

let g:buffergator_suppress_keymaps=1

let g:tmux_navigator_save_on_switch=2

let g:omni_sql_no_default_maps=1

let g:XkbSwitchEnabled=1

let g:vimfiler_as_default_explorer=1

let g:hs_module_no_mappings=1

let g:clever_f_across_no_line=1
let g:clever_f_timeout_ms=3000

let g:elm_setup_keybindings = 0

let g:hindent_on_save = 0

autocmd CompleteDone * pclose

augroup fmt
  autocmd!
  autocmd BufWritePre * Neoformat
augroup END

func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc

augroup whitespace
    autocmd!
    autocmd BufWrite *.hs :call DeleteTrailingWS()
augroup END

