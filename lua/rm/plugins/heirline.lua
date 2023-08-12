local fn, v, api, opt, cmd = vim.fn, vim.v, vim.api, vim.opt, vim.cmd
local ui, sep, falsy = rvim.ui, rvim.ui.icons.separators, rvim.falsy

---@class StringComponent
---@field component string
---@field length integer,
---@field priority integer

---@alias ExtmarkSign {[1]: number, [2]: number, [3]: number, [4]: {sign_text: string, sign_hl_group: string}}

local space = ' '
local fcs = opt.fillchars:get()
local shade, separator = sep.light_shade_block, sep.left_thin_block -- '│'

local align = { provider = '%=' }
local spacer = { provider = space }
local divider = { provider = separator, hl = 'LineNr' }

---@param line_count integer
---@param lnum integer
---@param relnum integer
---@param virtnum integer
---@return string
local function nr(win, lnum, relnum, virtnum, line_count)
  local col_width = api.nvim_strwidth(tostring(line_count))
  if virtnum and virtnum ~= 0 then
    return space:rep(col_width - 1) .. (virtnum < 0 and shade or space)
  end -- virtual line
  local num = vim.wo[win].relativenumber and not falsy(relnum) and relnum or lnum
  if line_count > 999 then col_width = col_width + 1 end
  local ln = tostring(num):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
  local num_width = col_width - api.nvim_strwidth(ln)
  return string.rep(space, num_width) .. ln
end

---@generic T:table<string, any>
---@param t T the object to format
---@param k string the key to format
---@return T?
local function format_text(t, k)
  local txt = t[k] and t[k]:gsub('%s', '') or ''
  if #txt < 1 then return end
  t[k] = txt
  return t
end

---@param curbuf integer
---@param lnum integer
---@return StringComponent[]
local function signplaced_signs(curbuf, lnum)
  return vim
    .iter(fn.sign_getplaced(curbuf, { group = '*', lnum = lnum })[1].signs)
    :map(function(s)
      local sign = format_text(fn.sign_getdefined(s.name)[1], 'text')
      return { sign.text, sign.texthl }
    end)
    :totable()
end

---@param curbuf integer
---@return StringComponent[], StringComponent[]
local function extmark_signs(curbuf, lnum)
  lnum = lnum - 1
  ---@type ExtmarkSign[]
  local signs = api.nvim_buf_get_extmarks(
    curbuf,
    -1,
    { lnum, 0 },
    { lnum, -1 },
    { details = true, type = 'sign' }
  )
  local sns = vim
    .iter(signs)
    :map(function(item) return format_text(item[4], 'sign_text') end)
    :fold({ git = {}, other = {} }, function(acc, item)
      local txt, hl = item.sign_text, item.sign_hl_group
      -- HACK: to remove number from trailblazer signs by replacing it with a bookmark icon
      local is_trail = hl:match('^Trail')
      if is_trail then txt = ui.codicons.misc.bookmark end
      local is_git = hl:match('^Git')
      local target = is_git and acc.git or acc.other
      table.insert(target, { txt, hl })
      return acc
    end)
  return sns.git, sns.other
end

return {
  {
    'rebelot/heirline.nvim',
    event = 'VeryLazy',
    enabled = not rvim.plugins.minimal or not rvim.ui.statuscolumn.enable,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local conditions = require('heirline.conditions')
      local gitsigns_avail, gitsigns = pcall(require, 'gitsigns')

      local static = {
        click_args = function(self, minwid, clicks, button, mods)
          local args = {
            minwid = minwid,
            clicks = clicks,
            button = button,
            mods = mods,
            mousepos = fn.getmousepos(),
          }
          local sign = fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
          if sign == ' ' then
            sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
          end
          args.sign = self.signs[sign]
          api.nvim_set_current_win(args.mousepos.winid)
          api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

          return args
        end,
        handlers = {},
      }

      local init = function(self)
        self.signs = {}

        self.handlers.signs = function(_) return vim.schedule(vim.diagnostic.open_float) end

        self.handlers.line_number = function(_)
          local dap_avail, dap = pcall(require, 'dap')
          if dap_avail then vim.schedule(dap.toggle_breakpoint) end
        end

        self.handlers.git_signs = function(_)
          if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
        end

        self.handlers.fold = function(args)
          local lnum = args.mousepos.line
          if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return end
          cmd.execute(
            "'" .. lnum .. 'fold' .. (fn.foldclosed(lnum) == -1 and 'close' or 'open') .. "'"
          )
        end
      end

      local line_numbers = {
        provider = function()
          local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)
          local line_count = api.nvim_buf_line_count(buf)
          return nr(win, lnum, relnum, virtnum, line_count)
        end,
        on_click = {
          name = 'line_number_click',
          callback = function(self, ...)
            if self.handlers.line_number then
              self.handlers.line_number(self.click_args(self, ...))
            end
          end,
        },
      }

      local folds = {
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
          provider = ' ',
        },
        on_click = {
          name = 'fold_click',
          callback = function(self, ...)
            if self.handlers.fold then self.handlers.fold(self.click_args(self, ...)) end
          end,
        },
      }

      local signs = {
        init = function(self)
          local lnum = v.lnum
          local win = api.nvim_get_current_win()
          local buf = api.nvim_win_get_buf(win)

          local sns = signplaced_signs(buf, lnum)
          local _, other_sns = extmark_signs(buf, lnum)

          if #sns > 0 then
            vim.list_extend(sns, other_sns)
            self.sign = unpack(sns)
          elseif #other_sns > 0 then
            self.sign = unpack(other_sns)
          else
            self.sign = nil
          end
          self.has_sign = self.sign ~= nil
        end,
        provider = function(self)
          if self.has_sign then return self.sign[1] end
          return ' '
        end,
        hl = function(self)
          if self.has_sign then return self.sign[2] end
          return 'HeirlineStatusColumn'
        end,
        on_click = {
          name = 'sign_click',
          callback = function(self, ...)
            if self.handlers.signs then self.handlers.signs(self.click_args(self, ...)) end
          end,
        },
      }

      local git_signs = {
        {
          condition = function() return not conditions.is_git_repo() or v.virtnum ~= 0 end,
          provider = ' ',
          hl = 'HeirlineStatusColumn',
        },
        {
          condition = function() return conditions.is_git_repo() and v.virtnum == 0 end,
          init = function(self)
            local lnum = v.lnum
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)

            local gitsign, _ = extmark_signs(buf, lnum)

            if #gitsign == 0 then
              self.sign = nil
            else
              self.sign = unpack(gitsign)
            end
            self.has_sign = self.sign ~= nil
          end,
          provider = function(self)
            if self.has_sign then return self.sign[1] end
            return ' '
          end,
          hl = function(self)
            if self.has_sign then return self.sign[2] end
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
      }

      require('heirline').setup({
        statuscolumn = {
          condition = function()
            local win = api.nvim_get_current_win()
            local buf = api.nvim_win_get_buf(win)
            local d = ui.decorations.get({
              ft = vim.bo[buf].ft,
              fname = fn.bufname(buf),
              setting = 'statuscolumn',
            })
            if falsy(d) then return true end
            return d and d.ft == true or d and d.fname == true
          end,
          static = static,
          init = init,
          signs,
          align,
          spacer,
          line_numbers,
          spacer,
          git_signs,
          divider,
          folds,
          spacer,
        },
      })
    end,
  },
}
