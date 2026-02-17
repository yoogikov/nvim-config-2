return {
  'voldikss/vim-floaterm',
  config = function()
    vim.keymap.set('n', '<F12>', ':FloatermNew lazygit<CR>', {})
    vim.keymap.set('t', '<F12>', '<C-\\><C-n>:FloatermKill<CR>', {})
  end
}
