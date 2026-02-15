return {
  "snacks.nvim",
  keys = {
    { "<leader>e", false },
    { "<leader>E", false },
    { "<leader>fe", false },
    { "<leader>fE", false },
  },
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true, -- show dotfiles
          ignored = false, -- don't hide .gitignore files
        },
        grep = {
          hidden = true,
        },
      },
    },
    dashboard = {
      preset = {
        header = [[
        █████╗ ██╗     ████████╗ █████╗ ██╗   ██╗        Z
       ██╔══██╗██║     ╚══██╔══╝██╔══██╗╚██╗ ██╔╝     Z   
       ███████║██║        ██║   ███████║ ╚████╔╝   z      
       ██╔══██║██║        ██║   ██╔══██║  ╚██╔╝  z        
       ██║  ██║███████╗   ██║   ██║  ██║   ██║            
       ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝            
        ]],
      },
    },
  },
}
