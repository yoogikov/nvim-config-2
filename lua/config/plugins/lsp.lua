local function switch_source_header(bufnr, client)
  local method_name = 'textDocument/switchSourceHeader'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = 'textDocument/symbolInfo'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify('Clangd client not found', vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format('container: %s', res[1].containerName) ---@type string
    local name = string.format('name: %s', res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = 'Symbol Info',
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                disable = { "trailing-space" },
              }
            }
          }
        },
        clangd = {
          cmd = { 'clangd', "--background-index" },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          root_markers = {
            '.clangd',
            '.clang-tidy',
            '.clang-format',
            'compile_commands.json',
            'compile_flags.txt',
            'configure.ac', -- AutoTools
            '.git',
          },
          capabilities = {
            textDocument = {
              completion = {
                editsNearCursor = true,
              },
            },
            offsetEncoding = { 'utf-8', 'utf-16' },
          },
          ---@param init_result ClangdInitializeResult
          on_init = function(client, init_result)
            if init_result.offsetEncoding then
              client.offset_encoding = init_result.offsetEncoding
            end
          end,
          on_attach = function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdSwitchSourceHeader', function()
              switch_source_header(bufnr, client)
            end, { desc = 'Switch between source/header' })

            vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdShowSymbolInfo', function()
              symbol_info(bufnr, client)
            end, { desc = 'Show symbol info' })
          end,
        },
        ocamllsp = {
          cmd = { 'ocamllsp' },
          filetypes = { 'ocaml', 'ocaml.interface', 'dune' },
          root_markers = { 'dune-project', 'dune-workspace' },
          settings = {},
        },
      }


      for key, value in pairs(servers) do
        vim.lsp.config(key, value)
        vim.lsp.enable(key)
      end

      -- Keymaps

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            print("no formatting")
            return
          end
          if client:supports_method('textDocument/formatting', 0) then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end
            })
          end
        end
      })
      vim.keymap.set("n", "<space>f", function() vim.lsp.buf.format() end)
    end,
  }
}
