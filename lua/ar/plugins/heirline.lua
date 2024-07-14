local fn, v, api, opt, cmd = vim.fn, vim.v, vim.api, vim.opt, vim.cmd
local bo, wo = vim.bo, vim.wo
local ui, sep = ar.ui, ar.ui.icons.separators

local buftypes = {
  'nofile',
  'prompt',
  'help',
  'quickfix',
}

-- Filetypes which force the statusline to be inactive
local force_inactive_filetypes = {
  '^aerial$',
  '^alpha$',
  '^chatgpt$',
  '^DressingInput$',
  '^frecency$',
  '^lazy$',
  '^lazyterm$',
  '^netrw$',
  '^oil$',
  '^TelescopePrompt$',
  '^undotree$',
}

local function setup_colors()
  local P = require('onedark.palette')
  return P
end

ar.augroup('Heirline', {
  event = 'ColorScheme',
  command = function()
    local utils = require('heirline.utils')
    utils.on_colorscheme(setup_colors)
  end,
})

return {
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = not ar.plugins.minimal,
    opts = { colors = setup_colors },
    config = function(_, opts)
      local statusline = require('ar.statusline')
      local conditions = require('heirline.conditions')
      local align = { provider = '%=' }

      opts.statusline = {
        condition = function()
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)
          local d = ui.decorations.get({
            ft = bo[buf].ft,
            fname = fn.bufname(buf),
            setting = 'statusline',
          })
          if ar.falsy(d) then
            return not conditions.buffer_matches({
              buftype = buftypes,
              filetype = force_inactive_filetypes,
            })
          end
          return d and d.ft == true or d and d.fname == true
        end,
        hl = statusline.hl,
        statusline.vim_mode,
        statusline.git_branch,
        statusline.file_name_block,
        statusline.python_env,
        statusline.lsp_diagnostics,
        align,
        statusline.dap,
        statusline.package_info,
        statusline.git_diff,
        statusline.lazy_updates,
        statusline.search_results,
        statusline.word_count,
        statusline.lsp_clients,
        statusline.attached_clients,
        -- statusline.copilot_attached,
        statusline.copilot_status,
        statusline.file_type,
        -- statusline.buffers,
        -- statusline.file_encoding,
        statusline.formatting,
        statusline.spell,
        -- statusline.treesitter,
        -- statusline.session,
        statusline.macro_recording,
        statusline.ruler,
        statusline.scroll_bar,
        -- statusline.vim_mode,
      }

      local separator = sep.left_thin_block
      local fcs = opt.fillchars:get()
      local shade = sep.light_shade_block

      local statuscol = require('ar.statuscolumn')
      local space = statuscol.space
      local spacer = { provider = space(), hl = 'HeirlineStatusColumn' }

      opts.statuscolumn = {
        condition = function()
          if not ar.ui.statuscolumn.enable or ar.ui.statuscolumn.custom then
            return false
          end
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)
          local d = ui.decorations.get({
            ft = bo[buf].ft,
            fname = fn.bufname(buf),
            setting = 'statuscolumn',
          })
          if ar.falsy(d) then
            return not conditions.buffer_matches({
              buftype = buftypes,
              filetype = force_inactive_filetypes,
            })
          end
          return d and d.ft == true or d and d.fname == true
        end,
        static = {
          click_args = function(self, minwid, clicks, button, mods)
            local args = {
              minwid = minwid,
              clicks = clicks,
              button = button,
              mods = mods,
              mousepos = fn.getmousepos(),
            }
            local sign =
              fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
            if sign == ' ' then
              sign = fn.screenstring(
                args.mousepos.screenrow,
                args.mousepos.screencol - 1
              )
            end
            args.sign = self.signs[sign]
            api.nvim_set_current_win(args.mousepos.winid)
            api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

            return args
          end,
          handlers = {},
        },
        init = function(self)
          self.signs = {}

          self.handlers.signs = function(_)
            return vim.schedule(vim.diagnostic.open_float)
          end

          self.handlers.line_number = function(_)
            local dap_avail, dap = pcall(require, 'dap')
            if dap_avail then vim.schedule(dap.toggle_breakpoint) end
          end

          self.handlers.git_signs = function(_)
            local gitsigns_avail, gitsigns = pcall(require, 'gitsigns')
            if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
          end

          self.handlers.fold = function(args)
            local lnum = args.mousepos.line
            if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return end
            cmd.execute(
              "'"
                .. lnum
                .. 'fold'
                .. (fn.foldclosed(lnum) == -1 and 'close' or 'open')
                .. "'"
            )
          end
        end,
        {
          init = function(self)
            local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local line_count = api.nvim_buf_line_count(buf)

            self.ln = statuscol.nr(win, lnum, relnum, virtnum, line_count)
            self.left, self.g_sns = statuscol.get_left(buf, lnum)
            self.no = wo[win].signcolumn == 'no'
          end,
          -- Signs
          {
            provider = function(self) return self.no and '' or self.left end,
            on_click = {
              name = 'sign_click',
              callback = function(self, ...)
                if self.handlers.signs then
                  self.handlers.signs(self.click_args(self, ...))
                end
              end,
            },
          },
          align,
          spacer,
          -- Line numbers
          {
            provider = function(self) return self.ln end,
            on_click = {
              name = 'line_number_click',
              callback = function(self, ...)
                if self.handlers.line_number then
                  self.handlers.line_number(self.click_args(self, ...))
                end
              end,
            },
          },
          spacer,
          {
            {
              condition = function()
                return not conditions.is_git_repo() or v.virtnum ~= 0
              end,
              provider = space(),
              hl = 'HeirlineStatusColumn',
            },
            -- Git signs
            {
              condition = function()
                return conditions.is_git_repo() and v.virtnum == 0
              end,
              init = function(self)
                if #self.g_sns == 0 then
                  self.gitsign = nil
                else
                  self.gitsign = unpack(self.g_sns)
                end
                self.has_gitsign = self.gitsign ~= nil
              end,
              provider = function(self)
                if self.has_gitsign then return self.gitsign.text end
                return space()
              end,
              hl = function(self)
                if self.has_gitsign then return self.gitsign.texthl end
                return 'HeirlineStatusColumn'
              end,
              on_click = {
                name = 'gitsigns_click',
                callback = function(self, ...)
                  if self.handlers.git_signs then
                    self.handlers.git_signs(self.click_args(self, ...))
                  end
                end,
              },
            },
          },
          -- Virtual lines
          {
            init = function(self)
              self.is_wrap = self.ln:gsub('^%s*(.-)%s*$', '%1') == ''
              self.is_shade = self.ln:gsub('^%s*(.-)%s*$', '%1') == shade
            end,
            provider = function(self)
              if self.is_shade then return '' end
              if not self.is_wrap then return separator end
              return ''
            end,
            hl = 'IndentBlanklineChar',
          },
        },
        {
          condition = function() return v.virtnum == 0 end,
          init = function(self)
            self.lnum = v.lnum
            self.folded = fn.foldlevel(self.lnum) > fn.foldlevel(self.lnum - 1)
          end,
          {
            condition = function(self) return self.folded end,
            {
              provider = function(self)
                if fn.foldclosed(self.lnum) == -1 then return fcs.foldopen end
              end,
            },
            {
              provider = function(self)
                if fn.foldclosed(self.lnum) ~= -1 then return fcs.foldclose end
              end,
            },
          },
          {
            condition = function(self) return not self.folded end,
            provider = space(),
          },
          on_click = {
            name = 'fold_click',
            callback = function(self, ...)
              if self.handlers.fold then
                self.handlers.fold(self.click_args(self, ...))
              end
            end,
          },
          spacer,
        },
      }

      require('heirline').setup(opts)
    end,
  },
}
