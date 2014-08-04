local version = "1.9"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/szczurekPROS/GitHub/master/scripts/SorakaBot Free Edition by szczurekPROS.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."SorakaBot Free Edition by szczurekPROS.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function _AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>SorakaBot Free by szczurekPROS:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
        local ServerData = GetWebResult(UPDATE_HOST, "/szczurekPROS/GitHub/master/scripts/Version/sorakabotfree.version")
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

    welcome = "Welcome to SorakaBot version 1.9 by szczurekPROS"
    --[[
    SorakaBot V1.02
    Free Edition by szczurekPROS
    --]]
     
    --press this key for spell settings(F1 default)
    desiredGuiKey = 0x70
    --soraka will heal target up to this percent
    desiredHeal = 0.9
    --soraka will repelnish target mana up to this percent
    desiredReplenish = 0.5
    --soraka will ult teammates up to this percent
    desiredUlt = 0.75
    --soraka will use summoners
    desiredSummoners = true
    --enable autobuy items from list
    desiredItems = true
    --Item List
	--[[ Config ]]
	shopList = {1006, 3301, 3096, 1001, 1028, 3158, 3067, 3069, 1028, 3105, 3190, 1028, 3010, 3027, 3065}
	--item ids can be found at many websites, ie: http://www.lolking.net/items/1004

	nextbuyIndex = 1
	wardBought = 0
	firstBought = false
	lastBuy = 0
	
	buyDelay = 100 --default 100
    --enable level spells from array bellow
    desiredLevel = true
    --level sequence
    spells = {_W,_E,_Q,_W,_E,_R,_W,_Q,_W,_E,_R,_E,_Q,_Q,_Q,_R,_E,_W}
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
     
    ------------------------------------------------
    ----------------------init----------------------
    ------------------------------------------------
     
    function OnLoad()
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
                    guiMenu = {AIGui.text(0,0,"SorakaBot V1.9 by szczurekPROS")}
                    if brainTimer ~= nil then guiMenu[#guiMenu + 1] = AIGui.button(0,0,"Stop action",function()
                                    AITimer.remove(brainTimer)
                                    AITimer.remove(actionTimer)
                                    brainTimer,actionTimer = nil,nil
                                    removeGui()
                                    drawGui()
                            end)
                    else
                            for i=1,#AIData.allies,1 do
                                    if AIData.allies[i].networkID ~= myHero.networkID then
                                            guiMenu[#guiMenu + 1] = AIGui.button(0,0,"Follow "..AIData.allies[i].charName,function()
                                                            followTarget = AIData.allies[i]
                                                            action = decide()
                                                            actionTimer = action()
                                                            brainTimer = AITimer.add(0.125,function()
                                                                            local candidate = decide()
                                                                            if action ~= candidate then
                                                                                    AITimer.remove(actionTimer)
                                                                                    action = candidate
                                                                                    actionTimer = action()
                                                                            end
                                                                    end)
                                                            removeGui()
                                                            drawGui()
                                                    end)
                                    end
                            end
                    end
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Ult till %hp"),AIGui.slider(0,0,desiredUlt * 100,0,110,function(num) desiredUlt = num/100 end)})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Heal till %hp"),AIGui.slider(0,0,desiredHeal * 100,0,110,function(num) desiredHeal = num/100 end)})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.text(0,0,"Auto Replenish till %mp"),AIGui.slider(0,0,desiredReplenish * 100,0,110,function(num) desiredReplenish = num/100 end)})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.tick(0,0,desiredSummoners,function(state) desiredSummoners = state end),AIGui.text(0,0,"Auto Summoner Spells")})
                    guiMenu[#guiMenu + 1] = AIGui.line(0,0,{AIGui.tick(0,0,desiredLevel,function(state) desiredLevel = state if state == true and spells ~= nil then AISpell.level(spells) end end),AIGui.text(0,0,"Auto LVL Skills")})
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
		if firstBought == false and GetTickCount() - startingTime > 2000 then
			BuyItem(2044)
			BuyItem(1004) -- Faerie Charm
			BuyItem(2004)
			BuyItem(2004)
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
		
	end
    ------------------------------------------------
    ----------------------AI-----------------------
    ------------------------------------------------
     
    function attackEnemy()
            PrintChat("Attack Enemy")
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
            PrintChat("Kill Steal")
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
            PrintChat("Wait Near Tower")
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
            SendChat("I Go Base")
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
            PrintChat("Follow Ally")
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
            else return follow 
end
	end
