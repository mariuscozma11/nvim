local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Go uses tabs by convention
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
