
-----------------------------------------
--  Setup Variable Names    
-----------------------------------------

SpellInfo = {}
SpellInfo.constants = {}
SpellInfo.constants.specs = {}
SpellInfo.constants.spells = {}
SpellInfo.constants.start = {}
SpellInfo.constants.finish = {}
SpellInfo.constants.groups = {}

local c = SpellInfo.constants
local specs = SpellInfo.constants.specs
local spells = SpellInfo.constants.spells
local start = SpellInfo.constants.start
local finish = SpellInfo.constants.finish
local groups = SpellInfo.constants.groups



----------------------------------------
-- Spell Groups 
----------------------------------------

groups.raidheal = {name = "raidheal", title= "Healing Cooldowns" }



---------------------------------------
--  Spells
---------------------------------------

-- MONK
	--Life Cocoon
	spells[116849] = {group1 = "raidheal", len=12, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="LifeCocoon"}
	-- Revival
	spells[115310] = {group1 = "raidheal", len=3, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", soundfile="Revival", soundfile='Revival'}

	
--ROGUE
	-- Smoke Bomb
	spells[76577] = {group1 = "raidheal", len=7, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="SmokeBomb"}

-- DK
	-- AMZ
	spells[51052] = {group1 = "raidheal", len=10, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='AMZ'}
	-- Raise Ally
	spells[61999] = {group1 = "res", len=3, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='RaiseAlly'}


-- Priest
	-- DH
	spells[64843] = {group1 = "raidheal", len=8, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='DivineHymn'}
	-- Barrier
	spells[62618] = {group1 = "raidheal", len=10, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='PWB'}
	-- Vampiric Embrace
	spells[15286] = {group1 = "raidheal", len=8, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='VampiricEmbrace'}
	-- Pain Suppression
	spells[33206] = {group1 = "raidheal", len=8, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='PainSuppression'}
	-- Guardian Spirit
	spells[47788] = {group1 = "raidheal", len=10, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='GuardianSpirit'}

	
-- Warrior
	--Rally
	spells[97462] = {group1 = "raidheal", len=10, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile='RallyingCry'}

-- Shaman 
	-- AG
	spells[108281] = {group1 = "raidheal", len=10, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="AncestralGuidance"}

	-- HTT
	spells[108280] = {group1 = "raidheal", len=11, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", soundfile="HealingTideTotem"}

	-- Spirit Link
	spells[98008] = {group1 = "raidheal", len=6, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", soundfile="SpiritLinkTotem"}

	-- Riptide -- clearly not something we want to track - this is for testing. If it's uncommented, I dun screwed up
	--spells[61295] = {group1 = "raidheal", len=5, cd=1, mt=false, start="SPELL_CAST_SUCCESS", soundfile='0342'}

-- Paladin
	-- DA
	spells[31821] = {group1 = "raidheal", len=6, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="DevotionAura"}
	-- Hand of Sac
	spells[6940] = {group1 = "raidheal", len=12, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="HandofSac"}
	-- Hand of Purity
	spells[114039] = {group1 = "raidheal", len=6, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="HandofPurity"}

--Druid
	--tranq
	spells[740] = {group1 = "raidheal", len=8, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="Tranquility"}
	--IronBark
	spells[102342] = {group1 = "raidheal", len=12, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="Ironbark"}
	--Rebirth
	spells[20484] = {group1 = "res", len=3, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="Rebirth"}

--Hunter

	--aspect of the fox
	spells[172106] = {group1 = "raidheal", len=6, cd=180, mt=true, start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="AspectoftheFox"}
--Warlock
	--soulstone
	spells[20707] = {group1 = "res", len=3, cd=180, mt=false,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED", soundfile="Soulstone"}

--Mage
	--amplify magic
	spells[159916] = {group1 = "raidheal", len=6, cd=120, mt=true, start='SPELL_CAST_SUCCESS', finish='SPELL_AURA_REMOVED', soundfile="AmplifyMagic"}



--testing only
--soothing
--spells[115175] = {group1 = "raidheal", len=12, cd=180, mt=true,  start="SPELL_CAST_SUCCESS", finish="SPELL_AURA_REMOVED"}