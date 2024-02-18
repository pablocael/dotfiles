-- Example for configuring Neovim to load user-installed installed Lua rocks:
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require("options-config")
require("key-mappings-config")
require("plugins-custom-config")

-- default config
require("image").setup({
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
    },
    neorg = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      filetypes = { "norg" },
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
  tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
})

-- Set up nvim-cmp.
local cmp = require'cmp'

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
-- LSP Configs
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
                black = { enabled = true, lineLength = maxLineLength },
                isort = { enabled = true }
            }
        }
    }
}
lsp.lua_ls.setup {}


require 'soil'.setup {
    -- If you want to use Plant UML jar version instead of the install version
    puml_jar = "/home/pablo-elias/bin/plantuml.jar",

    -- If you want to customize the image showed when running this plugin
    image = {
        darkmode = false, -- Enable or disable darkmode
        format = "png",   -- Choose between png or svg
    }
}

return require("packer").startup(function()
    -- Packer plugin for packer :-}
    use "wbthomason/packer.nvim"

    use {
      'benlubas/molten-nvim',
      version = '1.6.0', -- To specify a version in packer, use the git tag or commit hash
      requires = {'3rd/image.nvim'}, -- 'dependencies' is specified as 'requires' in packer
      config = function()
        -- The 'init' function's content goes into the 'config' section in packer
        vim.g.molten_image_provider = 'image.nvim'
        vim.g.molten_output_win_max_height = 20
      end,
      run = ':UpdateRemotePlugins', -- 'build' commands can be specified using 'run' in packer
    }

    -- Plenary is used to implement asynchoronous corountines (used by other plugins)
    use "nvim-lua/plenary.nvim"

    -- Plugins that provides floating panels and supports different extensions
    use {
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" }, { "kdheepak/lazygit.nvim" },
            { "nvim-telescope/telescope-live-grep-args.nvim" } }
    }

    use "smartpde/telescope-recent-files"

    -- A pluging that will provide a start page for vim, with bookmars and Last Recent Used files
    use "mhinz/vim-startify"
    use "tpope/vim-fugitive"

    -- required by other plugins, a tree visualizer
    use "nvim-treesitter/nvim-treesitter"

    use "nvim-neotest/neotest-python"
    -- tests plugin
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim"
        }
    }

    use "mfussenegger/nvim-dap"
    use "mfussenegger/nvim-dap-python"

    -- latex preview and support in vim
    use 'lervag/vimtex'

    -- terraform syntax highlight
    use "hashivim/vim-terraform"

    -- auto completion
    use { "hrsh7th/nvim-cmp" }

    -- jupyter notebooks

    -- A style plugin for providing vscode look to nvim
    use "Mofiqul/vscode.nvim"

    -- A Telescope extension for file browsing
    use {
        "nvim-telescope/telescope-file-browser.nvim",
        requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    }

    -- A pluging for allowing multiple copy and cycle pasting
    use "gbprod/yanky.nvim"

    -- A pluging for commenting on almost any file and language
    use "tpope/vim-commentary"

    -- A pluging for providing identation guides
    use "lukas-reineke/indent-blankline.nvim"

    -- LSP language server
    use {
        "neovim/nvim-lspconfig",
        config = function()
        end
    }

    -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-nvim-lsp'

    -- Snippet engine
    use 'hrsh7th/vim-vsnip'

    -- Snippet source for nvim-cmp
    use 'hrsh7th/cmp-vsnip'

    -- Other common sources
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'

    -- A toggable embedded terminal for nvim
    use { "akinsho/toggleterm.nvim", tag = "*" }

    -- Lazygit integration for nvim
    use "kdheepak/lazygit.nvim"

    use 'nvim-tree/nvim-web-devicons'

    -- Airline like statusline but configured in lua
    use {
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true }
    }

    -- Pluging for surrounding yanks with () "" "" and others
    use {
        "ur4ltz/surround.nvim",
        config = function()
            require "surround".setup { mappings_style = "surround" }
        end
    }

    -- puml support
    use 'javiorfo/nvim-soil'

    -- Optional for puml syntax highlighting:
    use 'javiorfo/nvim-nyctophilia'

    -- install without yarn or npm
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    use "peterhoeg/vim-qml"

    use "thinca/vim-qfreplace"

    use {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end
    }
    -- spell checker
    use {
        -- Optional but recommended
        -- 'nvim-treesitter/nvim-treesitter',
        'lewis6991/spellsitter.nvim',
    }
end)
