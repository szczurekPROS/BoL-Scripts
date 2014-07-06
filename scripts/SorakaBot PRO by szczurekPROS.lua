local version = "1.0"
local AuthList = {"mazix","szczurek","Spider2023","kuba2023"} --[[Table of users who you wish to use the script.]]
local User = string.lower(GetUser()) --[[Calls the GetUser() function once for better performance.]]
function Auth()
    for i, users in pairs(AuthList) do --[[For loop to compare the usernames.]]
        if string.lower(users) == User then --[[Checks if the usernames match.]]
            return true --[[Authenticates the user if the usernames match.]]
        end
    end
    return false --[[If the usernames don't match after the for loop is completed, the script doesn't authenticate you.]]
end
if not Auth() then print("Not Authenticated") return end --[[Tells the user that they can't use the script.]]
print("Authenticated as "..User) --[[Tells the user know that they can use the script.]]
--[[Place your script code here.]]

local AUTOUPDATE = true
local UPDATE_HOST = "pasterbin.com"
local UPDATE_PATH = "/raw.php?i=BZDi7bMr".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."SorakaBot PRO by szczurekPROS.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>SorakaBot PRO by szczurekPROS:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
        local ServerData = GetWebResult(UPDATE_HOST, "/k9jZFXMY")
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

welcome = "Welcome to SorakaBot PRO Edition by szczurekPROS Version 0.0.3.4"
--[[
SorakaBot by szczurekPROS

GPL v2 license
--]]

--press this key for spell settings(F2 default)
desiredGuiKey = 0x71
--soraka will heal target up to this percent
desiredHeal = 0.9
--soraka will repelnish target mana up to this percent
desiredReplenish = 0.5
--soraka will ult teammates up to this percent
desiredUlt = 0.75
--soraka will use summoners
desiredSummoners = true
--Item List
shopList = {1006, 3301, 3096, 1001, 1028, 3158, 3067, 3069, 1028, 3105, 3190, 1028, 3010, 3027, 3065}
nextbuyIndex = 1
	wardBought = 0
	firstBought = false
	lastBuy = 0
	
	buyDelay = 100 --default 100
--enable level spells from array bellow
desiredLevel = true
--level sequence
spells = {_E,_W,_Q,_E,_W,_R,_W,_Q,_W,_E,_R,_E,_Q,_Q,_Q,_R,_E,_W}

-- SETTINGS
do
-- you can change true to false and false to true
-- false is turn off
-- true is turn on

SetupTogleKey = 115	 --Key to Togle script. [ F4 - 115 ] default
SetupTogleKeyText = "F4"
					 
SetupFollowDistance = 500
--Distance between FollowTarget and Champion in which champion starts correcting itself
--Should be more then 400

SetupFollowAlly = true
-- you start follow near ally when your followtarget have been diead

SetupRunAway = true
-- if no ally was near when followtarget died, you run to close tower

SetupRunAwayRecall = true
-- if you succesfully recall after followtarget died or recalled, you start recall

SetupFollowRecall = true
-- should you recall as soon as follow target racalled

SetupAutoHold = true -- Need work
-- stop autohit creeps when following target

afktime = 180 -- the time if the adc is afk b4 change the follower per second
end

-- GLOBALS [Do Not Change]
do
SetupDebug = true
switcher = true
following = nil
temp_following = nil
stopPosition = false
breaker = false

--state of app enum
FOLLOW = 1
TEMP_FOLLOW = -33
WAITING_FOLLOW_RESP = 150
GOING_TO_TOWER = 666

--by default
state = FOLLOW

-- spawn
allySpawn = nil
enemySpawn = nil

--player status
isRegen = false

--follow menu
SetupDrawX = 0.1
SetupDrawY = 0.15
MenuTextSize = 18

allies = {}
FollowKeysText = {"F5", "F6", "F7", "F8"} --Key names for menu
FollowKeysCodes = {116,117,118,119} --Decimal key codes corressponding to key names

--summoners
HL_slot = nil
CL_slot = nil
lastHeal = -30000
lastMana = -18000
HLCooldown = 30000
CLCooldown =  18000


version = 2.2
player = GetMyHero()
end

recallStartTime = 0
recallDetected = false

recentrecallTarget = player

-- ABSTRACTION-METHODS

--return players table
function GetPlayers(team, includeDead, includeSelf)
	local players = {}
	for i=1, heroManager.iCount, 1 do
		local member = heroManager:getHero(i)
		if member ~= nil and member.valid and member.type == "obj_AI_Hero" and member.visible and member.team == team then
			if member.name ~= player.name or includeSelf then 
				if includeDead then
					table.insert(players,member)
				elseif member.dead == false then
					table.insert(players,member)
				end
			end
		end
	end
	if #players > 0 then
		return players
	else
		return false
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

--here get close tower
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

--here get close player
function GetClosePlayer(hero, team)
	local players = GetPlayers(team,false,false)
	if #players > 0 then
		local candidate = players[1]
		for i=2, #players, 1 do
			if hero:GetDistance(candidate) > hero:GetDistance(players[i]) then candidate = players[i] end
		end
		return candidate
	else
		return false
	end
end

-- return count of champs near hero
function cntOfChampsNear(hero,team,distance)
	local cnt = 0 -- default count of champs near HERO
	local players = GetPlayers(team,false,true)
	for i=1, #players, 1 do
		if players[i] ~= hero and hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
	end
	return cnt
end

-- return %hp of champs near hero
function hpOfChampsNear(hero,team,distance)
	local percent = 0 -- default %hp of champs near HERO
	local players = GetPlayers(team,false, true)
	for i=1, #players, 1 do
		if players[i] ~= hero and hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
	end
	return percent
end

function OnProcessSpell(object,spellProc) --for soraka + sona
	if switcher == true and object.name == player.name and (spellProc.name == "SonaHymnofValorAttack" or spellProc.name == "SonaAriaofPerseveranceAttack" or spellProc.name == "SonaBasicAttack" or spellProc.name == "SonaBasicAttack2" or spellProc.name == "SonaSongofDiscordAttack" or spellProc.name == "SorakaBasicAttack" or spellProc.name == "SorakaBasicAttack2") then
		Run(GetCloseTower(player,player.team))
	end
end

-- is recall, return true/false
function isRecall(hero)
	if GetTickCount() - recallStartTime > 8000 then
		return false
	else
		if recentrecallTarget.name == hero.name then
			return true
		end
		return false
	end
end

function OnCreateObj(object)
	if object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy" then
		for i = 1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			if GetDistance(target, object) < 100 then
				recentrecallTarget = target
			end
		end
		recallStartTime = GetTickCount()
	end
end

-- turn (off - on) by SetupTogleKey
-- follow summoners via follow menu
function OnWndMsg(msg, keycode)
	if keycode == SetupTogleKey and msg == KEY_DOWN then
        if switcher == true then
            switcher = false
			PrintChat("<font color='#FF0000'>Passive Follow >> TURNED OFF </font>")
        else
            switcher = true
			PrintChat("<font color='#00FF00'>Passive Follow >> TURNED ON </font>")
        end
    end
	
	for i=1, #allies, 1 do 
		if keycode == FollowKeysCodes[i] and msg == KEY_DOWN then
			following = allies[i]
			PrintChat("Passive Follow >> following summoner: "..allies[i].name)
			state = FOLLOW
		end
	end
end

-- CHAT CALLBACK
function OnSendChat(text)
	if string.sub(text,1,7) == ".follow" then
	BlockChat()
		if string.sub(text,9,13) == "start" then
			name = string.sub(text,15)
			players = GetPlayers(player.team, true, false)
			if players ~= false then
				for i=1, #players, 1 do
					if (string.lower(players[i].name) == string.lower(name))  then 
						following = players[i]
						PrintChat("Passive Follow >> following summoner: "..players[i].name)
						carryCheck = true
						if following.dead then state = WAITING_FOLLOW_RESP else state = FOLLOW end
					end
				end
				if following == nil then PrintChat("Passive Follow >> "..name.." did not found") end
			end
		end
		if string.sub(text,9,12) == "stop" then
			following = nil
			state = FOLLOW
			PrintChat("Passive Follow >> terminated")
		end
	end
end

function setSummonerSlots()
	--set heal
	if player:GetSpellData(SUMMONER_1).name == "SummonerHeal" then
		HL_slot = SUMMONER_1
	elseif player:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
		HL_slot = SUMMONER_2
	end
	
	--set clarity
	if player:GetSpellData(SUMMONER_1).name == "SummonerMana" then
		CL_slot = SUMMONER_1
	elseif player:GetSpellData(SUMMONER_2).name == "SummonerMana" then
		CL_slot = SUMMONER_2
	end
end
-- TIMER CALLBACK
mytime = GetTickCount() 

-- STATUS CALLBACK
function Status(member, desc, value)
	if member == following and desc == 1 then
		if member.dead and state == FOLLOW then
			PrintChat("Passive Follow >> "..member.name.." dead")
			-- if SetupFollowAlly == true and ALLYNEAR then temporary changing follow target
			if SetupFollowAlly and player:GetDistance(GetClosePlayer(player,player.team)) < SetupFollowDistance then 
				temp_following = GetClosePlayer(player,player.team)
				PrintChat("Passive Follow >> "..(GetClosePlayer(player,player.team)).name.." temporary following")
				state = TEMP_FOLLOW
			elseif SetupRunAway then 
				state = GOING_TO_TOWER
			else
				state = WAITING_FOLLOW_RESP
			end
		end
		if member.dead == false then
			if state == WAITING_FOLLOW_RESP then
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
			if state == TEMP_FOLLOW then
				temp_following = nil
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
			if state == GOING_TO_TOWER then
				PrintChat("Passive Follow >> "..member.name.." alive")
				state = FOLLOW
			end
		end
	end
end

-- SEMICORE
-- run(follow) to target
function Run(target)
	if target.type == "obj_AI_Hero" then
		if target:GetDistance(allySpawn) > SetupFollowDistance then
			if (player:GetDistance(target) > SetupFollowDistance or player:GetDistance(target) < 275 --[[this is to stop get aoe, which are often 275 range]] or player:GetDistance(allySpawn) + 275 > target:GetDistance(allySpawn)) then
				followX = ((allySpawn.x - target.x)/(target:GetDistance(allySpawn)) * ((SetupFollowDistance - 300) / 2 + 300) + target.x + math.random(-((SetupFollowDistance-300)/3),((SetupFollowDistance-300)/3)))
				followZ = ((allySpawn.z - target.z)/(target:GetDistance(allySpawn)) * ((SetupFollowDistance - 300) / 2 + 300) + target.z + math.random(-((SetupFollowDistance-300)/3),((SetupFollowDistance-300)/3)))
				player:MoveTo(followX, followZ)
			else
				player:HoldPosition()
			end
		elseif SetupFollowRecall and player:GetDistance(allySpawn) > (SetupFollowDistance * 3) then
			state = GOING_TO_TOWER
		end
	end
	if target.type == "obj_AI_Turret" then 
		if player:GetDistance(target) > 300 then 
			player:MoveTo(target.x + math.random(-150,150), target.z + math.random(-150,150))
		elseif SetupRunAwayRecall then
			CastSpell(RECALL)
			if following.dead == true then
				state = WAITING_FOLLOW_RESP
			else
				state = FOLLOW
			end
		end
	end
end

-- CORE
function Brain()
	if following ~= nil and player.dead == false and isRecall(player) == false then 
		if state == FOLLOW then 
			Run(following) 
		end
		if state == TEMP_FOLLOW and temp_following ~= nil then Run(temp_following) end
		if state == GOING_TO_TOWER then Run(GetCloseTower(player,player.team)) end
		
	end
end

-- Drawing follow menu
function OnDraw()
	local tempSetupDrawY = SetupDrawY

	DrawText("Press "..SetupTogleKeyText.." to toggle passive follow script.", MenuTextSize , (WINDOW_W - WINDOW_X) * SetupDrawX, (WINDOW_H - WINDOW_Y) * tempSetupDrawY , 0xffffff00) 
	tempSetupDrawY = tempSetupDrawY + 0.03
	
	for i=1, #allies, 1 do
		DrawText("Press "..FollowKeysText[i].." to follow player: "..allies[i].name.." ("..allies[i].charName..")", MenuTextSize , (WINDOW_W - WINDOW_X) * SetupDrawX, (WINDOW_H - WINDOW_Y) * tempSetupDrawY , 0xffffff00) 
		tempSetupDrawY = tempSetupDrawY + 0.03
	end
end


-- AT LOADING OF SCRIPT

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

------------------------------------------------
----------------------init----------------------
------------------------------------------------

function OnLoad()
breakers = os.clock()    --start timer
	PrintChat("Passive Follow >> v"..tostring(version).." LOADED")
	carryCheck = false
	-- numerate spawn
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
	-- fix user settings
	if SetupFollowDistance < 400 then SetupFollowDistance = 400 end
	-- count towers
	
	--set allies player list
	allies = GetPlayers(player.team, true, false)


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
				local result = AIFind.weakAlly(myHero,750,false,true)
				if result ~= nil and (result.health + AIStat.heal(result,GetSpellData(_W).level * 70 + myHero.ap * 0.4))/result.maxHealth <= desiredHeal then 
					CastSpell(_W,result) 
					return
				end
			end
			--check for ult
			if CanUseSpell(_R) == READY then
				--save ult power
				local ultPower = (200 + (GetSpellData(_R).level - 1) * 120 + myHero.ap * 0.7)
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
			--check for mana 
			if CanUseSpell(_E) == READY then
				local result = AIFind.depletedAlly(myHero,750)
				if result ~= nil and (result.mana +  GetSpellData(_E).level * 40)/result.maxMana <= desiredReplenish then 
					CastSpell(_E,result) 
					return
				end
			end
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
	
	--buy items
	AITimer.add(0.5,function() if desiredItems == true and AIRoutine.distance(myHero,AIData.allySpawn) <  500  and items ~= nil then AISpell.buy(items) if AISpell.ward() == nil then BuyItem(2044) end end end)
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
------------------------------------------------

guiMenu = nil
action,actionTimer,brainTimer = nil,nil
function drawGui()
	if guiMenu == nil then
		guiMenu = {AIGui.text(0,0,"SorakaBot PRO Edition Settings")}
		guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Ult till %hp"),AIGui.slider(0,0,desiredUlt * 100,0,110,function(num) desiredUlt = num/100 end)})
		guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Heal till %hp"),AIGui.slider(0,0,desiredHeal * 100,0,110,function(num) desiredHeal = num/100 end)})
		guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Replenish till %mp"),AIGui.slider(0,0,desiredReplenish * 100,0,110,function(num) desiredReplenish = num/100 end)})
		guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.tick(0,0,desiredSummoners,function(state) desiredSummoners = state end),AIGui.text(0,0,"Auto Summoners Spells")})
		guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.tick(0,0,desiredLevel,function(state) desiredLevel = state if state == true and spells ~= nil then AISpell.level(spells) end end),AIGui.text(0,0,"Auto Level Spells")})
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

------------------------------------------------
----------------------AI-----------------------
------------------------------------------------

function attackEnemy()
	PrintChat("Harras Enemy")
	return AITimer.add(0.1,function()
			if lastEnemy[1] ~= nil and lastEnemy[1].dead == false and lastEnemy[1].visible == true then
				myHero:Attack(lastEnemy[1])
				CastSpell(_E,lastEnemy[1])
				if AIRoutine.distance(myHero,lastEnemy[1]) < 530 then 
					CastSpell(_Q) 
					local summoner = AISpell.ignite()
					if summoner ~= nil and lastEnemy[1].health + lastEnemy[1].hpRegen * 2.5 < 50 + 20 * myHero.level then CastSpell(summoner,lastEnemy[1]) end
				end
			end
		end)
end

function ks()
	PrintChat("Killer Mode. Now Will Be Revange!")
	local target = AIFind.weakMagicEnemy(myHero,600)
	return AITimer.add(0.1,function()
			if target ~= nil and target.dead == false and target.visible == true then
				myHero:Attack(target)
				CastSpell(_E,target)
				if AIRoutine.distance(myHero,target) < 530 then 
					CastSpell(_Q) 
					local summoner = AISpell.ignite() 
					if summoner ~= nil and target.health + target.hpRegen * 2.5 < 50 + 20 * myHero.level then CastSpell(summoner,target) end
				end
			end
		end)
end

function attackTower()
	PrintChat("Attack Tower")
	return AITimer.add(0.1,function()
			if lastTower[1] ~= nil and lastTower[1].valid == true and lastTower[1].dead == false and lastTower[1].visible == true then
				myHero:Attack(lastTower[1])
			end
		end)
end

function towerWait()
	PrintChat("Wait Under Tower")
	local tower = AIFind.allyTower(myHero,2000) or AIData.allySpawn
	tower = AIRoutine.pos(tower,AIRoutine.rad(tower,AIData.allySpawn),200) 
	return AITimer.add(0.1,function()
			--smart move
			if AIData.map == "classic" and AICondition.enemySide(myHero) == true and AICondition.river(myHero) == false then
				local toGo = AIRoutine.project({x=1000,z=13600},{x=13100,z=1500},myHero)
				myHero:MoveTo(toGo.x,toGo.z)
			-- go to wait tower
			elseif AIRoutine.distance(tower,myHero) > 125 then myHero:MoveTo(tower.x,tower.z) end
		end)
end

function ward()
	SendChat("I Go Put Ward")
	local pos = AIRoutine.findMatch(wards,
							function(this) return AIFind.ward(this) == nil end,
							function(a,b) return AIRoutine.distance(myHero,a) < AIRoutine.distance(myHero,b) end)
	return AITimer.add(0.5,function()
			local slot = AISpell.ward()
			if slot ~= nil and pos ~= nil and AIFind.ward(pos) == nil then CastSpell(slot,pos.x,pos.z) end
		end)
end

function followRecall()
	PrintChat("Follow Recall")
	return AITimer.add(0.2,function()
		--we ready to recall with followtarget
		if AIRoutine.distance(myHero,followTarget) < 200 or AIRoutine.distance(followTarget,AIData.allySpawn) < followTarget.ms * 10 then CastSpell(RECALL) 
		--we need to come 
		else myHero:MoveTo(followTarget.x,followTarget.z) end
	end)
end

function runAway()
	PrintChat("Run Away")
	local tower = AIFind.safeTower(myHero)
	return AITimer.add(0.25,function()
		--check summoners
		local summoner = AISpell.barrier() or AISpell.ghost()
		if summoner ~= nil and AIStat.hps(myHero) / myHero.maxHealth < -0.2 then CastSpell(summoner) end
		--smart move
		if AIData.map == "classic" and AICondition.enemySide(myHero) == true and AICondition.river(myHero) == false then
			local toGo = AIRoutine.project({x=1000,z=13600},{x=13100,z=1500},myHero)
			myHero:MoveTo(toGo.x,toGo.z)
		--is safe tower exist
		elseif tower ~= nil and tower.valid == true then
			--are we near safe tower
			if AIRoutine.distance(myHero,tower) < 300 then tower = nil
			--check enemies
			elseif AIFind.enemy(tower,900) ~= nil then tower = nil
			--go to tower
			else myHero:MoveTo(tower.x,tower.z) end
		--go to spawn
		elseif AIRoutine.distance(myHero,AIData.allySpawn) > 200 then myHero:MoveTo(AIData.allySpawn.x,AIData.allySpawn.z) end
	end)
end

tempFollowTarget = nil
function tempFollow()
	PrintChat("Temp Follow")
	return AITimer.add(0.25,function() 
			if AIRoutine.distance(myHero,tempFollowTarget) > 50 and AIRoutine.distance(myHero,tempFollowTarget) < 475 and AICondition.behind(myHero,tempFollowTarget) == true then
				myHero:StopPosition() 
			elseif AICondition.enemySide(myHero) == false then
				local toGo = nil
				if IsWallOfGrass(D3DXVECTOR3(tempFollowTarget.x,tempFollowTarget.y,tempFollowTarget.z)) == 0 then toGo = AIRoutine.pos(tempFollowTarget,AIRoutine.rad(myHero,AIData.allyNexus),250)
				--if hero is inside grass then we go more close
				else toGo = AIRoutine.pos(tempFollowTarget,AIRoutine.rad(myHero,AIData.allyNexus),110) end
				myHero:MoveTo(toGo.x + math.random(-20,20),toGo.z + math.random(-20,20))
			else 
				local toGo = nil
				if IsWallOfGrass(D3DXVECTOR3(tempFollowTarget.x,tempFollowTarget.y,tempFollowTarget.z)) == 0 then toGo = AIRoutine.pos(tempFollowTarget,AIRoutine.rad(AIData.enemyNexus,myHero),250)
				--if hero is inside grass then we go more close
				else toGo = AIRoutine.pos(tempFollowTarget,AIRoutine.rad(AIData.enemyNexus,myHero),110) end
				myHero:MoveTo(toGo.x + math.random(-20,20),toGo.z + math.random(-20,20))
			end
		end)
end

function goToSpawn()
	SendChat("I Go 2 Spawn")
	local recall = AIFind.safeTower(myHero)
	--fix recall pos
	if recall ~= nil then recall = AIRoutine.pos(recall,AIRoutine.rad(recall,AIData.allySpawn),200) end
	--choose way: RECALL or RUN STRAIGHT
	if recall ~= nil and AICondition.recallFaster(recall,myHero.ms) == true then
		return AITimer.add(0.25,function() 
			--fix recall pos
			if recall == nil or AICondition.recallFaster(recall,myHero.ms) == false or AIFind.enemy(recall,900) ~= nil then
				recall = AIFind.safeTower(myHero)
				if recall ~= nil then recall = AIRoutine.pos(recall,AIRoutine.rad(recall,AIData.allySpawn),200) end
			end
			--smart move
			if AIData.map == "classic" and AICondition.enemySide(myHero) == true and AICondition.river(myHero) == false then
				local toGo = AIRoutine.project({x=1000,z=13600},{x=13100,z=1500},myHero)
				myHero:MoveTo(toGo.x,toGo.z)
			--if recall pos is not available then go straight
			elseif recall == nil and AIRoutine.distance(myHero,AIData.allySpawn) > 200 then myHero:MoveTo(AIData.allySpawn.x,AIData.allySpawn.z)
			--check did we recalled
			elseif AIRoutine.distance(myHero,AIData.allySpawn) < 500 then recall = nil
			--going to recall pos
			elseif AIRoutine.distance(myHero,recall) > 125 then myHero:MoveTo(recall.x,recall.z) 
			--recall
			else CastSpell(RECALL) end
		end)
	else
		return AITimer.add(0.25,function() 
				--smart move
				if AIData.map == "classic" and AICondition.enemySide(myHero) == true and AICondition.river(myHero) == false then
					local toGo = AIRoutine.project({x=1000,z=13600},{x=13100,z=1500},myHero)
					myHero:MoveTo(toGo.x,toGo.z)
				elseif AIRoutine.distance(myHero,AIData.allySpawn) > 200 then myHero:MoveTo(AIData.allySpawn.x,AIData.allySpawn.z) end
			end) 
	end
	
end

followTarget = nil
function follow()
	PrintChat("Follow")
	return AITimer.add(0.25,function() 
			if AIRoutine.distance(myHero,followTarget) > 50 and AIRoutine.distance(myHero,followTarget) < 475 and AICondition.behind(myHero,followTarget) == true then
				myHero:StopPosition() 
			elseif AICondition.enemySide(myHero) == false then
				local toGo = nil
				if IsWallOfGrass(D3DXVECTOR3(followTarget.x,followTarget.y,followTarget.z)) == 0 then toGo = AIRoutine.pos(followTarget,AIRoutine.rad(myHero,AIData.allyNexus),225)
				--if hero is inside grass then we go more close
				else toGo = AIRoutine.pos(followTarget,AIRoutine.rad(myHero,AIData.allyNexus),110) end
				myHero:MoveTo(toGo.x + math.random(-20,20),toGo.z + math.random(-20,20))
			else 
				local toGo = nil
				if IsWallOfGrass(D3DXVECTOR3(followTarget.x,followTarget.y,followTarget.z)) == 0 then toGo = AIRoutine.pos(followTarget,AIRoutine.rad(AIData.enemyNexus,myHero),225)
				--if hero is inside grass then we go more close
				else toGo = AIRoutine.pos(followTarget,AIRoutine.rad(AIData.enemyNexus,myHero),110) end
				myHero:MoveTo(toGo.x + math.random(-20,20),toGo.z + math.random(-20,20))
			end
		end)
end

function wait()
	PrintChat("Wait")
	return AITimer.add(0.25,function() 
			if myHero.dead == false and AIRoutine.distance(myHero,AIData.allySpawn) > 200 then myHero:MoveTo(AIData.allySpawn.x,AIData.allySpawn.z) end
		end)
end

--brain
lastEnemy= {nil,0}
lastTower = {nil,0}
AddProcessSpellCallback(function(unit,spell) 
		if followTarget ~= nil and unit.networkID == followTarget.networkID then
			lastEnemy[1] = AIFind.enemy(spell.endPos,50)
			if lastEnemy[1] ~= nil then lastEnemy[2] = os.clock() 
			else
				lastTower[1] = AIFind.enemyTower(spell.endPos,50)
				if lastTower[1] ~= nil then lastTower[2] = os.clock() end
			end
		end
	end)

goingToSpawn = false
function decide()
	if myHero.dead == true then 
		goingToSpawn = false 
		return wait
	elseif AIRoutine.distance(myHero,AIData.allySpawn) < 500 then
		goingToSpawn = false
		if myHero.mana < myHero.maxMana or myHero.health < myHero.maxHealth then return wait
		elseif followTarget.dead == true then return wait
		elseif AIRoutine.distance(followTarget,AIData.allySpawn) < 500 then return wait
		else return follow end
	elseif goingToSpawn == true then return goToSpawn
	elseif AIStat.hps(myHero)/myHero.health < -0.075 then return runAway
	elseif followTarget.dead == true then 
		local weak = AIFind.weakMagicEnemy(myHero,600) 
		if weak ~= nil and weak.health/weak.maxHealth < 0.15 and AIStat.pvp({myHero},{weak}) > 0.9 then return ks 
		elseif followTarget.deathTimer < AIRoutine.distance(myHero,AIData.allySpawn)/myHero.ms - 10 then return goToSpawn
		elseif AIFind.ally(myHero,1000) ~= nil then
			tempFollowTarget = AIFind.ally(myHero,1000)
			return tempFollow
		elseif AIFind.allyTower(myHero,2000) ~= nil then return towerWait
		else return goToSpawn end
	elseif AICondition.recall(followTarget) == true and AICondition.recallFaster(followTarget,myHero.ms) == true then 
		if AIRoutine.distance(myHero,followTarget) > myHero.ms * 2.5 then return goToSpawn
		elseif AIFind.enemy(myHero,900) ~= nil then return runAway
		else return followRecall end
	elseif AICondition.recall(myHero) == true and AIRoutine.distance(followTarget,AIData.allySpawn) < followTarget.ms * 10 then
		if AIFind.enemy(myHero,900) ~= nil then return runAway
		else return followRecall end
	elseif myHero.health/myHero.maxHealth < 0.25 or myHero.mana < 70 + myHero.level * 5 then 
		goingToSpawn = true 
		return goToSpawn
	elseif myHero.gold > 1250 and AISpell.ward() == nil then 
		goingToSpawn = true
		return goToSpawn
	elseif GetInGameTimer() > 180 and AISpell.ward() ~= nil and AIRoutine.findMatch(wards,
										    function(this) return AIFind.ward(this) == nil and AIRoutine.distance(this,myHero) < 1500 and AIFind.enemy(this,AIRoutine.distance(this,myHero) * 1.1) == nil end,
										    function(a,b) return AIRoutine.distance(myHero,a) < AIRoutine.distance(myHero,b) end) ~= nil then return ward
	elseif AIRoutine.distance(myHero,followTarget) > 475 then return follow
	elseif lastEnemy[1] ~= nil  and lastEnemy[2] + 1.5 > os.clock() and AIRoutine.distance(myHero,lastEnemy[1]) < 850 and AIFind.enemyTower(myHero,1000) == nil then return attackEnemy
	elseif lastTower[1] ~= nil and lastTower[1].valid == true and lastTower[2] + 1.5 > os.clock() and AIRoutine.distance(myHero,lastTower[1]) < 850 then return  attackTower
	else return follow end
	end
	
	function OnTick()
		if firstBought == false and GetTickCount() - startingTime > 2000 then
			BuyItem(2044) -- stealth ward (green)
			BuyItem(2044)
			BuyItem(1004) -- Faerie Charm
			BuyItem(2004) -- Mana Potion
			BuyItem(2004)
			BuyItem(2004)
			BuyItem(2003) -- Health Potion
			BuyItem(3340) -- warding totem (trinket)
			firstBought = true
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
		

-- if in fountain and has no mana/hp, wait to fill up mana/hp bar before heading back out
if InFountain() and (player.mana ~= player.maxMana or player.health ~= player.maxHealth) then
		if isRegen == false then
			PrintChat("Passive Follow >> Waiting at fountain to replenish mana and health.")
			isRegen = true
		end
		
		player:HoldPosition()
else
isRegen = false

-- use summoners if health of ally is low or if your mana is low 
local lowHPPercent = 40
local lowManaPercent = 40
local healDistance = 500 --actual heal distance is 300 but 500 set due to player distance

if GetTickCount() - lastHeal > HLCooldown then 
	if following ~= nil and following.dead == false and (following.health/following.maxHealth) * 100 < lowHPPercent and player:GetDistance(following) <= healDistance then
		setSummonerSlots()
		
		if HL_slot ~= nil and player:CanUseSpell(HL_slot) == READY then
			PrintChat("Passive Follow >> Used summoner spell: HEAL.")
			CastSpell(HL_slot)
			lastHeal = GetTickCount()
		end

	end
end

if GetTickCount() - lastMana > CLCooldown then 
	if (player.mana/player.maxMana) * 100 < lowManaPercent then
		setSummonerSlots()
		
		if CL_slot ~= nil and player:CanUseSpell(CL_slot) == READY then
			PrintChat("Passive Follow >> Used summoner spell: CLARITY.")
			CastSpell(CL_slot)
			lastMana = GetTickCount()
		end
	end
end

-- if there is no one go to bot "no adc(follower target)"
if carryCheck == false and breaker == false and os.clock() >= breakers + afktime and following == nil then
for i = 1, heroManager.iCount, 1 do --get heros
		local teammates = heroManager:getHero(i)
		if teammates.team == player.team and teammates.name ~= player.name and teammates.name ~= following and MapPosition:inBase(teammates) == false then 
		
		following = teammates
		PrintChat("Passive Follow >> following summoner: "..teammates.name)
		state = FOLLOW
		carryCheck = true
		breakers = os.clock()
		end
end
end


-- if the target is afk
if carryCheck == true and breaker == false then
if MapPosition:inBase(following) == true then
breakers = os.clock()
breaker = true
end
end
-- if the target moved again after afk "maybe the adc recall or die"
if carryCheck == true and breaker == true then
if MapPosition:inBase(following) == false then
breaker = false
end
end
-- choose new hero to follow
if os.clock() >= breakers + afktime and breaker == true then 
		
		for i = 1, heroManager.iCount, 1 do --get heros

		local teammates = heroManager:getHero(i)

		if teammates.team == player.team and teammates.name ~= player.name and teammates.name ~= following and MapPosition:inBase(teammates) == false then --check if hero is alive, in my team(!) and not the same like before
		
		following = teammates

		PrintChat("Passive Follow >> following summoner: "..teammates.name)

		state = FOLLOW
		breaker = false
end
end
end

	--Identify AD carry and follow
	if carryCheck == false then
		for i = 1, heroManager.iCount, 1 do
		local teammates = heroManager:getHero(i) 
		--Coordinates are for bots only
			if math.sqrt((teammates.x - 12143)^2 + (teammates.z - 2190)^2) < 4500 and teammates.team == player.team and teammates.name ~= player.name then
				following = teammates
				PrintChat("Passive Follow >> following summoner: "..teammates.name)
				state = FOLLOW
				carryCheck = true
			end
		end
		
	end

	if GetTickCount() - mytime > 800 and switcher then 
		Brain()
		mytime = GetTickCount() 
	end
	if following ~= nil then
		Status(following, 1, value)
	end
end

end