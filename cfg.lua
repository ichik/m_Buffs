  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\Addons\\m_Buffs\\media\\"
  cfg.auratex = MediaPath.."iconborder" 
  cfg.font = MediaPath.."font.ttf"
  cfg.backdrop_texture = "Interface\\Buttons\\WHITE8x8"
  cfg.backdrop_edge_texture = "Interface\\Buttons\\WHITE8x8"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.iconsize = 32							-- Buffs and debuffs size
  cfg.timefontsize = 14									-- Time font size
  cfg.countfontsize = 15								-- Count font size
  cfg.spacing = 4										-- Spacing between icons
  cfg.timeYoffset = -3									-- Verticall offset value for time text field
  cfg.BUFFpos = {"TOPRIGHT","UIParent", -25, -25} 		-- Buffs position
  cfg.DEBUFFpos = {"TOPLEFT", "oUF_monoPlayerFrame", 0, 40}	-- Debuffs position

  -- HANDOVER
  ns.cfg = cfg
