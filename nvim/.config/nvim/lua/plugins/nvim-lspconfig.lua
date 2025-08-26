return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers.vtsls.settings.vtsls.autoUseWorkspaceTsdk = false
  end,
}
