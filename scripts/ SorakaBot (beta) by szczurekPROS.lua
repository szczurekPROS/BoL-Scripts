local version = "1.2"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/szczurekPROS/GitHub/master/scripts/SorakaBot (beta) by szczurekPROS.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."SorakaBot (beta) by szczurekPROS.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>SorakaBot (beta) by szczurekPROS:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
        local ServerData = GetWebResult(UPDATE_HOST, "/szczurekPROS/GitHub/master/scripts/Version/sorakabot(beta).version")
        if ServerData then
                ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
                if ServerVersion then
                        if tonumber(version) < ServerVersion then
                                _AutoupdaterMsg("New version available"..ServerVersion)
                                _AutoupdaterMsg("Updating, please don't press F9")
                                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
                        else
                                _AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
                        end
                end
        else
                _AutoupdaterMsg("Error downloading version info")
        end
end

--[[AUTO UPDATE END]]--

    welcome = "Welcome to SorakaBot version 1.2 (beta) by szczurekPROS"
    --[[
    SorakaBot (beta) V1.2 by szczurekPROS
    GPL v2 license
    --]]
     
		 --[[ Config ]]
local HK = 117 -- 117 is F6
local wardRange = 600


--Nothing
local scriptActive = true
local wardTimer = 0
local wardSlot = nil
local wardMatrix = {}
local wardDetectedFlag = {}
local lastWard = 0
wardMatrix[1] = {10000,11578,10012,8924,7916,11369,6185,4911,4025,2579,4031,2788}
wardMatrix[2] = {2868,3452,4842,5461,4595,6885,9856,8878,9621,10943,11519,7611}
wardMatrix[3] = {}
for i = 1, 12 do
--Ward present nearby ?
wardMatrix[3][i] = false
wardDetectedFlag[i] = false
end
		 
		 --Classes Area
		root = nil
		 --Task Class
		Task = {}
		 
     --Auto Potion--
    MPotUsed = false
    HPotUsed = false
    manaLimit = 0.55
    hpLimit = 0.4
    lastTimeMPot = 0
    lastTimeHPot = 0
     
		 --Auto (Q)
local STARCALL_RANGE = 675
local DEFAULT_STARCALL_MODE = 3
local DEFAULT_STARCALL_MIN_MANA = 300
local DEFAULT_NUM_HIT_MINIONS = 3
    --press this key for spell settings(F1 default)
    desiredGuiKey = 0x70
    --soraka will heal target up to this percent
    desiredHeal = 0.75
    --soraka will repelnish target mana up to this percent
    desiredReplenish = 0.74
    --soraka will ult teammates up to this percent
    desiredUlt = 0.80
    --soraka will use summoners
    desiredSummoners = true
    --enable autobuy items from list
    desiredItems = true
    --Item List
	--[[ Config ]]
	shopList = {2004, 2004, 1006, 1004, 3096, 1001, 1028, 3158, 3067, 3069, 1028, 3105, 3190, 1028, 3010, 3027, 3065}

	nextbuyIndex = 1
	wardBought = 0
	firstBought = false
	lastBuy = 0
	
	buyDelay = 100 --default 100
    --enable level spells from array bellow
    desiredLevel = true
    --level sequence
    spells = {_W,_E,_W,_Q,_E,_R,_W,_Q,_W,_E,_R,_E,_Q,_E,_W,_R,_Q,_Q}
    --wards
    wards = {{x=10000,z=2860},{x=4000,z=11600},{x=4800,z=8925},{x=9125,z=5315},{x=11450,z=6990},{x=6735,z=2925},{x=2615,z=7500},{x=7300,z=11490}}
    --team dependent wards
    if myHero.team == TEAM_BLUE then
            wards[#wards + 1] = {x=13260,z=2910}
            wards[#wards + 1] = {x=2550,z=13450}
    else
            wards[#wards + 1] = {x=11675,z=1100}
            wards[#wards + 1] = {x=935,z=12245}
    end
     
    ------------------------------------------------
    --------------------code-----------------------
    ------------------------------------------------
    if myHero.charName ~= "Soraka" then return end
    --fix bugsplat for now
    IsWallOfGrass = function() return 0 end
    
		require "AIData"
    require "AIRoutine"
    require "AITimer"
    require "AIFind"
    require "AIGui"
    require "AIStat"
    require "AICondition"
		require "AISpell"
     
    ------------------------------------------------
    ----------------------init----------------------
    ------------------------------------------------
     
    function OnLoad()
		player = GetMyHero()
		initVariables()
		drawMenu()
		mountBehaviorTree()
			if GetInventorySlotIsEmpty(ITEM_1) == false then
			firstBought = true
		end

		startingTime = GetTickCount()
		
		
            --spell dispatcher
            AITimer.add(0.25,function()
                            --dont do any action if dead or recall
                            if myHero.dead == true or AICondition.recall(myHero) == true then return end
                            --check for heal
                            if CanUseSpell(_W) == READY then
                                    local result = AIFind.weakAlly(myHero,450,false,true)
                                    if result ~= nil and (result.health + AIStat.heal(result,GetSpellData(_W).level * 30 + myHero.ap * 0.60))/result.maxHealth <= desiredHeal then
                                            CastSpell(_W,result)
                                            return
                                    end
                            end
                            --check for ult
                            if CanUseSpell(_R) == READY then
                                    --save ult power
                                    local ultPower = (150 + (GetSpellData(_R).level - 1) * 100 + myHero.ap * 0.55)
                                    --save result variable
                                    local result = 0
                                    --get heal results on targets
                                    for i = 1, #AIData.allies, 1 do
                                            --dont count afk
                                            if AIStat.afk(AIData.allies[i]) > 180 then result = result + desiredUlt
                                            --ult wasted cases
                                            elseif AIData.allies[i].dead == true or AIRoutine.distance(AIData.allySpawn,AIData.allies[i]) < 1500 or AICondition.recall(AIData.allies[i]) == true then result = result + 1
                                            --calculate
                                            else result = result + (AIData.allies[i].health + AIStat.heal(AIData.allies[i],ultPower))/AIData.allies[i].maxHealth end
                                    end
                                    --check amount
                                    if result/#AIData.allies <= desiredUlt then
                                            CastSpell(_R)
                                            return
                                    end
                            end
-----------------------------------------------------------------------------------------------
-- 															Automatyczne E (Do Naprawy)																	 --
-----------------------------------------------------------------------------------------------

                            --check for mana
 --                           if CanUseSpell(_E) == READY then
 --                                   local result = AIFind.depletedAlly(myHero,725)
 --                                   if result ~= nil and (result.mana +  GetSpellData(_E).level * 20)/result.maxMana <= desiredReplenish then
 --                                           CastSpell(_E,result)
 --                                           return
 --                                   end
 --                           end
 -----------------------------------------------------------------------------------------------
-- 															Koniec Automatyczne E 																	     --
-----------------------------------------------------------------------------------------------
                            --check for summoners
                            local summoner = AISpell.heal()
                            --heal
                            if desiredSummoners == true and summoner ~= nil and AIRoutine.distance(myHero,AIData.allySpawn) > 1000 then
                                    --save HEAL power
                                    local healPower = 75 + (myHero.level * 15)
                                    --save result variable
                                    local result = 0
                                    --get allies
                                    local allies = AIFind.allies(myHero,600,false,true)
                                    if #allies > 1 then
                                            --get heal results on targets
                                            for i = 1, #allies, 1 do
                                                    --calculate
                                                    if allies[i].maxHealth - allies[i].health > healPower then result = result + math.max(1.5,-1 * AIStat.hps(allies[i]) / healPower) end
                                            end
                                            --check result
                                            if result/#allies >= desiredHeal then
                                                    CastSpell(summoner)
                                                    return
                                            end
                                    end
                            end
                            --mana
                            summoner = AISpell.clarity()
                            if desiredSummoners == true and summoner ~= nil and AIRoutine.distance(myHero,AIData.allySpawn) > 1000 then
                                    --save result variable
                                    local result = 0
                                    --get allies
                                    local allies = AIFind.allies(myHero,600,false,true)
                                    if #allies > 1 then
                                            --get clarity results on targets
                                            for i = 1, #allies, 1 do
                                                    --calculate
                                                    if allies[i].mana/allies[i].maxMana + 0.4 < desiredHeal then result = result + 1 end
                                            end
                                            --check result
                                            if result/#allies >= desiredHeal then
                                                    CastSpell(summoner)
                                                    return
                                            end
                                    end
                            end
                            --revive
                            summoner = AISpell.revive()
                            if desiredSummoners == true and summoner ~= nil and myHero.deathTimer > 25 and #AIRoutine.findMatches(AIData.allies,function(this) return this.dead == false end) + 1 > #AIRoutine.findMatches(AIData.enemies,function(this) return this.dead == false end) then
                                    CastSpell(summoner)
                            end
                            --check for items
                            local item = AISpell.locket()
                            --locket
                            if desiredItems == true and item ~= nil and AIRoutine.distance(myHero,AIData.allySpawn) > 1000 then
                                    --save SHIELD power
                                    local locketPower = 50 + (myHero.level * 10)
                                    --save result variable
                                    local result = 0
                                    --get allies
                                    local allies = AIFind.allies(myHero,600,false,true)
                                    if #allies > 1 then
                                            --get heal results on targets
                                            for i = 1, #allies, 1 do
                                                    --calculate
                                                    if allies[i].maxHealth - allies[i].health > locketPower then result = result + math.max(1.5,-1 * AIStat.hps(allies[i]) /locketPower) end
                                            end
                                            --check result
                                            if result/#allies >= desiredHeal then
                                                    CastSpell(item)
                                                    return
                                            end
                                    end
                            end
                    end)
           
            
            --gui
            AIBind.key(desiredGuiKey,drawGui,removeGui)
            --welcome message
            PrintChat(welcome)
            --level spells
            AddCreateObjCallback(function(obj) if desiredLevel == true and obj.x == myHero.x and obj.z == myHero.z and obj.name == "LevelUp_glb.troy" then AISpell.level(spells) end end)
            --slightly bugged
            if desiredLevel == true and spells ~= nil then AISpell.level(spells) end
    end
     
    ------------------------------------------------
    ---------------------GUI----------------------
    ------------------------------------------------a
     
    guiMenu = nil
    action,actionTimer,brainTimer = nil,nil
    function drawGui()
            if guiMenu == nil then
                    guiMenu = {AIGui.text(0,0,"SorakaBot (beta) by szczurekPROS")}
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Heal till %hp"),AIGui.slider(0,0,desiredHeal * 100,0,110,function(num) desiredHeal = num/100 end)})
--                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Mana till %mp"),AIGui.slider(0,0,desiredReplenish * 100,0,110,function(num) desiredReplenish = num/100 end)})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Ultimate till %hp"),AIGui.slider(0,0,desiredUlt * 100,0,110,function(num) desiredUlt = num/100 end)})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.tick(0,0,desiredLevel,function(state) desiredLevel = state if state == true and spells ~= nil then AISpell.level(spells) end end),AIGui.text(0,0,"Auto LVL Skills")})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,version,function(state) version = state end),AIGui.text(0,0,"Version")})
					guiMenu = AIGui.list(WINDOW_W*0.4,WINDOW_H*0.3,guiMenu)
            end
    end
    function removeGui()
            if guiMenu ~= nil then
                    AIGui.remove(guiMenu)
                    guiMenu = nil
            end
    end
     
    ------------------------------------------------
    ------------------spell action-----------------
    ------------------------------------------------
    function OnProcessSpell(unit, spell)
            if myHero.dead == true or unit == nil or unit.valid == false or unit.team ~= TEAM_ENEMY then return
            ------------------------------------------------
            -------------------silence---------------------
            ------------------------------------------------
            --check is it enemy and is silence usable
            elseif CanUseSpell(_E) == READY and AIRoutine.distance(myHero,unit) <= 750  then
                    --check is spell important
                    if  spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel"
                    or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp"
                    or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole"
                    or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport"
                    then CastSpell(_E,unit) end
            ------------------------------------------------
            ------------------ohmwrecker-----------------
            ------------------------------------------------
            elseif desiredItems == true and unit.type == "obj_AI_Turret" and unit.team == TEAM_ENEMY and AIRoutine.distance(myHero,unit) < 600 then
                    local item = AISpell.ohm()
                    if item ~= nil and AIFind.ally(spell.endPos,30,true,true) ~= nil then CastSpell(item) end
            end
    end
     
		 function OnTick()
		 if(config.enableScript) then
	   root:run()
		 end
		if firstBought == false and GetTickCount() - startingTime > 2000 then
			BuyItem(2044)
			BuyItem(3301) -- Ancient Coin
			BuyItem(3340) -- warding totem (trinket)
			firstBought = true
		end
		-----------------------------------------------------------------------------------------------
-- 															Automatyczne Q (Do Naprawy)																	 --
-----------------------------------------------------------------------------------------------
		-- Auto (Q)
--		if config.autoStarcall.enabled and player:CanUseSpell(_Q) == READY and player.mana > --config.autoStarcall.starcallMinMana then
--			doSorakaStarcall()
--		end
-----------------------------------------------------------------------------------------------
-- 															Koniec Automatyczne Q 																	     --
-----------------------------------------------------------------------------------------------

local manaPercent = player.mana/player.maxMana
        local ItemSlot = {ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,}
            for i=1, 6, 1 do
                if player:getInventorySlot(ItemSlot[i]) == 2004 and manaLimit >= manaPercent and MPotUsed == false then
                 FinalItemslotM = ItemSlot[i]
                 CastSpell(FinalItemslotM)
                 MPotUsed = true
                 lastTimeMPot = GetTickCount()
                end
            end
            if GetTickCount() - lastTimeMPot > 15000 then
             MPotUsed = false
            end
      
        local hpPercent = player.health/player.maxHealth
            for i=1, 6, 1 do
                if (player:getInventorySlot(ItemSlot[i]) == 2003 or player:getInventorySlot(ItemSlot[i]) == 2010) and hpLimit >= hpPercent and HPotUsed == false then
                 FinalItemslotH = ItemSlot[i]
                 CastSpell(FinalItemslotH)
                 HPotUsed = true
                 lastTimeHPot = GetTickCount()
                end
            end

            if GetTickCount() - lastTimeHPot > 15000 then
             HPotUsed = false
            end

		-- Run buy code only if in fountain
		if InFountain() then
			-- Continuous ward purchases
			if GetTickCount() - wardBought > 30000 and GetTickCount() - startingTime > 8000 and GetInventorySlotItem(2044) == nil then
				BuyItem(2044) -- stealth ward (green)
				wardBought = GetTickCount()
			end
			
			-- Item purchases
			if GetTickCount() - startingTime > 5000 then	
				if GetTickCount() > lastBuy + buyDelay then
					if GetInventorySlotItem(shopList[nextbuyIndex]) ~= nil then
						--Last Buy successful
						nextbuyIndex = nextbuyIndex + 1
					else
						--Last Buy unsuccessful (buy again)
						BuyItem(shopList[nextbuyIndex])
						lastBuy = GetTickCount()
					end
				end
			end
		end
		
		if scriptActive then
if GetTickCount() - wardTimer > 10000 then
wardUpdate()
end	

if (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3340) then
wardSlot = GetInventorySlotItem(3340)
elseif (myHero:CanUseSpell(ITEM_7) == READY and myHero:getItem(ITEM_7).id == 3350) then
wardSlot = GetInventorySlotItem(3350)
elseif GetInventorySlotItem(2044) ~= nil then
wardSlot = GetInventorySlotItem(2044)
elseif GetInventorySlotItem(2043) ~= nil then
wardSlot = GetInventorySlotItem(2043)
else
wardSlot = nil
end

for i = 1, 12 do
if wardSlot ~= nil and GetTickCount() - lastWard > 2000 then
if math.sqrt((wardMatrix[1][i] - player.x)*(wardMatrix[1][i] - player.x) + (wardMatrix[2][i] - player.z)*(wardMatrix[2][i] - player.z)) < 600 and wardMatrix[3][i] == false then
CastSpell( wardSlot, wardMatrix[1][i], wardMatrix[2][i] )
lastWard = GetTickCount()
wardMatrix[3][i] = true
break
end
end
end
end	
end
    ------------------------------------------------
    ------------------Auto Follow-------------------
    ------------------------------------------------
		function Task:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function Task:run()
	PrintChat("CHAMOU TASK RUN")
end

function Task:addChild(value)
	table.insert(self,value)
end

function Task:addAll(value)
	for i = 1, #value, 1 do
		table.insert(self, value[i])
	end
end

function Task:printAll()
	for i = 1, #self, 1 do
		PrintChat("Value: "..self[i])
	end
end

-- Selector Class
Selector = Task:new()

function Selector:run()
	for i, v in ipairs(self) do
		if v:run() then return true end
	end
	return false
end

--Sequence Class
Sequence = Task:new()

function Sequence:run()
	for i, v in ipairs(self) do
		if not v:run() then return false end
	end
	return true
end

--Action Class
Action = Task:new()

function Action:run()
	local actions = {}
	--PrintChat(self.action)
	
	actions["startTime"] = function()
		if os.clock() > SCRIPT_START_TIME then return true
		else return false end
	end
	
	actions["noPartner"] = function()
		--if(partner ~= nil) then PrintChat(partner.name) end
		if partner == nil then return true
		else return false
		end
	end
	
	actions["partnerAfk"] = function()
		checkAfk()
		if pAfk then partner = nil end
		return pAfk
	end
	
	actions["partnerAlive"] = function()
		if partner ~= nil and not partner.dead then return true
		else return false
		end
	end
	
	actions["partnerDead"] = function()
		if partner ~= nil and  partner.dead then return true
		else return false
		end
	end
	
	actions["partnerClose"] = function()
		if player:GetDistance(partner) <= config.followChamp.followDist then return true
		else return false
		end
	end
	
	--TODO: Implements
	actions["followFriend"] = function()
		
	end
	
	actions["friendClose"] = function()
		local friends = GetPlayers(player.team, false, false)
		local closest = friends[1]
		for i = 1, #friends, 1 do
			if friends[i] ~= nil and player:GetDistance(friends[i]) < player:GetDistance(closest) then closest = friends[i] end
		end
		
		if closest ~= nil and player:GetDistance(closest) <= config.followChamp.followDist then return true
		else return false
		end
	end
	
	actions["inTurret"] = function()
		local myTurret = GetCloseTower(player, player.team)
		if player:GetDistance(myTurret) <= config.followChamp.followDist and player:GetDistance(allySpawn) < GetDistance(allySpawn, myTurret) then return true
		else return false
		end
	end
	
	actions["matchPartner"] = function()
		if partner == nil then
			local myCarry = GetPlayers(player.team, false, false)
			local score = {}
			local maxScore = -1
			partner = nil
		
			for i = 1, #myCarry, 1 do
				score[i] = 0
				for j = 1, #myCarry, 1 do
					if GetDistance(myCarry[i], bottomPoint) < GetDistance(myCarry[j], bottomPoint) then score[i] = score[i] + 1 end
				end
				if GetDistance(bottomPoint, myCarry[i]) < 6000 then score[i] = score[i] + 5 end
				if GetDistance(allySpawn, myCarry[i]) < 5000 then score[i] = score[i] - 10000 end
			end
			
			for k = 1, #myCarry, 1 do
				if score[k] > maxScore and score[k] > 0 then
					maxScore = score[k]
					partner = myCarry[k]
				end
			end
			
			if partner ~= nil then
				SendChat("myPartner: "..partner.name)
				pAfk = false
				lastPartnerMove = os.clock()
				return true
			else
				return false
			end
		else
			return false
		end
	end
	
	actions["partnerRecalling"] = function()
		return pRecalling
	end
	
	actions["isRecalling"] = function()
		for i=1, objManager.maxObjects, 1 do
			local obj = objManager:getObject(i)
			if obj ~= nil and obj.valid and obj.name:find("TeleportHome") ~= nil and player:GetDistance(obj) < 70 then
				return true
			end
		end
		return false
	end
	
	actions["followPartner"] = function()
		followX = ((allySpawn.x - partner.x)/(partner:GetDistance(allySpawn)) * ((config.followChamp.followDist - 300) / 2 + 300) + partner.x + math.random(-((config.followChamp.followDist-300)/3),((config.followChamp.followDist-300)/3)))
		followZ = ((allySpawn.z - partner.z)/(partner:GetDistance(allySpawn)) * ((config.followChamp.followDist - 300) / 2 + 300) + partner.z + math.random(-((config.followChamp.followDist-300)/3),((config.followChamp.followDist-300)/3)))
			
		player:MoveTo(followX, followZ)
		
		return true
	end
	
	actions["goTurret"] = function()
		local myTurret = GetCloseTower(player, player.team)
		followX = (allySpawn.x - myTurret.x)/(myTurret:GetDistance(allySpawn)) * ((config.followChamp.followDist - 300) / 2 + 300) + myTurret.x
		followZ = (allySpawn.z - myTurret.z)/(myTurret:GetDistance(allySpawn)) * ((config.followChamp.followDist - 300) / 2 + 300) + myTurret.z
		player:MoveTo(math.floor(followX), math.floor(followZ))
			
		return true
	end
	
	actions["towerFocusPlayer"] = function()
		return FocusOfTower
	end
	
	actions["runFromTower"] = function()
		local followX = (2 * myHero.x) - yikesTurret.x
		local followZ = (2 * myHero.z) - yikesTurret.z
		player:MoveTo(followX, followZ)
		
		return true
	end
	
	actions["recall"] = function()
		--PrintChat("Recalling")
		if not InFountain() then CastSpell(RECALL) end
		return true
	end
	
	local result = actions[self.action]()
	--if result then PrintChat("true") else PrintChat("false") end
	return result
end

--End of Classes area

--Util Section
function detectSpawnPoints()
	for i=1, objManager.maxObjects, 1 do
		local candidate = objManager:getObject(i)
		if candidate ~= nil and candidate.valid and candidate.type == "obj_SpawnPoint" then 
			if candidate.x < 3000 then 
				if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
			else 
				if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
			end
		end
	end
end

--return towers table
function GetTowers(team)
	local towers = {}
	for i=1, objManager.maxObjects, 1 do
		local tower = objManager:getObject(i)
		if tower ~= nil and tower.valid and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
			table.insert(towers,tower)
		end
	end
	if #towers > 0 then
		return towers
	else
		return false
	end
end

function GetCloseTower(hero, team)
	local towers = GetTowers(team)
	if #towers > 0 then
		local candidate = towers[1]
		for i=2, #towers, 1 do
			if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
		end
		return candidate
	else
		return false
	end
end

function GetPlayers(team, includeDead, includeSelf)
	local players = {}
	local result = {}
	
	if team == player.team then
		players = GetAllyHeroes()
	else
		players = GetEnemyHeroes()
	end
	
	for i=1, #players, 1 do
		if players[i].visible and (not players[i].dead or players[i].dead == includeDead) then
			table.insert(result, players[i])
		end
	end
	
	if 
		includeSelf then table.insert(result, player)
	else 
		for i=1, #result, 1 do
			if result[i] == player then
				table.remove(result, i)
				break
			end
		end
	end
	
	return result
end

function checkAfk()
	if partner ~= nil and GetDistance(partner, allySpawn) < 3000 then
		if os.clock() >= lastPartnerMove + AFK_MAXTIME then
			pAfk = true
		end
	elseif partner ~= nil then
		lastPartnerMove = os.clock()
		pAfk = false
	end
end

--End Util Section

function mountBehaviorTree()
	--1st level
	root = Sequence:new()
	sequence1 = Sequence:new()
	sequence2 = Sequence:new()
	sequence3 = Sequence:new()
	sequence4 = Sequence:new()
	sequence5 = Sequence:new()
	sequence6 = Sequence:new()
	sequence7 = Sequence:new() -- Attacked by tower
	sequence8 = Sequence:new() -- Safe in turret
	
	selector1 = Selector:new()
	selector2 = Selector:new()
	selector3 = Selector:new()
	selector4 = Selector:new()
	selector5 = Selector:new() -- partner afk
	
	startTime 		= Action:new{action = "startTime"}
	noPartner 		= Action:new{action = "noPartner"}
	partnerAfk 		= Action:new{action = "partnerAfk"}
	matchPartner 	= Action:new{action = "matchPartner"}
	partnerAlive 	= Action:new{action = "partnerAlive"}
	partnerDead 	= Action:new{action = "partnerDead"}
	inTurret 		= Action:new{action = "inTurret"}
	recall 			= Action:new{action = "recall"}
	partnerClose 	= Action:new{action = "partnerClose"}
	followPartner 	= Action:new{action = "followPartner"}
	goTurret 		= Action:new{action = "goTurret"}
	partnerRecalling= Action:new{action = "partnerRecalling"}
	friendClose		= Action:new{action = "friendClose"}
	followFriend 	= Action:new{action = "followFriend"}
	towerFocusPlayer= Action:new{action = "towerFocusPlayer"}
	runFromTower	= Action:new{action = "runFromTower"}
	
	--lvl 1
	root:addChild(startTime)
	root:addChild(selector1)
	
	--lvl2
	selector1:addChild(sequence1)
	selector1:addChild(sequence7) -- flee from tower
	selector1:addChild(sequence2)
	selector1:addChild(sequence3)
	selector1:addChild(sequence4)
	
	--lvl3
	sequence1:addChild(selector5)
	sequence1:addChild(matchPartner)
	
	sequence7:addChild(towerFocusPlayer)
	sequence7:addChild(runFromTower)
	
	sequence2:addChild(partnerAlive)
	sequence2:addChild(selector2)
	
	sequence3:addChild(partnerDead)
	sequence3:addChild(selector3)
	
	sequence4:addChild(inTurret)
	sequence4:addChild(recall)
	
	--lvl 4
	selector5:addChild(partnerAfk)
	selector5:addChild(noPartner)
	
	selector2:addChild(sequence5)
	selector2:addChild(partnerClose)
	selector2:addChild(followPartner)
	
	--selector3:addChild(sequence6)
	selector3:addChild(selector4)
	
	--lvl 5
	sequence5:addChild(partnerRecalling)
	--sequence5:addChild(partnerClose)
	sequence5:addChild(recall)
	
	--sequence6:addChild(friendClose)
	--sequence6:addChild(followFriend)
	
	selector4:addChild(sequence8)
	selector4:addChild(goTurret)
	
	--lvl 6
	sequence8:addChild(inTurret)
	sequence8:addChild(recall)
end

function OnRecall(hero, channelTimeInMs)
    if hero.isMe then
        meRecalling = true
	elseif hero.name == partner.name then
		pRecalling = true
    end
end

function OnAbortRecall(hero)
    if hero.isMe then
        meRecalling = false
	elseif hero.name == partner.name then
		pRecalling = false
    end        
end

function OnFinishRecall(hero)
    if hero.isMe then
        meRecalling = false
	elseif hero.name == partner.name then
		pRecalling = false
    end
end

function OnDeleteObj(object)
	if object.name:find("yikes") then
		FocusOfTower = false
		yikesTurret = nil
	elseif object.name:find("TeleportHome") and GetDistance(partner, object) < 70 then
		DelayAction(function() 
		pRecalling = false 
		end, 0.5, {0})
	end
end

function OnCreateObj(object)
	if object.name:find("yikes") then
		FocusOfTower = true
		yikesTurret = GetCloseTower(player, TEAM_ENEMY)
	elseif object.name:find("TeleportHome") and GetDistance(partner, object) < 70 then
		pRecalling = true
	end
end

function OnDraw()
	if partner ~= nil then DrawCircle(partner.x, partner.y, partner.z, 70, ARGB(200,255,255,0)) end
	if config.followChamp.drawFollowDist then DrawCircle(myHero.x, myHero.y, myHero.z, config.followChamp.followDist, ARGB(200,1,33,0)) end
end

function drawMenu()
	config = scriptConfig("Sorakabot Auto Follow", "Passive Follow") 

	config:addParam("enableScript", "Auto Follow", SCRIPT_PARAM_ONKEYTOGGLE, true, 116)
	  
	config:addSubMenu("Follow Settings", "followChamp")
	config:addSubMenu("Regen at Fountain", "fontRegen")
	config:addSubMenu("Auto use Summoner Spells", "autoSpells")
	--config:addSubMenu("Auto Starcall", "autoStarcall")
	
	config.fontRegen:addParam("hpRegen", "Min HP% to leave", SCRIPT_PARAM_SLICE, DEFAULT_HP_REGEN, 0, 100, 0)
	config.fontRegen:addParam("manaRegen", "Min Mana% to leave", SCRIPT_PARAM_SLICE, DEFAULT_MANA_REGEN, 0, 100, 0)
	
	config.autoSpells:addParam("useHeal", "Auto Summoner Heal", SCRIPT_PARAM_ONOFF, false)
	config.autoSpells:addParam("useClarity", "Auto Summoner Clarity", SCRIPT_PARAM_ONOFF, false)
	
	config.autoSpells:addParam("manaThreshold", "Mana% for use Clarity", SCRIPT_PARAM_SLICE, DEFAULT_MANA_THRESHOLD, 0, 100, 0)
	config.autoSpells:addParam("healthThreshold", "HP% for use Cure", SCRIPT_PARAM_SLICE, DEFAULT_HEALTH_THRESHOLD, 0, 100, 0)
	
	config.followChamp:addParam("followDist", "Follow Distance", SCRIPT_PARAM_SLICE, DEFAULT_FOLLOW_DISTANCE, 400, 2000, 0)
	config.followChamp:addParam("drawFollowDist", "Draw Follow Distance", SCRIPT_PARAM_ONOFF, true)
-----------------------------------------------------------------------------------------------
-- 															Automatyczne Q (Do Naprawy)																	 --
-----------------------------------------------------------------------------------------------

--config.autoStarcall:addParam("enabled", "Enable", SCRIPT_PARAM_ONOFF, true)
--	config.autoStarcall:addParam("starcallMode", "Starcall Mode", SCRIPT_PARAM_LIST, DEFAULT_STARCALL_MODE, { "Harass Only", "Farm/Push", "Both (hit any)", "Both (hit enemy and minions)" })
--	config.autoStarcall:addParam("starcallMinMana", "Starcall Minimum Mana", SCRIPT_PARAM_SLICE, DEFAULT_STARCALL_MIN_MANA, 50, 500, 0)
--	config.autoStarcall:addParam("numOfHitMinions", "Minimum Hit Minions", SCRIPT_PARAM_SLICE, DEFAULT_NUM_HIT_MINIONS, 1, 10, 0)
	-----------------------------------------------------------------------------------------------
-- 															Koniec Automatyczne Q 																	     --
-----------------------------------------------------------------------------------------------

	config:addSubMenu("Auto Wards F6 - On/Off", "autowards")
	
	enemyMinions = minionManager(MINION_ENEMY, STARCALL_RANGE, player, MINION_SORT_HEALTH_ASC) -- for starcall
end

function initVariables()
	
	bottomPoint = Vector(12100, 2100)
	--summoners
	DEFAULT_FOLLOW_DISTANCE = 400
	DEFAULT_MANA_REGEN = 80
	DEFAULT_HP_REGEN = 80

	--CONSTANTS
	MIN_DISTANCE = 275
	HEAL_DISTANCE = 700
	DEFAULT_HEALTH_THRESHOLD = 70
	DEFAULT_MANA_THRESHOLD = 66

	AFK_MAXTIME = 120
	SCRIPT_START_TIME = os.clock() + 60 -- change the adc selecting time
	lastPartnerMove = nil
	
	FocusOfTower = false
	partner = nil
	temp_partner = nil
	pAfk = true
	pRecalling = false -- is Partner Recalling?
	meRecalling = false
	yikesTurret = nil
	collectTimer = true

	-- spawn
	allySpawn = nil
	enemySpawn = nil

	detectSpawnPoints()
end
-----------------------------------------------------------------------------------------------
-- 															Automatyczne Q (Do Naprawy)																	 --
-----------------------------------------------------------------------------------------------

--function doSorakaStarcall()
	-- Perform Starcall based on starcallMode
	--local hitEnemy = false
	--local hitMinions = false
	
	-- Calculations
	--local enemy = GetPlayer(TEAM_ENEMY, false, false, player, STARCALL_RANGE, NO_RESOURCE)
	
	--if enemy ~= nil then hitEnemy = true end
	
	-- Minion Calculations
	--enemyMinions:update()
	--local totalMinionsInRange = 0
	
--	for _, minion in pairs(enemyMinions.objects) do
--		if player:GetDistance(minion) < STARCALL_RANGE then
--			totalMinionsInRange = totalMinionsInRange + 1
--		end
--	
--		if totalMinionsInRange >= config.autoStarcall.numOfHitMinions then 
--			hitMinions = true
--			break 
--		end
--	end
--		
--	if config.autoStarcall.starcallMode == 1 and hitEnemy then
--		CastSpell(_Q)
--	elseif config.autoStarcall.starcallMode == 2 and hitMinions then 
--		CastSpell(_Q)
--	elseif config.autoStarcall.starcallMode == 3 and (hitEnemy or hitMinions) then
--		CastSpell(_Q)
--	elseif config.autoStarcall.starcallMode == 4 and (hitEnemy and hitMinions) then
--		CastSpell(_Q)
--	end
--end
-----------------------------------------------------------------------------------------------
-- 															Koniec Automatyczne Q 																	     --
-----------------------------------------------------------------------------------------------
function GetPlayer(team, includeDead, includeSelf, distanceTo, distanceAmount, resource)
	local target = nil
	
	for i=1, heroManager.iCount do
		local member = heroManager:GetHero(i)
		
		if member ~= nil and member.type == "obj_AI_Hero" and member.team == team and (member.dead ~= true or includeDead) then
			if member.charName ~= player.charName or includeSelf then
				if distanceAmount == GLOBAL_RANGE or member:GetDistance(distanceTo) <= distanceAmount then
					if target == nil then target = member end
					
					if resource == "health" then --least health
						if member.health < target.health then target = member end
					elseif resource == "mana" then --least mana
						if member.mana < target.mana then target = member end
					elseif resource == "AD" then --highest AD
						if member.totalDamage > target.totalDamage then target = member end
					elseif resource == NO_RESOURCE then
						return member -- as any member is eligible
					end
				end
			end
		end
	end
	
	return target
end

function wardUpdate()
for i = 1, 12 do
wardDetectedFlag[i] = false
end
for k = 1, objManager.maxObjects do
local object = objManager:GetObject(k)
if object ~= nil and (string.find(object.name, "Ward") ~= nil or string.find(object.name, "Wriggle") ~= nil) then
for i = 1, 12 do
if math.sqrt((wardMatrix[1][i] - object.x)*(wardMatrix[1][i] - object.x) + (wardMatrix[2][i] - object.z)*(wardMatrix[2][i] - object.z)) < 1100 then
wardDetectedFlag[i] = true
wardMatrix[3][i] = true
end
end
end
for i = 1, 12 do
if wardDetectedFlag[i] == false then
wardMatrix[3][i] = false
end
end
end
wardTimer = GetTickCount()
end

function OnWndMsg(msg,key)
    if key == HK then
        if msg == KEY_DOWN then
         if scriptActive then
         scriptActive = false
         PrintChat("Sorakabot Auto Wards disabled")
  else
     scriptActive = true
     PrintChat("Sorakabot Auto Wards enabled")
     end
        end
    end
end
