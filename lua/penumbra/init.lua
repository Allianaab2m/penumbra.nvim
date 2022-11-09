local o = vim.o
local g = vim.g
local cmd = vim.cmd
local nvim_set_hl = vim.api.nvim_set_hl
local tbl_deep_extend = vim.tbl_deep_extend

local palette = require('penumbra.palette')

local DEFAULT_CONFIG = {
  italic_comment = false,
  transparent_bg = false,
  show_end_of_buffer = false,
  lualine_bg_color = nil,
  light = false,
  contrast = nil,
  colors = palette.contrast,
  overrides = {},
}

local TRANSPARENTS = {
  'Normal',
  'SignColumn',
  'NvimTreeNormal',
  'NvimTreeVertSplit',
}

local function apply_term_colors(colors)
  g.terminal_color_0 = colors.shade_m
  g.terminal_color_1 = colors.red
  g.terminal_color_2 = colors.green
  g.terminal_color_3 = colors.yellow
  g.terminal_color_4 = colors.purple
  g.terminal_color_5 = colors.magenta
  g.terminal_color_6 = colors.cyan
  g.terminal_color_7 = colors.sun
  g.terminal_color_8 = colors.sun_m
  g.terminal_color_9 = colors.red
  g.terminal_color_10 = colors.green
  g.terminal_color_11 = colors.yellow
  g.terminal_color_12 = colors.blue
  g.terminal_color_13 = colors.magenta
  g.terminal_color_14 = colors.cyan
  g.terminal_color_15 = colors.sun_p
  g.terminal_color_background = colors.shade
  g.terminal_color_foreground = colors.sky
end

--@param configs DefaultConfig
local function apply(configs)
  local colors = configs.colors

  if configs.contrast == 'plus' then
    colors = palette.contrast_p
  elseif configs.contrast == 'plusplus' then
    colors = palette.contrast_pp
  end

  apply_term_colors(colors)
  configs.colors = colors
  local groups = require('penumbra.groups').setup(configs)

  if configs.transparent_bg then
    for _, group in ipairs(TRANSPARENTS) do
      groups[group].bg = nil
    end
  end

  for group, setting in pairs(configs.overrides) do
    groups[group] = setting
  end

  for group, setting in pairs(groups) do
    nvim_set_hl(0, group, setting)
  end
end

local local_configs = DEFAULT_CONFIG

local function setup(configs)
  if type(configs) == 'table' then
    local_configs = tbl_deep_extend('force', DEFAULT_CONFIG, configs)
  end
end

local function load()
  if vim.version().minor < 7 then
    vim.notify_once('[penumbra.nvim]: You must use Neovim v0.7 or higher.')
    return
  end

  if g.colors_name then
    cmd('hi clear')
  end

  if vim.fn.exists('syntax_on') then
    cmd('syntax reset')
  end

  o.background = 'dark'
  o.termguicolors = true
  g.colors_name = 'penumbra'

  apply(local_configs)
end

return {
  load = load,
  setup = setup,
  configs = function()
    return local_configs
  end,
  colors = function()
    return local_configs.colors
  end,
}
