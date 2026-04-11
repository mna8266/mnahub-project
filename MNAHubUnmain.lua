--[[
    MNAHub - Xeno Compatible Version v6.6
    Melhorado: UI Moderna, ESP com Cores de Time
]]

print("MNAHub v6.6 Iniciando")

-- DETECTAR XENO
local Executor = "Unknown"
if Xeno then
    Executor = "Xeno"
end

-- KEY SYSTEM
local Keys = {
    MNA2026 = true,
    FREEKEY = true
}

-- VARIAVEIS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ANTI DETECTION - Muda nome das funcoes
local _getService = game.GetService
local _pairs = pairs
local _tick = tick
local _wait = task.wait
local _spawn = task.spawn

-- CONFIGURAÇÕES DA UI
local UISettings = {
    Transparency = 0.1,
    MainColor = Color3.fromRGB(0, 150, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    BGColor = Color3.fromRGB(20, 20, 30),
    AnimationSpeed = 0.3
}

-- FEATURES
local Features = {
    Noclip = false,
    ESP = false,
    Aimbot = false,
    InfiniteJump = false,
    Fly = false,
    SpeedHack = false,
    Godmode = false,
    Fullbright = false,
    TPClick = false,
    AntiAFK = false,
    AntiStun = false,
    AutoRejoin = false,
    AntiKick = false,
    AntiCrash = false,
    FPSUnlocker = false
}

-- AIMBOT SETTINGS
local AimbotSettings = {
    Enabled = false,
    WallCheck = true,
    AliveCheck = true,
    TeamCheck = true,
    Smoothness = 5,
    AimPart = "Head"
}

-- FPS SETTINGS
local FPSSettings = {
    Enabled = false,
    MaxFPS = 144,
    LastFrame = _tick(),
    FrameTime = 1 / 144
}

-- VALORES
local WalkSpeedValue = 50
local FlySpeedValue = 50
local FlyBodyVelocity = nil
local ESPObjects = {}

-- UI
local ScreenGui = nil
local MainFrame = nil
local isUILoaded = false

-- ANTI-AFK
local lastActivityTime = _tick()
local antiAFKConnection = nil

-- ANTI-STUN
local stunConnections = {}

-- AIMBOT LOOP
local aimbotConnection = nil

-- ANTI CRASH
local antiCrashConnection = nil

-- FUNÇÃO DE ANIMAÇÃO
local function AnimateUI(object, properties)
    local tween = TweenService:Create(object, TweenInfo.new(UISettings.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- CORES DOS TIMES (Dinamico)
local function GetTeamColor(player)
    local team = player.Team
    if not team then
        return Color3.fromRGB(128, 128, 128) -- Cinza padrão para sem time
    end
    
    local teamName = team.Name
    local teamColor = team.TeamColor
    
    -- Prisoneiros
    if teamName and string.find(string.lower(teamName), "prisioneiro") then
        return Color3.fromRGB(255, 165, 0) -- Laranja
    end
    -- Polícia
    if teamName and string.find(string.lower(teamName), "policia") then
        return Color3.fromRGB(0, 100, 255) -- Azul
    end
    -- Criminosos / Bandidos / Ladrões
    if teamName and (string.find(string.lower(teamName), "criminoso") or 
       string.find(string.lower(teamName), "ladrao") or 
       string.find(string.lower(teamName), "bandido")) then
        return Color3.fromRGB(255, 50, 50) -- Vermelho
    end
    -- Cores por BrickColor
    if teamColor == BrickColor.new("Bright red") then
        return Color3.fromRGB(255, 50, 50)
    elseif teamColor == BrickColor.new("Bright blue") then
        return Color3.fromRGB(50, 100, 255)
    elseif teamColor == BrickColor.new("Bright green") then
        return Color3.fromRGB(50, 255, 50)
    elseif teamColor == BrickColor.new("Bright yellow") then
        return Color3.fromRGB(255, 255, 50)
    elseif teamColor == BrickColor.new("Bright orange") then
        return Color3.fromRGB(255, 165, 0)
    elseif teamColor == BrickColor.new("White") then
        return Color3.fromRGB(255, 255, 255)
    elseif teamColor == BrickColor.new("Black") then
        return Color3.fromRGB(50, 50, 50)
    else
        return Color3.fromRGB(128, 128, 128) -- Cinza padrão
    end
end

-- FUNCOES AUXILIARES
local function GetChar()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetChar()
    if char then return char:FindFirstChild("Humanoid") end
    return nil
end

local function GetRoot()
    local char = GetChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- LIMPAR ESP
local function CleanupESP(player)
    local obj = ESPObjects[player]
    if obj then
        _spawn(function()
            _wait(0.05)
            if obj.box then obj.box:Remove() end
            if obj.text then obj.text:Remove() end
            if obj.health then obj.health:Remove() end
            ESPObjects[player] = nil
        end)
    end
end

local function CleanupAllESP()
    for player, obj in _pairs(ESPObjects) do
        _spawn(function()
            if obj.box then obj.box:Remove() end
            if obj.text then obj.text:Remove() end
            if obj.health then obj.health:Remove() end
        end)
    end
    ESPObjects = {}
end

-- VALIDAR TARGET
local function IsValidTarget(player)
    if not AimbotSettings.Enabled then return false end
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if AimbotSettings.AliveCheck then
        if not humanoid or humanoid.Health <= 0 then return false end
    end
    
    if AimbotSettings.TeamCheck then
        local myTeam = LocalPlayer.Team
        local targetTeam = player.Team
        if myTeam and targetTeam and myTeam == targetTeam then return false end
    end
    
    if AimbotSettings.WallCheck then
        local root = GetRoot()
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if root and targetRoot then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {GetChar(), player.Character}
            local result = Workspace:Raycast(root.Position, (targetRoot.Position - root.Position), params)
            if result then return false end
        end
    end
    
    return true
end

-- AIMBOT COM SMOOTH
local function DoAimbot()
    if not AimbotSettings.Enabled then return end
    
    local closest = nil
    local closestDist = 300
    
    for _, player in _pairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local targetPart = player.Character:FindFirstChild(AimbotSettings.AimPart)
            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = targetPart
                    end
                end
            end
        end
    end
    
    if closest then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        if AimbotSettings.Smoothness > 1 then
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / AimbotSettings.Smoothness)
        else
            Camera.CFrame = targetCFrame
        end
    end
end

local function StartAimbot()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(DoAimbot)
end

local function StopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- ESP CORRIGIDO COM COR DO TIME
local function UpdateESP()
    if not Features.ESP then
        CleanupAllESP()
        return
    end
    
    for _, player in _pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and rootPart and humanoid and humanoid.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local head = char:FindFirstChild("Head")
                    local headPos = head and Camera:WorldToViewportPoint(head.Position) or rootPos
                    
                    local height = math.abs(rootPos.Y - headPos.Y) * 2.5
                    local width = height * 0.6
                    local boxX = rootPos.X - (width / 2)
                    local boxY = headPos.Y - (height * 0.3)
                    
                    if not ESPObjects[player] then
                        local box = Drawing.new("Square")
                        box.Thickness = 2
                        box.Filled = false
                        box.Transparency = 0.7
                        box.Visible = true
                        
                        local text = Drawing.new("Text")
                        text.Size = 14
                        text.Center = true
                        text.Outline = true
                        text.OutlineColor = Color3.fromRGB(0, 0, 0)
                        text.Visible = true
                        
                        local health = Drawing.new("Text")
                        health.Size = 12
                        health.Center = true
                        health.Outline = true
                        health.OutlineColor = Color3.fromRGB(0, 0, 0)
                        health.Visible = true
                        
                        ESPObjects[player] = {box = box, text = text, health = health}
                    end
                    
                    -- COR DO TIME DO JOGADOR
                    local color = GetTeamColor(player)
                    ESPObjects[player].box.Color = color
                    ESPObjects[player].text.Color = color
                    ESPObjects[player].health.Color = color
                    
                    ESPObjects[player].box.Size = Vector2.new(width, height)
                    ESPObjects[player].box.Position = Vector2.new(boxX, boxY)
                    ESPObjects[player].box.Visible = true
                    
                    -- Nome do jogador
                    ESPObjects[player].text.Text = player.Name
                    ESPObjects[player].text.Position = Vector2.new(rootPos.X, boxY - 15)
                    ESPObjects[player].text.Visible = true
                    
                    -- Vida do jogador
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    ESPObjects[player].health.Text = "❤️ " .. healthPercent .. "%"
                    ESPObjects[player].health.Position = Vector2.new(rootPos.X, boxY + height + 5)
                    ESPObjects[player].health.Visible = true
                else
                    if ESPObjects[player] then
                        ESPObjects[player].box.Visible = false
                        ESPObjects[player].text.Visible = false
                        if ESPObjects[player].health then
                            ESPObjects[player].health.Visible = false
                        end
                    end
                end
            else
                CleanupESP(player)
            end
        end
    end
end

-- TP CLICK
local function TeleportToMouse()
    if not Features.TPClick then return end
    
    local unitRay = Mouse.UnitRay
    local origin = unitRay.Origin
    local direction = unitRay.Direction * 1000
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {GetChar()}
    
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        local hit = result.Position
        local root = GetRoot()
        if root then
            root.CFrame = CFrame.new(hit + Vector3.new(0, 3, 0))
        end
    end
end

-- ANTI-AFK
local function ResetActivity()
    lastActivityTime = _tick()
end

local function DoAntiAFK()
    if not Features.AntiAFK then return end
    
    local now = _tick()
    if now - lastActivityTime >= 30 then
        local char = GetChar()
        local humanoid = GetHumanoid()
        local root = GetRoot()
        
        if char and humanoid and root then
            local original = root.Position
            local forward = original + char.HumanoidRootPart.CFrame.LookVector * 2
            root.CFrame = CFrame.new(forward)
            _wait(0.1)
            root.CFrame = CFrame.new(original)
            _wait(0.1)
            
            _spawn(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end)
            end)
            
            ResetActivity()
        end
    end
end

UserInputService.InputBegan:Connect(ResetActivity)
UserInputService.InputChanged:Connect(ResetActivity)
Mouse.Move:Connect(ResetActivity)

local function StartAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    antiAFKConnection = RunService.Heartbeat:Connect(DoAntiAFK)
end

-- ANTI-STUN
local function RemoveStun()
    if not Features.AntiStun then return end
    
    local root = GetRoot()
    if not root then return end
    
    for _, v in _pairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyForce") then
            if v ~= FlyBodyVelocity then
                v:Destroy()
            end
        end
    end
    
    local humanoid = GetHumanoid()
    if humanoid then
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
        if humanoid.Sit then humanoid.Sit = false end
    end
    
    if root.AssemblyLinearVelocity.Magnitude > 50 then
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end
end

local function SetupStun()
    local root = GetRoot()
    if not root then return end
    
    local c1 = root:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
        if Features.AntiStun and root.AssemblyLinearVelocity.Magnitude > 30 then
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end)
    
    local c2 = root.ChildAdded:Connect(function(child)
        if Features.AntiStun then
            if child:IsA("BodyVelocity") or child:IsA("BodyForce") then
                if child ~= FlyBodyVelocity then
                    _wait(0.1)
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
    
    table.insert(stunConnections, c1)
    table.insert(stunConnections, c2)
end

local function ClearStun()
    for _, c in _pairs(stunConnections) do
        pcall(function() c:Disconnect() end)
    end
    stunConnections = {}
end

-- AUTO REJOIN
local function SaveServerInfo()
    lastPlaceId = game.PlaceId
    lastJobId = game.JobId
end

local function RejoinServer()
    if not Features.AutoRejoin then return end
    
    if lastPlaceId and lastJobId then
        _wait(3)
        _spawn(function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(lastPlaceId, lastJobId, LocalPlayer)
            end)
        end)
    end
end

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Starting then
        SaveServerInfo()
    end
end)

-- ANTI KICK
local originalKick = nil

local function SetupAntiKick()
    originalKick = LocalPlayer.Kick
    LocalPlayer.Kick = function(reason)
        if Features.AntiKick then
            return nil
        else
            return originalKick(reason)
        end
    end
end

local function RestoreKick()
    if originalKick then
        LocalPlayer.Kick = originalKick
    end
end

-- ANTI CRASH
local function CleanupUnusedObjects()
    if not Features.AntiCrash then return end
    
    local count = 0
    for _, v in _pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") and v.Enabled then
            v.Enabled = false
            count = count + 1
        end
        if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
            count = count + 1
        end
        if count > 100 then break end
    end
end

-- FPS UNLOCKER
local function SetupFPSUnlocker()
    if not Features.FPSUnlocker then return end
    
    local frameTime = 1 / FPSSettings.MaxFPS
    local lastTime = _tick()
    
    local conn = RunService.RenderStepped:Connect(function()
        if not Features.FPSUnlocker then
            conn:Disconnect()
            return
        end
        
        local now = _tick()
        local delta = now - lastTime
        if delta < frameTime then
            _wait(frameTime - delta)
        end
        lastTime = now
    end)
end

-- TOGGLES
local function ToggleTPClick(state) Features.TPClick = state end
local function ToggleAntiAFK(state) 
    Features.AntiAFK = state
    if state then ResetActivity(); StartAntiAFK() end
end
local function ToggleAntiStun(state)
    Features.AntiStun = state
    if state then ClearStun(); SetupStun() end
end
local function ToggleNoclip(state) Features.Noclip = state end
local function ToggleESP(state) 
    Features.ESP = state
    if not state then CleanupAllESP() end
end
local function ToggleAimbot(state) 
    AimbotSettings.Enabled = state
    if not state then StopAimbot() end
end
local function ToggleInfiniteJump(state) Features.InfiniteJump = state end
local function ToggleFly(state)
    Features.Fly = state
    if not state and FlyBodyVelocity then
        pcall(function() FlyBodyVelocity:Destroy() end)
        FlyBodyVelocity = nil
    end
end
local function ToggleSpeedHack(state)
    Features.SpeedHack = state
    if not state then
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end
local function ToggleGodmode(state) Features.Godmode = state end
local function ToggleFullbright(state)
    Features.Fullbright = state
    local lighting = _getService(game, "Lighting")
    if state then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.GlobalShadows = false
    else
        lighting.Brightness = 1
        lighting.GlobalShadows = true
    end
end
local function ToggleAutoRejoin(state)
    Features.AutoRejoin = state
    if state then SaveServerInfo() end
end
local function ToggleAntiKick(state)
    Features.AntiKick = state
    if state then SetupAntiKick() else RestoreKick() end
end
local function ToggleAntiCrash(state)
    Features.AntiCrash = state
    if state then
        if not antiCrashConnection then
            antiCrashConnection = RunService.Heartbeat:Connect(CleanupUnusedObjects)
        end
    else
        if antiCrashConnection then
            antiCrashConnection:Disconnect()
            antiCrashConnection = nil
        end
    end
end
local function ToggleFPSUnlocker(state)
    Features.FPSUnlocker = state
    if state then SetupFPSUnlocker() end
end
local function SetMaxFPS(value)
    FPSSettings.MaxFPS = value
    FPSSettings.FrameTime = 1 / value
    if Features.FPSUnlocker then SetupFPSUnlocker() end
end

-- LOOPS
RunService.Stepped:Connect(function()
    if Features.Noclip then
        local char = GetChar()
        if char then
            for _, part in _pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Features.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if Features.SpeedHack then
        local hum = GetHumanoid()
        if hum and hum.WalkSpeed ~= WalkSpeedValue then
            hum.WalkSpeed = WalkSpeedValue
        end
    end
end)

RunService.Stepped:Connect(function()
    if Features.Godmode then
        local hum = GetHumanoid()
        if hum then hum.Health = math.huge end
    end
end)

RunService.Heartbeat:Connect(function()
    if Features.Fly then
        local root = GetRoot()
        if not root then return end
        
        if not FlyBodyVelocity then
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            FlyBodyVelocity.Parent = root
        end
        
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        
        if move.Magnitude > 0 then
            FlyBodyVelocity.Velocity = move.Unit * FlySpeedValue
        else
            FlyBodyVelocity.Velocity = Vector3.new()
        end
    elseif FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end)

RunService.RenderStepped:Connect(UpdateESP)
RunService.Stepped:Connect(RemoveStun)

-- EVENTOS DO MOUSE
Mouse.Button2Down:Connect(function()
    if AimbotSettings.Enabled then StartAimbot() end
end)

Mouse.Button2Up:Connect(function()
    StopAimbot()
end)

Mouse.Button1Down:Connect(function()
    if Features.TPClick then TeleportToMouse() end
end)

-- EVENTOS DE JOGADOR
local function OnPlayerRemoving(player)
    CleanupESP(player)
end

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        CleanupESP(player)
    end)
end

Players.PlayerRemoving:Connect(OnPlayerRemoving)
Players.PlayerAdded:Connect(OnPlayerAdded)

for _, player in _pairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

-- RECONECTAR
LocalPlayer.CharacterAdded:Connect(function()
    _wait(0.5)
    if Features.AntiStun then ClearStun(); SetupStun() end
    if Features.AntiAFK then ResetActivity() end
    CleanupAllESP()
end)

-- UI PRINCIPAL MODERNA
local function CreateMainUI()
    if isUILoaded then return end
    isUILoaded = true
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MNAHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 360, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -290)
    MainFrame.BackgroundColor3 = UISettings.BGColor
    MainFrame.BackgroundTransparency = UISettings.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    local Title = Instance.new("Frame")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = UISettings.MainColor
    Title.BackgroundTransparency = 0.2
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "MNAHub v6.6"
    TitleLabel.TextColor3 = UISettings.TextColor
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = Title
    
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0.7, 0, 0, 20)
    SubLabel.Position = UDim2.new(0, 15, 0, 30)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Executor: " .. Executor
    SubLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SubLabel.TextSize = 10
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Parent = Title
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    MinimizeBtn.Position = UDim2.new(1, -50, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = UISettings.TextColor
    MinimizeBtn.TextSize = 24
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = Title
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 8)
    MinimizeCorner.Parent = MinimizeBtn
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -70)
    Scroll.Position = UDim2.new(0, 10, 0, 60)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 4
    Scroll.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Scroll
    
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            AnimateUI(MainFrame, {Size = UDim2.new(0, 360, 0, 50)})
            MinimizeBtn.Text = "+"
        else
            AnimateUI(MainFrame, {Size = UDim2.new(0, 360, 0, 580)})
            MinimizeBtn.Text = "−"
        end
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Title.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Criar Toggle Moderno
    local function CreateModernToggle(text, callback, isEnabled)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = Scroll
        
        local fcorner = Instance.new("UICorner")
        fcorner.CornerRadius = UDim.new(0, 10)
        fcorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = UISettings.TextColor
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -75, 0.5, -15)
        toggleBtn.BackgroundColor3 = isEnabled and UISettings.MainColor or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = isEnabled and "ON" or "OFF"
        toggleBtn.TextColor3 = UISettings.TextColor
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = frame
        
        local bcorner = Instance.new("UICorner")
        bcorner.CornerRadius = UDim.new(0, 8)
        bcorner.Parent = toggleBtn
        
        local state = isEnabled or false
        
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                AnimateUI(toggleBtn, {BackgroundColor3 = UISettings.MainColor})
                toggleBtn.Text = "ON"
            else
                AnimateUI(toggleBtn, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)})
                toggleBtn.Text = "OFF"
            end
            callback(state)
        end)
        
        return toggleBtn
    end
    
    -- Slider Moderno
    local function CreateModernSlider(text, minVal, maxVal, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 75)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = Scroll
        
        local fcorner = Instance.new("UICorner")
        fcorner.CornerRadius = UDim.new(0, 10)
        fcorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 30)
        label.Position = UDim2.new(0, 15, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = UISettings.TextColor
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 60, 0, 30)
        valLabel.Position = UDim2.new(1, -75, 0, 5)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(defaultVal)
        valLabel.TextColor3 = UISettings.MainColor
        valLabel.TextSize = 13
        valLabel.Font = Enum.Font.GothamBold
        valLabel.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.85, 0, 0, 4)
        slider.Position = UDim2.new(0, 15, 0, 55)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = UISettings.MainColor
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
        knob.BackgroundColor3 = UISettings.TextColor
        knob.Text = ""
        knob.BorderSizePixel = 0
        knob.Parent = slider
        
        local kcorner = Instance.new("UICorner")
        kcorner.CornerRadius = UDim.new(1, 0)
        kcorner.Parent = knob
        
        local dragging = false
        
        knob.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local perc = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                local value = math.floor(minVal + (maxVal - minVal) * perc)
                fill.Size = UDim2.new(perc, 0, 1, 0)
                knob.Position = UDim2.new(perc, -7, 0.5, -7)
                valLabel.Text = tostring(value)
                callback(value)
            end
        end)
    end
    
    -- Criar Separador
    local function CreateModernSeparator(text)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 35)
        frame.BackgroundColor3 = UISettings.MainColor
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = Scroll
        
        local fcorner = Instance.new("UICorner")
        fcorner.CornerRadius = UDim.new(0, 8)
        fcorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = UISettings.TextColor
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
    end
    
    -- CRIAR CATEGORIAS
    CreateModernSeparator("⚡ MOVIMENTO")
    CreateModernToggle("Noclip", ToggleNoclip, false)
    CreateModernToggle("Infinite Jump", ToggleInfiniteJump, false)
    CreateModernToggle("Fly", ToggleFly, false)
    CreateModernSlider("Fly Speed", 10, 200, 50, function(v) FlySpeedValue = v end)
    CreateModernToggle("Speed Hack", ToggleSpeedHack, false)
    CreateModernSlider("Walk Speed", 16, 250, 50, function(v) WalkSpeedValue = v end)
    
    CreateModernSeparator("⚔️ COMBATE")
    CreateModernToggle("Godmode", ToggleGodmode, false)
    CreateModernToggle("ESP", ToggleESP, false)
    CreateModernToggle("Aimbot", ToggleAimbot, false)
    CreateModernSlider("Aimbot Smoothness", 1, 20, 5, function(v) AimbotSettings.Smoothness = v end)
    
    CreateModernSeparator("🎯 AIMBOT CHECKS")
    CreateModernToggle("Wall Check", function(v) AimbotSettings.WallCheck = v end, true)
    CreateModernToggle("Alive Check", function(v) AimbotSettings.AliveCheck = v end, true)
    CreateModernToggle("Team Check", function(v) AimbotSettings.TeamCheck = v end, true)
    
    CreateModernSeparator("🔧 UTILIDADES")
    CreateModernToggle("TP Click", ToggleTPClick, false)
    CreateModernToggle("Anti-AFK", ToggleAntiAFK, false)
    CreateModernToggle("Anti-Stun", ToggleAntiStun, false)
    
    CreateModernSeparator("🛡️ PROTEÇÃO")
    CreateModernToggle("Auto Rejoin", ToggleAutoRejoin, false)
    CreateModernToggle("Anti Kick", ToggleAntiKick, false)
    CreateModernToggle("Anti Crash", ToggleAntiCrash, false)
    
    CreateModernSeparator("⚙️ OTIMIZAÇÃO")
    CreateModernToggle("FPS Unlocker", ToggleFPSUnlocker, false)
    CreateModernSlider("Max FPS", 60, 240, 144, function(v) SetMaxFPS(v) end)
    
    CreateModernSeparator("🎨 VISUAIS")
    CreateModernToggle("Fullbright", ToggleFullbright, false)
    
    local function UpdateCanvas()
        local size = 0
        for _, child in _pairs(Scroll:GetChildren()) do
            if child:IsA("Frame") then
                size = size + child.Size.Y.Offset + 8
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, size + 20)
    end
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
    _wait(0.1)
    UpdateCanvas()
end

-- TELA DE KEY MODERNA
local function ShowKeyWindow()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "MNAKey"
    KeyGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 260)
    frame.Position = UDim2.new(0.5, -190, 0.5, -130)
    frame.BackgroundColor3 = UISettings.BGColor
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = KeyGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(-0.03, 0, -0.03, 0)
    glow.BackgroundColor3 = UISettings.MainColor
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = frame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 25)
    glowCorner.Parent = glow
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundColor3 = UISettings.MainColor
    title.BackgroundTransparency = 0.2
    title.Text = "MNAHub v6.6"
    title.TextColor3 = UISettings.TextColor
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 20)
    titleCorner.Parent = title
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 25)
    sub.Position = UDim2.new(0, 0, 0, 60)
    sub.BackgroundTransparency = 1
    sub.Text = "Executor: " .. Executor .. " | ESP com Cores de Time"
    sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    sub.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.8, 0, 0, 45)
    input.Position = UDim2.new(0.1, 0, 0.45, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    input.TextColor3 = UISettings.TextColor
    input.PlaceholderText = "🔑 Digite sua Key"
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.Parent = frame
    
    local icorner = Instance.new("UICorner")
    icorner.CornerRadius = UDim.new(0, 10)
    icorner.Parent = input
    
    local verify = Instance.new("TextButton")
    verify.Size = UDim2.new(0.4, 0, 0, 40)
    verify.Position = UDim2.new(0.3, 0, 0.72, 0)
    verify.BackgroundColor3 = UISettings.MainColor
    verify.Text = "VERIFICAR"
    verify.TextColor3 = UISettings.TextColor
    verify.TextSize = 14
    verify.Font = Enum.Font.GothamBold
    verify.BorderSizePixel = 0
    verify.Parent = frame
    
    local vcorner = Instance.new("UICorner")
    vcorner.CornerRadius = UDim.new(0, 10)
    vcorner.Parent = verify
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0.86, 0)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    verify.MouseButton1Click:Connect(function()
        local key = input.Text
        if key == "" then
            status.Text = "⚠️ Digite uma key"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        if Keys[key] or key == "MNA2026" or key == "FREEKEY" then
            status.Text = "✅ Key válida! Carregando..."
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            AnimateUI(frame, {BackgroundTransparency = 1})
            _wait(0.5)
            KeyGui:Destroy()
            CreateMainUI()
        else
            status.Text = "❌ Key inválida!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            AnimateUI(input, {BackgroundColor3 = Color3.fromRGB(80, 30, 30)})
            _wait(0.2)
            AnimateUI(input, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)})
        end
    end)
end

-- Iniciar
ShowKeyWindow()
