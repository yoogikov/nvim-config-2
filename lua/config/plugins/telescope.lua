return {
  {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.2.1',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        pickers = {
          live_grep = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            additional_args = function(_)
              return { "--hidden" }
            end
          },
          find_files = {
            theme = "ivy",
            find_command = { "rg", "--files", "--sortr=modified" },
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            additional_args = function(_)
              return { "--hidden" }
            end
          }

        },
        extensions = {
          "fzf"
        },
      })
      telescope.load_extension("fzf")
      local tbuiltin = require("telescope.builtin")
      vim.keymap.set("n", "<space>fh", tbuiltin.help_tags)
      vim.keymap.set("n", "<space>fd", tbuiltin.find_files)
      vim.keymap.set("n", "<space>/", tbuiltin.current_buffer_fuzzy_find)
      vim.keymap.set("n", "<space>fb", tbuiltin.buffers)
      vim.keymap.set("n", "<space>fc", tbuiltin.git_commits)
      vim.keymap.set("n", "<space>fj", tbuiltin.command_history)
      vim.keymap.set("n", "<space>fk", tbuiltin.keymaps)
      vim.keymap.set("n", "<space>fl", tbuiltin.lsp_references)
      vim.keymap.set("n", "<space>fo", tbuiltin.oldfiles)
      vim.keymap.set("n", "<space>fg", tbuiltin.live_grep)
      vim.keymap.set("n", "<space>fs", tbuiltin.grep_string)
      vim.keymap.set("n", "<space>ft", tbuiltin.treesitter)
      vim.keymap.set("n", "<space>en", function()
        require("telescope.builtin").find_files({
          cwd = vim.fn.stdpath("config")
        })
      end)
      vim.keymap.set("n", "<space>ep", function()
        require('telescope.builtin').find_files {
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
        }
      end)
    end,
  }
}
--return {
--  {
--    config = function()
--      require("telescope").setup {
--        pickers = {
--          find_files = {
--            theme = "ivy"
--          }
--        },
--        extensions = {
--          fzf = {},
--        }
--      }
--
--      require('telescope').load_extension('fzf')
--
--      vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)
--      vim.keymap.set("n", "<space>fd", require("telescope.builtin").find_files)
--      vim.keymap.set("n", "<space>en", function()
--        require("telescope.builtin").find_files({
--          cwd = vim.fn.stdpath("config")
--        })
--      end)
--      vim.keymap.set("n", "<space>ep", function()
--        require('telescope.builtin').find_files {
--          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
--        }
--      end)
--
--      vim.keymap.set("n", "<leader>fg", function()
--        require "config.telescope.multigrep"
--      end)
--    end
--  }
--}
