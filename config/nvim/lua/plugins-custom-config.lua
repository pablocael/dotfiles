if isModuleAvailable("toggleterm") then
    require("toggleterm").setup{
      open_mapping = [[<c-\>]],
      auto_scroll = true, -- automatically scroll to the bottom on terminal output
      -- This field is only relevant if direction is set to 'float'
      direction = 'float',
      float_opts = {
        border = 'curved',
        -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
        winblend = 3,
        title_pos = 'center'
      },
      winbar = {
        enabled = false,
        name_formatter = function(term) --  term: Terminal
          return term.name
        end
      },
    }
end

if isModuleAvailable("cmp") then
    -- Set up nvim-cmp.
    local cmp = require("cmp")

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to false to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
      }, {
        { name = 'buffer' },
      })
    })

end

if isModuleAvailable("neotest") then
    require("neotest").setup({
        adapters = {
            require("neotest-python")({
                -- Extra arguments for nvim-dap configuration
                -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
                dap = { justMyCode = false },
                -- Command line arguments for runner
                -- Can also be a function to return dynamic values
                args = { "--log-level", "DEBUG" },
                -- Runner to use. Will use pytest if available by default.
                -- Can be a function to return dynamic value.
                runner = "pytest"

            })
        }
    })
end

-- LSP Configs
if isModuleAvailable("lspconfig") then
    local lsp = require('lspconfig')
    local maxLineLength = 120
    lsp.pylsp.setup {
        on_attach = function(client, bufnr)
            local opts = { noremap = true, silent = true }
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        end,
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = { enabled = true, maxLineLength = maxLineLength },
                    pyflakes = { enabled = true, maxLineLength = maxLineLength },
                    flake8 = { enabled = true, maxLineLength = maxLineLength },
                    black = { enabled = false, lineLength = maxLineLength },
                    isort = { enabled = true }
                }
            }
        }
    }
    lsp.lua_ls.setup {}
    lsp.clangd.setup {}
end

if isModuleAvailable("dap") then
    local dap = require('dap')
    dap.adapters.python = {
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
    }
    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
    dap.configurations.python = {
        {
            -- The first three options are required by nvim-dap
            type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch',
            name = "Launch file",

            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

            program = "${file}", -- This configuration will launch the current file if used.
            pythonPath = function()
                -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                return os.getenv("VIRTUAL_ENV") .. "/bin/python" or '/usr/bin/env python'
            end,
        },
    }
end

require('lazygit.utils').project_root_dir()
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")

require 'nvim-treesitter.configs'.setup {
highlight = {
    enable = true,
    -- additional_vim_regex_highlighting = true, -- DO NOT SET THIS
},
}

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

if isModuleAvailable("nvim-tree") then
    -- empty setup using defaults
    require("nvim-tree").setup()

    -- OR setup with some options
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 50,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
end

-- Configure telescope
require('telescope').setup {
pickers = {
    find_files = {
        path_display = { "smart" },
        hidden = true,
    },
},
defaults = {
    history = {
        path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
        limit = 100,
    },
    vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
    },
    mappings = {
        i = {
            ["<esc>"] = actions.close,
            ["<C-o>"] = function(prompt_bufnr)
                require("telescope.actions").select_default(prompt_bufnr)
                require("telescope.builtin").resume()
            end,
            ["<C-f>"] = actions.send_to_qflist,
            },
        },
    },
    extensions = {
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = {"png", "webp", "jpg", "jpeg"},
          -- find command (defaults to `fd`)
          find_cmd = "rg"
        },
        file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
                ["i"] = {
                    -- your custom insert mode mappings
                },
                ["n"] = {
                    -- your custom normal mode mappings
                },
            },
        },
        live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = {
                -- extend mappings
                i = {
                    ["<C-k>"] = lga_actions.quote_prompt(),
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                }
            }
        }
    }
}
require("toggleterm").setup {
    -- size can be a number or function which is passed the current terminal
    open_mapping = [[<c-\>]]
}
-- Lua:
-- For dark theme (neovim's default)
vim.o.background = 'dark'
-- For light theme
vim.o.background = 'light'

local c = require('vscode.colors').get_colors()
require('vscode').setup({
    -- Alternatively set style in setup
    style = 'dark'
})

require('vscode').load()

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { {
            'filename',
            file_status = true, -- displays file status (readonly status, modified status)
            path = 2            -- 0 = just filename, 1 = relative path, 2 = absolute path
        } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

require("telescope").load_extension("file_browser")
require("telescope").load_extension("lazygit")
require("telescope").load_extension("live_grep_args")
require("telescope").load_extension("recent_files")
require('telescope').load_extension('media_files')

require("yanky").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
})
require("telescope").load_extension("yank_history")

require "surround".setup {
    context_offset = 100,
    load_autogroups = false,
    mappings_style = "sandwich",
    map_insert_mode = true,
    quotes = { "'", '"' },
    brackets = { "(", '{', '[' },
    space_on_closing_char = false,
    pairs = {
        nestable = { b = { "(", ")" }, s = { "[", "]" }, B = { "{", "}" }, a = { "<", ">" } },
        linear = { q = { "'", "'" }, t = { "`", "`" }, d = { '"', '"' } }
    },
    prefix = "s"
}

