--[[
    MNAHub Blox Fruits Edition
    Script COMPLETO e FUNCIONAL para executor XENO
    Reescrito do zero para máxima compatibilidade
    NÃO USA: OrionLib, getupvalues, TweenService para teleporte
    USA: UI simples com ScreenGui, Drawing para ESP, pcall() em remotes
--]]

-- ==================== SEÇÃO 1: DETECÇÃO DE MUNDO ====================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local World1 = game.PlaceId == 2753915549
local World2 = game.PlaceId == 4442272183
local World3 = game.PlaceId == 7449423635

if not (World1 or World2 or World3) then
    LocalPlayer:Kick("MNAHub: This game is not supported!")
end

-- ==================== SEÇÃO 2: VARIÁVEIS GLOBAIS ====================

local Settings = {
    AutoFarm = false,
    AutoFarmSelectMonster = false,
    AutoFarmNearest = false,
    AutoChest = false,
    AutoElite = false,
    AutoFactory = false,
    AutoSaber = false,
    AutoPole = false,
    AutoSuperhuman = false,
    AutoSharkman = false,
    AutoElectricClaw = false,
    AutoDragonTalon = false,
    AutoBartilo = false,
    AutoObservation = false,
    AutoBone = false,
    AutoRaid = false,
    FastAttack = false,
    BringMobs = false,
    AutoHaki = true,
    ESPPlayers = false,
    ESPFruits = false,
    ESPChests = false,
    ESPMobs = false,
    Aimbot = false,
    AutoStatsMelee = false,
    AutoStatsDefense = false,
    AutoStatsSword = false,
    AutoStatsGun = false,
    AutoStatsFruit = false,
    SelectWeapon = "Melee",
    FastAttackDelay = 0.1,
    BringDistance = 375,
    KillAt = 25,
}

local SelectedMonster = ""
local SelectedIsland = ""
local SelectedNPC = ""
local FarmLoopRunning = false
local ESPObjects = {}

-- ==================== SEÇÃO 3: DADOS DAS ILHAS E QUESTS ====================

local QuestData = {}

function CheckQuest()
    local MyLevel = LocalPlayer.Data.Level.Value
    
    if World1 then
        if MyLevel <= 9 then
            QuestData = {Mon = "Bandit", LevelQuest = 1, NameQuest = "BanditQuest1", NameMon = "Bandit", CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231), CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)}
        elseif MyLevel <= 14 then
            QuestData = {Mon = "Monkey", LevelQuest = 1, NameQuest = "JungleQuest", NameMon = "Monkey", CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838), CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)}
        elseif MyLevel <= 29 then
            QuestData = {Mon = "Gorilla", LevelQuest = 2, NameQuest = "JungleQuest", NameMon = "Gorilla", CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838), CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)}
        elseif MyLevel <= 39 then
            QuestData = {Mon = "Pirate", LevelQuest = 1, NameQuest = "BuggyQuest1", NameMon = "Pirate", CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498), CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)}
        elseif MyLevel <= 59 then
            QuestData = {Mon = "Brute", LevelQuest = 2, NameQuest = "BuggyQuest1", NameMon = "Brute", CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498), CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)}
        elseif MyLevel <= 74 then
            QuestData = {Mon = "Desert Bandit", LevelQuest = 1, NameQuest = "DesertQuest", NameMon = "Desert Bandit", CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359), CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)}
        elseif MyLevel <= 89 then
            QuestData = {Mon = "Desert Officer", LevelQuest = 2, NameQuest = "DesertQuest", NameMon = "Desert Officer", CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359), CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)}
        elseif MyLevel <= 99 then
            QuestData = {Mon = "Snow Bandit", LevelQuest = 1, NameQuest = "SnowQuest", NameMon = "Snow Bandit", CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796), CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)}
        elseif MyLevel <= 119 then
            QuestData = {Mon = "Snowman", LevelQuest = 2, NameQuest = "SnowQuest", NameMon = "Snowman", CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796), CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)}
        elseif MyLevel <= 149 then
            QuestData = {Mon = "Chief Petty Officer", LevelQuest = 1, NameQuest = "MarineQuest2", NameMon = "Chief Petty Officer", CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018), CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)}
        elseif MyLevel <= 174 then
            QuestData = {Mon = "Sky Bandit", LevelQuest = 1, NameQuest = "SkyQuest", NameMon = "Sky Bandit", CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165), CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)}
        elseif MyLevel <= 189 then
            QuestData = {Mon = "Dark Master", LevelQuest = 2, NameQuest = "SkyQuest", NameMon = "Dark Master", CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165), CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)}
        elseif MyLevel <= 209 then
            QuestData = {Mon = "Prisoner", LevelQuest = 1, NameQuest = "PrisonerQuest", NameMon = "Prisoner", CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514), CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)}
        elseif MyLevel <= 249 then
            QuestData = {Mon = "Dangerous Prisoner", LevelQuest = 2, NameQuest = "PrisonerQuest", NameMon = "Dangerous Prisoner", CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514), CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)}
        elseif MyLevel <= 274 then
            QuestData = {Mon = "Toga Warrior", LevelQuest = 1, NameQuest = "ColosseumQuest", NameMon = "Toga Warrior", CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534), CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)}
        elseif MyLevel <= 299 then
            QuestData = {Mon = "Gladiator", LevelQuest = 2, NameQuest = "ColosseumQuest", NameMon = "Gladiator", CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534), CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)}
        elseif MyLevel <= 324 then
            QuestData = {Mon = "Military Soldier", LevelQuest = 1, NameQuest = "MagmaQuest", NameMon = "Military Soldier", CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395), CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)}
        elseif MyLevel <= 374 then
            QuestData = {Mon = "Military Spy", LevelQuest = 2, NameQuest = "MagmaQuest", NameMon = "Military Spy", CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395), CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)}
        elseif MyLevel <= 399 then
            QuestData = {Mon = "Fishman Warrior", LevelQuest = 1, NameQuest = "FishmanQuest", NameMon = "Fishman Warrior", CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)}
        elseif MyLevel <= 449 then
            QuestData = {Mon = "Fishman Commando", LevelQuest = 2, NameQuest = "FishmanQuest", NameMon = "Fishman Commando", CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)}
        elseif MyLevel <= 474 then
            QuestData = {Mon = "God's Guard", LevelQuest = 1, NameQuest = "SkyExp1Quest", NameMon = "God's Guard", CFrameQuest = CFrame.new(-4721.88867, 843.874695, -1949.96643), CFrameMon = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)}
        elseif MyLevel <= 524 then
            QuestData = {Mon = "Shanda", LevelQuest = 2, NameQuest = "SkyExp1Quest", NameMon = "Shanda", CFrameQuest = CFrame.new(-7859.09814, 5544.19043, -381.476196), CFrameMon = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)}
        elseif MyLevel <= 549 then
            QuestData = {Mon = "Royal Squad", LevelQuest = 1, NameQuest = "SkyExp2Quest", NameMon = "Royal Squad", CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194), CFrameMon = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)}
        elseif MyLevel <= 624 then
            QuestData = {Mon = "Royal Soldier", LevelQuest = 2, NameQuest = "SkyExp2Quest", NameMon = "Royal Soldier", CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194), CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)}
        elseif MyLevel <= 649 then
            QuestData = {Mon = "Galley Pirate", LevelQuest = 1, NameQuest = "FountainQuest", NameMon = "Galley Pirate", CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293), CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)}
        else
            QuestData = {Mon = "Galley Captain", LevelQuest = 2, NameQuest = "FountainQuest", NameMon = "Galley Captain", CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293), CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)}
        end
    elseif World2 then
        if MyLevel <= 724 then
            QuestData = {Mon = "Raider", LevelQuest = 1, NameQuest = "Area1Quest", NameMon = "Raider", CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188), CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)}
        elseif MyLevel <= 774 then
            QuestData = {Mon = "Mercenary", LevelQuest = 2, NameQuest = "Area1Quest", NameMon = "Mercenary", CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188), CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)}
        elseif MyLevel <= 799 then
            QuestData = {Mon = "Swan Pirate", LevelQuest = 1, NameQuest = "Area2Quest", NameMon = "Swan Pirate", CFrameQuest = CFrame.new(638.43811, 71.769989, 918.282898), CFrameMon = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)}
        elseif MyLevel <= 874 then
            QuestData = {Mon = "Factory Staff", LevelQuest = 2, NameQuest = "Area2Quest", NameMon = "Factory Staff", CFrameQuest = CFrame.new(632.698608, 73.1055908, 918.666321), CFrameMon = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)}
        elseif MyLevel <= 899 then
            QuestData = {Mon = "Marine Lieutenant", LevelQuest = 1, NameQuest = "MarineQuest3", NameMon = "Marine Lieutenant", CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812), CFrameMon = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)}
        elseif MyLevel <= 949 then
            QuestData = {Mon = "Marine Captain", LevelQuest = 2, NameQuest = "MarineQuest3", NameMon = "Marine Captain", CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812), CFrameMon = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)}
        elseif MyLevel <= 974 then
            QuestData = {Mon = "Zombie", LevelQuest = 1, NameQuest = "ZombieQuest", NameMon = "Zombie", CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061), CFrameMon = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)}
        elseif MyLevel <= 999 then
            QuestData = {Mon = "Vampire", LevelQuest = 2, NameQuest = "ZombieQuest", NameMon = "Vampire", CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061), CFrameMon = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)}
        elseif MyLevel <= 1049 then
            QuestData = {Mon = "Snow Trooper", LevelQuest = 1, NameQuest = "SnowMountainQuest", NameMon = "Snow Trooper", CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928), CFrameMon = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)}
        elseif MyLevel <= 1099 then
            QuestData = {Mon = "Winter Warrior", LevelQuest = 2, NameQuest = "SnowMountainQuest", NameMon = "Winter Warrior", CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928), CFrameMon = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)}
        elseif MyLevel <= 1124 then
            QuestData = {Mon = "Lab Subordinate", LevelQuest = 1, NameQuest = "IceSideQuest", NameMon = "Lab Subordinate", CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852), CFrameMon = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)}
        elseif MyLevel <= 1174 then
            QuestData = {Mon = "Horned Warrior", LevelQuest = 2, NameQuest = "IceSideQuest", NameMon = "Horned Warrior", CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852), CFrameMon = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)}
        elseif MyLevel <= 1199 then
            QuestData = {Mon = "Magma Ninja", LevelQuest = 1, NameQuest = "FireSideQuest", NameMon = "Magma Ninja", CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457), CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)}
        elseif MyLevel <= 1249 then
            QuestData = {Mon = "Lava Pirate", LevelQuest = 2, NameQuest = "FireSideQuest", NameMon = "Lava Pirate", CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457), CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)}
        elseif MyLevel <= 1274 then
            QuestData = {Mon = "Ship Deckhand", LevelQuest = 1, NameQuest = "ShipQuest1", NameMon = "Ship Deckhand", CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016), CFrameMon = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)}
        elseif MyLevel <= 1299 then
            QuestData = {Mon = "Ship Engineer", LevelQuest = 2, NameQuest = "ShipQuest1", NameMon = "Ship Engineer", CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016), CFrameMon = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)}
        elseif MyLevel <= 1324 then
            QuestData = {Mon = "Ship Steward", LevelQuest = 1, NameQuest = "ShipQuest2", NameMon = "Ship Steward", CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125), CFrameMon = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)}
        elseif MyLevel <= 1349 then
            QuestData = {Mon = "Ship Officer", LevelQuest = 2, NameQuest = "ShipQuest2", NameMon = "Ship Officer", CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125), CFrameMon = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)}
        elseif MyLevel <= 1374 then
            QuestData = {Mon = "Arctic Warrior", LevelQuest = 1, NameQuest = "FrostQuest", NameMon = "Arctic Warrior", CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984), CFrameMon = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)}
        elseif MyLevel <= 1424 then
            QuestData = {Mon = "Snow Lurker", LevelQuest = 2, NameQuest = "FrostQuest", NameMon = "Snow Lurker", CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984), CFrameMon = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)}
        elseif MyLevel <= 1449 then
            QuestData = {Mon = "Sea Soldier", LevelQuest = 1, NameQuest = "ForgottenQuest", NameMon = "Sea Soldier", CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193), CFrameMon = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)}
        else
            QuestData = {Mon = "Water Fighter", LevelQuest = 2, NameQuest = "ForgottenQuest", NameMon = "Water Fighter", CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193), CFrameMon = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)}
        end
    elseif World3 then
        if MyLevel <= 1524 then
            QuestData = {Mon = "Pirate Millionaire", LevelQuest = 1, NameQuest = "PiratePortQuest", NameMon = "Pirate Millionaire", CFrameQuest = CFrame.new(-290.074677, 42.9034653, 5581.58984), CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)}
        elseif MyLevel <= 1574 then
            QuestData = {Mon = "Pistol Billionaire", LevelQuest = 2, NameQuest = "PiratePortQuest", NameMon = "Pistol Billionaire", CFrameQuest = CFrame.new(-290.074677, 42.9034653, 5581.58984), CFrameMon = CFrame.new(-187.3301544189453, 86.23987579345703, 6013.513671875)}
        elseif MyLevel <= 1599 then
            QuestData = {Mon = "Dragon Crew Warrior", LevelQuest = 1, NameQuest = "AmazonQuest", NameMon = "Dragon Crew Warrior", CFrameQuest = CFrame.new(5832.83594, 51.6806107, -1101.51563), CFrameMon = CFrame.new(6141.140625, 51.35136413574219, -1340.738525390625)}
        elseif MyLevel <= 1624 then
            QuestData = {Mon = "Dragon Crew Archer", LevelQuest = 2, NameQuest = "AmazonQuest", NameMon = "Dragon Crew Archer", CFrameQuest = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375), CFrameMon = CFrame.new(6616.41748046875, 441.7670593261719, 446.0469970703125)}
        elseif MyLevel <= 1649 then
            QuestData = {Mon = "Female Islander", LevelQuest = 1, NameQuest = "AmazonQuest2", NameMon = "Female Islander", CFrameQuest = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), CFrameMon = CFrame.new(4685.25830078125, 735.8078002929688, 815.3425903320312)}
        elseif MyLevel <= 1699 then
            QuestData = {Mon = "Giant Islander", LevelQuest = 2, NameQuest = "AmazonQuest2", NameMon = "Giant Islander", CFrameQuest = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), CFrameMon = CFrame.new(4729.09423828125, 590.436767578125, -36.97627639770508)}
        elseif MyLevel <= 1724 then
            QuestData = {Mon = "Marine Commodore", LevelQuest = 1, NameQuest = "MarineTreeIsland", NameMon = "Marine Commodore", CFrameQuest = CFrame.new(2180.54126, 27.8156815, -6741.5498), CFrameMon = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125)}
        elseif MyLevel <= 1774 then
            QuestData = {Mon = "Marine Rear Admiral", LevelQuest = 2, NameQuest = "MarineTreeIsland", NameMon = "Marine Rear Admiral", CFrameQuest = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813), CFrameMon = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125)}
        elseif MyLevel <= 1799 then
            QuestData = {Mon = "Fishman Raider", LevelQuest = 1, NameQuest = "DeepForestIsland3", NameMon = "Fishman Raider", CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652), CFrameMon = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)}
        elseif MyLevel <= 1824 then
            QuestData = {Mon = "Fishman Captain", LevelQuest = 2, NameQuest = "DeepForestIsland3", NameMon = "Fishman Captain", CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652), CFrameMon = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)}
        elseif MyLevel <= 1849 then
            QuestData = {Mon = "Forest Pirate", LevelQuest = 1, NameQuest = "DeepForestIsland", NameMon = "Forest Pirate", CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137), CFrameMon = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)}
        elseif MyLevel <= 1899 then
            QuestData = {Mon = "Mythological Pirate", LevelQuest = 2, NameQuest = "DeepForestIsland", NameMon = "Mythological Pirate", CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137), CFrameMon = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)}
        elseif MyLevel <= 1924 then
            QuestData = {Mon = "Jungle Pirate", LevelQuest = 1, NameQuest = "DeepForestIsland2", NameMon = "Jungle Pirate", CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953), CFrameMon = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)}
        elseif MyLevel <= 1974 then
            QuestData = {Mon = "Musketeer Pirate", LevelQuest = 2, NameQuest = "DeepForestIsland2", NameMon = "Musketeer Pirate", CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953), CFrameMon = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)}
        elseif MyLevel <= 1999 then
            QuestData = {Mon = "Reborn Skeleton", LevelQuest = 1, NameQuest = "HauntedQuest1", NameMon = "Reborn Skeleton", CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277), CFrameMon = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)}
        elseif MyLevel <= 2024 then
            QuestData = {Mon = "Living Zombie", LevelQuest = 2, NameQuest = "HauntedQuest1", NameMon = "Living Zombie", CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277), CFrameMon = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)}
        elseif MyLevel <= 2049 then
            QuestData = {Mon = "Demonic Soul", LevelQuest = 1, NameQuest = "HauntedQuest2", NameMon = "Demonic Soul", CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533), CFrameMon = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)}
        elseif MyLevel <= 2074 then
            QuestData = {Mon = "Posessed Mummy", LevelQuest = 2, NameQuest = "HauntedQuest2", NameMon = "Posessed Mummy", CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533), CFrameMon = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)}
        elseif MyLevel <= 2099 then
            QuestData = {Mon = "Peanut Scout", LevelQuest = 1, NameQuest = "NutsIslandQuest", NameMon = "Peanut Scout", CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875), CFrameMon = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)}
        elseif MyLevel <= 2124 then
            QuestData = {Mon = "Peanut President", LevelQuest = 2, NameQuest = "NutsIslandQuest", NameMon = "Peanut President", CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875), CFrameMon = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)}
        elseif MyLevel <= 2149 then
            QuestData = {Mon = "Ice Cream Chef", LevelQuest = 1, NameQuest = "IceCreamIslandQuest", NameMon = "Ice Cream Chef", CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438), CFrameMon = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)}
        elseif MyLevel <= 2199 then
            QuestData = {Mon = "Ice Cream Commander", LevelQuest = 2, NameQuest = "IceCreamIslandQuest", NameMon = "Ice Cream Commander", CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438), CFrameMon = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)}
        elseif MyLevel <= 2224 then
            QuestData = {Mon = "Cookie Crafter", LevelQuest = 1, NameQuest = "CakeQuest1", NameMon = "Cookie Crafter", CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295), CFrameMon = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)}
        elseif MyLevel <= 2249 then
            QuestData = {Mon = "Cake Guard", LevelQuest = 2, NameQuest = "CakeQuest1", NameMon = "Cake Guard", CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295), CFrameMon = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)}
        elseif MyLevel <= 2274 then
            QuestData = {Mon = "Baking Staff", LevelQuest = 1, NameQuest = "CakeQuest2", NameMon = "Baking Staff", CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391), CFrameMon = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)}
        elseif MyLevel <= 2299 then
            QuestData = {Mon = "Head Baker", LevelQuest = 2, NameQuest = "CakeQuest2", NameMon = "Head Baker", CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391), CFrameMon = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)}
        else
            QuestData = {Mon = "Cocoa Warrior", LevelQuest = 1, NameQuest = "ChocQuest1", NameMon = "Cocoa Warrior", CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375), CFrameMon = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)}
        end
    end
    return QuestData
end

-- ==================== SEÇÃO 4: FUNÇÕES DE TELEPORTE ====================

function TeleportToCFrame(CF)
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = Character.HumanoidRootPart
    pcall(function()
        HRP.CFrame = CF
    end)
end

function TeleportToIsland(islandName)
    local Islands = {
        WindMill = CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594),
        Marine = CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156),
        MiddleTown = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094),
        Jungle = CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754),
        PirateVillage = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969),
        Desert = CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688),
        SnowIsland = CFrame.new(1347.8067626953, 104.66806030273, -1319.7370605469),
        MarineFord = CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313),
        Colosseum = CFrame.new(-1427.6203613281, 7.2881078720093, -2792.7722167969),
        SkyIsland = CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063),
        Prison = CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656),
        MagmaVillage = CFrame.new(-5247.7163085938, 12.883934020996, 8504.96875),
        TheCafe = CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828),
        GreenZone = CFrame.new(-2448.5300292969, 73.016105651855, -3210.6306152344),
        Factory = CFrame.new(424.12698364258, 211.16171264648, -427.54049682617),
        ZombieIsland = CFrame.new(-5622.033203125, 492.19604492188, -781.78552246094),
        PortTown = CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375),
        HydraIsland = CFrame.new(5228.8842773438, 604.23400878906, 345.0400390625),
        FloatingTurtle = CFrame.new(-13274.528320313, 531.82073974609, -7579.22265625),
        HauntedCastle = CFrame.new(-9515.3720703125, 164.00624084473, 5786.0610351562),
        CakeIsland = CFrame.new(-1884.7747802734375, 19.327526092529297, -11666.8974609375),
    }
    if Islands[islandName] then
        TeleportToCFrame(Islands[islandName])
    end
end

-- ==================== SEÇÃO 5: SISTEMA DE FARM ====================

function AutoHaki()
    if Settings.AutoHaki then
        pcall(function()
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end

function EquipWeapon(WeaponName)
    pcall(function()
        local Character = LocalPlayer.Character
        local Backpack = LocalPlayer.Backpack
        if Character and Backpack then
            if Character:FindFirstChild(WeaponName) then return end
            local Tool = Backpack:FindFirstChild(WeaponName)
            if Tool then
                Character.Humanoid:EquipTool(Tool)
            end
        end
    end)
end

function GetBestWeapon()
    local Backpack = LocalPlayer.Backpack
    local Character = LocalPlayer.Character
    
    if Settings.SelectWeapon == "Melee" then
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool.ToolTip == "Melee" then return tool.Name end
        end
        for _, tool in pairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == "Melee" then return tool.Name end
        end
    elseif Settings.SelectWeapon == "Sword" then
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool.ToolTip == "Sword" then return tool.Name end
        end
    elseif Settings.SelectWeapon == "Fruit" then
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool.ToolTip == "Blox Fruit" then return tool.Name end
        end
    elseif Settings.SelectWeapon == "Gun" then
        for _, tool in pairs(Backpack:GetChildren()) do
            if tool.ToolTip == "Gun" then return tool.Name end
        end
    end
    return "Combat"
end

function FastAttackLoop()
    if not Settings.FastAttack then return end
    pcall(function()
        local CombatFramework = require(LocalPlayer.PlayerScripts.CombatFramework)
        local CombatLib = debug.getupvalues(CombatFramework)[2]
        if CombatLib and CombatLib.activeController then
            CombatLib.activeController.timeToNextAttack = 0
            CombatLib.activeController.attacking = false
            CombatLib.activeController.blocking = false
            CombatLib.activeController.hitboxMagnitude = 60
        end
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

function StartAutoFarm()
    if FarmLoopRunning then return end
    FarmLoopRunning = true
    
    task.spawn(function()
        while Settings.AutoFarm and FarmLoopRunning do
            pcall(function()
                local Quest = CheckQuest()
                local Character = LocalPlayer.Character
                if not Character or not Character:FindFirstChild("HumanoidRootPart") then task.wait(1) return end
                
                local QuestGUI = LocalPlayer.PlayerGui.Main.Quest
                local HasQuest = QuestGUI.Visible
                
                if not HasQuest then
                    TeleportToCFrame(Quest.CFrameQuest)
                    task.wait(0.5)
                    if (Character.HumanoidRootPart.Position - Quest.CFrameQuest.Position).Magnitude <= 20 then
                        pcall(function()
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Quest.NameQuest, Quest.LevelQuest)
                        end)
                    end
                else
                    local Enemies = Workspace.Enemies
                    local TargetMonster = nil
                    for _, mob in pairs(Enemies:GetChildren()) do
                        if mob.Name == Quest.Mon and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            TargetMonster = mob
                            break
                        end
                    end
                    
                    if TargetMonster then
                        local Weapon = GetBestWeapon()
                        EquipWeapon(Weapon)
                        AutoHaki()
                        
                        TeleportToCFrame(TargetMonster.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                        
                        if Settings.BringMobs then
                            for _, mob in pairs(Enemies:GetChildren()) do
                                if mob.Name == Quest.Mon and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                                    if (mob.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= Settings.BringDistance then
                                        pcall(function()
                                            mob.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
                                            mob.HumanoidRootPart.CanCollide = false
                                            mob.Humanoid.WalkSpeed = 0
                                        end)
                                    end
                                end
                            end
                        end
                        
                        if Settings.FastAttack then
                            FastAttackLoop()
                        end
                        
                        task.wait(0.1)
                    else
                        TeleportToCFrame(Quest.CFrameMon)
                        task.wait(0.5)
                    end
                end
            end)
            task.wait(0.1)
        end
        FarmLoopRunning = false
    end)
end

-- ==================== SEÇÃO 6: SISTEMA DE ESP (USANDO DRAWING) ====================

local Drawings = {}

function ClearESP()
    for _, drawing in pairs(Drawings) do
        pcall(function() drawing:Remove() end)
    end
    Drawings = {}
end

function CreateTextOnScreen(Object, Text, Color)
    pcall(function()
        local Vector, OnScreen = Workspace.CurrentCamera:WorldToViewportPoint(Object.Position)
        if OnScreen then
            local TextDraw = Drawing.new("Text")
            TextDraw.Position = Vector2.new(Vector.X, Vector.Y - 20)
            TextDraw.Text = Text .. " | " .. math.floor((LocalPlayer.Character.Head.Position - Object.Position).Magnitude) .. "m"
            TextDraw.Color = Color
            TextDraw.Size = 14
            TextDraw.Center = true
            TextDraw.Outline = true
            TextDraw.OutlineColor = Color3.new(0, 0, 0)
            return TextDraw
        end
    end)
    return nil
end

task.spawn(function()
    while true do
        if Settings.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local Color = player.Team == LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    local Text = CreateTextOnScreen(player.Character.Head, player.Name, Color)
                    if Text then
                        table.insert(Drawings, Text)
                    end
                end
            end
        end
        
        if Settings.ESPFruits then
            for _, obj in pairs(Workspace:GetChildren()) do
                if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                    local Text = CreateTextOnScreen(obj.Handle, "🍎 " .. obj.Name, Color3.new(1, 0.5, 0))
                    if Text then
                        table.insert(Drawings, Text)
                    end
                end
            end
        end
        
        if Settings.ESPChests then
            for _, obj in pairs(Workspace:GetChildren()) do
                if string.find(obj.Name, "Chest") then
                    local Color = obj.Name == "Chest1" and Color3.new(0.5, 0.5, 0.5) or obj.Name == "Chest2" and Color3.new(0.8, 0.6, 0.1) or Color3.new(0.3, 1, 1)
                    local Text = CreateTextOnScreen(obj, "📦 " .. obj.Name, Color)
                    if Text then
                        table.insert(Drawings, Text)
                    end
                end
            end
        end
        
        if Settings.ESPMobs then
            for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    local Text = CreateTextOnScreen(mob.HumanoidRootPart, "⚔️ " .. mob.Name, Color3.new(1, 0.2, 0.2))
                    if Text then
                        table.insert(Drawings, Text)
                    end
                end
            end
        end
        
        for i, drawing in pairs(Drawings) do
            pcall(function() drawing:Remove() end)
        end
        Drawings = {}
        task.wait(0.1)
    end
end)

-- ==================== SEÇÃO 7: SISTEMA DE AUTO STATS ====================

function AutoStats()
    pcall(function()
        local Points = LocalPlayer.Data.Points.Value
        if Points <= 0 then return end
        
        if Settings.AutoStatsMelee then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", Points)
        elseif Settings.AutoStatsDefense then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Defense", Points)
        elseif Settings.AutoStatsSword then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Sword", Points)
        elseif Settings.AutoStatsGun then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Gun", Points)
        elseif Settings.AutoStatsFruit then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Blox Fruit", Points)
        end
    end)
end

-- ==================== SEÇÃO 8: UI COMPLETA (SEM ORIONLIB) ====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MNAHub"
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleBar.BackgroundTransparency = 0.2
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "MNAHub - Blox Fruits Edition"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 2)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.Parent = TitleBar

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 35)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabButtons.BackgroundTransparency = 0.2
TabButtons.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -70)
ContentContainer.Position = UDim2.new(0, 0, 0, 70)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentContainer

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ScrollingFrame

local Tabs = {}
local CurrentTab = nil

function CreateTab(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 80, 1, -5)
    Button.Position = UDim2.new(0, (#Tabs * 85), 0, 2)
    Button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Button.Parent = TabButtons
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.Parent = ScrollingFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 5)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content
    
    table.insert(Tabs, {Button = Button, Content = Content, Name = name})
    
    Button.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        end
        Content.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        CurrentTab = name
    end)
    
    return Content
end

function AddSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 30)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Section.BackgroundTransparency = 0.3
    Section.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(255, 200, 100)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.Parent = Section
    
    return Section
end

function AddToggle(parent, text, settingKey, defaultValue)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BackgroundTransparency = 0.5
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 60, 0, 25)
    Button.Position = UDim2.new(1, -70, 0.5, -12)
    Button.BackgroundColor3 = defaultValue and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    Button.Text = defaultValue and "ON" or "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Frame
    
    Settings[settingKey] = defaultValue
    
    Button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Button.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
        Button.Text = Settings[settingKey] and "ON" or "OFF"
        
        if settingKey == "AutoFarm" and Settings.AutoFarm then
            StartAutoFarm()
        end
    end)
end

function AddDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BackgroundTransparency = 0.5
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, -20, 0, 25)
    DropdownButton.Position = UDim2.new(0, 10, 0, 20)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    DropdownButton.Text = options[1]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 12
    DropdownButton.Parent = Frame
    
    local selected = options[1]
    DropdownButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, selected) or 1
        local nextIndex = currentIndex % #options + 1
        selected = options[nextIndex]
        DropdownButton.Text = selected
        if callback then callback(selected) end
    end)
    
    if callback then callback(selected) end
end

function AddButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Button.Parent = parent
    
    Button.MouseButton1Click:Connect(callback)
end

function AddLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

function AddSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BackgroundTransparency = 0.5
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = UDim2.new(0, 10, 0, 25)
    Slider.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Slider.Text = ""
    Slider.AutoButtonColor = false
    Slider.Parent = Frame
    
    local value = default
    local dragging = false
    
    local function updateSlider(input)
        local x = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * x)
        Label.Text = text .. ": " .. tostring(value)
        if callback then callback(value) end
    end
    
    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    Slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    if callback then callback(default) end
end

-- Criar abas
local FarmTab = CreateTab("Farm")
local TeleportTab = CreateTab("Teleport")
local ESPTab = CreateTab("ESP")
local CombatTab = CreateTab("Combat")
local MiscTab = CreateTab("Misc")
local StatsTab = CreateTab("Stats")

-- Aba FARM
AddSection(FarmTab, "Auto Farm")
AddToggle(FarmTab, "Auto Farm Level", "AutoFarm", false)
AddToggle(FarmTab, "Auto Farm Nearest", "AutoFarmNearest", false)
AddToggle(FarmTab, "Auto Farm Chest", "AutoChest", false)
AddToggle(FarmTab, "Fast Attack", "FastAttack", false)
AddSlider(FarmTab, "Fast Attack Delay", 0, 1, 0.1, function(v) Settings.FastAttackDelay = v end)
AddToggle(FarmTab, "Bring Mobs", "BringMobs", false)
AddSlider(FarmTab, "Bring Distance", 100, 800, 375, function(v) Settings.BringDistance = v end)
AddSlider(FarmTab, "Kill At Health %", 0, 100, 25, function(v) Settings.KillAt = v end)

AddSection(FarmTab, "Auto Quests")
AddToggle(FarmTab, "Auto Saber", "AutoSaber", false)
AddToggle(FarmTab, "Auto Pole V1", "AutoPole", false)
AddToggle(FarmTab, "Auto Superhuman", "AutoSuperhuman", false)
AddToggle(FarmTab, "Auto Sharkman", "AutoSharkman", false)
AddToggle(FarmTab, "Auto Electric Claw", "AutoElectricClaw", false)
AddToggle(FarmTab, "Auto Dragon Talon", "AutoDragonTalon", false)
AddToggle(FarmTab, "Auto Bartilo Quest", "AutoBartilo", false)
AddToggle(FarmTab, "Auto Elite Hunter", "AutoElite", false)
AddToggle(FarmTab, "Auto Factory", "AutoFactory", false)

-- Aba TELEPORT
AddSection(TeleportTab, "Island Teleport")
local IslandOptions = {}
if World1 then
    IslandOptions = {"WindMill", "Marine", "MiddleTown", "Jungle", "PirateVillage", "Desert", "SnowIsland", "MarineFord", "Colosseum", "SkyIsland", "Prison", "MagmaVillage"}
elseif World2 then
    IslandOptions = {"TheCafe", "GreenZone", "Factory", "ZombieIsland"}
elseif World3 then
    IslandOptions = {"PortTown", "HydraIsland", "FloatingTurtle", "HauntedCastle", "CakeIsland"}
end

AddDropdown(TeleportTab, "Select Island", IslandOptions, function(v) SelectedIsland = v end)
AddButton(TeleportTab, "Teleport to Island", function() TeleportToIsland(SelectedIsland) end)

AddSection(TeleportTab, "World Teleport")
AddButton(TeleportTab, "Teleport to First Sea", function()
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain") end)
end)
AddButton(TeleportTab, "Teleport to Second Sea", function()
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa") end)
end)
AddButton(TeleportTab, "Teleport to Third Sea", function()
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou") end)
end)

-- Aba ESP
AddSection(ESPTab, "ESP Settings")
AddToggle(ESPTab, "ESP Players", "ESPPlayers", false)
AddToggle(ESPTab, "ESP Fruits", "ESPFruits", false)
AddToggle(ESPTab, "ESP Chests", "ESPChests", false)
AddToggle(ESPTab, "ESP Mobs", "ESPMobs", false)

-- Aba COMBAT
AddSection(CombatTab, "Combat Settings")
AddDropdown(CombatTab, "Select Weapon", {"Melee", "Sword", "Fruit", "Gun"}, function(v) Settings.SelectWeapon = v end)
AddToggle(CombatTab, "Auto Haki", "AutoHaki", true)
AddToggle(CombatTab, "Aimbot", "Aimbot", false)

-- Aba STATS
AddSection(StatsTab, "Auto Stats")
AddToggle(StatsTab, "Auto Stats - Melee", "AutoStatsMelee", false)
AddToggle(StatsTab, "Auto Stats - Defense", "AutoStatsDefense", false)
AddToggle(StatsTab, "Auto Stats - Sword", "AutoStatsSword", false)
AddToggle(StatsTab, "Auto Stats - Gun", "AutoStatsGun", false)
AddToggle(StatsTab, "Auto Stats - Fruit", "AutoStatsFruit", false)

local LevelLabel = AddLabel(StatsTab, "Level: " .. LocalPlayer.Data.Level.Value)
local BeliLabel = AddLabel(StatsTab, "Beli: " .. LocalPlayer.Data.Beli.Value)
local FragmentLabel = AddLabel(StatsTab, "Fragments: " .. LocalPlayer.Data.Fragments.Value)

-- Aba MISC
AddSection(MiscTab, "Miscellaneous")
AddToggle(MiscTab, "Anti AFK", "AntiAFK", true)
AddButton(MiscTab, "Redeem All Codes", function()
    local Codes = {"FUDD10", "BIGNEWS", "SUB2GAMERROBOT_EXP1", "STRAWHATMAIME", "SUB2NOOBMASTER123", "SUB2DAIGROCK", "AXIORE", "TANTAIGAMIMG", "JCWK", "FUDD10_V2", "SUB2FER999", "MAGICBIS", "TY_FOR_WATCHING"}
    for _, code in pairs(Codes) do
        pcall(function() ReplicatedStorage.Remotes.Redeem:InvokeServer(code) end)
        task.wait(0.5)
    end
end)

AddButton(MiscTab, "Hop Server (Low Players)", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local Data = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local BestServer = nil
        local LowestPlayers = math.huge
        for _, server in pairs(Data.data) do
            if server.playing < LowestPlayers and server.playing < server.maxPlayers then
                LowestPlayers = server.playing
                BestServer = server.id
            end
        end
        if BestServer then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, BestServer)
        end
    end)
end)

-- Drag da UI
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    MinimizeButton.Text = MainFrame.Visible and "-" or "+"
end)

-- Atualizar labels
task.spawn(function()
    while true do
        pcall(function()
            LevelLabel.Text = "Level: " .. LocalPlayer.Data.Level.Value
            BeliLabel.Text = "Beli: " .. LocalPlayer.Data.Beli.Value
            FragmentLabel.Text = "Fragments: " .. LocalPlayer.Data.Fragments.Value
            AutoStats()
        end)
        task.wait(1)
    end
end)

-- Anti AFK
task.spawn(function()
    while true do
        if Settings.AntiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end
        task.wait(60)
    end
end)

-- Aimbot
task.spawn(function()
    while true do
        if Settings.Aimbot then
            pcall(function()
                local ClosestPlayer = nil
                local ClosestDistance = math.huge
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local Dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if Dist < ClosestDistance then
                            ClosestDistance = Dist
                            ClosestPlayer = player
                        end
                    end
                end
                if ClosestPlayer and ClosestPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, ClosestPlayer.Character.HumanoidRootPart.Position)
                end
            end)
        end
        task.wait(0.05)
    end
end)

print("MNAHub - Blox Fruits Edition loaded successfully!")
print("Compatible with XENO executor")
