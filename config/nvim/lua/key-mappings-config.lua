-- Debug
vim.keymap.set('n', '<leader>dc', require'dap'.continue)
vim.keymap.set('n', '<leader>ds', require'dap'.step_over)
vim.keymap.set('n', '<leader>di', require'dap'.step_into)
vim.keymap.set('n', '<leader>do', require'dap'.step_out)
vim.keymap.set('n', '<Leader>db', require'dap'.toggle_breakpoint)
vim.keymap.set('n', '<Leader>dB', function()
  require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end)
vim.keymap.set('n', '<Leader>lp', function()
  require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end)
vim.keymap.set('n', '<Leader>dr', require'dap'.repl.open)
vim.keymap.set('n', '<Leader>dl', require'dap'.run_last)
vim.keymap.set('n', '<leader>dv', function()
  local variable = vim.fn.expand('<cword>')
  require('dap.ui.widgets').hover(variable)
end, { desc = "DAP inspect variable under cursor" })
vim.keymap.set('n', '<esc>', function()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, true)
    end
  end
end, { desc = "DAP Close All Float Windows" })

vim.api.nvim_set_keymap('n', '<esc><esc>', ':silent! nohls<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>S', ':Startify <CR>', { noremap = true, desc = "Toggle Startify Home Page" })
vim.api.nvim_set_keymap('n', '<Leader>x', ':bd<CR>', { noremap = true, desc = "Delete Current Buffer" })
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, desc = "Save Current Buffer" })

-- Saves the file if modified and quit
vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "quit current window" })

-- Quit all opened buffers
vim.api.nvim_set_keymap("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- File Group
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fF', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap=true, desc = "Format Code", silent=false })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':lua require(\'telescope\').extensions.live_grep_args.live_grep_args()<CR>',
    { noremap = true, desc = "Grep content in Files" })
vim.api.nvim_set_keymap('n', '<Leader>a', ':Telescope buffers sort_mru=true, ignore_current_buffer=true<CR>',
    { noremap = true, desc = "Current Buffers" })
vim.api.nvim_set_keymap('n', '<Leader>fs', ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
    { noremap = true, desc = 'Toggle File Browser' }
)
vim.api.nvim_set_keymap('n', '<Leader>cd', ':lua require(\'telescope.builtin\').diagnostics({ bufnr = 0 })<CR>',
    { noremap = true, desc = 'Show LSP Diagnostics for current buffer' }
)
vim.api.nvim_set_keymap('n', '<Leader>cD', ':lua require(\'telescope.builtin\').diagnostics()<CR>',
    { noremap = true, desc = 'Show LSP Diagnostics for all files in this project' }
)


-- Clear trailing spaces
vim.api.nvim_create_user_command('Tws',
    function(opts)
        local save = vim.fn.winsaveview()
        vim.cmd('keeppatterns %s/\\s\\+$//e')
        vim.fn.winrestview(save)
    end,
    { nargs = 0 }
)
vim.api.nvim_set_keymap('n', '<Leader>fw', ':Tws<CR>', { noremap = true, desc = "Trim White Spaces" })


-- Code group
vim.api.nvim_set_keymap('n', '<Leader>cc', ':Copilot<CR>', { silent = true, desc = "Copilot code suggestions" })
vim.api.nvim_set_keymap('n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true, desc = "Rename Symbol Under Cursor", silent = true})
vim.api.nvim_set_keymap('n', '<leader>cf', ':NvimTreeFindFile<CR>', {noremap = true, desc = "Toggle navigator tree on current buffer", silent = true})
vim.api.nvim_set_keymap('n', 'cd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, desc = "Go To Definition", silent = true})
vim.api.nvim_set_keymap('n', 'cr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true, desc = "Find References", silent = true})


-- Use k to show documentation in preview window.
function show_documentation()
    if vim.bo.filetype == 'vim' or vim.bo.filetype == 'help' then
        vim.cmd('h ' .. vim.fn.expand('<cword>'))
    elseif vim.fn.exists(':CocActionAsync') == 2 and vim.fn 'coc#rpc#ready' then
        vim.fn.CocActionAsync('doHover')
    else
        vim.fn.execute('!' .. vim.bo.keywordprg .. ' ' .. vim.fn.expand('<cword>'))
    end
end

-- Git Group 
vim.api.nvim_set_keymap('n', '<Leader>gs', ':lua require(\'neogit\').open({kind=\'floating\'})<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>gb', ':Git blame<CR>', { noremap = true })

-- GoTo code navigation.
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")

-- CoC commands mappings  
vim.api.nvim_set_keymap('n', '[g', '<Plug>(coc-diagnostic-prev)', {silent = true})
vim.api.nvim_set_keymap('n', ']g', '<Plug>(coc-diagnostic-next)', {silent = true})

vim.cmd([[
function!   QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction
]])

whichkey = require("which-key")

whichkey.setup({
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
            operators = true, -- adds help for operators like d, y, ...
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true,    -- misc bindings to work with windows
            z = true,      -- bindings for folds, spelling and others prefixed with z
            g = true,      -- bindings for prefixed with g
        },
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "(+) ",  -- symbol prepended to a group
    },
})
whichkey.add(
  {
    { "<leader>c", group = "Code" },
    { "<leader>f", group = "File" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LaTeX" },
  }
)
