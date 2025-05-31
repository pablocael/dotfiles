if isModuleAvailable("jupytext") then

    require("toggleterm").setup{
        opts = {
          jupytext = 'jupytext',
          format = "markdown",
          update = true,
          filetype = require("jupytext").get_filetype,
          new_template = require("jupytext").default_new_template(),
          sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
          autosync = true,
          handle_url_schemes = true,
        }
    }
end

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

if isModuleAvailable("iron") then
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup {
      config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
          sh = {
            -- Can be a table or a function that
            -- returns a table (see below)
            command = {"zsh"}
          },
          python = {
            command = { "ipython", "--no-autoindent" },
            format = common.bracketed_paste_python,
            block_dividers = { "# %%", "#%%" },
          }
        },
        -- set the file type of the newly created repl to ft
        -- bufnr is the buffer id of the REPL and ft is the filetype of the
        -- language being used for the REPL.
        repl_filetype = function(bufnr, ft)
          return ft
          -- or return a string name such as the following
          -- return "iron"
        end,
        -- How the repl window will be displayed
        -- See below for more information
        -- repl_open_cmd = view.bottom(40),

        -- repl_open_cmd can also be an array-style table so that multiple
        -- repl_open_commands can be given.
        -- When repl_open_cmd is given as a table, the first command given will
        -- be the command that `IronRepl` initially toggles.
        -- Moreover, when repl_open_cmd is a table, each key will automatically
        -- be available as a keymap (see `keymaps` below) with the names
        -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
        -- For example,
        --
        repl_open_cmd = {
          view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
          view.split.rightbelow("%25")  -- cmd_2: open a repl below
        }

      },
      -- Iron doesn't set keymaps by default anymore.
      -- You can set them here or manually add keymaps to the functions in iron.core
      keymaps = {
        toggle_repl = "<space>rr", -- toggles the repl open and closed.
        -- If repl_open_command is a table as above, then the following keymaps are
        -- available
        -- toggle_repl_with_cmd_1 = "<space>rv",
        -- toggle_repl_with_cmd_2 = "<space>rh",
        restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_paragraph = "<space>sp",
        send_until_cursor = "<space>su",
        send_mark = "<space>sm",
        send_code_block = "<space>sb",
        send_code_block_and_move = "<space>sn",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",
        exit = "<space>sq",
        clear = "<space>cl",
      },
      -- If the highlight is on, you can change how it looks
      -- For the available options, check nvim_set_hl
      highlight = {
        italic = true
      },
      ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    }
end

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

if isModuleAvailable("cmp") then
    -- Set up nvim-cmp.
    local cmp = require'cmp'

    cmp.setup({
      sources = {
        { name = 'path' },  -- Enable file and directory completion
        { name = 'buffer' },
        { name = 'nvim_lsp' },
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
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
  local lsp = require("lspconfig")

  lsp.pyright.setup({
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    end,
    settings = {
      python = {
        analysis = {
            diagnosticMode = "workspace",       -- Check entire project, not just open files
            useLibraryCodeForTypes = false,      -- Use `.pyi` or inline stubs from installed packages
            autoSearchPaths = true,             -- Automatically find dependencies
            stubPath = "typings",               -- (optional) Add extra stub file locations
        },
      },
    },
  })

  -- other non-python servers
  lsp.lua_ls.setup({})
  lsp.clangd.setup({})
  -- js / ts
  require'lspconfig'.ts_ls.setup{
      init_options = {
          plugins = {
              {
                  name = "@vue/typescript-plugin",
                  location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
                  languages = {"javascript", "typescript", "vue"},
              },
          },
      },
      filetypes = {
          "javascript",
          "typescript",
          "vue",
      },
  }

end

if isModuleAvailable("dap") then
    local dap = require('dap')
    local dapui = require('dapui')
    local dap_python = require('dap-python')
    dap_python.setup('/home/pablo-elias/.pyenv/shims/python')
    -- Override launch config to set proper working directory
    dap.configurations.python = {
        {
            type = 'python',
            request = 'launch',
            name = "Launch with arguments",

            program = "${file}", -- Debug current file

            pythonPath = function()
                local venv = os.getenv("VIRTUAL_ENV")
                return venv and venv .. "/bin/python" or "python"
            end,

            -- Prompt for custom args
            args = function()
                local input = vim.fn.input("Arguments: ")
                return vim.fn.split(input, " ", true)
            end,

            cwd = vim.fn.getcwd(),       -- 🧠 Set base path (you can customize this)

            justMyCode = true,
            console = "integratedTerminal",  -- Optional: show stdin
        },
    }

    -- Optional UI setup
    dapui.setup()

    -- Automatically open/close dap-ui on start/stop
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
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

