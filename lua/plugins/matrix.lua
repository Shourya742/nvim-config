return {
    "iruzo/matrix-nvim",
    priority = 1000,
    config = function()
      
      vim.g.matrix_contrast = true
      vim.g.matrix_borders = false
      vim.g.matrix_disable_background = false
      vim.g.matrix_italic = true
      vim.cmd.colorscheme("matrix")
    end,
}
