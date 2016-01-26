-- Test checking


------------------------------------
--  Setup Variable names          --
------------------------------------
local SWRaidCD = LibStub("AceAddon-3.0"):NewAddon("SWRaidCD", "LibBars-1.0", "AceEvent-3.0", "AceConsole-3.0") 
local version = GetAddOnMetadata("SWRaidCD", "Version")
if version:match("@") then
	version = "Development"
else
	version = "Alpha" .. version
end
--add localization
SWRaidCD.L = L
--decare teh database
local db

--------------------------------------
-- Additional Libraries
--------------------------------------
local Media = LibStub:GetLibrary("LibSharedMedia-3.0")
local DataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
local Bars = LibStub:GetLibrary("LibBars-1.0")
Media:Register("statusbar", "Blizzard", [[Interface\TargetingFrame\UI-StatusBar]])
-------------------------------------
-- Spell info for bars
-------------------------------------
local c = SpellInfo.constants;
local specs = SpellInfo.constants.specs;
local start = SpellInfo.constants.start;
local finish = SpellInfo.constants.finish;
local spells = SpellInfo.constants.spells;
local groups = SpellInfo.constants.groups;
local localclasses = {}
local skins = {}


local activebars = {}
local activeanchor = {}
local available = {}
local cooldowns = {}
local sortedcooldowns = {}
local GetTime = GetTime

-------------------------------------
-- Setup some defaults
-------------------------------------
local defaults = {
	profile = {
		barHeight = 20,
		barWidth = 300, 
		enableAddon = true, 
		enableSound=true,
		horizontalOrientation = "RIGHT",
		maxBars = 10,
		scale = 1.0,
		hideAnchor = false,
		BarX = 400,
		BarY = 400,
		fontFlags = "NONE", 
		fontScale = 12, 
		fontType = "Friz Quadrata TT", 
		BarBorder = "None", 
		BarTexture = "Blizzard", 
     	BarsColour = { r = 0, g = 1, b = 0, a = 1 },
     	borderThickness = 10,
     	BarsAlpha = 1,
     	BarsIcon = true,
     	reverseGrowth=false,
     	showBattleRes = true


	}
}

-----------------------------------------
-- Setup the addon 
-----------------------------------------
function SWRaidCD:OnInitialize()
	--register saved variaables
	db = LibStub("AceDB-3.0"):New("SWRaidCDDB", defaults, true)
	db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileReset", "OnNewProfile")
	db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
	self.db = db
	self:SetEnabledState(self.db.profile.enableAddon)
	
	--addon options table
	self.options = OptionsTable(self)
	-- add profiles
	self.options.args.profilesTab = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profilesTab.order = 50

	--Register options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SWRaidCD", self.options)
	--Add to Blizzard Window
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SWRaidCD", "SWRaidCD")

	--support for LibAbout
	if LibStub:GetLibrary("LibAboutPanel", true) then
		self.optionsFrame["About"] = LibStub("LibAboutPanel").new("SWRaidCD", "SWRaidCD")
	end

	-- auto expand the sub-panels
	do 
		self.optionsFrame:HookScript("OnShow", function(self)
			if InCombatLockdown() then return end
			local target = self.parent or self.name
			local i = 1
			local button = _G["InterfaceOptionsFrameAddonsButton"..i]
			while button do
				local element = button.element
				if element.name == target then
					if element.hasChildren and element.collapsed then
						_G["InterfaceOptionsFrameAddonsButton"..i.."Toggle"]:Click()
					end
					return
				end
				i = i + 1
				button = _G["InterfaceOptionsFrameAddonsButton"..i]
			end
		end)
		local function OnClose(self)
			if InCombatLockdown() then return end
			local target = self.parent or self.name
			local i = 1
			local button = _G["InterfaceOptionsFrameAddonsButton"..i]
			while button do
				local element=button.element
				if element.name == target then
					if element.hasChildren and not element.collapsed then 
						local selection = InterfaceOptionsFrameAddons.selection
						if not selection or selection.parent ~= target then
							_G["InterfaceOptionsFrameAddonsButton"..i.."Toggle"]:Click()
						end
					end
					return
				end
				i= i +1
				button = _G["InterfaceOptionsFrameAddonsButton"..i]
			end
		end
		hooksecurefunc(self.optionsFrame, "okay", OnClose)
		hooksecurefunc(self.optionsFrame, "cancel", OnClose)
	end

	--add console commands
	self:RegisterChatCommand("sw", "SlashHandler")
	self:RegisterChatCommand("swraidcd", "SlashHandler")

	--Create DataBroker
	if DataBroker then
		local launcher = DataBroker:NewDataObject("SWRaidCD", {
			type = "launcher",
			OnClick = function(clickedframe, button)
				if button == "LeftButton" then
					self.db.profile.hideAnchor = not self.db.profile.hideAnchor
					if self.db.profile.hideAnchor then
						self.RaidCD_group.HideAnchor()
						self.RaidCD_group.Lock()
					else
						self.RaidCD_group.ShowAnchor()
						self.RaidCD_group.Unlock()
						self.RaidCD_group.SetClampedToScreen(true)
					end
					LibStub("AceConfigRegistry-3.0"):NotifyChange("SWRaidCD")
				elseif button == "RightButton" then
					InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
				elseif button == "Middle Button" then
					self:StartTestBars()
				end
			end,
			OnTooltipShow = function(self)
				GameTooltip:AddLine("SWRaidCD".." "..version, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				GameTooltip:AddLine("Left Click to lock/unlock bars. Right click for Config.\n Middle click for Test Bars.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				GameTooltip:Show()
			end
		})
		self.launcher = launcher
	end



	--------------------------------------
	-- Build tables 
	--------------------------------------

	for k,v in pairs(spells) do 
		--icons and names

		local name, _, icon = GetSpellInfo(k)
		if (not v.name) then -- allow a custom name
			v.name = name;
		end
		if (not v.icon) then -- custom icon
			v.icon = icon;
		end
		v.id = k;
		if v.group1 == 'raidheal' then
			v.group = 'heal'
		elseif v.group1 == 'res' then 
			v.group = 'res'
		end
		
	
		--localize talent names
		if (v.talents) then 
			for tid, t in pairs(v.talents) do 
				local name = GetSpellInfo(tid);
				if (not t.name) then 
					t.name = name;
				end
			end
		end
	
		if (v.glyphs) then 
			for gid, g in pairs(v.glyphs) do
				local name = GetSpellInfo(gid)
				if (not g.name) then 
					g.name = name;
				end
			end
		end
	
		if (v.thetalent) then
			local name = GetSpellInfo(v.thetalent);
			v.thetalent = name;
		end
		
		--start and end tables
		if (v.start) then 
			if (not start[v.start]) then start[v.start] = {}; end
			start[v.start][k] = v;		
		end
		if (v.finish) then
			if (not finish[v.finish]) then finish[v.finish] = {}; end
			finish[v.finish][k] = v;
		end
	end

end

function SWRaidCD:OnDisable()
	self:UnregisterAllEvents()
	Media.UnregisterAllCallbacks(self)
	self.RaidCD_group.UnregisterAllCallbacks(self)
end

function SWRaidCD:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	--Create the bar groupsf
	self.RaidCD_group = self.RaidCD_group or SWRaidCD:NewBarGroup("Raid CDs", self.db.profile.horizontalOrientation, 300, 15, "SWRaidCD_bars")
	RaidCD_group = self.RaidCD_group
	self.RaidCD_group:SetClampedToScreen(true)
	if self.db.profile.hideAnchor then
		self.RaidCD_group:HideAnchor()
		self.RaidCD_group:Lock()
	else
		self.RaidCD_group:ShowAnchor()
		self.RaidCD_group:Unlock()
	end

	self.RaidCD_group:SetMaxBars(self.db.profile.maxBars)
	self.RaidCD_group:SetHeight(self.db.profile.barHeight)
	self.RaidCD_group:SetWidth(self.db.profile.barWidth)
	self.RaidCD_group:SetScale(self.db.profile.scale)
	self.RaidCD_group:ReverseGrowth(self.db.profile.reverseGrowth)
	self:RestorePosition()
	Media.RegisterCallback(self, "OnValueChanged", "UpdateMedia")
	self.RaidCD_group.RegisterCallback(self, "AnchorMoved", "SavePosition")
	self.RaidCD_group.RegisterCallback(self, "AnchorClicked")



end

function SWRaidCD:AnchorClicked(callback, group, button)

	if button == "RightButton" then
		self.RaidCD_group:HideAnchor()
		self.RaidCD_group:Lock()
		self.db.profile.hideAnchor = true
	end
end

function SWRaidCD:SavePosition()
	local f = self.RaidCD_group
	local s = f:GetEffectiveScale()
	self.db.profile.BarX = f:GetLeft()*s
	self.db.profile.BarY = f:GetTop()*s
end

function SWRaidCD:RestorePosition()
	local x =self.db.profile.BarX
	local y = self.db.profile.BarY
	if not x or not y then return end

	local f = self.RaidCD_group
	local s = f:GetEffectiveScale()
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/s, y/s)
end

function SWRaidCD:UpdateMedia(callback, type, handle)
	if type == 'statusbar' then
		self.RaidCD_group:SetTexture(Media:Fetch("statusbar", self.db.profile.BarsTexture))
	elseif type == "border" then
		self.RaidCD_group:SetBackdrop({
			edgeFile = Media:Fetch("border", self.db.profile.BarBorder),
			tile = false,
			tileSize = self.db.profile.scale + 1, 
			edgeSize = self.db.profile.borderThickness,
			insets = {left=0, right=0, top=0, bottom=0}
			})
	elseif type == "font" then 
		self.RaidCD_group:SetFont(Media:Fetch("font", self.db.profile.fontType), self.db.profile.fontScale, self.db.profile.fontFlags)
	end
end
-------------------------------------------
-- Tools for tracking party versus raid
-------------------------------------------
-- process slash commands ---------------------------------------------------
function SWRaidCD:SlashHandler(input)
	input = input:lower()
	if input == "test" then
		self:StartTestBars()
	elseif input == "toggle" or input == "anchor" then
		if self.db.profile.hideAnchor == false then
			self.RaidCD_group:HideAnchor()
			self.RaidCD_group:Lock()
			self.db.profile.hideAnchor = true
		else
			self.RaidCD_group:ShowAnchor()
			self.RaidCD_group:Unlock()
			self.RaidCD_group:SetClampedToScreen(true)
			self.db.profile.hideAnchor = false
		end
	elseif input == "grow" then
		if self.db.profile.reverseGrowth == true then 
			value=false
		else
			value = true
		end
		self.db.profile.reverseGrowth = value
		self.RaidCD_group:ReverseGrowth(value)	
	else
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
end
---Generic info for solo/party/raid
local function getgroupUnitInfo(index)
	local raidN = GetNumGroupMembers()	
	local doReturnSelf = false;
	if (raidN>0) then
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index);
		return name, class, online, isDead, subgroup;
	else
		doReturnSelf=true;
	end	
	if(doReturnSelf) then
		local name = UnitName("player");
		local class = UnitClass("player");
		local online = true;
		local isDead = UnitIsDeadOrGhost("player");
		return name, class, online, isDead, 1
	end
end

local function updateRoster()
	local total = getNumGroupMembers();
	if(total == 1) then -- clear when leaving party
		local count = 0;
		for k,v in pairs(cooldowns) do
			count = count + 1
		end
		if(count > 1) then
			cooldowns = {};
			sortedcooldowns = {}
		end
	end
	for k,v in pairs(cooldowns) do -- disable availability by default todo: this is an ugly way of achieving what i want
		for k2,v2 in pairs(v) do
			if(v2.available) then
				v2.available = false;
			end
		end
	end
	for i=1, total do
		local name, class, online, isDead, subgroup = getGroupUnitInfo(i);
		if(name and (db.subgroups["group"..subgroup] == 1)) then
			if(not cooldowns[name]) then
				cooldowns[name] = {}
				cooldowns[name].name = name;
			end
			local _, classnolocale = UnitClass(name);
			local mastery = getMastery(name);
			local icons = {}
			icons[1], icons[2], icons[3] = talents:GetTreeIcons(classnolocale);
			cooldowns[name].classicon = icons[mastery];
			for k,v in pairs(spells) do
				if(v.class == classnolocale and dbpc.spellvisibility[v.id] == 1) then
					local cd = getCooldown(v, name);
					local available
					if(not cd or isDead or (not online)) then
						available = false
					else
						available = true;
					end
					if(not cooldowns[name][v.id]) then
						cooldowns[name][v.id] = {lastused=-999999, available=available, cd=cd};
						table.insert(sortedcooldowns, {root=cooldowns[name] ,spellid = v.id,info=cooldowns[name][v.id] }); -- using a ref here, so should stay up to date!
					else
						cooldowns[name][v.id].available = available;
						cooldowns[name][v.id].cd = cd;
					end				
				end
			end
		end
	end
	
	table.sort(sortedcooldowns, function (a,b)
		if(a.spellid < b.spellid) then
			return true;
		elseif(a.spellid == b.spellid) then
			return a.root.name < b.root.name;
		else
			return false
		end
	end)
	
end

-----------------------------------------
-- Manage bars 
-----------------------------------------
local function sortBars()
	local refs = {}
	for k, v in pairs(activebars) do 
		if (v.expires <= GetTime()) then
			activebars[k] = nil;
		else
			table.insert(refs, {expires = v.expires, key=k});
		end
	end
	table.sort(refs, function(a, b) return a.expires < b.expires end);
	for i = 1, getn(refs) do 
		local bar = activebars[refs[i].key].barl
		if (bar) then 
			bar:SetPoint("TOP", activeanchor.frame, "BOTTOM", 0, -db.activebarheight*(i-1))
		else
			activebars[refs[i].key] = nil
		end 
		i = i+1
	end
	refs = nil;
end

local totalelapsed = 0 ;
local function onUpdate(self, elapsed, ...)
	totalelapsed = totalelapsed + elapsed;
	if (totalelapsed >= 0.3) then
		totalelapsed = 0;
		-- updateCoolDownFrame();
	end
end

--test bars
function SWRaidCD:StartTestBars()
	if not self.db.profile.enableAddon then return end
	orientation = (db.profile.horizontalOrientation == "RIGHT") and Bars.RIGHT_TO_LEFT or Bars.LEFT_TO_RIGHT
	SWRaidCDDrawNewBar("Test Bar 1", 4, spells[76577].icon, 0, 'ROGUE')
	SWRaidCDDrawNewBar("Test Bar 2", 5, spells[740].icon, 0, "DRUID")
	SWRaidCDDrawNewBar("Test Bar 3", 6, spells[115176].icon, 0, 'MONK')
	SWRaidCDDrawNewBar("Test Bar 4", 7, spells[15286].icon, 0, 'PRIEST')
	SWRaidCDDrawNewBar("Test Bar 5", 8, spells[108280].icon, 0, 'SHAMAN')


end

function SWRaidCDDrawNewBar(title, duration, icon, descriptor, class, soundfile)


	bar = RaidCD_group:NewTimerBar(title, title, duration, nil, icon, 0)
	orientation = (db.profile.horizontalOrientation == "RIGHT") and Bars.RIGHT_TO_LEFT or Bars.LEFT_TO_RIGHT
	t = db.profile.BarsColour
	if db.profile.classColours and class ~= nil then
		local c = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		bar.texture:SetVertexColor(c.r, c.g, c.b, t.a)
	else
		bar.texture:SetVertexColor(t.r, t.g, t.b, t.a)
	end
	bar:SetOrientation(orientation)
	bar:ShowIcon()
	bar:SetFont(Media:Fetch("font", db.profile.fontType), db.profile.fontScale, db.profile.fontFlags)
	bar:SetTexture(Media:Fetch("statusbar", db.profile.BarsTexture))
	bar:SetBackdrop({
		edgefile = Media:Fetch("border", db.profile.BarBorder), 
		tile=true,
		tileSize=db.profile.scale+1, 
		edgeSize=db.profile.borderThickness, 
		insets = {left=0, right=0, bottom=0, top=0}
		})

	activebars[descriptor] = {expires=GetTime()+duration, bar=bar}

	if db.profile.enableSound then 
		local willplay, soundhandle = PlaySoundFile(soundfile, "Master")
	end
end	
-------------------------------------------------------------
-- bars for active cooldowns
-------------------------------------------------------------
local function spellUsed(spell, sourceGUID, targetGUID, sourceName, targetName, duration)

	local duration = duration or spell.len
	local descriptor = spell.id .. sourceGUID;

	local label;
	local soundfile;

	raidN = GetNumGroupMembers()
	local i = 0
	local isingroup = 0
	
	if (raidN == 0) then 
		member = getgroupUnitInfo(1)
	
		if member == sourceName then isingroup = 1; end
	else
		for i = 0,raidN do
			member = getgroupUnitInfo(i)
			if member == sourceName then isingroup = 1; end
			i = i + 1
		end
	end

	if isingroup == 0 then return; end

	if(spell.mt) then 
		label = spell.name .. " (" .. sourceName .. ")"
	else
		label = spell.name .. " (" .. sourceName .. " -> " .. targetName .. ")"
	end
	if(spell.soundfile) then
		soundfile = "Interface\\Addons\\SWRaidCD\\Sounds\\" .. spell.soundfile .. ".mp3";
	end

	local text
	local descriptor = spell.id .. sourceGUID;
	local _, class = UnitClass(sourceName)
	SWRaidCDDrawNewBar(label, duration, spell.icon, descriptor, class, soundfile)
	
	
end

local function spellFinish(spell, sourceGUID, targetGUID, sourceName, targetName)
	local descriptor = spell.id .. sourceGUID;
	if(activebars[descriptor]) then
		if (activebars[descriptor].expires > GetTime()) then
			RaidCD_group:RemoveBar(activebars[descriptor].bar);
		end
		activebars[descriptor] = nil;
	end
end

local function print(message)
	ChatFrame1.AddMessage(message)
end
---------------------------
-- Spell events
---------------------------

local function SpellCastSuccess( event, sourceGUID, targetGUID, sourceName, targetName, spellId, spellName)
	if ((start[event] ~= nil) and (start[event][spellId] ~= nil)) then
		local spell = start[event][spellId];
		if ((not spell.mt) or event=="SPELL_CAST_SUCCESS" or (spell.mt and targetGUID==sourceGUID)) then
			local spellname, _, _, _, _, endTime=UnitChannelInfo(sourceName);
			local duration
			if (spellname) then
				duration = endTime/1000.0 - GetTime();
			end
			if (not db.profile.showBattleRes) and (spell.group == 'res') then return; end
			spellUsed(spell, sourceGUID, targetGUID, sourceName, targetName, duration)
		end
	end
end

local function SpellAuraRemoved( event, sourceGUID, targetGUID, sourceName, targetName, spellId, spellName)
	if(finish[event] ~= nil and finish[event][spellId] ~= nil) then
		local spell = finish[event][spellId];
		if(not spell.mt or (spell.mt and targetGUID == sourceGUID)) then
			spellFinish(spell, sourceGUID, targetGUID, sourceName, targetName)
		end
	end
end
	
	
-----------------------------
-- Housekeeping
----------------------------
--User changes profile
function SWRaidCD:OnProfileChanged()
	db = self.db 
end

--New Profile
function SWRaidCD:OnNewProfile()
end


------------------------------------
-- Event Handling
------------------------------------
local events = {}

function SWRaidCD:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceraidFlags, targetGUID, targetName, targetFlags = select(1, ...)
	if type == "SPELL_CAST_SUCCESS" then 
		local spellId, spellName = select(12, ...)
		SpellCastSuccess(type, sourceGUID, targetGUID, sourceName, targetName, spellId); end
	if type == "SPELL_AURA_REMOVED" then 
		local spellId, spellName = select(12, ...)
		SpellAuraRemoved(type, sourceGUID, targetGUID, sourceName, targetName, spellId); end
end

--eventcatcher:SetScript("OnEvent", function(self, event, ...)
--	events[event](self, ...);
--end);
--eventcatcher:SetScript("OnUpdate", function(...)
--	onUpdate(...);
--end);
--for k, v in pairs(events) do
--	eventcatcher:RegisterEvent(k); 
--end
