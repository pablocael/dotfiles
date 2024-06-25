require("options-config")
require("key-mappings-config")
require("plugins-custom-config")

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
      end,
      run = ':UpdateRemotePlugins', -- 'build' commands can be specified using 'run' in packer
    }

    -- Plenary is used to implement asynchoronous corountines (used by other plugins)
    use "nvim-lua/plenary.nvim"
    use 'nvim-lua/popup.nvim'
    use 'nvim-telescope/telescope-media-files.nvim'

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
    use {
      'nvim-tree/nvim-tree.lua',
      requires = {
        'nvim-tree/nvim-web-devicons', -- optional
      },
    }

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
