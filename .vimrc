" vim:fileencoding=utf-8:ft=vim:foldmethod=marker

" Plugins " {{{

function! SetupVundle()
  filetype off        " required !

  let install_path = expand('$HOME') . '/.vim/bundle/Vundle.vim'
  if !filereadable(install_path.'/.git/config')
    exec '!git clone https://github.com/VundleVim/Vundle.vim '.install_path
  endif

  let g:vundle_default_git_proto='git'

  exec 'set runtimepath+='.install_path
  call vundle#begin()

  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'

  " Editor extensions
  Plugin 'terryma/vim-multiple-cursors'
  Plugin 'maxbrunsfeld/vim-yankstack'
  Plugin 'sjl/gundo.vim'

  " Snippets
  Plugin 'garbas/vim-snipmate'
  Plugin 'honza/vim-snippets'
  Plugin 'scrooloose/snipmate-snippets'

  " Syntax and code editing aid
  Plugin 'editorconfig/editorconfig-vim'
  Plugin 'tpope/vim-surround'
  Plugin 'tpope/vim-repeat'
  Plugin 'tpope/vim-endwise'
  Plugin 'tpope/vim-abolish'
  Plugin 'tpope/vim-unimpaired'
  Plugin 'jiangmiao/auto-pairs'
  Plugin 'scrooloose/syntastic'
  Plugin 'neomake/neomake'
  Plugin 'neoclide/coc.nvim', {'branch': 'release'}
  Plugin 'Konfekt/FastFold'
  Plugin 'Konfekt/FoldText'

  Plugin 'rgarver/Kwbd.vim'
  Plugin 'MarcWeber/vim-addon-mw-utils'
  Plugin 'tomtom/tlib_vim'
  Plugin 'tsaleh/vim-align'
  "Plugin 'sjl/splice.vim'
  Plugin 'YankRing.vim'
  "Plugin 'easymotion/vim-easymotion'

  " Buffer/session manipulation and file search
  Plugin 'L9'
  Plugin 'rking/ag.vim'
  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'majutsushi/tagbar'
  Plugin 'dbakker/vim-projectroot'
  Plugin 'jeetsukumaran/vim-buffergator'
  Plugin 'bling/vim-bufferline'
  Plugin 'scrooloose/nerdtree'
  Plugin 'scrooloose/nerdcommenter'
  Plugin 'tpope/vim-vinegar'

  " Git
  Plugin 'tpope/vim-git'
  Plugin 'tpope/vim-fugitive'
  Plugin 'taq/vim-git-branch-info'

  " Utilities
  Plugin 'tpope/vim-eunuch'
  Plugin 'tpope/vim-dispatch'

  " Languages
  Plugin 'sheerun/vim-polyglot'

  " Html & JS
  Plugin 'tpope/vim-ragtag'
  Plugin 'mattn/emmet-vim'
  Plugin 'vim-eco'

  " Rust
  Plugin 'racer-rust/vim-racer'

  Plugin 'hashivim/vim-vagrant'
  Plugin 'fladson/vim-kitty'

  " Themes
  Plugin 'bling/vim-airline'
  Plugin 'dracula/vim', { 'name': 'dracula' }
  Plugin 'catppuccin/vim', { 'name': 'catppuccin' }
  "Plugin 'folke/tokyonight.nvim'  Works only on NeoVim"

  " All of your Plugins must be added before the following line
  call vundle#end()            " required
  filetype plugin indent on    " required
  " To ignore plugin indent changes, instead use:
  "filetype plugin on
  "
  " Brief help
  " :BundleList       - lists configured plugins
  " :BundleInstall    - installs plugins; append `!` to update or just :PluginUpdate
  " :BundleSearch foo - searches for foo; append `!` to refresh local cache
  " :BundleClean      - confirms removal of unused plugins; append `!` to auto-approve removal
  "
  " see :h vundle for more details or wiki for FAQ
  " Put your non-Plugin stuff after this line
endfunction

" "}}}

" General "{{{

if !isdirectory($HOME . '/.vim')
  call mkdir($HOME . '/.vim/tmp', "p")
endif

call SetupVundle() " initialize plugin manager

set nocompatible " be iMproved

set history=100

" persistent undo
set undofile
set undodir=~/.vim/tmp

" backup options
set directory=~/.vim/tmp
set nobackup
set nowritebackup

" handle multiple buffers better
set hidden

" enable shared clipboard between X and vim
"set clipboard+=unnamed

" prevent vim from connecting to the X server
set clipboard=autoselect,exclude:.*

set shellcmdflag=-dfc

if has("multi_byte")
  set encoding=utf-8             " better default than latin1
  setglobal fileencoding=utf-8   " change default file encoding when writing new files

  if &termencoding == ""
    let &termencoding = &encoding
  endif
endif

" Sends more characters to terminal, improving window redraw
set ttyfast
" "}}}

" Formatting "{{{

set fo-=t " Do no auto-wrap text using textwidth (does not apply to comments)

set nowrap
set textwidth=0 " Don't wrap lines by default

set wildmenu              " enhanced command line completion
set wildmode=longest,list " At command line, complete longest common string, then list alternatives.

set backspace=indent,eol,start " more powerful backspacing

set tabstop=2     " Set the default tabstop
set softtabstop=2
set shiftwidth=2  " Set the default shift width for indents
set expandtab     " Make tabs into spaces (set by tabstop)
set smarttab      " Smarter tab levels
set smartindent   " smart (language based) auto indent

set autoindent
set cindent
set cinoptions=:s,ps,ts,cs,j1,J1
set cinwords=if,else,while,do,for,switch,case

set linebreak                " don't break wrapped lines on words
set fileformats=unix,mac,dos " EOL format

syntax on

filetype on        " auto detect the type of file that is being edited
filetype indent on " enable file type detection
filetype plugin on " enable filetype-based indentation

setglobal fileencoding=utf-8
" "}}}

" Visual "{{{

set showmatch    " Show matching brackets.
set matchtime=5  " Bracket blinking.

let &t_ut=''     " Fix for Kitty background erase (https://sw.kovidgoyal.net/kitty/faq.html#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim)

" Disable any annoying bells.
set noerrorbells visualbell t_vb=
if has("autocmd") && has("gui_running")
  au GUIEnter * set visualbell t_vb=
endif

set ruler         " Show ruler
set showcmd       " Display an incomplete command in the lower right corner of the Vim window
set shortmess=atI " Shortens messages
set number        " show line numbers

set list          " Display unprintable characters f12 - switches
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»,precedes:« " use the same symbols as TextMate for tabstops and EOLs

" Folding
set foldmethod=syntax
set foldcolumn=1
set foldlevelstart=20
set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds

let javaScript_fold=0         " JavaScript
let perl_fold=1               " Perl
let php_folding=1             " PHP
let r_syntax_folding=1        " R
let ruby_fold=1               " Ruby
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=0      " XML

"set mouse=
if has('mouse')
  set mouse=a           " Enable mouse for GVim and Terminal
  set mousehide         " Hide mouse after chars typed
  set mousemodel=popup  " Right mouse button pops up a menu
  set scrolloff=3       " show 3 lines of context around the cursor

  if &term =~ "xterm" || &term =~ "screen"
    " as of March 2013, this works:
    set ttymouse=xterm2
  endif
endif

set splitbelow
set splitright

set cursorline  " highlight cursor line

" Match and search
set hlsearch    " highlight search
set ignorecase  " Do case in sensitive matching with
set smartcase   " be sensitive when there's a capital letter
set incsearch   " highlight matches as you type

set background=dark
set termguicolors

function! SafeColorscheme(name, default) abort
  let pat = 'colors/'.a:name.'.vim'
  if !empty(globpath(&rtp, pat))
    execute 'colorscheme ' . a:name
  else
    execute 'colorscheme ' . a:default
  endif
endfunction

call SafeColorscheme('catppuccin_macchiato', 'slate')

set laststatus=2  " Always show status line.
" Useful status information at bottom of screen
if exists("*GitBranchInfoString")
  set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}[fo=%{&fo}]%k\ %{GitBranchInfoString()}\ %=%-16(\ %l,%c-%v\ %)%P
else
  set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}[fo=%{&fo}]%k%=%-16(\ %l,%c-%v\ %)%P
endif
" "}}}

" Command and Auto commands " {{{

" Write as sudo
command W w !sudo tee %

" Auto commands
if has("autocmd")
  augroup vimrc_general_commands
    autocmd!

    "au BufWritePre * call <SID>StripTrailingWhitespaces()
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g'\"" | endif " restore position in file
  augroup END

  augroup filetype_detect
    autocmd!

    au BufRead,BufNewFile {*.zsh*}                                              set ft=zsh
    au BufRead,BufNewFile {*.json,*.json.base,*.ign}                            set ft=json
    au BufRead,BufNewFile {Gemfile,Rakefile,Capfile,Guardfile,*.rake,config.ru} set ft=ruby
    au BufRead,BufNewFile {*.md,*.mkd,*.markdown}                               set ft=markdown
    au BufRead,BufNewFile {COMMIT_EDITMSG,TAG_EDITMSG}                          set ft=gitcommit
    au BufRead,BufNewFile {*/etc/nginx/*,/opt/nginx/conf/*}                     set ft=nginx
    au BufRead,BufNewFile {*.sbt}                                               set ft=scala
    au BufRead,BufNewFile {*.m,*.oct,*octaverc}                                 set ft=octave
    au BufRead,BufNewFile {*.ensime}                                            set ft=lisp
    au BufRead,BufNewFile {*tmux.conf}                                          set ft=tmux
    au BufRead,BufNewFile {*.edn,*.cljx,*.cljs.hl,*.boot}                       set ft=clojure
    au BufRead,BufNewFile {*/.kube/config}                                      set ft=yaml
    au BufRead,BufNewFile {*Brewfile*}                                          set ft=ruby syntax=brewfile
    au BufRead,BufNewFile {*.tf.erb}                                            set ft=terraform
    au BufRead,BufNewFile {.envrc}                                              set ft=sh
  augroup END

  augroup filetype_customs
    autocmd!

    au FileType vim,diff let b:noStripWhitespace=1

    au FileType gitcommit     setlocal spell textwidth=72
    au FileType markdown,rst  setlocal spell textwidth=80

    au FileType nginx setlocal tabstop=2 softtabstop=2 shiftwidth=2

    au FileType ruby,eruby nmap <F6> :R<CR>
    au FileType ruby,eruby nmap <S-F6> <C-W>v:R<CR>
    au FileType ruby,eruby nmap <F7> :A<CR>
    au FileType ruby,eruby nmap <S-F7> <C-W>v:A<CR>

    if exists("+omnifunc")
      au Filetype octave if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
    endif

    au FileType octave setlocal keywordprg=info\ octave\ --vi-keys\ --index-search
  augroup END

  augroup text_wrap
    autocmd!
    autocmd BufEnter * call HighlightOverLength()
  augroup END

  "augroup RainbowParentheses
    "au VimEnter * RainbowParenthesesToggle
    "au Syntax * RainbowParenthesesLoadRound
    "au Syntax * RainbowParenthesesLoadSquare
    "au Syntax * RainbowParenthesesLoadBraces
  "augroup END
endif
" " }}}

" Key mappings " {{{

let mapleader=","
let maplocalleader=","

" save keystrokes, so we don't need to press the Shift key
nnoremap ; :

" Tabs
nnoremap <silent> <S-Tab> :tabprevious<CR>
nnoremap <silent> <Tab> :tabnext<CR>

" Buffers
" delete all hidden buffers
map <leader>bw :call Wipeout()<CR>
" keep window on buffer delete
nmap <silent> <LocalLeader>bd <Plug>Kwbd
" switch to last used buffer
nnoremap <leader>l :e#<CR>
" open last used buffer in vertical split
nnoremap <leader>v :vsplit#<CR>

" Split line(opposite to S-J joining line)
nnoremap <silent> <C-J> gea<CR><ESC>ew

" Hard-wrap paragraphs of text
nnoremap <leader>= gqip

" searches for the word under cursor on buffer
nnoremap # :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>
nnoremap * #

" visual substitution
vnoremap <silent> <C-H> y:execute "%s/".escape(@",'[]/')."//g"<Left><Left><Left>
" clears the search register
nnoremap <silent> <leader>/ :nohlsearch<CR>

" Control+S and Control+Q are flow-control characters: disable them in your terminal settings.
" $ stty -ixon -ixoff
noremap <silent> <C-S> :update<CR>
vnoremap <silent> <C-S> <C-C>:update<CR>
inoremap <silent> <C-S> <C-O>:update<CR>

" show/Hide hidden Chars
map <silent> <F12> :set invlist<CR>

" clipboard
nnoremap <silent> <Leader>y "*yy
vnoremap <silent> <Leader> "*y

noremap <Leader>ws :call StripTrailingWhitespaces()<CR>

" GVim specific "{{{
if has("gui_running")
  set guifont=Monaco\ for\ Powerline\ 10

  set guioptions-=tT
  set guioptions+=agm
  set winaltkeys=no

  inoremap <C-S-V> <ESC>"+gpa
  vnoremap <C-S-C> "+y

  " Window navigation
  inoremap <silent> <C-Tab> <C-O><C-W>w
  inoremap <silent> <C-S-Tab> <C-O><C-W>W
  noremap <silent> <C-Tab> <C-W>w
  noremap <silent> <C-S-Tab> <C-W>W
endif
" " }}}

" " }}}

" Plugins Settings " {{{

" Powerline
let g:Powerline_symbols = 'fancy'

" vim-airline
let g:airline_theme = 'catppuccin_mocha'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0

"let g:airline_section_x = '%{rvm#statusline()}'

" Bufferline
"let g:bufferline_active_buffer_left = '['
"let g:bufferline_active_buffer_right = ']'
let g:bufferline_modified = '+'
let g:bufferline_rotate = 1
let g:bufferline_fixed_index =  1
let g:bufferline_echo = 0

" Gundo
nnoremap <leader>u :GundoToggle<CR>

" NERDTree
let NERDChristimasTree=1
let NERDTreeAutoCenter=1
let NERDTreeChDirMode=2
let NERDTreeMinimalUI=1
let NERDTreeWinSize=40
"let NERDTreeHijackNetrw=1

noremap <silent> <F9> :NERDTreeToggle<CR>
noremap <silent> <S-F9> :NERDTreeFind<CR>
noremap <silent> <C-k><C-b> :NERDTreeFind<CR>

" neomake
autocmd! BufWritePost * Neomake

" syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" coc.vim
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" Enable omni completion.
"autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags

" CtrlP
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]((\.(git|hg|svn|history))|tmp|log|target|vendor|coverage|node_modules)$',
  \ 'file': '\v\.(exe|so|dll|bkp|tmp|jpg|jpeg|gif|png|bmp|tiff|zip|rar|gz|jar)$',
  \ 'link': '',
  \ }

if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
  let g:ctrlp_clear_cache_on_exit = 0
endif

" ragtag
let g:ragtag_global_maps = 1

" GitGutter
let g:gitgutter_enabled = 1

nnoremap <silent> <S-F12> :call ToggleGitGutterLineHighlights()<CR>
inoremap <silent> <S-F12> <C-O>:call ToggleGitGutterLineHighlights()<CR>
vnoremap <silent> <S-F12> :call ToggleGitGutterLineHighlights()<CR>

" SnipMate
"inoremap <TAB> <Plug>snipMateNextOrTrigger
"snoremap <TAB> <Plug>snipMateNextOrTrigger
 let g:snipMate = { 'snippet_version' : 1 }

" Emmet
let g:user_emmet_leader_key = '<c-y>'
let g:use_emet_complete_tag = 1

" vim-json
let g:vim_json_syntax_conceal = 0

" AutoPairs
let g:AutoPairsShortcutFastWrap='<C-E>'

" YankRing mapping
nnoremap <leader>y :YRShow<CR>

" Tagbar
nnoremap <silent> <F8> :TagbarToggle<CR>

" Buffergator
nnoremap <silent> <leader>bg :BuffergatorToggle<CR>

" ag - The Silver Searcher
nmap <C-S-F> :Ag! 

" JSX
let g:jsx_ext_required = 1

"  }}}

" Helper functions " {{{

" function to remove trailing white space (while saving cursor position)
" http://vimcasts.org/episodes/tidying-whitespace/
"
function! StripTrailingWhitespaces()
  " Only strip if the b:noStripeWhitespace variable isn't set
  if exists("b:noStripWhitespace")
    return
  endif

  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" function to delete all hidden buffers
function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " do not wipeout unlisted buffers"
    for l:buf in copy(l:buffers)
      if getbufvar(l:buf, "&buflisted") == 0
        call remove(l:buffers, index(l:buffers, l:buf))
      endif
    endfor

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction

function! HighlightOverLength()
  if &textwidth > 0
    let l:guibg = "#191919"
    let l:match_group = "OverLength"
    let l:pattern = "\\v%" . &textwidth . "v.*"
    let l:priority = 1

    exec "highlight " . l:match_group . " ctermbg=darkgrey guibg=" . l:guibg

    if exists("w:overlength_match_id")
      call matchdelete(w:overlength_match_id)
      call matchadd(l:match_group, l:pattern, l:priority, w:overlength_match_id)
    else
      let w:overlength_match_id = matchadd(l:match_group, l:pattern, l:priority)
    endif

  elseif exists("w:overlength_match_id")
    call matchdelete(w:overlength_match_id)
    unlet! w:overlength_match_id

  endif
endfunction

" "}}}
