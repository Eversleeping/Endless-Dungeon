require("utility_functions")

if Talent == nil then Talent = class({}) end

-- 初始化
function Talent:Init()
	print("Initing talent system")

	-- 天赋使用英雄定义
	HeroKVs = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	--[[
		"Talents"
		{
			"01"	// 第一行
			{
				"frost_bite"
				{
					"ID"			"1"
					"MaxLevel"		"4"
					"Require"
					{
						"2"		"3" // 需要frost_flow达到3级
					}
				}
				"frost_flow"
				{
					"ID"			"2"
					"MaxLevel"		"4"
				}
				"frost_xxx"
				{
					"ID"			"3"
					"MaxLevel"		"4"
				}
			}
			"02"
			{
				...
			}
		}
	]]
	for hero_name, hero_info in pairs( HeroKVs) do
		if type(hero_info) == "table" then
			local talent = hero_info["Talents"]
			if talent ~= nil then
				self.tTalentInfo[hero_name] = talent
				CustomNetTableManager:SetTableValue("talent_table", hero_name, talent)
			end
		end
	end

	CustomGameEventManager:RegisterListener("client_update_talent_list", Dynamic_Wrap(Talent, "OnClientUpdateTalentList"))
	-- client_update_talent_list => sTalentString => "3*1|11*0|22*5|13*1|25*2"

	self.init = true
end

-- 当客户端更新天赋列表
function Talent:OnClientUpdateTalentList(  keys )
	local playerId = keys.PlayerID
	local talentStr = keys.sTalentString
	local hero_entindex = keys.entindex
	local talentIds = stringSplit( talentStr, "|" )

	local spent_points = 0

	for _,v in pairs( talentIds) do
		local s = stringSplit( talentIds, "*")
		self:ActivateTalent( hero_entindex, s[1], tonumber(s[2]) )

		spent_points = spent_points + tonumber(s[2])
	end

	print("Client talent points setting finished, all spent points => " , spent_points)
end

-- 激活单个天赋，并将其设置为对应等级
function Talent:ActivateTalent( hero_entindex, id, level)
	self.tTalentData = self.tTalentData or {}
	self.tTalentData[hero_entindex] = self.tTalentData[hero_entindex] or {}
	self.tTalentData[hero_entindex][id] = level
end

-- 根据ID获取天赋名称
function Talent:GetTalentNameById( heroName, id)
	local talentInfo = self.tTalentInfo
	local talent = talentInfo[heroName]
	for row, info in pairs( talent ) do
		for k,v in pairs( info ) do
			if v == id then return k end
		end
	end
end

-- 根据天赋名称获取天赋ID
function Talent:GetTalentIdByName( heroName, name)
	local talentInfo = self.tTalentInfo
	local talent = talentInfo[heroName]
	for row, info in pairs( talent ) do
		for k,v in pairs( info ) do
			if k == name then return tonumber(v) end
		end
	end
end

-- 根据天赋名称查询某个天赋是否已经被激活
function Talent:IsTalentActivateByName( hero, talentName)
	local hero_entindex = hero:entindex()
	local hero_name = hero:GetUnitName()

	local talents = self.tTalentData[hero_entindex]
	for talent_id, level in pairs(talents) do
		local tn = self:GetTalentNameById(hero_name, talent_id)
		if talentName == tn and level > 0 then return true end
	end
	return false
end

-- 查询根据名称天赋等级
function Talent:GetTalentLevelByName(hero, talentName)
	local hero_entindex = hero:entindex()
	local hero_name = hero:GetUnitName()

	local talents = self.tTalentData[hero_entindex]
	for talent_id, level in pairs(talents) do
		local tn = self:GetTalentNameById(hero_name, talent_id)
		if talentName == tn and level > 0 then return level end
	end
	return nil
end

-- 根据天赋ID查询某个天赋是否已经被激活
function Talent:IsTalentActivateById(hero, talentID)
	local hero_entindex = hero:entindex()
	local hero_name = hero:GetUnitName()

	local talents = self.tTalentData[hero_entindex]
	for talent_id, level in pairs(talents) do
		if talent_id == talentID and level > 0 then return true end
	end
	return false
end

-- 根据天赋ID查询天赋等级
function Talent:IsTalentActivateById(hero, talentID)
	local hero_entindex = hero:entindex()
	local hero_name = hero:GetUnitName()

	local talents = self.tTalentData[hero_entindex]
	for talent_id, level in pairs(talents) do
		if talent_id == talentID and level > 0 then return level end
	end
	return nil
end

if not Talent.init then Talent:Init() end
