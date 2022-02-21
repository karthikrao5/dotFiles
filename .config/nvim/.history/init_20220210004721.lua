local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')
    Plug 'tpope/vim-sensible'

    -- https://github.com/ellisonleao/gruvbox.nvim
    Plug 'ellisonleao/gruvbox.nvim'

    Plug 'https://github.com/vim-airline/vim-airline'
    Plug 'https://github.com/preservim/nerdtree'
    Plug 'christoomey/vim-system-copy'

    -- JS/TS styling and autocompleted
    Plug 'pangloss/vim-javascript'
    Plug 'leafgarland/typescript-vim'
    Plug 'peitalin/vim-jsx-typescript'
    Plug 'styled-components/vim-styled-components', { branch: 'main' }
    Plug 'jparise/vim-graphql'

    Plug 'neoclide/coc.nvim', {branch: 'release'}


    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'airblade/vim-gitgutter'

    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { do: { -> fzf#install() } }
    Plug 'fatih/vim-go', { do: ':GoUpdateBinaries' }
vim.call('plug#end')

vim.opt.termguicolors = true
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])