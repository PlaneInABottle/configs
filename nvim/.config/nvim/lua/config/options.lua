-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Focus handling: Dim the entire screen using a floating window overlay
vim.api.nvim_create_augroup("FocusHighlight", { clear = true })

local dim_buf = nil
local dim_win = nil

local function create_dim_overlay()
  if not dim_buf then
    dim_buf = vim.api.nvim_create_buf(false, true)
  end

  dim_win = vim.api.nvim_open_win(dim_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    focusable = false,
    style = "minimal",
    zindex = 50,
  })

  vim.wo[dim_win].winblend = 40
  vim.api.nvim_set_hl(0, "DimOverlay", { bg = "#000000" })
  vim.wo[dim_win].winhighlight = "Normal:DimOverlay"
end

local function remove_dim_overlay()
  if dim_win then
    vim.api.nvim_win_close(dim_win, true)
    dim_win = nil
  end
end

vim.api.nvim_create_autocmd("FocusLost", {
  group = "FocusHighlight",
  callback = create_dim_overlay,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = "FocusHighlight",
  callback = remove_dim_overlay,
})
