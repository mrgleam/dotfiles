" Plugins setup
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'LnL7/vim-nix'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'
Plug 'justinmk/vim-sneak'
Plug 'ojroques/vim-oscyank'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
if has('nvim')
    Plug 'ndmitchell/ghcid', { 'rtp': 'plugins/nvim' }
endif
if has('nvim-0.6.1')
    " For completion
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/nvim-cmp'
    " For vsnip users
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'hrsh7th/vim-vsnip'
    " Theses two are for Typescript
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
    Plug 'neovim/nvim-lspconfig'
    " This one is used by nvim-lsp-ts-utils
    Plug 'nvim-lua/plenary.nvim'
endif
call plug#end()

" Disable netrw
let g:loaded_netrwPlugin = 1
" From https://github.com/justinmk/config/blob/15011c1e5a9104e1d842bf5fffdb820b00eea5d4/.config/nvim/lua/plugins.lua#L17
" Make gx work
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<CR>
nmap gx <Plug>NetrwBrowseX
" For dirvish
" Sort directory first then files
let g:dirvish_mode = ':sort ,^.*[\/],'
" Hide hidden files
autocmd FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _

" A good color scheme
colorscheme onedark
if (has('nvim'))
    set termguicolors
endif
set background=dark

" Show line numbers
set nu
set relativenumber
set colorcolumn=81

" To be able to switch buffer without saving
set hidden

" Add mouse support in console mode
set mouse=a

" 4 spaces is good
set tabstop=4
" I use spaces for indenting my code
set expandtab
" One tab makes 4 spaces
set shiftwidth=4
" When shifting lines, round the indentation to the nearest multiple of
" shiftwidth
set shiftround

" Turn on syntax highlight
syntax on
" Activate plugin for specific filetype and indentation
filetype plugin indent on

" Highlights search results as you type vs after you press Enter
set incsearch
" Ignore case when searching
set ignorecase
set smartcase
" Turns search highlighting on
set hlsearch

" Highlight end of line
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" F5 delete all the trailing whitespaces
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Highlight yanked text
if has('nvim-0.6.1')
    autocmd TextYankPost * lua vim.highlight.on_yank {
        \higroup="IncSearch", timeout=150, on_visual=true
        \}
endif

" Set leader key as space
let mapleader=" "

" Airline configuration
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" For vimgutter
let updatetime=100

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" For completion-nvim

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" For vim-oscyank to copy the plus register in the system clipboard as well
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | OSCYankReg + | endif

" For FZF to make Ag to search only in file content
" https://github.com/junegunn/fzf.vim/issues/346#issuecomment-655446292
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>,
    \fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
" https://github.com/junegunn/fzf.vim/issues/714
command! -bang -nargs=* Rg
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Function to run fourmolu on the buffer
function! Fourmolu(buffer) abort
    return {
    \   'command': 'fourmolu -o -XTypeApplications -m inplace %t',
    \   'read_temporary_file': 1,
    \}
endfunction

" Function to run ormolu on the buffer
function! Ormolu(buffer) abort
    return {
    \   'command': 'ormolu -o -XTypeApplications -m inplace %t',
    \   'read_temporary_file': 1,
    \}
endfunction

" Add a column by the number to show hints
set signcolumn=yes

" Activate embedded syntax highlight in vimrc file
let g:vimsyn_embed = 'l'
" Activate language servers on neovim
if has('nvim-0.6.1')
lua << EOF
  local lspconfig = require('lspconfig')

  local_settings = require('local_settings')

  -- Setup nvim-cmp
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })

  local on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

      -- Mappings.
      local opts = { noremap=true, silent=true }

      -- See `:help vim.lsp.*` for documentation on any of the below functions
      buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
      buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

      vim.api.nvim_command[[
          autocmd BufWritePre <buffer> lua local_settings.format()]]
  end

  -- Typescript configuration
  local ts_utils = require("nvim-lsp-ts-utils")
  on_attach_tsserver = function(client)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
      ts_utils.setup({ auto_inlay_hints = false });
      ts_utils.setup_client(client)
      on_attach(client)
  end

  -- null-ls is also used for Typescript
  local null_ls = require("null-ls")
  null_ls.setup({
      debug = false,
      sources = {
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.code_actions.eslint_d,
          null_ls.builtins.formatting.eslint_d
      },
      on_attach = on_attach,
  })

  local servers = {
      ccls = { on_attach = on_attach },
      hls = { on_attach = on_attach },
      tsserver = {
          on_attach = on_attach_tsserver,
          init_options = ts_utils.init_options
      }
  }
  local capabilities = require('cmp_nvim_lsp').update_capabilities(
      vim.lsp.protocol.make_client_capabilities())

  for lsp, fcts in pairs(servers) do
      lspconfig[lsp].setup({
          init_options = fcts.init_options,
          on_attach = fcts.on_attach,
          capabilities = capabilities,
          on_new_config = local_settings.on_new_config(lsp)
      })
  end

  vim.api.nvim_command[[
      autocmd BufNewFile,BufRead * lua local_settings.apply()]]
EOF
endif
