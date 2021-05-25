# telescope-hoogle.nvim
Telescope integration with hoogle

#### Installation

* Install `hoogle`
* Install `w3m` to preview results
```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nkpart/telescope-hoogle.nvim'
```
## Setup

require('telescope').load_extension('hoogle')
```
## Available commands
```viml
Telescope hoogle search

" Using lua
lua require('telescope').extensions.hoogle.search()<cr>

```
