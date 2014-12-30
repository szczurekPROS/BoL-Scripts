    local abilitySequence
    local qOff, wOff, eOff, rOff = 0,0,0,0
    buyIndex = 1
    shoplist = {}
    buffs = {{pos = { x = 8922, y = 10, z = 7868 },current=0},{pos = { x = 7473, y = 10, z = 6617 },current=0},{pos = { x = 5929, y = 10, z = 5190 },current=0},{pos = { x = 4751, y = 10, z = 3901 },current=0}}
    lastsixpos = {0,0,0,0,0,0,0,0,0,0}
    do
            myHero = GetMyHero()
            Target = nil
            spawnpos  = { x = myHero.x, z = myHero.z}
            ranged = 0
            assassins = {"Akali","Diana","Evelynn","Fizz","Katarina","Nidalee"}
            adtanks = {"DrMundo","Garen","Hecarim","Jarvan IV","Nasus","Skarner","Volibear","Yorick"}
            adcs = {"Ashe","Caitlyn","Corki","Draven","Ezreal","Gankplank","Graves","KogMaw","Lucian","MissFortune","Quinn","Sivir","Thresh","Tristana","Tryndamere","Twitch","Urgot","Varus","Vayne"}
            aptanks = {"Alistar","Amumu","Blitzcrank","ChoGath","Leona","Malphite","Maokai","Nautilus","Rammus","Sejuani","Shen","Singed","Zac"}
            mages = {"Ahri","Anivia","Annie","Brand","Cassiopeia","Galio","Gragas","Heimerdinger","Janna","Karma","Karthus","LeBlanc","Lissandra","Lulu","Lux","Malzahar","Morgana","Nami","Nunu","Orianna","Ryze","Sona","Swain","Syndra","Taric","TwistedFate","Veigar","Viktor","Xerath","Ziggs","Zilian","Zyra"}
            hybrids = {"Kayle","Teemo"}
            bruisers = {"Darius","Irelia","Khazix","LeeSin","Olaf","Pantheon","Renekton","Rengar","Riven","Shyvana","Talon","Trundle","Vi","Wukong","Zed"}
            fighters = {"Aatrox","Fiora","Jax","Jayce","Nocturne","Poppy","Sion","Udyr","Warwick","XinZhao"}
            apcs = {"Elise","FiddleSticks","Kennen","Mordekaiser","Rumble","Vladimir"}
     
            heroType = nil
           
            for i,nam in pairs(adcs) do
                   
                    if nam == myHero.charName then
                            heroType = 1
                    end
            end
           
            for i,nam in pairs(adtanks) do
                    if nam == myHero.charName then
                            heroType = 2
                    end
            end
            for i,nam in pairs(aptanks) do
                    if nam == myHero.charName then
                            heroType = 3
                    end
            end
            for i,nam in pairs(hybrids) do
                    if nam == myHero.charName then
                            heroType = 4
                    end
            end
            for i,nam in pairs(bruisers) do
                    if nam == myHero.charName then
                            heroType = 5
                    end
            end
            for i,nam in pairs(assassins) do
                    if nam == myHero.charName then
                            heroType = 6
                    end
            end
            for i,nam in pairs(mages) do
                    if nam == myHero.charName then
                            heroType = 7
                    end
            end
            for i,nam in pairs(apcs) do
                    if nam == myHero.charName then
                            heroType = 8
                    end
            end
            for i,nam in pairs(fighters) do
                    if nam == myHero.charName then
                            heroType = 9
                    end
            end
            if heroType == nil then
                    heroType = 10
            end
            if heroType ~= 10 then
                    SendChat("Hero Items Loaded")
            end
            if heroType == 1 then
                    SendChat("Hero Type: ADC" )
            elseif heroType == 2 then
                    SendChat("Hero Type: ADTANK" )
            elseif heroType == 3 then
                    SendChat("Hero Type: APTANK" )
            elseif heroType == 4 then
                    SendChat("Hero Type: HYBRID" )
            elseif heroType == 5 then
                    SendChat("Hero Type: BRUISER" )       
            elseif heroType == 6 then
                    SendChat("Hero Type: ASSASSIN" )      
            elseif heroType == 7 then
                    SendChat("Hero Type: MAGE" )  
            elseif heroType == 8 then
                    SendChat("Hero Type: APC" )   
            elseif heroType == 9 then
                    SendChat("Hero Type: FIGHTER" )       
            else
                    SendChat("Hero Type: I don't know :(" )
            end
           
            if myHero.range > 400 then
                    ranged = 1
            end
           
            if heroType == 1 then
                    shopList = {3006,1042,3086,3087,3144,3153,1038,3181,1037,3035,3026,0}
            end
            if heroType == 2 then
                    shopList = {3047,1011,3134,3068,3024,3025,3071,3082,3143,3005,0}
            end
            if heroType == 3 then
                    shopList = {3111,1031,3068,1057,3116,1026,3001,3082,3110,3102,0}
            end
            if heroType == 4 then
                    shopList = {1001,3108,3115,3020,1026,3136,3089,1043,3091,3151,3116}
            end
            if heroType == 5 then
                    shopList = {3111,3134,1038,3181,3155,3071,1053,3077,3074,3156,3190}
            end
            if heroType == 6 then
                    shopList = {3020,3057,3100,1026,3089,3136,3151,1058,3157,3135,0}
            end
            if heroType == 7 then
                    shopList = {3028,1001,3020,3136,1058,3089,3174,3151,1026,3001,3135,0}
            end
            if heroType == 8 then
                    shopList = {3145,3020,3152,1026,3116,1058,3089,1026,3001,3157}
            end
            if heroType == 9 or heroType == 10 then
                    shopList = {3111,3044,3086,3078,3144,3153,3067,3065,3134,3071,3156,0}
            end
    end
     
    buyDelay = 500
     
    function OnTick()
            if not myHero.dead then
                    stance = 0
                    if Allies() >=  2 then
                            stance = 1
                            PrintFloatText(myHero, 0, "TF mode")
                    else
                            stance = 0
                            PrintFloatText(myHero, 0, "Alone mode")
                    end
                    val = myHero.maxHealth/myHero.health
                    if  val > 3 and GetDistance(findClosestEnemy()) > 300 then
                            stance = 3
                            PrintFloatText(myHero, 0, "Low Health mode")
                    end
                    if findLowHp() ~= 0 then
                            Target = findLowHp()
                            else
                            Target = findClosestEnemy()
                    end
                   
                    Allie = followHero()
                    if Target ~= nil then
                      myHero:Attack(Target)
                            if stance == 1  then
                                    attacksuccess = 0
                                    if myHero:GetSpellData(_W).range > GetDistance(Target) then
                                            CastSpell(_W, Target)
                                            attacksuccess =1
                                            PrintFloatText(Target,0,"Casting spell to".. Target.charName)
                                    end
                                    if myHero:GetSpellData(_Q).range > GetDistance(Target) then
                                            CastSpell(_Q, Target)
                                            attacksuccess =1
                                            PrintFloatText(Target,0,"Casting spell to".. Target.charName)
                                    end
                                    if myHero:GetSpellData(_E).range > GetDistance(Target) then
                                            CastSpell(_E, Target)
                                            attacksuccess = 1
                                            PrintFloatText(Target,0,"Casting spell to".. Target.charName)
                                    end
                                    if myHero:GetSpellData(_R).range > GetDistance(Target) then
                                            CastSpell(_R, Target)
                                            attacksuccess =1
                                            PrintFloatText(Target,0,"Casting spell to".. Target.charName)
                                    end
                                    if GetDistance(Target) < getTrueRange() then
                                            myHero:Attack(Target)
                                            if ranged == 1 then
                                                    attacksuccess = 1
                                                    missilesent = 0
                                                    while not missilesent do
                                                            if myHero.dead then missilesent = 1 end
                                                            for _, v in pairs(getChampTable()[myHero.charName].aaParticles) do
                                                                    if obj.name:lower():find(v:lower()) then
                                                                            missilesent =1
                                                                    end
                                                            end
                                                    end
                                            end
                                    end
                                    if attacksuccess == 0 then
                                            --Attack Minions
                                    end
                            elseif stance == 0 then
                                    --alone
                            elseif stance == 3 then
                                    --low health
                                    for i,buff in pairs(buffs) do
                                            if buff.current ==1 then
                                                    if GetDistance(spawnpos,findClosestEnemy()) > GetDistance(spawnpos,buff.pos) then
                                                            myHero:MoveTo(buff.pos.x,buff.pos.z)
                                                            break
                                                    end
                                            end
                                    end
                                    --low health
                            end
                            allytofollow = followHero()
                            if allytofollow ~= nil and GetDistance(allytofollow,myHero) > 350  then
                                    PrintFloatText(allytofollow, 0, "Following")
                                    distance1 = math.random(250,300)
                                    distance2 = math.random(250,300)
                                    neg1 = 1
                                    neg2 = 1
                                    if myHero.team == TEAM_BLUE then
                                            myHero:MoveTo(allytofollow.x-distance1*neg1,allytofollow.z-distance2*neg2)
                                    else
                                            myHero:MoveTo(allytofollow.x+distance1*neg1,allytofollow.z+distance2*neg2)
                                    end
                            end
                            if frontally() == myHero then
                                    myHero:MoveTo(spawnpos.x,spawnpos.z)
                            end
                    end    
                   
            else
                    --dead
                    buyItems()
            end
            buyItems()
            --
            for i =1, objManager.maxObjects do
                    local object = objManager:getObject(i)
                    if object ~= nil and object.name == "HA_AP_HealthRelic4.1.1" then
                            buffs[4].current =1
                    else
                            buffs[4].current=0
                    end
                    if object ~= nil and object.name == "HA_AP_HealthRelic3.1.1" then
                            buffs[3].current =1
                    else
                            buffs[3].current=0
                    end
                    if object ~= nil and object.name == "HA_AP_HealthRelic2.1.1" then
                            buffs[2].current =1
                    else
                            buffs[2].current=0
                    end
                    if object ~= nil and object.name == "HA_AP_HealthRelic1.1.1" then
                            buffs[1].current =1
                    else
                            buffs[1].current=0
                    end
            end
            --
            --LEVELUP
            local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
            if qL + wL + eL + rL < player.level then
                    local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
                    local level = { 0, 0, 0, 0 }
                    for i = 1, player.level, 1 do
                            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
                    end
                    for i, v in ipairs({ qL, wL, eL, rL }) do
                            if v < level[i] then LevelSpell(spellSlot[i]) end
                    end
            end
            --LEVELUP
    end
     
     
    function OnDraw()
             DrawCircle(myHero.x,myHero.y,myHero.z,getTrueRange(),RGB(0,255,0))
             DrawCircle(myHero.x,myHero.y,myHero.z,400,RGB(55,64,60))
             for i,buff in pairs(buffs) do
                    if buff.current == 1 then
                            DrawCircle(buff.pos.x,buff.pos.y,buff.pos.z,150,RGB(0,0,255))
                    end
             end
    end
     
     
    function findClosestEnemy()
        local closestEnemy = nil
        local currentEnemy = nil
        for i=1, heroManager.iCount do
            currentEnemy = heroManager:GetHero(i)
            if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
                if closestEnemy == nil then
                    closestEnemy = currentEnemy
                    elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
                        closestEnemy = currentEnemy
                end
            end
        end
            PrintFloatText(closestEnemy, 0, "Enemy!")
            return closestEnemy
    end
     
    function findLowHp()
            local lowEnemy = nil
        local currentEnemy = nil
        for i=1, heroManager.iCount do
            currentEnemy = heroManager:GetHero(i)
            if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
                   
                if lowEnemy == nil then
                                    lowEnemy = currentEnemy
                            end
                           
                        if currentEnemy.health < lowEnemy.health then
                                    lowEnemy = currentEnemy
                            end
            end
        end
            if lowEnemy ~= nil  then
                    if lowEnemy.health < 200 then
                            PrintFloatText(lowEnemy, 0, "Kill Me")
                            return lowEnemy
                    else
                            return 0
                    end
            else
                    return 0
            end
    end
     
    function Allies()
        local allycount = 0
        for i=1, heroManager.iCount do
            hero = heroManager:GetHero(i)
            if hero.team == myHero.team and not hero.dead and GetDistance(hero) < 350 then
                                            allycount = allycount + 1
                                    end
        end
            return allycount
    end
     
    function frontally()
            local target = nil
            local dist = 0
            for d=1, heroManager.iCount, 1 do
                    TargetAlly = heroManager:getHero(d)
                    if TargetAlly.afk == nil and TargetAlly.dead == false and TargetAlly.team == myHero.team and GetDistance(TargetAlly,spawnpos) > dist then
                            target = TargetAlly
                            dist = GetDistance(target,spawnpos)
                    end
            end
            return target
    end
     
    function getlowMinionHp()
           
    end
     
    function followHero()
            local target =nil
            for d=1, heroManager.iCount, 1 do
                    TargetAlly = heroManager:getHero(d)
                    if TargetAlly.afk == nil and TargetAlly.dead == false and GetDistance(TargetAlly,spawnpos) > 3000 then
                            if TargetAlly.team == myHero.team and TargetAlly.name ~= myHero.name then
                                    target = TargetAlly
                            end
                    end
            end
            return target
    end
     
    function buyItems()
            if shopList[buyIndex] ~= 0 then
                    local itemval = shopList[buyIndex]
                    BuyItem(itemval)
                    if GetInventorySlotItem(shopList[buyIndex]) ~= nil then
                            --Last Buy successful
                            buyIndex = buyIndex + 1
                            buyItems()
                    end
                   
            end
    end
     
    function attackMinions()
     
    end
     
     
     
     
    function getTrueRange()
        return myHero.range + GetDistance(myHero.minBBox)+100
    end
     
    function OnLoad()
        local champ = player.charName
        if champ == "Aatrox" then           abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Ahri" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
        elseif champ == "Akali" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Alistar" then      abilitySequence = { 1, 3, 2, 1, 3, 4, 1, 3, 1, 3, 4, 1, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Amumu" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Anivia" then       abilitySequence = { 1, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 1, 1, 1, 2, 4, 2, 2, }
        elseif champ == "Annie" then        abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Ashe" then         abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Blitzcrank" then   abilitySequence = { 1, 3, 2, 3, 2, 4, 3, 2, 3, 2, 4, 3, 2, 1, 1, 4, 1, 1, }
        elseif champ == "Brand" then        abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Caitlyn" then      abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Cassiopeia" then   abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Chogath" then      abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Corki" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
        elseif champ == "Darius" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
        elseif champ == "Diana" then        abilitySequence = { 2, 1, 2, 3, 1, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "DrMundo" then      abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Draven" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Elise" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, } rOff = -1
        elseif champ == "Evelynn" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Ezreal" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "FiddleSticks" then abilitySequence = { 3, 2, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Fiora" then        abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Fizz" then         abilitySequence = { 3, 1, 2, 1, 2, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Galio" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 3, 2, 2, 4, 3, 3, }
        elseif champ == "Gangplank" then    abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Garen" then        abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Gragas" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
        elseif champ == "Graves" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
        elseif champ == "Hecarim" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Heimerdinger" then abilitySequence = { 1, 2, 2, 1, 1, 4, 3, 2, 2, 2, 4, 1, 1, 3, 3, 4, 1, 1, }
        elseif champ == "Irelia" then       abilitySequence = { 3, 1, 2, 2, 2, 4, 2, 3, 2, 3, 4, 1, 1, 3, 1, 4, 3, 1, }
        elseif champ == "Janna" then        abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 2, 3, 2, 1, 2, 2, 1, 1, 1, 4, 4, }
        elseif champ == "JarvanIV" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 2, 1, 4, 3, 3, 3, 2, 4, 2, 2, }
        elseif champ == "Jax" then          abilitySequence = { 3, 2, 1, 2, 2, 4, 2, 3, 2, 3, 4, 1, 3, 1, 1, 4, 3, 1, }
        elseif champ == "Jayce" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, } rOff = -1
        elseif champ == "Karma" then        abilitySequence = { 1, 3, 1, 2, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 2, }
        elseif champ == "Karthus" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 1, 3, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Kassadin" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Katarina" then     abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
        elseif champ == "Kayle" then        abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
        elseif champ == "Kennen" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Khazix" then       abilitySequence = { 1, 3, 1, 2 ,1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "KogMaw" then       abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Leblanc" then      abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
        elseif champ == "LeeSin" then       abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Leona" then        abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Lissandra" then    abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Lucian" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Lulu" then         abilitySequence = { 3, 2, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
        elseif champ == "Lux" then          abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Malphite" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
        elseif champ == "Malzahar" then     abilitySequence = { 1, 3, 3, 2, 3, 4, 1, 3, 1, 3, 4, 2, 1, 2, 1, 4, 2, 2, }
        elseif champ == "Maokai" then       abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
        elseif champ == "MasterYi" then     abilitySequence = { 3, 1, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 2, 2, 4, 2, 2, }
        elseif champ == "MissFortune" then  abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "MonkeyKing" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Mordekaiser" then  abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Morgana" then      abilitySequence = { 1, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Nami" then         abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 2, 3, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Nasus" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
        elseif champ == "Nautilus" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Nidalee" then      abilitySequence = { 2, 3, 1, 3, 1, 4, 3, 2, 3, 1, 4, 3, 1, 1, 2, 4, 2, 2, }
        elseif champ == "Nocturne" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Nunu" then         abilitySequence = { 3, 1, 3, 2, 1, 4, 3, 1, 3, 1, 4, 1, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Olaf" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Orianna" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Pantheon" then     abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
        elseif champ == "Poppy" then        abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 2, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, }
        elseif champ == "Quinn" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Rammus" then       abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
        elseif champ == "Renekton" then     abilitySequence = { 2, 1, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Rengar" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 2, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Riven" then        abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Rumble" then       abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Ryze" then         abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Sejuani" then      abilitySequence = { 2, 1, 3, 3, 2, 4, 3, 2, 3, 3, 4, 2, 1, 2, 1, 4, 1, 1, }
        elseif champ == "Shaco" then        abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
        elseif champ == "Shen" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Shyvana" then      abilitySequence = { 2, 1, 2, 3, 2, 4, 2, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, }
        elseif champ == "Singed" then       abilitySequence = { 1, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 2, 3, 2, 4, 2, 3, }
        elseif champ == "Sion" then         abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Sivir" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
        elseif champ == "Skarner" then      abilitySequence = { 1, 2, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 3, 3, 4, 3, 3, }
        elseif champ == "Sona" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Soraka" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
        elseif champ == "Swain" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Syndra" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Talon" then        abilitySequence = { 2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Taric" then        abilitySequence = { 3, 2, 1, 2, 2, 4, 1, 2, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
        elseif champ == "Teemo" then        abilitySequence = { 1, 3, 2, 3, 1, 4, 3, 3, 3, 1, 4, 2, 2, 1, 2, 4, 2, 1, }
        elseif champ == "Thresh" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
        elseif champ == "Tristana" then     abilitySequence = { 3, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
        elseif champ == "Trundle" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
        elseif champ == "Tryndamere" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "TwistedFate" then  abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Twitch" then       abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 1, 2, 2, }
        elseif champ == "Udyr" then         abilitySequence = { 4, 2, 3, 4, 4, 2, 4, 2, 4, 2, 2, 1, 3, 3, 3, 3, 1, 1, }
        elseif champ == "Urgot" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
        elseif champ == "Varus" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Vayne" then        abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Veigar" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 2, 2, 2, 2, 4, 3, 1, 1, 3, 4, 3, 3, }
        elseif champ == "Vi" then           abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
        elseif champ == "Viktor" then       abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, }
        elseif champ == "Vladimir" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Volibear" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 4, 3, 1, 3, 1, 4, 3, 1, }
        elseif champ == "Warwick" then      abilitySequence = { 2, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
        elseif champ == "Xerath" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "XinZhao" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Yorick" then       abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 1, 4, 2, 1, 2, 1, 4, 2, 1, }
        elseif champ == "Zac" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Zed" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Ziggs" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        elseif champ == "Zilean" then       abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
        elseif champ == "Zyra" then         abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
        else PrintChat(string.format(" >> AutoLevelSpell  disabled for %s", champ))
        end
        if abilitySequence and #abilitySequence == 18 then
                    --good
        else
            PrintChat(" >> AutoLevel Error")
            OnTick = function() end
            return
        end
    end
    --
    --     
    --
    --
    function getChampTable()
        return {                                                  
            Ahri         = { projSpeed = 1.6, aaParticles = {"Ahri_BasicAttack_mis", "Ahri_BasicAttack_tar"}, aaSpellName = "ahribasicattack", startAttackSpeed = "0.668",  },
            Anivia       = { projSpeed = 1.05, aaParticles = {"cryo_BasicAttack_mis", "cryo_BasicAttack_tar"}, aaSpellName = "aniviabasicattack", startAttackSpeed = "0.625",  },
            Annie        = { projSpeed = 1.0, aaParticles = {"AnnieBasicAttack_tar", "AnnieBasicAttack_tar_frost", "AnnieBasicAttack2_mis", "AnnieBasicAttack3_mis"}, aaSpellName = "anniebasicattack", startAttackSpeed = "0.579",  },
            Ashe         = { projSpeed = 2.0, aaParticles = {"bowmaster_frostShot_mis", "bowmasterbasicattack_mis"}, aaSpellName = "ashebasicattack", startAttackSpeed = "0.658" },
            Brand        = { projSpeed = 1.975, aaParticles = {"BrandBasicAttack_cas", "BrandBasicAttack_Frost_tar", "BrandBasicAttack_mis", "BrandBasicAttack_tar", "BrandCritAttack_mis", "BrandCritAttack_tar", "BrandCritAttack_tar"}, aaSpellName = "brandbasicattack", startAttackSpeed = "0.625" },
            Caitlyn      = { projSpeed = 2.5, aaParticles = {"caitlyn_basicAttack_cas", "caitlyn_headshot_tar", "caitlyn_mis_04"}, aaSpellName = "caitlynbasicattack", startAttackSpeed = "0.668" },
            Cassiopeia   = { projSpeed = 1.22, aaParticles = {"CassBasicAttack_mis"}, aaSpellName = "cassiopeiabasicattack", startAttackSpeed = "0.644" },
            Corki        = { projSpeed = 2.0, aaParticles = {"corki_basicAttack_mis", "Corki_crit_mis"}, aaSpellName = "CorkiBasicAttack", startAttackSpeed = "0.658" },
            Draven       = { projSpeed = 1.4, aaParticles = {"Draven_BasicAttack_mis", "Draven_crit_mis", "Draven_Q_mis", "Draven_Qcrit_mis"}, aaSpellName = "dravenbasicattack", startAttackSpeed = "0.679",  },
            Ezreal       = { projSpeed = 2.0, aaParticles = {"Ezreal_basicattack_mis", "Ezreal_critattack_mis"}, aaSpellName = "ezrealbasicattack", startAttackSpeed = "0.625" },
            FiddleSticks = { projSpeed = 1.75, aaParticles = {"FiddleSticks_cas", "FiddleSticks_mis", "FiddleSticksBasicAttack_tar"}, aaSpellName = "fiddlesticksbasicattack", startAttackSpeed = "0.625" },
            Graves       = { projSpeed = 3.0, aaParticles = {"Graves_BasicAttack_mis",}, aaSpellName = "gravesbasicattack", startAttackSpeed = "0.625" },
            Heimerdinger = { projSpeed = 1.4, aaParticles = {"heimerdinger_basicAttack_mis", "heimerdinger_basicAttack_tar"}, aaSpellName = "heimerdingerbasicAttack", startAttackSpeed = "0.625" },
            Janna        = { projSpeed = 1.2, aaParticles = {"JannaBasicAttack_mis", "JannaBasicAttack_tar", "JannaBasicAttackFrost_tar"}, aaSpellName = "jannabasicattack", startAttackSpeed = "0.625" },
            Jayce        = { projSpeed = 2.2, aaParticles = {"Jayce_Range_Basic_mis", "Jayce_Range_Basic_Crit"}, aaSpellName = "jaycebasicattack", startAttackSpeed = "0.658",  },
            Karma        = { projSpeed = nil, aaParticles = {"karma_basicAttack_cas", "karma_basicAttack_mis", "karma_crit_mis"}, aaSpellName = "karmabasicattack", startAttackSpeed = "0.658",  },
            Karthus      = { projSpeed = 1.25, aaParticles = {"LichBasicAttack_cas", "LichBasicAttack_glow", "LichBasicAttack_mis", "LichBasicAttack_tar"}, aaSpellName = "karthusbasicattack", startAttackSpeed = "0.625" },
            Kayle        = { projSpeed = 1.8, aaParticles = {"RighteousFury_nova"}, aaSpellName = "KayleBasicAttack", startAttackSpeed = "0.638",  }, -- Kayle doesn't have a particle when auto attacking without E buff..
            Kennen       = { projSpeed = 1.35, aaParticles = {"KennenBasicAttack_mis"}, aaSpellName = "kennenbasicattack", startAttackSpeed = "0.690" },
            KogMaw       = { projSpeed = 1.8, aaParticles = {"KogMawBasicAttack_mis", "KogMawBioArcaneBarrage_mis"}, aaSpellName = "kogmawbasicattack", startAttackSpeed = "0.665", },
            Leblanc      = { projSpeed = 1.7, aaParticles = {"leBlanc_basicAttack_cas", "leBlancBasicAttack_mis"}, aaSpellName = "leblancbasicattack", startAttackSpeed = "0.625" },
            Lulu         = { projSpeed = 2.5, aaParticles = {"lulu_attack_cas", "LuluBasicAttack", "LuluBasicAttack_tar"}, aaSpellName = "LuluBasicAttack", startAttackSpeed = "0.625" },
            Lux          = { projSpeed = 1.55, aaParticles = {"LuxBasicAttack_mis", "LuxBasicAttack_tar", "LuxBasicAttack01"}, aaSpellName = "luxbasicattack", startAttackSpeed = "0.625" },
            Malzahar     = { projSpeed = 1.5, aaParticles = {"AlzaharBasicAttack_cas", "AlZaharBasicAttack_mis"}, aaSpellName = "malzaharbasicattack", startAttackSpeed = "0.625" },
            MissFortune  = { projSpeed = 2.0, aaParticles = {"missFortune_basicAttack_mis", "missFortune_crit_mis"}, aaSpellName = "missfortunebasicattack", startAttackSpeed = "0.656" },
            Morgana      = { projSpeed = 1.6, aaParticles = {"FallenAngelBasicAttack_mis", "FallenAngelBasicAttack_tar", "FallenAngelBasicAttack2_mis"}, aaSpellName = "Morganabasicattack", startAttackSpeed = "0.579" },
            Nidalee      = { projSpeed = 1.7, aaParticles = {"nidalee_javelin_mis"}, aaSpellName = "nidaleebasicattack", startAttackSpeed = "0.670" },
            Orianna      = { projSpeed = 1.4, aaParticles = {"OrianaBasicAttack_mis", "OrianaBasicAttack_tar"}, aaSpellName = "oriannabasicattack", startAttackSpeed = "0.658" },
            Quinn        = { projSpeed = 1.85, aaParticles = {"Quinn_basicattack_mis", "QuinnValor_BasicAttack_01", "QuinnValor_BasicAttack_02", "QuinnValor_BasicAttack_03", "Quinn_W_mis"}, aaSpellName = "QuinnBasicAttack", startAttackSpeed = "0.668" },  --Quinn's critical attack has the same particle name as his basic attack.
            Ryze         = { projSpeed = 2.4, aaParticles = {"ManaLeach_mis"}, aaSpellName = {"RyzeBasicAttack"}, startAttackSpeed = "0.625" },
            Sivir        = { projSpeed = 1.4, aaParticles = {"sivirbasicattack_mis", "sivirbasicattack2_mis", "SivirRicochetAttack_mis"}, aaSpellName = "sivirbasicattack", startAttackSpeed = "0.658" },
            Sona         = { projSpeed = 1.6, aaParticles = {"SonaBasicAttack_mis", "SonaBasicAttack_tar", "SonaCritAttack_mis", "SonaPowerChord_AriaofPerseverance_mis", "SonaPowerChord_AriaofPerseverance_tar", "SonaPowerChord_HymnofValor_mis", "SonaPowerChord_HymnofValor_tar", "SonaPowerChord_SongOfSelerity_mis", "SonaPowerChord_SongOfSelerity_tar", "SonaPowerChord_mis", "SonaPowerChord_tar"}, aaSpellName = "sonabasicattack", startAttackSpeed = "0.644" },
            Soraka       = { projSpeed = 1.0, aaParticles = {"SorakaBasicAttack_mis", "SorakaBasicAttack_tar"}, aaSpellName = "sorakabasicattack", startAttackSpeed = "0.625" },
            Swain        = { projSpeed = 1.6, aaParticles = {"swain_basicAttack_bird_cas", "swain_basicAttack_cas", "swainBasicAttack_mis"}, aaSpellName = "swainbasicattack", startAttackSpeed = "0.625" },
            Syndra       = { projSpeed = 1.2, aaParticles = {"Syndra_attack_hit", "Syndra_attack_mis"}, aaSpellName = "sorakabasicattack", startAttackSpeed = "0.625",  },
            Teemo        = { projSpeed = 1.3, aaParticles = {"TeemoBasicAttack_mis", "Toxicshot_mis"}, aaSpellName = "teemobasicattack", startAttackSpeed = "0.690" },
            Tristana     = { projSpeed = 2.25, aaParticles = {"TristannaBasicAttack_mis"}, aaSpellName = "tristanabasicattack", startAttackSpeed = "0.656",  },
            TwistedFate  = { projSpeed = 1.5, aaParticles = {"TwistedFateBasicAttack_mis", "TwistedFateStackAttack_mis"}, aaSpellName = "twistedfatebasicattack", startAttackSpeed = "0.651",  },
            Twitch       = { projSpeed = 2.5, aaParticles = {"twitch_basicAttack_mis",--[[ "twitch_punk_sprayandPray_tar", "twitch_sprayandPray_tar",]] "twitch_sprayandPray_mis"}, aaSpellName = "twitchbasicattack", startAttackSpeed = "0.679" },
            Urgot        = { projSpeed = 1.3, aaParticles = {"UrgotBasicAttack_mis"}, aaSpellName = "urgotbasicattack", startAttackSpeed = "0.644" },
            Vayne        = { projSpeed = 2.0, aaParticles = {"vayne_basicAttack_mis", "vayne_critAttack_mis", "vayne_ult_mis" }, aaSpellName = "vaynebasicattack", startAttackSpeed = "0.658",  },
            Varus        = { projSpeed = 2.0, aaParticles = {"varus_basicAttack_mis", "varus_critAttack_mis" }, aaSpellName = "varusbasicattack", startAttackSpeed = "0.658",  },
            Veigar       = { projSpeed = 1.05, aaParticles = {"ahri_basicattack_mis"}, aaSpellName = "veigarbasicattack", startAttackSpeed = "0.625" },
            Viktor       = { projSpeed = 2.25, aaParticles = {"ViktorBasicAttack_cas", "ViktorBasicAttack_mis", "ViktorBasicAttack_tar"}, aaSpellName = "viktorbasicattack", startAttackSpeed = "0.625" },
            Vladimir     = { projSpeed = 1.4, aaParticles = {"VladBasicAttack_mis", "VladBasicAttack_mis_bloodless", "VladBasicAttack_tar", "VladBasicAttack_tar_bloodless"}, aaSpellName = "vladimirbasicattack", startAttackSpeed = "0.658" },
            Xerath       = { projSpeed = 1.2, aaParticles = {"XerathBasicAttack_mis", "XerathBasicAttack_tar"}, aaSpellName = "xerathbasicattack", startAttackSpeed = "0.625" },
            Ziggs        = { projSpeed = 1.5, aaParticles = {"ZiggsBasicAttack_mis", "ZiggsPassive_mis"}, aaSpellName = "ziggsbasicattack", startAttackSpeed = "0.656" },
            Zilean       = { projSpeed = 1.25, aaParticles = {"ChronoBasicAttack_mis"}, aaSpellName = "zileanbasicattack" },
            Zyra         = { projSpeed = 1.7, aaParticles = {"Zyra_basicAttack_cas", "Zyra_basicAttack_cas_02", "Zyra_basicAttack_mis", "Zyra_basicAttack_tar", "Zyra_basicAttack_tar_hellvine"}, aaSpellName = "zileanbasicattack", startAttackSpeed = "0.625",  },
     
        }
    end
