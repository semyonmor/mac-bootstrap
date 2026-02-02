# https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/

" Use Vim defaults instead of 100% vi compatibility
set nocompatible

" Enable syntax highlighting
syntax on

" Display line numbers
set number

" Enable smart indentation and expand tabs to spaces
set autoindent
set smartindent
set expandtab

" Set tab, softtab, and shift widths to 4 spaces (or your preference)
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Enable mouse support in the terminal
set mouse=a

" Set a color scheme (e.g., 'blue', 'darkblue', 'desert', 'koehler')
colorscheme desert

" Highlight the current line and column for better navigation
set cursorline
set cursorcolumn

" Show the status line always
set laststatus=2

" Display useful information in the status line (e.g., file path, line/col number)
set statusline=%F%M%R%h%w\ [FORMAT=%Y]\ [POS=%l,%c]\ %p%%

" Turn backup off, which can be useful when using version control like Git
set nobackup
set nowritebackup

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx