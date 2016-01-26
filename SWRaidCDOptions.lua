local addon = LibStub("AceAddon-3.0"):GetAddon("SWRaidCD")


local optWidth = nil
if locale ~= "enUS" then
	optWidth = "double"
end

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function OptionsTable(self)
	local AceConfig = LibStub("AceConfig-3.0")
	local options = {
		name = "SWRaidCD",
		handler = addon,
		type = "group",
		childGroups = "tab",
		args = {
			barsOptionsTab = {
				name = "Bar Layout",
				desc = "Options for the CD Bar",
				type = "group",
				order = 1,
				args = {
					barsOptionsHeader = {
						order = 10,
						type = "header",
						name = "Bar Layout"
					},
					BarsTestBars = {
						order = 20,
						type = "execute",
						name = "Test Bars",
						desc = "Show the test bars",
						func = function() self:StartTestBars() end,
						width = optWidth
					},
					spacer1 = {
						type = "description",
						name = "",
						order = 30
					},
					enableAddon = {
						order = 40,
						type = "toggle",
						name = "Enable SWRaidCD",
						desc = "Uncheck to disable SWRaidCD",
						get = function() return self.db.profile.enableAddon end,
						set = function(info, value)
							self.db.profile.enableAddon = value
							if value then
								self:Enable()
							else
								self:Disable()
							end
						end,
						width = optWidth
					},
					hideAnchor = {
						order = 50,
						type = "toggle",
						name = "Hide Anchor",
						desc = "Toggles the anchor for the res bars so you can move them",
						get = function() return self.db.profile.hideAnchor end,
						set = function(info, value)
							self.db.profile.hideAnchor = value
							if value then
								self.RaidCD_group:HideAnchor()
								self.RaidCD_group:Lock()
							else
								self.RaidCD_group:ShowAnchor()
								self.RaidCD_group:Unlock()
								self.RaidCD_group:SetClampedToScreen(true)
							end
						end,
						width = optWidth
					},
					reverseGrowth = {
						order = 80,
						type = "toggle",
						name = "Grow Upwards",
						desc = "Make the bars grow up instead of down",
						get = function() return self.db.profile.reverseGrowth end,
						set = function(info, value)
							self.db.profile.reverseGrowth = value
							self.RaidCD_group:ReverseGrowth(value)
						end,
						width = optWidth
					},
					resBarsIcon = {
						order = 90,
						type = "toggle",
						name = "Show Icon",
						desc = "Show or hide the icon for spells",
						get = function() return	self.db.profile.BarsIcon end,
						set = function(info, value)
							self.db.profile.BarsIcon = value
							if value then
								self.RaidCD_group:ShowIcon()
							else
								self.RaidCD_group:HideIcon()
							end
						end,
						width = optWidth
					},
					showBattleRes = {
						order = 100,
						type = "toggle",
						name = "Show Battle Resses",
						get = function() return self.db.profile.showBattleRes end,
						set = function(info, value)	self.db.profile.showBattleRes = value end,
						width = optWidth
					},
					classColours = {
						order = 110,
						type = "toggle",
						name = CLASS_COLORS,
						desc = "Use class colours for the target on the bars",
						get = function() return self.db.profile.classColours end,
						set = function(info, value)	self.db.profile.classColours = value end,
						width = optWidth
					},
					spacer2 = {
						type = "description",
						name = "",
						order = 130
					},
					numMaxBars = {
						order = 160,
						type = "range",
						name = "Maximum Bars",
						desc = "Set the maximum of displayed bars.",
						get = function() return self.db.profile.maxBars end,
						set = function(info, value)
							self.db.profile.maxBars = value
							self.RaidCD_group:SetMaxBars(value)
						end,
						min = 1,
						max = 39,
						step = 1,
						width = optWidth
					},
					barHeight = {
						order = 170,
						type = "range",
						name = "Bar Height",
						desc = "Control the height of the bars",
						get = function() return self.db.profile.barHeight end,
						set = function(info, value)
							self.db.profile.barHeight = value
							self.RaidCD_group:SetHeight(value)
						end,
						min = 6,
						max = 64,
						step = 1,
						width = optWidth
					},
					barWidth = {
						order = 180,
						type = "range",
						name = "Bar Width",
						desc = "Control the width of the bars",
						get = function() return self.db.profile.barWidth end,
						set = function(info, value)
							self.db.profile.barWidth = value
							self.RaidCD_group:SetWidth(value)
						end,
						min = 24,
						max = 512,
						step = 1,
						width = optWidth
					},
					scale = {
						order = 190,
						type = "range",
						name = "Scale",
						desc = "Set the scale for the  bars",
						get = function() return self.db.profile.scale end,
						set = function(info, value)
							self.db.profile.scale = value
							self.RaidCD_group:SetScale(value)
						end,
						min = 0.5,
						max = 2,
						step = 0.05,
						width = optWidth
					},
					resBarsAlpha = {
						order = 200,
						type = "range",
						name = OPACITY,
						desc = "Set the Alpha for the  bars",
						get = function() return self.db.profile.BarsAlpha end,
						set = function(info, value)
							self.db.profile.BarsAlpha = value
							self.RaidCD_group:SetAlpha(value)
						end,
						min = 0.1,
						max = 1,
						step = 0.1,
						width = optWidth
					},
					spacer3 = {
						type = "description",
						name = "",
						order = 220
					},
					resBarsTexture = {
						order = 230,
						type = "select",
						dialogControl = "LSM30_Statusbar",
						name = TEXTURES_SUBHEADER,
						desc = "Select the texture for the  bars",
						values = AceGUIWidgetLSMlists.statusbar,
						get = function() return self.db.profile.BarsTexture end,
						set = function(info, value)	self.db.profile.BarsTexture = value end,
						width = optWidth
					},
					horizontalOrientation = {
						order = 250,
						type = "select",
						name = "Horizontal Direction",
						desc = "Change the horizontal direction of the  bars",
						values = {
							["LEFT"] = "Right to Left",
							["RIGHT"] = "Left to Right"
						},
						get = function() return self.db.profile.horizontalOrientation end,
						set = function(info, value) self.db.profile.horizontalOrientation = value end,
						width = optWidth
					},
					spacer4 = {
						type = "description",
						name = "",
						order = 260
					},
					resBarsColour = {
						order = 270,
						type = "color",
						name = "Bar Colour",
						desc = "Pick the colour for non-collision (not a duplicate)  bar",
						hasAlpha = true,
						get = function()
							local t = self.db.profile.BarsColour
							return t.r, t.g, t.b, t.a
						end,
						set = function(info, r, g, b, a)
							local t = self.db.profile.BarsColour
							t.r, t.g, t.b, t.a = r, g, b, a
						end,
						width = optWidth
					},
				}
			},
			
			fontTab = {
				name = "Fonts",
				desc = "Control fonts on the res bars",
				type = "group",
				order = 30,
				args = {
					fontType = {
						order = 10,
						type = "select",
						dialogControl = "LSM30_Font",
						name = "Font Type",
						desc = "Select a font for the text on the res bars",
						values = AceGUIWidgetLSMlists.font,
						get = function() return self.db.profile.fontType end,
						set = function(info, value) self.db.profile.fontType = value end,
						width = optWidth
					},
					fontSize = {
						order = 20,
						type = "range",
						name = FONT_SIZE,
						desc = "Resize the res bars font",
						get = function() return self.db.profile.fontScale end,
						set = function(info, value) self.db.profile.fontScale = value end,
						min = 3,
						max = 20,
						step = 1,
						width = optWidth
					},
					fontFlags = {
						order = 30,
						type = "select",
						name = "Font Style",
						desc = "Nothing, outline, thick outline, or monochrome",
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "THICK_OUTLINE",
							["MONOCHROME,OUTLINE"] = "Outline and monochrome",
							["MONOCHROME,THICKOUTLINE"] = "Thick outline and monochrome"
						},
						get = function() return self.db.profile.fontFlags end,
						set = function(info, value) self.db.profile.fontFlags = value end,
						width = optWidth
					}
				}
			},
			

			soundsTab = {
				name = "Sounds",
				desc = "Configure sounds for alerts",
				type = "group",
				order = 60,
				order = 30,
				args = {
					enableAddon = {
						order = 40,
						type = "toggle",
						name = "Enable Sound Alerts",
						desc = "Uncheck to disable addon sounds",
						get = function() return self.db.profile.enableSound end,
						set = function(info, value)
							self.db.profile.enableSound = value
						end,
						width = optWidth
					},
					
				}
			},

			creditsTab = {
				name = "Credits",
				desc = "About the author and SWRaidCD",
				type = "group",
				order = 60,
				args = {
					creditsHeader1 = {
						order = 1,
						type = "header",
						name = "Credits"
					},
					creditsDesc1 = {
						order = 2,
						type = "description",
						name = "* Created by Arthureld/Drcool on Balnazzar-US Horde. Feel free to ask if there are questions",
						width = optWidth
					},
					creditsDesc2 = {
						order = 3,
						type = "description",
						name = "* Addon created to track active healing/raid CDs for Heroic progression with Skunkworks.",
						width = optWidth
					},
					creditsDesc3 = {
						order = 4,
						type = "description",
						name = "* Inspiration drawn from many addons, but especially the now defunct Raidboss",
						width = optWidth
					}
					
				}
			}
		}
	}
	return options
end