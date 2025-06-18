# nvim-highlight

Document highlighting in neovim.

Uses the LSP client attached to the buffer to run `textDocument/documentHighlight` on delayed hover.

## Installation

```lua
-- With lazy.nvim
{
  "rhydianjenkins/nvim-highlight",
  config = function()
    require("nvim-highlight").setup({
      delay = 500,    -- optional: delay in milliseconds (default: 500)
      enabled = true  -- optional: enable/disable plugin (default: true)
    })
  end
}
```
