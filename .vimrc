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
  "Plugin 'Shougo/neocomplete'
  Plugin 'neoclide/coc.nvim'
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
  Plugin 'kien/ctrlp.vim'
  Plugin 'majutsushi/tagbar'
  Plugin 'dbakker/vim-projectroot'
  "Plugin 'aelesbao/vim-session'
  Plugin 'jeetsukumaran/vim-buffergator'
  Plugin 'bling/vim-bufferline'
  Plugin 'scrooloose/nerdtree'
  Plugin 'scrooloose/nerdcommenter'
  Plugin 'tpope/vim-vinegar'
  "! Plugin 'MarcWebber/SmartTag'

  " Git
  Plugin 'tpope/vim-git'
  Plugin 'tpope/vim-fugitive'
  Plugin 'taq/vim-git-branch-info'
  "Plugin 'mattn/gist-vim'
  "Plugin 'gregsexton/gitv'
  "Plugin 'airblade/vim-gitgutter'

  " Utilities
  Plugin 'tpope/vim-eunuch'
  Plugin 'tpope/vim-heroku'
  Plugin 'tpope/vim-dispatch'

  " Html & JS
  Plugin 'othree/html5.vim'
  Plugin 'tpope/vim-ragtag'
  Plugin 'mattn/emmet-vim'
  Plugin 'nono/vim-handlebars'
  "Plugin 'vim-coffee-script'
  Plugin 'vim-eco'
  Plugin 'elzr/vim-json'
  Plugin 'briancollins/vim-jst'
  Plugin 'tpope/vim-markdown'
  Plugin 'mxw/vim-jsx'
  "Plugin 'mustache/vim-mustache-handlebars'

  " Ruby
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'tpope/vim-rake'
  Plugin 'tpope/vim-rails'
  Plugin 'tpope/vim-bundler'
  Plugin 'thoughtbot/vim-rspec'
  Plugin 'ecomba/vim-ruby-refactoring'
  Plugin 'bfontaine/Brewfile.vim'

  " Elixir
  "Plugin 'elixir-lang/vim-elixir'
  
  " Rust
  Plugin 'rust-lang/rust.vim'
  Plugin 'racer-rust/vim-racer'
  Plugin 'cespare/vim-toml.git'

  " DevOps
  "Plug 'docker/docker', {'rtp': '/contrib/syntax/vim/'}
  Plugin 'ekalinin/Dockerfile.vim'
  Plugin 'hashivim/vim-terraform'
  Plugin 'hashivim/vim-vagrant'
  Plugin 'hashivim/vim-consul'
  "Plugin 'hashivim/vim-vaultproject'
  Plugin 'zimbatm/haproxy.vim'

  " C/C++
  "! Plugin 'vim-cmake-project'
  "! Plugin 'DoxygenToolkit'
  "! Plugin 'OmniCppComplete'
  "! Plugin 'Rip-Rip/clang_complete'

  " Themes
  Plugin 'Colour-Sampler-Pack'
  Plugin 'bling/vim-airline'

  " Others
  Plugin 'nginx.vim'
  Plugin 'zaiste/tmux.vim'
  "Plugin 'Rykka/riv.vim'
  "Plugin 'jvirtanen/vim-octave'
  "Plugin 'kylef/apiblueprint.vim'

  " All of your Plugins must be added before the following line
  call vundle#end()            " required
  filetype plugin indent on    " required
  " To ignore plugin indent changes, instead use:
  "filetype plugin on
  "
  " Brief help
  " :PluginList       - lists configured plugins
  " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
  " :PluginSearch foo - searches for foo; append `!` to refresh local cache
  " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
  "
  " see :h vundle for more details or wiki for FAQ
  " Put your non-Plugin stuff after this line
endfunction

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

set mouse=
"if has('mouse')
"  set mouse=a           " Enable mouse for GVim and Terminal
"  set mousehide         " Hide mouse after chars typed
"  set scrolloff=3       " show 3 lines of context around the cursor
"
"  if &term =~ "xterm" || &term =~ "screen"
"    " as of March 2013, this works:
"    set ttymouse=xterm2
"  endif
"endif

" Disable arrow keys and ESC
inoremap <Left>  <NOP>
inoremap <Right> <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>
nnoremap <Left>  <NOP>
nnoremap <Right> <NOP>
nnoremap <Up>    <NOP>
nnoremap <Down>  <NOP>
vnoremap <Left>  <NOP>
vnoremap <Right> <NOP>
vnoremap <Up>    <NOP>
vnoremap <Down>  <NOP>

set splitbelow
set splitright

set cursorline  " highlight cursor line

" Match and search
set hlsearch    " highlight search
set ignorecase  " Do case in sensitive matching with
set smartcase   " be sensitive when there's a capital letter
set incsearch   " highlight matches as you type

set background=dark
"set t_Co=256    " enable 256 colors in terminal

if !isdirectory($HOME . '/.vim/colors')
  silent !ln -s $HOME/.vim/bundle/Colour-Sampler-Pack $HOME/.vim/colors
endif

colorscheme jellybeans
"colorscheme wombat256

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
"let g:airline_theme = 'jellybeans'
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

" neocomplete
let g:neocomplete#enable_at_startup = 1

" syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" Enable omni completion.
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags

" YouCompleteMe
let g:ycm_collect_identifiers_from_tags_files = 0
let g:ycm_key_list_select_completion = ['<Down>']

" CtrlP
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]((\.(git|hg|svn))|tmp|log|target|vendor|coverage|node_modules)$',
      \ 'file': '\v\.(so|bkp|tmp|jpg|jpeg|gif|png|bmp|tiff|zip|rar|gz|jar)$',
      \ }

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

" Session
let g:session_autoload = 1
let g:session_autosave = 1

nnoremap <silent> <leader>ss :let v:this_session = 0<CR>:SaveSession<CR>

" ag - The Silver Searcher
nmap <C-S-F> :Ag! 

" JSX
let g:jsx_ext_required = 1

" RSpec
let g:rspec_command = "!RAILS_ENV=test; bin/rspec {spec}"
let g:rspec_runner = "os_x_iterm2"

map <Leader>rc :call RunCurrentSpecFile()<CR>
map <Leader>rs :call RunNearestSpec()<CR>
map <Leader>rl :call RunLastSpec()<CR>
map <Leader>ra :call RunAllSpecs()<CR>

"  }}}


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

" function to pretty format a xml document
" http://vim.wikia.com/wiki/Pretty-formatting_XML
"
function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format --recover -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  execute "set ft=" . l:origft
endfunction

command! PrettyXML call DoPrettyXML()

" Markdown to HTML
function! Markdown2HTML()
  let l:tmp_filename = '/tmp/' . shellescape(expand('%:t')) . '.html'
  echom l:tmp_filename
  silent exec 'w !markdown % > ' . l:tmp_filename
  silent exec '!xdg-open ' . l:tmp_filename . ' &'
endfunction

command! Markdown2HTML call Markdown2HTML()
nmap <leader>mh :Markdown2HTML<CR>

function! SubstituteSelection()
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
