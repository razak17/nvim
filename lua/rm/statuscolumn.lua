local fn, v, api, opt, cmd = vim.fn, vim.v, vim.api, vim.opt, vim.cmd
local ui, sep, falsy = rvim.ui, rvim.ui.icons.separators, rvim.falsy
local format_text = rvim.format_text

local separator = sep.left_thin_block
local space = ' '
local fcs = opt.fillchars:get()
local shade = sep.light_shade_block

local align = { provider = '%=' }
local spacer = { provider = space, hl = 'HeirlineStatusColumn' }

---@alias ExtmarkSign {[1]: number, [2]: number, [3]: number, [4]: {sign_text: string, sign_hl_group: string}}
---@alias Sign {name:string, text:string, texthl:string, priority:number}

---@param line_count integer
---@param lnum integer
---@param relnum integer
---@param virtnum integer
---@return string
local function nr(win, lnum, relnum, virtnum, line_count)
  local col_width = api.nvim_strwidth(tostring(line_count))
  if virtnum and virtnum ~= 0 then
    return space:rep(col_width - 1) .. (virtnum < 0 and '' or space)
  end -- virtual line
  local num = vim.wo[win].relativenumber and not falsy(relnum) and relnum
    or lnum
  if line_count > 999 then col_width = col_width + 1 end
  local ln =
    tostring(num):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
  local num_width = col_width - api.nvim_strwidth(ln)
  if num_width == 0 then return ln end
  return string.rep(space, num_width) .. ln
end

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[],Sign[]
---@param curbuf integer
---@param lnum number
local function extmark_signs(curbuf, lnum)
  ---@type ExtmarkSign[]
  local signs = api.nvim_buf_get_extmarks(
    curbuf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = 'sign' }
  )
  local sns = vim
    .iter(signs)
    :map(function(item) return format_text(item[4], 'sign_text') end)
    :fold({ git = {}, other = {} }, function(acc, item)
      local txt, hl = item.sign_text, item.sign_hl_group
      -- HACK: to remove number from trailblazer signs by replacing it with a bookmark icon
      if hl:match('^Trail') then txt = ui.codicons.misc.bookmark end
      local target = hl:match('^Git') and acc.git or acc.other
      table.insert(target, { text = txt, texthl = hl })
      return acc
    end)
  return sns.git, sns.other
end

---@return Sign?
---@param buf number
---@param lnum number
local function get_mark(buf, lnum)
  local marks = fn.getmarklist(buf)
  vim.list_extend(marks, fn.getmarklist())
  for _, mark in ipairs(marks) do
    if
      mark.pos[1] == buf
      and mark.pos[2] == lnum
      and mark.mark:match('[a-zA-Z]')
    then
      return { text = mark.mark:sub(2), texthl = 'DiagnosticHint' }
    end
  end
end

---@param sign? Sign
---@param len? number
local function icon(sign, len)
  local spaces = len or 0
  sign = sign or {}
  local text = sign.text
  if spaces > 0 then
    text = fn.strcharpart(sign.text or '', 0, spaces) ---@type string
    text = text .. string.rep(space, spaces - fn.strchars(text))
  end
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

local conditions = rvim.reqidx('heirline.conditions')
local gitsigns_avail, gitsigns = pcall(require, 'gitsigns')

return {
  utils = {
    nr = nr,
    extmark_signs = extmark_signs,
    get_mark = get_mark,
    icon = icon,
  },
  components = {
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
          sign = vim.fn.screenstring(
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
    render = {
      init = function(self)
        local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
        local win = api.nvim_get_current_win()
        local buf = api.nvim_win_get_buf(win)
        local line_count = api.nvim_buf_line_count(buf)

        self.ln = nr(win, lnum, relnum, virtnum, line_count)
        self.marks = get_mark(buf, lnum)
        self.g_sns, self.sns = extmark_signs(buf, lnum)
      end,
      -- Signs
      {
        init = function(self)
          self.left = {}
          if self.marks then self.left[#self.left + 1] = icon(self.marks, 2) end
          if #self.sns > 0 then
            vim.iter(self.sns):fold(
              '',
              function(_, item) self.left[#self.left + 1] = icon(item, 2) end
            )
          end
        end,
        provider = function(self)
          if not falsy(self.left) then return table.concat(self.left, '') end
          return ' '
        end,
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
      -- spacer,
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
          provider = ' ',
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
            return ' '
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
        hl = 'LineNr',
      },
    },
    -- Folds
    folds = {
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
          if self.handlers.fold then
            self.handlers.fold(self.click_args(self, ...))
          end
        end,
      },
      spacer,
    },
    spacer,
  },
}
