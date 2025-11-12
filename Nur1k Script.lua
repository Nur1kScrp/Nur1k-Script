-- ======================================
-- ПОЛНЫЙ UI-СКРИПТ NUR1K (V13) - Ускоренный Server Hop
-- ======================================
local Services = setmetatable({}, {
    __index = function(self, key)
        local Service = game:GetService(key)
        rawset(self, key, Service)
        return Service
    end
})

local TweenService = Services.TweenService
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TeleportService = Services.TeleportService 
local HttpService = Services.HttpService 
local LocalPlayer = Players.LocalPlayer
local Workspace = Services.Workspace

-- КОНСТАНТЫ / НАСТРОЙКИ (сделаны изменяемыми)
local DEFAULT_JUMP_HEIGHT = 7.2
local TARGET_JUMP_HEIGHT = 5.6 
local baseSpeed = 21.7

-- Цвета
local ACTIVE_COLOR = Color3.fromRGB(0, 150, 75)
local INACTIVE_COLOR = Color3.fromRGB(25, 25, 30)
local STROKE_COLOR = Color3.fromRGB(0, 200, 255)
local HOP_COLOR = Color3.fromRGB(255, 165, 0) 

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Nur1kHubModernUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui and gethui() or game:GetService("CoreGui"))

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 360) 
mainFrame.AnchorPoint = Vector2.new(1, 1)
mainFrame.Position = UDim2.new(1, -20, 1, -20)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = STROKE_COLOR
mainStroke.Thickness = 2
mainStroke.Transparency = 0.2
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 0, 30) 
titleLabel.Position = UDim2.new(0, 10, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Nur1k HUB"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, -20, 0, 2)
titleLine.Position = UDim2.new(0, 10, 0, 36)
titleLine.BackgroundColor3 = STROKE_COLOR
titleLine.BorderSizePixel = 0
titleLine.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 100, 0, 14)
statusLabel.Position = UDim2.new(1, -110, 0, 8) 
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Anti-AFK on"
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.Parent = mainFrame

---
-- SCROLLINGFRAME (Контейнер с прокруткой)
---
local buttonContainer = Instance.new("ScrollingFrame")
buttonContainer.Size = UDim2.new(1, -10, 1, -120) 
buttonContainer.Position = UDim2.new(0, 5, 0, 45)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Настройки прокрутки
buttonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
buttonContainer.ScrollBarThickness = 8
buttonContainer.ScrollBarImageColor3 = STROKE_COLOR
buttonContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
buttonContainer.VerticalScrollBarInset = Enum.ScrollBarInset.None
buttonContainer.ScrollingDirection = Enum.ScrollingDirection.Y

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonContainer

-- АВТОМАТИЧЕСКАЯ ПОДГОНКА CANVASSIZE (для работы прокрутки)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    buttonContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)
---

local function toggleButtonState(button, stroke, isActive, customColor)
    local col = customColor or ACTIVE_COLOR
    if isActive then
        button.BackgroundColor3 = col
        stroke.Color = col
        stroke.Transparency = 0.3
    else
        button.BackgroundColor3 = INACTIVE_COLOR
        stroke.Color = STROKE_COLOR
        stroke.Transparency = 0.7
    end
end

local function createButton(name, icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = icon .. " " .. name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = INACTIVE_COLOR 
    button.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = STROKE_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = button

    button.Parent = buttonContainer

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(35, 35, 40) }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.1), { Transparency = 0.5 }):Play()
    end)

    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 == ACTIVE_COLOR or button.BackgroundColor3 == HOP_COLOR then return end
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = INACTIVE_COLOR }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.1), { Transparency = 0.7 }):Play()
    end)

    return button, stroke
end

-- Создаём КНОПКИ (ОСНОВНЫЕ)
local speedButton, speedStroke = createButton("Speed Boost [Q]", "⚡")
local jumpFixButton, jumpFixStroke = createButton("Jump Boost [X]", "⬆️") 
local floorButton, floorStroke = createButton("3rd Floor Glitch [C]", "🏢")
local espButton, espStroke = createButton("ESP Players [P]", "👁️")
local spinnerButton, spinnerStroke = createButton("Spinner [V]", "🔄")

-- НОВАЯ КНОПКА: SERVER HOP
local serverHopButton, serverHopStroke = createButton("Server Hop [G]", "➡️") 
-- ------------------------

local bindButton, bindStroke = createButton("Bind", "⚙️") 
local closeButton, closeStroke = createButton("Close UI [B]", "🗑")

local externalKeybinds = {}

local function RegisterKeybind(keyCode, callback)
    if keyCode and callback then externalKeybinds[keyCode] = callback end
end

---
-- SPEED BOOST
---
do
    local speedConn
    local active = false

    local function GetCharacter()
        local Char = LocalPlayer.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        return Char, HRP, Hum
    end

    local function startSpeedControl()
        if speedConn then return end
        speedConn = RunService.Heartbeat:Connect(function()
            local Char, HRP, Hum = GetCharacter()
            if not Char or not HRP or not Hum then return end
            local moveVector = Hum.MoveDirection
            if moveVector.Magnitude > 0.1 then
                local dir = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
                HRP.AssemblyLinearVelocity = Vector3.new(dir.X * baseSpeed, HRP.AssemblyLinearVelocity.Y, dir.Z * baseSpeed)
            end
        end)
    end

    local function stopSpeedControl()
        if speedConn then speedConn:Disconnect(); speedConn = nil end
    end

    local function toggleSpeed()
        active = not active
        toggleButtonState(speedButton, speedStroke, active)
        if active then startSpeedControl() else stopSpeedControl() end
    end

    speedButton.MouseButton1Click:Connect(toggleSpeed)
    RegisterKeybind(Enum.KeyCode.Q, toggleSpeed)
end

---
-- JUMP FIX (6.6) [X]
---
do
    local jumpActive = false
    local jumpConnection = nil
    
    local function applyJumpHeight(height)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpHeight = height
        end
    end

    local function updateJumpHeight()
        local char = LocalPlayer.Character
        if char then
            applyJumpHeight(TARGET_JUMP_HEIGHT)
        end
    end

    local function toggleJump()
        jumpActive = not jumpActive
        toggleButtonState(jumpFixButton, jumpFixStroke, jumpActive)
        
        if jumpActive then
            applyJumpHeight(TARGET_JUMP_HEIGHT)
            
            if not jumpConnection then
                jumpConnection = RunService.Heartbeat:Connect(updateJumpHeight)
            end
        else
            applyJumpHeight(DEFAULT_JUMP_HEIGHT)
            
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end

    -- Обрабатываем респавн (CharacterAdded)
    LocalPlayer.CharacterAdded:Connect(function(character)
        local hum = character:WaitForChild("Humanoid")
        
        if jumpActive then
            hum.JumpHeight = TARGET_JUMP_HEIGHT
        else
            hum.JumpHeight = DEFAULT_JUMP_HEIGHT
        end
    end)
    
    jumpFixButton.MouseButton1Click:Connect(toggleJump)
    RegisterKeybind(Enum.KeyCode.X, toggleJump)
end

---
-- 3RD FLOOR GLITCH
---
do
    local active = false
    local platform, conn
    local RISE_SPEED = 15

    local function destroyPlatform()
        if platform then platform:Destroy(); platform = nil end
        if conn then conn:Disconnect(); conn = nil end
    end

    local function createPlatform()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        destroyPlatform()
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 0.5, 6)
        platform.Anchored = true
        platform.Color = Color3.fromRGB(100, 200, 255)
        platform.Material = Enum.Material.Neon
        platform.Position = root.Position - Vector3.new(0, 4, 0)
        platform.Parent = Workspace

        local function canRise()
            local origin = platform.Position + Vector3.new(0, 1, 0)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {platform, LocalPlayer.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            return not Workspace:Raycast(origin, Vector3.new(0, 3, 0), rayParams)
        end

        conn = RunService.Heartbeat:Connect(function(dt)
            if platform and active and root then
                local pos = platform.Position
                local newPos = Vector3.new(root.Position.X, pos.Y, root.Position.Z)
                if canRise() then
                    platform.Position = newPos + Vector3.new(0, RISE_SPEED * dt, 0)
                else
                    platform.Position = newPos
                end
            end
        end)
    end

    local function toggleFloorGlitch()
        active = not active
        toggleButtonState(floorButton, floorStroke, active)
        if active then createPlatform() else destroyPlatform() end
    end

    floorButton.MouseButton1Click:Connect(toggleFloorGlitch)
    RegisterKeybind(Enum.KeyCode.C, toggleFloorGlitch)
end

---
-- ESP
---
do
    local ESP_CONTAINER = {}
    local espActive = false
    local MAX_DISTANCE = 200
    local ESP_COLOR = STROKE_COLOR
    local espConnection

    local function clearESP(player)
        if ESP_CONTAINER[player] then
            for _, v in pairs(ESP_CONTAINER[player]) do
                if v and v.Parent then v:Destroy() end
            end
            ESP_CONTAINER[player] = nil
        end
    end

    local function createESP(player)
        if not player.Character then return end
        clearESP(player)
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = ESP_COLOR
        highlight.FillTransparency = 0.85
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.2
        highlight.Parent = player.Character
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 120, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = screenGui
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 0.5
        label.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = label
        ESP_CONTAINER[player] = {highlight, billboard}
    end

    local function updateESP()
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                local phrp = char and char:FindFirstChild("HumanoidRootPart")
                if phrp then
                    local dist = (myHRP.Position - phrp.Position).Magnitude
                    if dist <= MAX_DISTANCE then
                        if not ESP_CONTAINER[p] then createESP(p) end
                    else
                        clearESP(p)
                    end
                end
            end
        end
    end

    local function enableESP()
        espActive = true
        toggleButtonState(espButton, espStroke, true)
        if not espConnection then
            espConnection = RunService.RenderStepped:Connect(function()
                if espActive then updateESP() end
            end)
        end
    end

    local function disableESP()
        espActive = false
        toggleButtonState(espButton, espStroke, false)
        if espConnection then espConnection:Disconnect(); espConnection = nil end
        for p in pairs(ESP_CONTAINER) do clearESP(p) end
    end

    local function toggleESP()
        if espActive then disableESP() else enableESP() end
    end

    espButton.MouseButton1Click:Connect(toggleESP)
    RegisterKeybind(Enum.KeyCode.P, toggleESP)
end

---
-- SPINNER [V]
---
do
    local player = LocalPlayer
    local spinnerActive = false
    local spinning = false

    local rotationSpeed = 1440
    local spinDuration = 0.25

    local humanoidStateChangedConn

    local function setupSpinner(character)
        if humanoidStateChangedConn then
            humanoidStateChangedConn:Disconnect()
            humanoidStateChangedConn = nil
        end
        
        local humanoid = character:WaitForChild("Humanoid")
        local root = character:WaitForChild("HumanoidRootPart")

        humanoidStateChangedConn = humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Jumping and spinnerActive and not spinning then
                spinning = true
                
                local rotVelocity = Instance.new("BodyAngularVelocity")
                rotVelocity.AngularVelocity = Vector3.new(0, math.rad(rotationSpeed), 0)
                rotVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                rotVelocity.P = 1000
                rotVelocity.Parent = root
                
                task.delay(spinDuration, function()
                    if rotVelocity.Parent then 
                        rotVelocity:Destroy()
                    end
                    spinning = false
                end)
            end
        end)
    end

    local function toggleSpinner()
        spinnerActive = not spinnerActive
        toggleButtonState(spinnerButton, spinnerStroke, spinnerActive)
    end

    spinnerButton.MouseButton1Click:Connect(toggleSpinner)
    RegisterKeybind(Enum.KeyCode.V, toggleSpinner)

    local function onCharacterAdded(character)
        setupSpinner(character)
    end
    
    if player.Character then
        task.defer(onCharacterAdded, player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
end

---
-- SERVER HOP [G] - УСКОРЕННАЯ ВЕРСИЯ (V13)
---
do
    local isHopping = false
    local HOP_TIMEOUT = 4 
    
    -- ФУНКЦИЯ ДЛЯ СУПЕРАГРЕССИВНОЙ ТЕЛЕПОРТАЦИИ (Без изменений)
    local function aggressiveTeleport(serverId)
        local success = false
        local attempts = 0
        local PlaceId = game.PlaceId
        local Player = game.Players.LocalPlayer
        
        while not success and attempts < 2 do
            attempts = attempts + 1
            
            success = pcall(function()
                -- 1. Стандартный метод Roblox
                TeleportService:TeleportToPlaceInstance(PlaceId, serverId, Player)
                
                -- 2. Обходной метод loadstring с прямой командой
                if loadstring and game:GetService("HttpService") then
                    local teleport_command = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)", PlaceId, serverId)
                    loadstring(teleport_command)()
                end

                -- 3. Специальные функции эксплойтов (Synapse X / Sentinel и др.)
                if Teleport and isfunction(Teleport) then Teleport(PlaceId, serverId) end
                if syn and syn.teleport then syn.teleport(PlaceId, serverId) end
                
            end)
            if not success then task.wait(0.5) end
        end
        return success
    end

    -- БЛОК ДЛЯ ОБХОДА БЛОКИРОВКИ HTTP (Без изменений)
    local function getServersData()
        local placeId = game.PlaceId
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" 
        
        local httpFunction = HttpGet or syn.request or game.HttpGet 

        if not httpFunction then
            local success, response = pcall(function()
                return HttpService:GetAsync(url)
            end)
            return success and response or nil
        end

        local response
        local success = pcall(function()
            if httpFunction == HttpGet or httpFunction == game.HttpGet then
                response = httpFunction(url)
            elseif httpFunction == syn.request then
                response = httpFunction({Url = url, Method = "GET"}).Body
            else
                response = httpFunction(url)
            end
        end)
        
        return success and response or nil
    end

    local function getAvailableServers()
        local servers = {}
        local response = getServersData()
        
        if response then
            local data
            local decodeSuccess = pcall(function()
                data = HttpService:JSONDecode(response)
            end)

            if decodeSuccess and data and data.data then
                for _, v in ipairs(data.data) do
                    -- Фильтруем: есть места, не текущий сервер И количество игроков > 0
                    if type(v) == "table" and v.id and v.playing < v.maxPlayers and v.id ~= game.JobId and v.playing > 0 then
                        table.insert(servers, v.id)
                    end
                end
            end
        end
        return servers
    end

    local function finalResetHopState(message)
        isHopping = false
        toggleButtonState(serverHopButton, serverHopStroke, false)
        serverHopButton.Text = message or "➡️ Server Hop [G]"
        task.wait(2)
        if not isHopping and serverHopButton.Text == message then 
            serverHopButton.Text = "➡️ Server Hop [G]"
        end
    end

    local function serverHop()
        if isHopping then 
            -- Если кнопка уже активна, выключаем ее и сбрасываем состояние
            finalResetHopState("➡️ Server Hop Disabled.")
            return 
        end
        
        isHopping = true
        toggleButtonState(serverHopButton, serverHopStroke, true, ACTIVE_COLOR) 
        
        local attempts = 0
        local teleportSuccessful = false

        -- БЕСКОНЕЧНЫЙ ЦИКЛ, ПОКА isHopping = true
        while isHopping and not teleportSuccessful do
            attempts = attempts + 1
            
            serverHopButton.Text = "➡️ Searching for Server..."
            
            local servers = getAvailableServers()

            if #servers == 0 then
                -- Уменьшена задержка с 5с до 2с
                serverHopButton.Text = "➡️ No Servers. Retrying in 2s..."
                task.wait(2)
                -- Цикл продолжится благодаря условию while isHopping
            else
                local randomServer = servers[math.random(1, #servers)]
                
                -- Убрано task.wait(1). Телепорт начинается немедленно.

                if not isHopping then break end 

                serverHopButton.Text = "➡️ Teleporting Now (Attempt " .. attempts .. ")"

                local hopDidTimeout = true
                
                local timeoutThread = task.spawn(function()
                    task.wait(HOP_TIMEOUT)
                    if hopDidTimeout and not teleportSuccessful and isHopping then
                        warn("Server Hop: Teleport timed out on attempt " .. attempts)
                    end
                end)

                teleportSuccessful = aggressiveTeleport(randomServer)
                
                hopDidTimeout = false 
                task.cancel(timeoutThread)

                if teleportSuccessful then
                    return -- Выход из функции при успехе
                else
                    warn("Teleport failed (Aggressive attempt) on attempt: " .. attempts)
                    
                    if not isHopping then break end
                    -- Уменьшена задержка повтора с 3с до 0.5с
                    serverHopButton.Text = "➡️ Hop Failed: Retrying fast..."
                    task.wait(0.5)
                end
            end
        end
        
        -- Выполняется, если цикл был прерван (isHopping = false)
        finalResetHopState("➡️ Server Hop Disabled.")
    end

    serverHopButton.MouseButton1Click:Connect(serverHop)
    RegisterKeybind(Enum.KeyCode.G, serverHop)
end

---
-- Settings Frame (для ⚙️ Bind)
---
do
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "BindSettingsFrame"
    settingsFrame.Size = UDim2.new(0, 160, 0, 120)
    settingsFrame.Position = UDim2.new(0, -180, 0, 60)
    settingsFrame.AnchorPoint = Vector2.new(0, 0)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = mainFrame
    settingsFrame.Visible = false
    settingsFrame.BackgroundTransparency = 1

    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 8)
    settingsCorner.Parent = settingsFrame

    local settingsStroke = Instance.new("UIStroke")
    settingsStroke.Color = STROKE_COLOR
    settingsStroke.Thickness = 1
    settingsStroke.Parent = settingsFrame

    -- Label Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 70, 0, 22)
    speedLabel.Position = UDim2.new(0, 10, 0, 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    speedLabel.Text = "Speed:"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = settingsFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0, 70, 0, 24)
    speedBox.Position = UDim2.new(0, 80, 0, 8)
    speedBox.BackgroundColor3 = INACTIVE_COLOR
    speedBox.TextColor3 = Color3.fromRGB(255,255,255)
    speedBox.TextSize = 14
    speedBox.Font = Enum.Font.Gotham
    speedBox.Text = tostring(baseSpeed)
    speedBox.ClearTextOnFocus = false
    speedBox.Parent = settingsFrame
    local sbCorner = Instance.new("UICorner"); sbCorner.Parent = speedBox

    -- Label Jump
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 70, 0, 22)
    jumpLabel.Position = UDim2.new(0, 10, 0, 42)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Font = Enum.Font.GothamBold
    jumpLabel.TextSize = 14
    jumpLabel.TextColor3 = Color3.fromRGB(255,255,255)
    jumpLabel.Text = "Jump:"
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = settingsFrame

    local jumpBox = Instance.new("TextBox")
    jumpBox.Size = UDim2.new(0, 70, 0, 24)
    jumpBox.Position = UDim2.new(0, 80, 0, 40)
    jumpBox.BackgroundColor3 = INACTIVE_COLOR
    jumpBox.TextColor3 = Color3.fromRGB(255,255,255)
    jumpBox.TextSize = 14
    jumpBox.Font = Enum.Font.Gotham
    jumpBox.Text = tostring(TARGET_JUMP_HEIGHT)
    jumpBox.ClearTextOnFocus = false
    jumpBox.Parent = settingsFrame
    local jbCorner = Instance.new("UICorner"); jbCorner.Parent = jumpBox

    -- Apply button
    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(0, 140, 0, 28)
    applyBtn.Position = UDim2.new(0, 10, 0, 74)
    applyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 14
    applyBtn.Text = "Apply"
    applyBtn.Parent = settingsFrame
    local applyCorner = Instance.new("UICorner"); applyCorner.Parent = applyBtn

    -- Toggle (fade) для settingsFrame
    local settingsVisible = false
    local function toggleSettingsFrame()
        if not settingsVisible then
            settingsFrame.Visible = true
            settingsFrame.BackgroundTransparency = 1
            TweenService:Create(settingsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1}):Play()
            settingsVisible = true
        else
            TweenService:Create(settingsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            task.delay(0.25, function()
                settingsFrame.Visible = false
            end)
            settingsVisible = false
        end
    end

    -- Привязываем toggle к bindButton
    bindButton.MouseButton1Click:Connect(function()
        toggleSettingsFrame()
    end)

    -- Apply: поменять baseSpeed и TARGET_JUMP_HEIGHT и применить на текущем Humanoid (если есть)
    applyBtn.MouseButton1Click:Connect(function()
        local s = tonumber(speedBox.Text)
        local j = tonumber(jumpBox.Text)
        if s and s > 0 then
            baseSpeed = s
        else
            speedBox.Text = tostring(baseSpeed) -- Вернуть старое значение, если ввод неверный
        end
        if j and j > 0 then
            TARGET_JUMP_HEIGHT = j
        else
            jumpBox.Text = tostring(TARGET_JUMP_HEIGHT) -- Вернуть старое значение
        end

        -- Применим сразу на текущем персонаже (Humanoid / HumanoidRootPart)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                -- Для Jump: set JumpHeight (и на будущее при респавне будет применяться)
                hum.JumpHeight = TARGET_JUMP_HEIGHT
                -- Для Speed: поменяем WalkSpeed, что также повлияет на логику Speed Boost
                hum.WalkSpeed = baseSpeed
            end
        end

        -- Короткое подтверждение (меняет текст кнопки на 1.2с)
        local original = applyBtn.Text
        applyBtn.Text = "Applied ✓"
        task.delay(1.2, function() applyBtn.Text = original end)
    end)
end

---
-- TOGGLE UI BUTTON (Для скрытия/показа)
---
local toggleUIButton = Instance.new("TextButton")
toggleUIButton.Name = "ToggleUI"
toggleUIButton.Size = UDim2.new(0, 20, 0, 20)
toggleUIButton.AnchorPoint = Vector2.new(1, 1)
toggleUIButton.Position = UDim2.new(1, 0, 1, 0)
toggleUIButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
toggleUIButton.BorderSizePixel = 0
toggleUIButton.Text = "🔓" 
toggleUIButton.Font = Enum.Font.Code
toggleUIButton.TextSize = 16
toggleUIButton.TextColor3 = STROKE_COLOR
toggleUIButton.TextScaled = true
toggleUIButton.Parent = screenGui 

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleUIButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = STROKE_COLOR
toggleStroke.Thickness = 2
toggleStroke.Transparency = 0.2
toggleStroke.Parent = toggleUIButton

---
-- CLOSE UI (МОМЕНТАЛЬНОЕ ПЕРЕКЛЮЧЕНИЕ)
---
local uiVisible = true
local function toggleUIVisibility()
    uiVisible = not uiVisible
    
    mainFrame.Visible = uiVisible
    
    toggleUIButton.Text = uiVisible and "🔓" or "🔒"
end

-- Подключаем к кнопкам и клавишам
closeButton.MouseButton1Click:Connect(toggleUIVisibility)
RegisterKeybind(Enum.KeyCode.B, toggleUIVisibility)
RegisterKeybind(Enum.KeyCode.Insert, toggleUIVisibility)
toggleUIButton.MouseButton1Click:Connect(toggleUIVisibility)


---
-- Unified Input Handler
---
do
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local key = input.KeyCode
        local ext = externalKeybinds[key]
        if ext then
            local ok, err = pcall(ext)
            if not ok then warn("External keybind error:", err) end
        end
    end)
end

---
-- НИЖНИЙ КОНТЕЙНЕР
---

local bottomPanel = Instance.new("Frame")
bottomPanel.Name = "BottomPanel"
bottomPanel.Size = UDim2.new(1, 0, 0, 70) 
bottomPanel.Position = UDim2.new(0, 0, 1, -70)
bottomPanel.BackgroundTransparency = 1
bottomPanel.Parent = mainFrame


-- 1. Таймер (Размещен в BottomPanel)
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -20, 0, 18)
timerLabel.Position = UDim2.new(0, 10, 0, 6)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Время в сессии: 00:00"
timerLabel.Font = Enum.Font.GothamSemibold
timerLabel.TextSize = 12
timerLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = bottomPanel

local startTick = tick()
local function formatTime(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds))
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - startTick
        timerLabel.Text = "Время в сессии: " .. formatTime(elapsed)
    end
end)

-- 2. Telegram button (Размещен в BottomPanel)
local telegramBtn = Instance.new("TextButton")
telegramBtn.Size = UDim2.new(1, -20, 0, 28)
telegramBtn.Position = UDim2.new(0, 10, 0, 35) 
telegramBtn.Text = "📱 Telegram: @nur1k_seller"
telegramBtn.Font = Enum.Font.GothamBold
telegramBtn.TextSize = 12
telegramBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
telegramBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
telegramBtn.AutoButtonColor = false
telegramBtn.Parent = bottomPanel

local telegramCorner = Instance.new("UICorner")
telegramCorner.CornerRadius = UDim.new(0, 6)
telegramCorner.Parent = telegramBtn

telegramBtn.MouseButton1Click:Connect(function()
    local telegramLink = "https://t.me/nur1k_seller"
    if setclipboard then
        setclipboard(telegramLink)
    elseif toclipboard then
        toclipboard(telegramLink)
    end
    local originalText = telegramBtn.Text
    telegramBtn.Text = "✅ Ссылка скопирована!"
    task.wait(2)
    telegramBtn.Text = originalText
end)
