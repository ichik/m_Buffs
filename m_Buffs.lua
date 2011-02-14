local addon, ns = ...
local cfg = ns.cfg

  local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/GetCVar("uiScale")
  local function scale(x) return mult*math.floor(x+.5) end

SetCVar("consolidateBuffs",0) -- disabling consolidated buffs (temp.)
SetCVar("buffDurations",1) -- enabling buff durations
BUFFS_PER_ROW = 16
DEBUFF_MAX_DISPLAY = 6

local backdrop_tab = { 
     bgFile = cfg.backdrop_texture, 
    edgeFile = cfg.backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = scale(1), 
	insets = { left = -scale(1), right = -scale(1), top = -scale(1), bottom = -scale(1)}}
local overlay

local make_backdrop = function(f)
	--f:SetFrameLevel(5)
	f:SetPoint("TOPLEFT",-1,1)
	f:SetPoint("BOTTOMRIGHT",1,-1)
	f:SetBackdrop(backdrop_tab);
	f:SetBackdropColor(.1,.1,.1,1)
	f:SetBackdropBorderColor(.3,.3,.3,1)
end

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint(unpack(cfg.BUFFpos))
ConsolidatedBuffs:SetSize(cfg.iconsize, cfg.iconsize)
ConsolidatedBuffs.SetPoint = nil
ConsolidatedBuffsIcon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
ConsolidatedBuffsIcon:SetTexCoord(0.03,0.97,0.03,0.97)
ConsolidatedBuffsIcon:SetSize(cfg.iconsize-2,cfg.iconsize-2)
local h = CreateFrame("Frame")
h:SetParent(ConsolidatedBuffs)
h:SetAllPoints(ConsolidatedBuffs)
h:SetFrameLevel(30)
ConsolidatedBuffsCount:SetParent(h)
ConsolidatedBuffsCount:SetPoint("BOTTOMRIGHT")
ConsolidatedBuffsCount:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
local CBbg = CreateFrame("Frame", nil, ConsolidatedBuffs)
make_backdrop(CBbg)

for i = 1, 3 do
	_G["TempEnchant"..i.."Border"]:Hide()
	local te 			= _G["TempEnchant"..i]
	local teicon 		= _G["TempEnchant"..i.."Icon"]
	local teduration 	= _G["TempEnchant"..i.."Duration"]
	local h = CreateFrame("Frame")
	h:SetParent(te)
	h:SetAllPoints(te)
	h:SetFrameLevel(30)
	te:SetSize(cfg.iconsize,cfg.iconsize)
	teicon:SetPoint("TOPLEFT", te, 1, -1)
	teicon:SetPoint("BOTTOMRIGHT", te, -1, 1)
	teicon:SetTexCoord(.08, .92, .08, .92)
	teduration:ClearAllPoints()
	teduration:SetParent(h)
	teduration:SetPoint("BOTTOM", 0, cfg.timeYoffset)
	teduration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
	local bg = CreateFrame("Frame", nil, te)
	bg:SetFrameLevel(0)
	make_backdrop(bg)
end

local function CreateBuffStyle(buttonName, i, debuff)
	local buff		= _G[buttonName..i]
	local icon		= _G[buttonName..i.."Icon"]
	local border	= _G[buttonName..i.."Border"]
	local duration	= _G[buttonName..i.."Duration"]
	local count 	= _G[buttonName..i.."Count"]
	if icon and not _G[buttonName..i.."Background"] then
		local h = CreateFrame("Frame")
		h:SetParent(buff)
		h:SetAllPoints(buff)
		h:SetFrameLevel(30)
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("TOPLEFT", buff, 1, -1)
		icon:SetPoint("BOTTOMRIGHT", buff, -1, 1)
		buff:SetSize(cfg.iconsize,cfg.iconsize)
		duration:ClearAllPoints()
		duration:SetParent(h)
		duration:SetPoint("BOTTOM", 0, cfg.timeYoffset)
		duration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
		local bg = CreateFrame("Frame", buttonName..i.."Background", buff)
		bg:SetFrameLevel(0)
		make_backdrop(bg)
		count:SetParent(h)
		count:ClearAllPoints()
		count:SetPoint("TOPRIGHT")
		count:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
	end
	if border then 
		border:SetTexture(cfg.auratex)
		border:SetTexCoord(0.03, 0.97, 0.03, 0.97)
		border:SetPoint("TOPLEFT",-scale(1),scale(1))
		border:SetPoint("BOTTOMRIGHT",scale(1),-scale(1))
	end
end

local function OverrideBuffAnchors()
	local buttonName = "BuffButton" -- c
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local slack = BuffFrame.numEnchants
	if ( BuffFrame.numConsolidated > 0 ) then
		slack = slack + 1;	
	end
	for i=1, BUFF_ACTUAL_DISPLAY do
		CreateBuffStyle(buttonName, i, false)
		local buff = _G[buttonName..i]
		if not ( buff.consolidated ) then	
			numBuffs = numBuffs + 1
			i = numBuffs + slack
			buff:ClearAllPoints()
			if ( (i > 1) and (mod(i, BUFFS_PER_ROW) == 1) ) then
 				if ( i == BUFFS_PER_ROW+1 ) then
					buff:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -10)
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -10)
				end
				aboveBuff = buff; 
			elseif ( i == 1 ) then
				buff:SetPoint(unpack(cfg.BUFFpos))
			else
				if ( numBuffs == 1 ) then
					local  mh, _, _, oh, _, _, te = GetWeaponEnchantInfo()
					if mh and oh and te and not UnitHasVehicleUI("player") then
						buff:SetPoint("TOPRIGHT", TempEnchant3, "TOPLEFT", -cfg.spacing, 0);
					elseif ((mh and oh) or (mh and te) or (oh and te)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -cfg.spacing, 0);
					elseif ((mh and not oh and not te) or (oh and not mh and not te) or (te and not mh and not oh)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -cfg.spacing, 0)
					else
						buff:SetPoint("TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", -cfg.spacing, 0);
					end
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.spacing, 0);
				end
			end
			previousBuff = buff
		end		
	end
end

local function OverrideDebuffAnchors(buttonName, i)
	CreateBuffStyle(buttonName, i, true)
	local color
	local buffName = buttonName..i
	local dtype = select(5, UnitDebuff("player",i))   
	local debuffSlot = _G[buffName.."Border"]
	local debuff = _G[buttonName..i];
	debuff:ClearAllPoints()
	if i == 1 then
		debuff:SetPoint(unpack(cfg.DEBUFFpos))
	else
		debuff:SetPoint("LEFT", _G[buttonName..(i-1)], "RIGHT", cfg.spacing, 0)
	end
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	if debuffSlot then debuffSlot:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1) end
end

-- fixing the consolidated buff container sizes because the default formula is just SHIT!
local z = 0.79 -- 37 : 28 // 30 : 24 -- dasdas;djal;fkjl;jkfsfoi !!!! meaningfull comments we all love them!!11
local function OverrideConsolidatedBuffsAnchors()
	ConsolidatedBuffsTooltip:SetWidth(min(BuffFrame.numConsolidated * cfg.iconsize * z + 18, 4 * cfg.iconsize * z + 18));
    ConsolidatedBuffsTooltip:SetHeight(floor((BuffFrame.numConsolidated + 3) / 4 ) * cfg.iconsize * z + CONSOLIDATED_BUFF_ROW_HEIGHT * z);
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", OverrideBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", OverrideDebuffAnchors)
hooksecurefunc("ConsolidatedBuffs_UpdateAllAnchors", OverrideConsolidatedBuffsAnchors)
