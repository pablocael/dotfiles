vim.api.nvim_set_keymap('n', '<esc><esc>', ':silent! nohls<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>S', ':Startify <CR>', { noremap = true, desc = "Toggle Startify Home Page" })
vim.api.nvim_set_keymap('n', '<Leader>x', ':bd<CR>', { noremap = true, desc = "Delete Current Buffer" })
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, desc = "Save Current Buffer" })
vim.api.nvim_set_keymap('n', '<Leader>ps', ':ProjectList<CR>', { noremap = true, desc = "Troggle Show Projects" })

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
vim.api.nvim_set_keymap('n', '<leader>t', ':NvimTreeFindFile<CR>', {noremap = true, desc = "Toggle navigator tree on current buffer", silent = true})
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

vim.api.nvim_set_keymap('n', 'ck', ':call v:lua.show_documentation()<CR>', { silent = true })

-- Latex group
vim.api.nvim_set_keymap('n', '<Leader>tc', ':VimtexCompile<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>tv', ':VimtexView<CR>', { noremap = true })
-- Git Group
vim.api.nvim_set_keymap('n', '<Leader>gs', ':Telescope lazygit<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>gb', ':Git blame<CR>', { noremap = true })

-- GoTo code navigation.
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")

-- CoC commands mappings
vim.api.nvim_set_keymap('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
vim.api.nvim_set_keymap('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })

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
vim.api.nvim_set_keymap('n', '<leader>ka', ':call QuickFixOpenAll()<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<leader>kr', ':Qfreplace<CR>', { noremap = true, silent = false })

whichkey = require("which-key")
whichkey.register({
    f = {
        name = "File", -- optional group name
    },
    c = {
        name = "Code"
    },

    g = {
        name = "Git"
    },
}, { prefix = "<leader>" })

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
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    motions = {
        count = true,
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "(+) ",  -- symbol prepended to a group
    },
})
