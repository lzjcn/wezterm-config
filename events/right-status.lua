local wezterm = require('wezterm')
local umath = require('utils.math')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ip = require('utils.ip')


---@alias Event.RightStatusOptions { date_format?: string }

---Setup options for the right status bar
local EVENT_OPTS = {}

---@type OptsSchema
EVENT_OPTS.schema = {
   {
      name = 'date_format',
      type = 'string',
      default = '%a %H:%M:%S',
   },
}
EVENT_OPTS.validator = OptsValidator:new(EVENT_OPTS.schema)

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- local ICON_SEPARATOR = nf.oct_dash
local ICON_SEPARATOR = '|'

local ICON_DATE = nf.fa_calendar

local ICON_LAN = nf.md_lan
local ICON_NETWORK = nf.md_network
local ICON_CLOCK = nf.md_clock


---@type string[]
local discharging_icons = {
   nf.md_battery_10,
   nf.md_battery_20,
   nf.md_battery_30,
   nf.md_battery_40,
   nf.md_battery_50,
   nf.md_battery_60,
   nf.md_battery_70,
   nf.md_battery_80,
   nf.md_battery_90,
   nf.md_battery,
}
---@type string[]
local charging_icons = {
   nf.md_battery_charging_10,
   nf.md_battery_charging_20,
   nf.md_battery_charging_30,
   nf.md_battery_charging_40,
   nf.md_battery_charging_50,
   nf.md_battery_charging_60,
   nf.md_battery_charging_70,
   nf.md_battery_charging_80,
   nf.md_battery_charging_90,
   nf.md_battery_charging,
}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
   date      = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
   battery   = { fg = '#f9e2af', bg = 'rgba(0, 0, 0, 0.4)' },
   local_ip   = { fg = '#f9e2af', bg = 'rgba(0, 0, 0, 0.4)' },
   public_ip   = { fg = '#fab387', bg = 'rgba(0, 0, 0, 0.4)' },
   separator = { fg = '#74c7ec', bg = 'rgba(0, 0, 0, 0.4)' }
}

local cells = Cells:new()

cells
   :add_segment('separator', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)

   :add_segment('date_icon', ICON_CLOCK .. '  ', colors.date, attr(attr.intensity('Bold')))
   :add_segment('date_text', '', colors.date, attr(attr.intensity('Bold')))

   :add_segment('battery_icon', '', colors.battery)
   :add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))

   :add_segment('local_ip_icon', ICON_LAN .. '  ', colors.local_ip, attr(attr.intensity('Bold')))
   :add_segment('local_ip', '' , colors.local_ip, attr(attr.intensity('Bold')))

   :add_segment('public_ip_icon', ICON_NETWORK .. '  ', colors.public_ip, attr(attr.intensity('Bold')))
   :add_segment('public_ip', '' , colors.public_ip, attr(attr.intensity('Bold')))


---@return string, string
local function battery_info()
   -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

   local charge = ''
   local icon = ''

   for _, b in ipairs(wezterm.battery_info()) do
      local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
      charge = string.format('%.0f%%', b.state_of_charge * 100)

      if b.state == 'Charging' then
         icon = charging_icons[idx]
      else
         icon = discharging_icons[idx]
      end
   end

   return charge, icon .. ' '
end

---@param opts? Event.RightStatusOptions Default: {date_format = '%a %H:%M:%S'}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS.validator:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   wezterm.on('update-right-status', function(window, _pane)
      -- local battery_text, battery_icon = battery_info()

      cells
         :update_segment_text('date_text', wezterm.strftime(valid_opts.date_format))
         -- :update_segment_text('battery_icon', battery_icon)
         -- :update_segment_text('battery_text', battery_text)
         :update_segment_text('local_ip', ip.local_ip())
         :update_segment_text('public_ip', ip.public_ip())


      window:set_right_status(
         wezterm.format(
            -- cells:render({ 'public_ip_icon', 'public_ip', 'separator', 'local_ip_icon', 'local_ip', 'separator', 'date_icon', 'date_text', 'separator', 'battery_icon', 'battery_text' })
            cells:render({ 'public_ip_icon', 'public_ip', 'separator', 'local_ip_icon', 'local_ip', 'separator', 'date_icon', 'date_text'})
         )
      )
   end)
end

return M
