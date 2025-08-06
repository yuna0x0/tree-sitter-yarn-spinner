-- Example Neovim configuration for Yarn Spinner tree-sitter support
-- Copy relevant parts to your init.lua or create as a separate plugin file

-- Parser configuration
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.yarn_spinner = {
  install_info = {
    url = "https://github.com/yuna0x0/tree-sitter-yarn-spinner",
    files = {"src/parser.c", "src/scanner.c"},
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "yarn",
}

-- Register the filetype
vim.treesitter.language.register('yarn_spinner', 'yarn')

-- Set up filetype detection
vim.filetype.add({
  extension = {
    yarn = 'yarn',
  },
})

-- Configure nvim-treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    -- Add yarn_spinner to your existing parsers
    "yarn_spinner",
    -- ... your other parsers
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },

  fold = {
    enable = true,
  },

  -- Optional: Incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  -- Optional: Text objects (requires nvim-treesitter-textobjects)
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- Functions
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",

        -- Classes/Nodes
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

        -- Blocks
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",

        -- Parameters
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",

        -- Statements
        ["as"] = "@statement.outer",

        -- Conditionals
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",

        -- Assignments
        ["a="] = "@assignment.outer",

        -- Calls
        ["al"] = "@call.outer",
        ["il"] = "@call.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
        ["]b"] = "@block.outer",
        ["]i"] = "@conditional.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
        ["]B"] = "@block.outer",
        ["]I"] = "@conditional.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[b"] = "@block.outer",
        ["[i"] = "@conditional.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
        ["[B"] = "@block.outer",
        ["[I"] = "@conditional.outer",
      },
    },

    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
  },
})

-- Auto-commands for Yarn Spinner files
vim.api.nvim_create_augroup("YarnSpinner", { clear = true })

-- Enable tree-sitter folding for .yarn files
vim.api.nvim_create_autocmd("FileType", {
  group = "YarnSpinner",
  pattern = "yarn",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldlevelstart = 1  -- Start with some folds open
  end,
})

-- Optional: Set specific options for Yarn files
vim.api.nvim_create_autocmd("FileType", {
  group = "YarnSpinner",
  pattern = "yarn",
  callback = function()
    -- Set tab settings (Yarn Spinner typically uses 4 spaces)
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true

    -- Enable spell checking for dialogue text
    vim.wo.spell = true
    vim.wo.spelllang = "en_us"

    -- Set comment string for commenting/uncommenting
    vim.bo.commentstring = "// %s"

    -- Enable line numbers and relative numbers for easy navigation
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

-- Custom highlight groups (optional)
-- These will override the default highlighting
vim.api.nvim_set_hl(0, "@markup.heading.yarn_spinner", { link = "Title", bold = true })
vim.api.nvim_set_hl(0, "@keyword.conditional.yarn_spinner", { link = "Conditional" })
vim.api.nvim_set_hl(0, "@keyword.function.yarn_spinner", { link = "Function" })
vim.api.nvim_set_hl(0, "@keyword.return.yarn_spinner", { link = "Statement" })
vim.api.nvim_set_hl(0, "@variable.yarn_spinner", { link = "Identifier" })
vim.api.nvim_set_hl(0, "@tag.yarn_spinner", { link = "Tag" })
vim.api.nvim_set_hl(0, "@punctuation.special.yarn_spinner", { link = "Special" })

-- Optional: Custom keybindings for Yarn Spinner files
vim.api.nvim_create_autocmd("FileType", {
  group = "YarnSpinner",
  pattern = "yarn",
  callback = function()
    local opts = { buffer = true, silent = true }

    -- Quick node navigation
    vim.keymap.set("n", "<leader>yn", "]]", { desc = "Next node", buffer = true })
    vim.keymap.set("n", "<leader>yp", "[[", { desc = "Previous node", buffer = true })

    -- Quick folding
    vim.keymap.set("n", "<leader>yf", "za", { desc = "Toggle fold", buffer = true })
    vim.keymap.set("n", "<leader>yF", "zA", { desc = "Toggle all folds", buffer = true })

    -- Inspect tree-sitter node under cursor (useful for debugging)
    vim.keymap.set("n", "<leader>yi", function()
      local ts_utils = require("nvim-treesitter.ts_utils")
      local node = ts_utils.get_node_at_cursor()
      if node then
        print("Node type: " .. node:type())
        print("Range: " .. node:range())
      end
    end, { desc = "Inspect TS node", buffer = true })
  end,
})

-- Optional: LSP-like features using tree-sitter
-- Jump to variable definition
vim.api.nvim_create_autocmd("FileType", {
  group = "YarnSpinner",
  pattern = "yarn",
  callback = function()
    vim.keymap.set("n", "gd", function()
      local ts_utils = require("nvim-treesitter.ts_utils")
      local node = ts_utils.get_node_at_cursor()

      if node and node:type() == "variable" then
        -- Simple implementation: search for variable declaration
        local var_name = vim.treesitter.get_node_text(node, 0)
        vim.cmd("/" .. vim.fn.escape(var_name, "/\\"))
      end
    end, { desc = "Go to definition", buffer = true })
  end,
})

-- Optional: Auto-format or lint on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = "YarnSpinner",
--   pattern = "*.yarn",
--   callback = function()
--     -- Add your formatting logic here
--     -- For example, you might want to ensure consistent indentation
--   end,
-- })
