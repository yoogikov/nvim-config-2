-- Importing lazy
require("config.lazy")

-- Makes folded text appear neater
vim.cmd([[
    set foldtext=MyFoldText()
    function MyFoldText()
      let line = getline(v:foldstart)
      let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
      return v:folddashes .. sub
    endfunction
            ]])

-- Setting tab length
vim.opt.shiftwidth = 4

-- allow project config file
vim.opt.exrc = true

-- Hilghlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Save and restore folds automatically
vim.api.nvim_create_autocmd('BufWinLeave', {
  desc = 'save folds when leavivng buffer',
  group = vim.api.nvim_create_augroup('remember-folds', { clear = true }),
  callback = function()
    vim.cmd('mkview');
  end
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'save folds when leavivng buffer',
  group = vim.api.nvim_create_augroup('remember-folds', { clear = true }),
  callback = function()
    vim.cmd("set foldmethod=manual")
    vim.cmd('silent! loadview');
  end
})
-- Setting global diagnostic options
vim.diagnostic.config({ virtual_text = true })

-- keymap to source the current file
vim.keymap.set("n", "<space><space>x", "<cmd>:source %<CR>")

-- keymap to run lua code
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")

-- keymap to create a horizontal split
vim.keymap.set("n", "<space>s", ":split<CR>")
-- keymap to create a vertical split
vim.keymap.set("n", "<space>v", ":vsplit<CR>")

-- keymaps for easier motion between windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- file navigation keymaps

-- Function for moving down on a quickfix list or a location list
function GetList()
  local bufs = vim.fn.execute('buffers')
  local lastLine = function(s)
    local last = string.match(s, ".*\\n(.*)")

    if last then
      -- Returns the captured part (the last line)
      return last
    else
      -- If no newline is found, the whole string is the single line
      return s
    end
  end
  local last = lastLine(bufs)
  if string.find(last, "Quickfix List") then
    return "qf"
  elseif string.find(last, "Location List") then
    return "ll"
  else
    return nil
  end
end

function Nextentry()
  local list = GetList()
  if list == "qf" then
    local _ = pcall(vim.fn.execute, 'cnext')
  elseif list == "ll" then
    local _ = pcall(vim.fn.execute, 'lnext')
  else
    print("Error: Neither Quick Fix List nor Location List open")
  end
end

function Preventry()
  local list = GetList()
  if list == "qf" then
    local _ = pcall(vim.fn.execute, 'cprev')
  elseif list == "ll" then
    local _ = pcall(vim.fn.execute, 'lprev')
  else
    print("Error: Neither Quick Fix List nor Location List open")
  end
end

-- keymaps for quickfix
vim.keymap.set("n", "<M-j>", ":lua Nextentry()<CR>")
vim.keymap.set("n", "<M-k>", ":lua Preventry()<CR>")
vim.keymap.set("n", "<M-l>", ":lua vim.diagnostic.setloclist()<CR>")
vim.keymap.set("n", "<M-q>", ":lua vim.diagnostic.setqflist()<CR>")

-- Keymaps for Oil
vim.keymap.set("n", "<BS>", "<cmd>Oil<CR>")

-- Functions for floating terminal and git
function TermToggle()
  local newtermcommand = "FloatermNew --wintype=split --height=15"
  if (is_created == false) then
    if (is_term == false) then
      if (is_git == true) then
        vim.cmd("FloatermKill")
        is_git = false
      end
      vim.cmd(newtermcommand)
      is_created = true
      is_term = true
    else
      vim.cmd("FloatermKill!")
      is_git = false
      is_term = false
      vim.cmd(newtermcommand)
      is_created = true
      is_term = true
    end
  else
    if (is_git == true) then
      vim.cmd("FloatermKill")
      is_git = false
    end
    vim.cmd("FloatermToggle")
    is_term = true
  end
end

function GitToggle()
  local newtermcommand = "FloatermNew --wintype=split lazygit"
  if (is_git == false) then
    if (is_term == true) then
      vim.cmd("FloatermToggle")
      is_term = false
    end
    vim.cmd(newtermcommand)
    is_git = true
  else
    if (is_term == true) then
      vim.cmd("FloatermToggle")
      is_term = false
      vim.cmd(newtermcommand)
    else
      vim.cmd("FloatermKill")
      is_git = false
    end
  end
end

-- Keymaps for floating terminal and git
vim.keymap.set("n", "<C-space>", ":lua TermToggle()<CR>", { silent = true })
vim.keymap.set("i", "<C-space>", "<Esc>:lua TermToggle()<CR>", { silent = true })
vim.keymap.set("t", "<C-space>", "<C-\\><C-n>:lua TermToggle()<CR>", { silent = true })
vim.keymap.set("n", "<C-g>", ":lua GitToggle()<CR>", { silent = true })
vim.keymap.set("i", "<C-g>", "<Esc>:lua GitToggle()<CR>", { silent = true })
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>:lua GitToggle()<CR>", { silent = true })

-- Keymaps for lsp
vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>")
vim.cmd("map <C-_> Vgc")
vim.cmd("vmap <C-_> gc")

-- Disable mouse
vim.cmd("set mouse=r")

-- Enable relative numbering in vim
vim.opt.relativenumber = true

-- Stuff for ocaml
vim.opt.rtp:prepend('/home/yoogi/.opam/5.4.0/share/ocp-indent/vim')

-- Stuff for vim wiki
vim.g.wiki_root = "~/wiki"
