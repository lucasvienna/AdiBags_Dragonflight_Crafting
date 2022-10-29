--[[

	The MIT License (MIT)

	Copyright (c) 2022 Lucas Vienna (Avyiel) <dev@lucasvienna.dev>
	Copyright (c) 2021 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
-- Retrive addon folder name, and our local, private namespace.
local Addon, Private = ...
local L = Private.L

-- Lua API
-----------------------------------------------------------
local _G = _G
local ipairs = ipairs

-- WoW API
-----------------------------------------------------------
-- Upvalue any WoW functions used here.

-- Callbacks
-----------------------------------------------------------
local function enableIds(dict, id_list)
	--@debug@
	assert(id_list["items"], "Items list not found")
	assert(id_list["category"], "Category name not found")
	--@debug@
	for _, v in ipairs(id_list.items) do
		dict[v] = L[id_list.category]
	end
end

-- Constants
-----------------------------------------------------------
local CacheIds
local Database = Private.Database

-- AdiBags namespace
-----------------------------------------------------------
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")

-- Filter Registration
-----------------------------------------------------------
local filter = AdiBags:RegisterFilter("Dragonflight Crafting", 90, "ABEvent-1.0")
filter.uiName = L["Dragonflight Crafting"]
filter.uiDesc = L["Categories for all Dragonflight Crafting items and reagents."]

function filter:OnInitialize()
	-- Register the settings namespace
	self.db = AdiBags.db:RegisterNamespace(self.filterName, {
		profile = {
			-- Add your settings here
			move_alchemy = true,
			move_cloth = true,
			move_cooking = true,
			split_tuskarr_feast = false,
			split_ingredients = false,
			split_meat = false,
			split_fish = false,
			split_reagents = false,
			move_enchanting = true,
			move_herbs = true,
			move_inscription = true,
			move_jewelcrafting = true,
			move_leather = true,
			move_ore_stone = true,
			move_parts = true,
			move_darkmoon_cards = false,
			move_reagents = true,
			move_crafting = true,
			move_treasure_sack = false,
			move_fortune_card = false,
		},
	})
end

function filter:Update()
	-- Reset filtered IDs
	CacheIds = nil
	-- Notify myself that the filtering options have changed
	self:SendMessage("AdiBags_FiltersChanged")
end

function filter:OnEnable()
	AdiBags:UpdateFilters()
end

function filter:OnDisable()
	AdiBags:UpdateFilters()
end

-- Main Filter
-----------------------------------------------------------
function filter:Filter(slotData)
	local itemId = slotData.itemId
	CacheIds = CacheIds or self:StartCache()

	if (itemId and CacheIds[itemId]) then
		return CacheIds[itemId]
	end

	-- TODO: some addons have a tooltip here, for whatever reason
	-- even if they're tracking by ID and not by tt scanning. 
	-- figure out why
end

function filter:StartCache()
	wipe(CacheIds)

	if self.db.profile.move_alchemy then
		enableIds(CacheIds, Database.alchemy)
	end
	if self.db.profile.move_cloth then
		enableIds(CacheIds, Database.cloth)
	end
	if self.db.profile.move_cooking then
		local cooking_ignores = {}

		if self.db.profile.split_tuskarr_feast then
			enableIds(CacheIds, Database.cooking.tuskarr_feast)
			cooking_ignores["tuskarr_feast"] = true
		end
		if self.db.profile.split_ingredients then
			enableIds(CacheIds, Database.cooking.ingredients)
			cooking_ignores["ingredients"] = true
		end
		if self.db.profile.split_meat then
			enableIds(CacheIds, Database.cooking.meat)
			cooking_ignores["meat"] = true
		end
		if self.db.profile.split_fish then
			enableIds(CacheIds, Database.cooking.fish)
			cooking_ignores["fish"] = true
		end
		if self.db.profile.split_reagents then
			enableIds(CacheIds, Database.cooking.reagents)
			cooking_ignores["reagents"] = true
		end

		for i, v in ipairs(Database.cooking) do
			if not cooking_ignores[i] then
				local c = v
				-- override split category with cooking
				c.category = Database.cooking
				enableIds(CacheIds, c)
			end
		end
		wipe(cooking_ignores)
	end
	if self.db.profile.move_enchanting then
		enableIds(CacheIds, Database.enchanting)
	end
	if self.db.profile.move_herbs then
		enableIds(CacheIds, Database.herbs)
	end
	if self.db.profile.move_inscription then
		enableIds(CacheIds, Database.inscription)
	end
	if self.db.profile.move_jewelcrafting then
		enableIds(CacheIds, Database.jewelcrafting)
	end
	if self.db.profile.move_leather then
		enableIds(CacheIds, Database.leather)
	end
	if self.db.profile.move_ore_stone then
		enableIds(CacheIds, Database.ore_stone)
	end
	if self.db.profile.move_parts then
		enableIds(CacheIds, Database.parts)
	end
	if self.db.profile.move_darkmoon_cards then
		enableIds(CacheIds, Database.darkmoon_cards)
	end
	if self.db.profile.move_reagents then
		enableIds(CacheIds, Database.reagents)
	end
	if self.db.profile.move_crafting then
		enableIds(CacheIds, Database.crafting)
	end
	if self.db.profile.move_treasure_sack then
		enableIds(CacheIds, Database.treasure_sack)
	end
	if self.db.profile.move_fortune_card then
		enableIds(CacheIds, Database.fortune_card)
	end

	return CacheIds
end

-- Filter Options Panel
-----------------------------------------------------------
function filter:GetOptions()
	return {
		-- Setup for the options panel
		move_alchemy = {
			name = L[self.db.profile.alchemy.name],
			desc = L[self.db.profile.alchemy.desc],
			type = "toggle",
			order = 0,
		},
		move_cloth = {
			name = L[self.db.profile.cloth.name],
			desc = L[self.db.profile.cloth.desc],
			type = "toggle",
			order = 2,
		},
		move_cooking = {
			name = L[self.db.profile.cooking.name],
			desc = L[self.db.profile.cooking.desc],
			type = "toggle",
			width = "double",
			order = 3,
		},
		cooking_splits = {
			name = L[self.db.profile.cooking.name],
			desc = L[self.db.profile.cooking.desc], -- doesn't seem to get used anyway
			type = "group",
			inline = true,
			order = 4,
			disabled = function () return not self.db.profile.move_cooking end,
			args = {
				split_tuskarr_feast = {
					name = L[self.db.profile.cooking.tuskarr_feast.name],
					desc = L[self.db.profile.cooking.tuskarr_feast.desc],
					type = "toggle",
					order = 10,
				},
				split_ingredients = {
					name = L[self.db.profile.cooking.ingredients.name],
					desc = L[self.db.profile.cooking.ingredients.desc],
					type = "toggle",
					order = 20,
				},
				split_meat = {
					name = L[self.db.profile.cooking.meat.name],
					desc = L[self.db.profile.cooking.meat.desc],
					type = "toggle",
					order = 30,
				},
				split_fish = {
					name = L[self.db.profile.cooking.fish.name],
					desc = L[self.db.profile.cooking.fish.desc],
					type = "toggle",
					order = 40,
				},
				split_reagents = {
					name = L[self.db.profile.cooking.reagents.name],
					desc = L[self.db.profile.cooking.reagents.desc],
					type = "toggle",
					order = 50,
				},
			}
		},
		move_enchanting = {
			name = L[self.db.profile.enchanting.name],
			desc = L[self.db.profile.enchanting.desc],
			type = "toggle",
			order = 6,
		},
		move_herbs = {
			name = L[self.db.profile.herbs.name],
			desc = L[self.db.profile.herbs.desc],
			type = "toggle",
			order = 8,
		},
		move_inscription = {
			name = L[self.db.profile.inscription.name],
			desc = L[self.db.profile.inscription.desc],
			type = "toggle",
			order = 10,
		},
		move_jewelcrafting = {
			name = L[self.db.profile.jewelcrafting.name],
			desc = L[self.db.profile.jewelcrafting.desc],
			type = "toggle",
			order = 12,
		},
		move_leather = {
			name = L[self.db.profile.leather.name],
			desc = L[self.db.profile.leather.desc],
			type = "toggle",
			order = 14,
		},
		move_ore_stone = {
			name = L[self.db.profile.ore_stone.name],
			desc = L[self.db.profile.ore_stone.desc],
			type = "toggle",
			order = 16,
		},
		move_parts = {
			name = L[self.db.profile.parts.name],
			desc = L[self.db.profile.parts.desc],
			type = "toggle",
			order = 18,
		},
		move_darkmoon_cards = {
			name = L[self.db.profile.darkmoon_cards.name],
			desc = L[self.db.profile.darkmoon_cards.desc],
			type = "toggle",
			order = 20,
		},
		move_reagents = {
			name = L[self.db.profile.reagents.name],
			desc = L[self.db.profile.reagents.desc],
			type = "toggle",
			order = 22,
		},
		move_crafting = {
			name = L[self.db.profile.crafting.name],
			desc = L[self.db.profile.crafting.desc],
			type = "toggle",
			order = 24,
		},
		move_treasure_sack = {
			name = L[self.db.profile.treasure_sack.name],
			desc = L[self.db.profile.treasure_sack.desc],
			type = "toggle",
			order = 26,
		},
		move_fortune_card = {
			name = L[self.db.profile.fortune_card.name],
			desc = L[self.db.profile.fortune_card.desc],
			type = "toggle",
			order = 28,
		},
	}, AdiBags:GetOptionHandler(self, true, function() return self:Update() end)
end

-- Setup the environment
-----------------------------------------------------------
(function(self)
	-- Private Default API
	-- This mostly contains methods we always want available
	-----------------------------------------------------------

	-- Addon version
	-- *Keyword substitution requires the packager,
	-- and does not affect direct GitHub repo pulls.
	local addonVersion = "@project-version@"
	if (addonVersion:find("project%-version")) then
		addonVersion = "Development"
	end
	Private.addonVersion = addonVersion

	-- WoW Client versions
	local currentClientPatch, currentClientBuild = GetBuildInfo()
	currentClientBuild = tonumber(currentClientBuild)

	local MAJOR, MINOR, PATCH = string.split(".", currentClientPatch)
	MAJOR = tonumber(MAJOR)

	-- WoW Client versions
	local patch, build, date, toc_version = GetBuildInfo()
	Private.IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
	Private.IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
	Private.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
	Private.IsWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
	Private.WoW10 = toc_version >= 100000

	-- Should mostly be used for debugging
	Private.Print = function(self, ...)
		print("|cff33ff99:|r", ...)
	end

	Private.GetAddOnInfo = function(self, index)
		local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(index)
		local enabled = not (GetAddOnEnableState(UnitName("player"), index) == 0)
		return name, title, notes, enabled, loadable, reason, security
	end

	-- Check if an addon exists in the addon listing and loadable on demand
	Private.IsAddOnLoadable = function(self, target, ignoreLoD)
		local target = string.lower(target)
		for i = 1, GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if loadable or ignoreLoD then
					return true
				end
			end
		end
	end

	-- This method lets you check if an addon WILL be loaded regardless of whether or not it currently is.
	-- This is useful if you want to check if an addon interacting with yours is enabled.
	-- My philosophy is that it's best to avoid addon dependencies in the toc file,
	-- unless your addon is a plugin to another addon, that is.
	Private.IsAddOnEnabled = function(self, target)
		local target = string.lower(target)
		for i = 1, GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = self:GetAddOnInfo(i)
			if string.lower(name) == target then
				if enabled and loadable then
					return true
				end
			end
		end
	end

	-- Event API
	-----------------------------------------------------------
	-- Proxy event registering to the addon namespace.
	-- The 'self' within these should refer to our proxy frame,
	-- which has been passed to this environment method as the 'self'.
	Private.RegisterEvent = function(_, ...) self:RegisterEvent(...) end
	Private.RegisterUnitEvent = function(_, ...) self:RegisterUnitEvent(...) end
	Private.UnregisterEvent = function(_, ...) self:UnregisterEvent(...) end
	Private.UnregisterAllEvents = function(_, ...) self:UnregisterAllEvents(...) end
	Private.IsEventRegistered = function(_, ...) self:IsEventRegistered(...) end

	-- Event Dispatcher and Initialization Handler
	-----------------------------------------------------------
	-- Assign our event script handler,
	-- which runs our initialization methods,
	-- and dispatches event to the addon namespace.
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			-- Nothing happens before this has fired for your addon.
			-- When it fires, we remove the event listener
			-- and call our initialization method.
			if ((...) == Addon) then
				-- Delete our initial registration of this event.
				-- Note that you are free to re-register it in any of the
				-- addon namespace methods.
				self:UnregisterEvent("ADDON_LOADED")
				-- Call the initialization method.
				if (Private.OnInit) then
					Private:OnInit()
				end
				-- If this was a load-on-demand addon,
				-- then we might be logged in already.
				-- If that is the case, directly run
				-- the enabling method.
				if (IsLoggedIn()) then
					if (Private.OnEnable) then
						Private:OnEnable()
					end
				else
					-- If this is a regular always-load addon,
					-- we're not yet logged in, and must listen for this.
					self:RegisterEvent("PLAYER_LOGIN")
				end
				-- Return. We do not wish to forward the loading event
				-- for our own addon to the namespace event handler.
				-- That is what the initialization method exists for.
				return
			end
		elseif (event == "PLAYER_LOGIN") then
			-- This event only ever fires once on a reload,
			-- and anything you wish done at this event,
			-- should be put in the namespace enable method.
			self:UnregisterEvent("PLAYER_LOGIN")
			-- Call the enabling method.
			if (Private.OnEnable) then
				Private:OnEnable()
			end
			-- Return. We do not wish to forward this
			-- to the namespace event handler.
			return
		end
		-- Forward other events than our two initialization events
		-- to the addon namespace's event handler.
		-- Note that you can always register more ADDON_LOADED
		-- if you wish to listen for other addons loading.
		if (Private.OnEvent) then
			Private:OnEvent(event, ...)
		end
	end)
end)((function() return CreateFrame("Frame", nil, WorldFrame) end)())
