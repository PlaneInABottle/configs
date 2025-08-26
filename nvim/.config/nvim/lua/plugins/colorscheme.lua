return {
  -- add gruvbox
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },
  { "ellisonleao/gruvbox.nvim" },
  {
    "EdenEast/nightfox.nvim",
    opts = {
      palettes = {
        nightfox = { green = "#00ff00" },
      },
      options = {
        colorblind = {
          enable = true,
          severity = {
            protan = 0,
            deutan = 0,
            tritan = 0.8,
          },
        },
        styles = {
          comments = "italic",
          keywords = "bold, italic",
        },
      },
    },
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
