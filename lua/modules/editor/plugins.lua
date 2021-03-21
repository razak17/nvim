local conf = require('modules.editor.conf')
local editor = {}

editor['norcalli/nvim-colorizer.lua'] = {config = conf.nvim_colorizer}

editor['kevinhwang91/rnvimr'] = {config = conf.rnvimr}

editor['windwp/nvim-autopairs'] = {config = conf.autopairs}

editor['voldikss/vim-floaterm'] = {config = conf.floaterm}

editor['b3nj5m1n/kommentary'] = {
    config = function()
        require('kommentary.config').configure_language("default", {
            prefer_single_line_comments = true
        })
    end
}

editor['romainl/vim-cool'] = {
    config = function()
        vim.g.CoolTotalMatches = 1
    end
}

editor['RRethy/vim-illuminate'] = {
    config = function()
        vim.g.Illuminate_ftblacklist = {
            'javascript', 'python', 'typescript', 'jsx', 'tsx', 'html'
        }
    end
}

editor['tpope/vim-fugitive'] = {}

return editor

