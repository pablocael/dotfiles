-- setup right lua path for finding new modules
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

function isModuleAvailable(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
vim.opt.undodir = { prefix .. "/nvim/.undo//"}
vim.opt.autoread=true
vim.opt.backupdir = {prefix .. "/nvim/.backup//"}
vim.opt.directory = { prefix .. "/nvim/.swp//"}
vim.opt.undofile=true
vim.g.directory='$HOME/.config/nvim/swapfiles'
vim.opt.listchars = {eol = '↵', tab = '>=', trail = '.'}
vim.opt.list = true
vim.opt.number=true
vim.g.python3_host_prog=vim.fn.expand("~/.pyenv/versions/neovim/bin/python3")
vim.opt.relativenumber=true
vim.opt.clipboard = 'unnamedplus'
vim.opt.nuw = 6
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab=true
vim.opt.cursorline=true
vim.opt.cursorcolumn=true

vim.g.latstatus=2
vim.g.mapleader = ","
vim.g.nofixendofline=true
vim.g.smarttab=true
vim.g.smartcase=true

vim.g.list=true
vim.g.background=dark
vim.g.hidden=true

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Appearance configurations
-- Change color of drop menu
vim.api.nvim_command('hi Pmenu ctermbg=darkgray ctermfg=white')


-- This is necessary for VimTeX to load properly. The "indent" is optional.
-- Note that most plugin managers will do this automatically.
vim.cmd('filetype plugin indent on')

-- This enables Vim's and Neovim's syntax-related features. Without this, some
-- VimTeX features will not work (see ":help vimtex-requirements" for more
-- info).
vim.cmd('syntax enable')

-- Viewer options: One may configure the viewer either by specifying a built-in
-- viewer method:
vim.g.vimtex_view_method = 'zathura'

-- Or with a generic interface:
vim.g.vimtex_view_general_viewer = 'zathura'

-- set current line color
vim.api.nvim_command('autocmd WinEnter * setlocal cursorline')
vim.api.nvim_command('autocmd WinLeave * setlocal nocursorline')
vim.api.nvim_command('highlight LineNr ctermfg=white ctermbg=236')
vim.api.nvim_command('highlight CursorColumn guibg=black ctermbg=234')
vim.api.nvim_command('highlight CursorLine guibg=black')
vim.api.nvim_command('highlight Normal ctermbg=233')
vim.cmd('highlight ExtraWhitespace ctermbg=red guibg=red')
vim.cmd('match ExtraWhitespace /\\s\\+$/')

vim.g.startify_enable_special         = 0
vim.g.startify_enable_unsafe          = 1
vim.g.startify_files_number           = 15
vim.g.startify_relative_path          = 1
vim.g.startify_change_to_dir          = 1
vim.g.startify_change_to_vcs_root     = 1
vim.g.startify_session_persistence    = 1
vim.g.startify_session_delete_buffers = 1
vim.g.startify_session_dir            = '~/.config/nvim/session'
vim.g.startify_session_savevars       = { '&makeprg' }
vim.g.startify_bookmarks              = { '~/.config/nvim/init.lua'}
vim.g.startify_list_order             = {
      { '  Bookmarks:' },
      'bookmarks',
      { '  Sessions:' },
      'sessions',
      { '  Recent files:' },
      'files',
}

vim.g.startify_custom_indices = {}
for i = 0, 9 do
    table.insert(vim.g.startify_custom_indices, tostring(i))
end
for i = string.byte('A'), string.byte('Z') do
    table.insert(vim.g.startify_custom_indices, string.char(i))
end

vim.g.startify_custom_header = {
    '             ⠀⠀⠀⠀⣠⣶⡾⠏⠉⠙⠳⢦⡀⠀⠀⠀⢠⠞⠉⠙⠲⡀',
    '             ⠀⠀⠀⣴⠿⠏⠀⠀⠀⠀⠀⠀⢳⡀⠀⡏⠀⠀⠀⠀⠀⢷',
    '             ⠀⠀⢠⣟⣋⡀⢀⣀⣀⡀⠀⣀⡀⣧⠀⢸⠀⠀⠀⠀⠀ ⡇',
    '             ⠀⠀⢸⣯⡭⠁⠸⣛⣟⠆⡴⣻⡲⣿⠀⣸⠀⠀OK⠀ ⡇',
    '             ⠀⠀⣟⣿⡭⠀⠀⠀⠀⠀⢱⠀⠀⣿⠀⢹⠀⠀⠀⠀⠀ ⡇',
    '             ⠀⠀⠙⢿⣯⠄⠀⠀⠀⢀⡀⠀⠀⡿⠀⠀⡇⠀⠀⠀⠀⡼',
    '             ⠀⠀⠀⠀⠹⣶⠆⠀⠀⠀⠀⠀⡴⠃⠀⠀⠘⠤⣄⣠⠞',
    '             ⠀⠀⠀⠀⠀⢸⣷⡦⢤⡤⢤⣞⣁',
    '             ⠀⠀⢀⣤⣴⣿⣏⠁⠀⠀⠸⣏⢯⣷⣖⣦⡀',
    '             ⢀⣾⣽⣿⣿⣿⣿⠛⢲⣶⣾⢉⡷⣿⣿⠵⣿',
    '             ⣼⣿⠍⠉⣿⡭⠉⠙⢺⣇⣼⡏⠀⠀⠀⣄⢸',
    '             ⣿⣿⣧⣀⣿.........⣀⣰⣏⣘⣆⣀',
}

function s_sy_add_bookmark(bookmark)
    if not vim.g.startify_bookmarks then
        vim.g.startify_bookmarks = {}
    end
    table.insert(vim.g.startify_bookmarks, bookmark)
end

vim.cmd('command! -nargs=1 StartifyAddBookmark call v:lua.s_sy_add_bookmark(<q-args>)')

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true


-- terraform commands 
vim.cmd([[let g:terraform_align=1]])
vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
