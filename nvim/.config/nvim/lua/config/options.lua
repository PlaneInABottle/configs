-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.fn.has("mac") == 1 then
  local system_open = vim.ui.open

  vim.ui.open = function(path, opts)
    local is_uri = path:match("^%a[%w+.-]*:") ~= nil
    local is_directory = not is_uri and vim.fn.isdirectory(vim.fs.normalize(path)) == 1

    if not is_uri and not is_directory and not (opts and opts.cmd) then
      opts = vim.tbl_extend("force", opts or {}, { cmd = { "open", "-a", "TextEdit" } })
    end

    return system_open(path, opts)
  end
end

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
