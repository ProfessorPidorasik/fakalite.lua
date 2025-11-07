local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer and LocalPlayer:GetMouse()

local featureState = {}
local featureHandlers = {}

local function setFeatureValue(binding, value)
    if not binding then
        return
    end
    featureState[binding] = value
    local handler = featureHandlers[binding]
    if handler then
        task.defer(handler, value)
    end
end

local function getFeatureValue(binding, defaultValue)
    local value = featureState[binding]
    if value == nil then
        return defaultValue
    end
    return value
end

local function registerBinding(binding, handler)
    featureHandlers[binding] = handler
    local stored = featureState[binding]
    if stored ~= nil then
        task.defer(handler, stored)
    end
end

local existing = parentGui:FindFirstChild("FatalityShell")
if existing then
    existing:Destroy()
end

local style = {
    background = Color3.fromRGB(6, 6, 10),
    panel = Color3.fromRGB(16, 10, 22),
    panelContrast = Color3.fromRGB(26, 14, 34),
    accent = Color3.fromRGB(255, 60, 180),
    accentAlt = Color3.fromRGB(160, 60, 255),
    accentSoft = Color3.fromRGB(90, 30, 150),
    textDim = Color3.fromRGB(188, 170, 210),
    textBright = Color3.fromRGB(236, 220, 255),
    stroke = Color3.fromRGB(62, 26, 88),
    buttonIdle = Color3.fromRGB(22, 14, 30),
    buttonHover = Color3.fromRGB(32, 18, 42),
    buttonActive = Color3.fromRGB(60, 20, 70),
}

local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property == "Children" then
            for _, child in ipairs(value) do
                child.Parent = instance
            end
        else
            instance[property] = value
        end
    end
    return instance
end

local finalTitleTransparency = 0.15
local finalSubtitleTransparency = 0.4
local containerFinalTransparency = 0.15
local containerHiddenTransparency = 0.45
local finalBackgroundTransparency = 0.05
local hiddenBackgroundTransparency = 0.4

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FatalityShell"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then
    pcall(syn.protect_gui, screenGui)
end
screenGui.Parent = parentGui

local rootFrame = Instance.new("Frame")
rootFrame.Name = "Root"
rootFrame.Size = UDim2.fromScale(1, 1)
rootFrame.BackgroundColor3 = style.background
rootFrame.BackgroundTransparency = 1
rootFrame.Parent = screenGui

local ambientGradient = Instance.new("UIGradient")
ambientGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(34, 0, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 20))
})
ambientGradient.Rotation = 75
ambientGradient.Parent = rootFrame

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(640, 420)
mainFrame.BackgroundColor3 = style.panel
mainFrame.BackgroundTransparency = finalBackgroundTransparency
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = rootFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = style.stroke
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local glassNoise = Instance.new("ImageLabel")
glassNoise.Name = "GlassNoise"
glassNoise.BackgroundTransparency = 1
glassNoise.Image = "rbxassetid://2151741365"
glassNoise.ImageColor3 = Color3.fromRGB(255, 255, 255)
glassNoise.ImageTransparency = 0.9
glassNoise.ScaleType = Enum.ScaleType.Tile
glassNoise.TileSize = UDim2.new(0, 90, 0, 90)
glassNoise.Size = UDim2.new(1, 0, 1, 0)
glassNoise.ZIndex = 0
glassNoise.Parent = mainFrame

local accentBar = Instance.new("Frame")
accentBar.Name = "AccentBar"
accentBar.Size = UDim2.new(1, 0, 0, 4)
accentBar.BackgroundColor3 = style.accent
accentBar.BorderSizePixel = 0
accentBar.Parent = mainFrame

local accentGradient = Instance.new("UIGradient")
accentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, style.accentAlt),
    ColorSequenceKeypoint.new(0.45, style.accent),
    ColorSequenceKeypoint.new(0.55, style.accent),
    ColorSequenceKeypoint.new(1, style.accentAlt),
})
accentGradient.Rotation = 0
accentGradient.Parent = accentBar

local accentGlow = Instance.new("ImageLabel")
accentGlow.BackgroundTransparency = 1
accentGlow.Image = "rbxassetid://1217159491"
accentGlow.ImageColor3 = style.accent
accentGlow.ImageTransparency = 0.75
accentGlow.Size = UDim2.new(1, 120, 0, 70)
accentGlow.Position = UDim2.new(0, -60, 0, -34)
accentGlow.ZIndex = 0
accentGlow.Parent = accentBar

local glowClock = 0
local glowConnection
glowConnection = RunService.Heartbeat:Connect(function(step)
    if not accentGlow.Parent then
        if glowConnection then
            glowConnection:Disconnect()
        end
        return
    end
    glowClock = glowClock + step
    local pulse = (math.sin(glowClock * 1.6) + 1) / 2
    accentGlow.ImageTransparency = 0.6 + pulse * 0.25
end)

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 20, 0, 20)
header.Size = UDim2.new(1, -40, 0, 40)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamSemibold
title.Text = "fatality.win"
title.TextColor3 = style.textBright
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

title.Size = UDim2.new(0.5, 0, 1, 0)

title.TextTransparency = 1

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, style.accentAlt),
    ColorSequenceKeypoint.new(0.5, style.textBright),
    ColorSequenceKeypoint.new(1, style.accent)
})
titleGradient.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextWrapped = false
subtitle.Text = "internal build"
subtitle.TextColor3 = style.textDim
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Right
subtitle.AnchorPoint = Vector2.new(1, 0)
subtitle.Position = UDim2.new(1, 0, 0, 0)
subtitle.Size = UDim2.new(0.4, 0, 1, 0)
subtitle.Parent = header
subtitle.TextTransparency = 1

local headerUnderline = Instance.new("Frame")
headerUnderline.BackgroundColor3 = style.stroke
headerUnderline.BackgroundTransparency = 0.3
headerUnderline.BorderSizePixel = 0
headerUnderline.Size = UDim2.new(1, 0, 0, 1)
headerUnderline.Position = UDim2.new(0, 0, 1, 0)
headerUnderline.ZIndex = 2
headerUnderline.Parent = header

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.BackgroundTransparency = 1
tabBar.Position = UDim2.new(0, 20, 0, 72)
tabBar.Size = UDim2.new(1, -40, 0, 36)
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 12)
tabLayout.Parent = tabBar

local tabs = {
    { id = "rage", label = "rage" },
    { id = "legit", label = "legit" },
    { id = "visuals", label = "visuals" },
    { id = "misc", label = "misc" },
    { id = "config", label = "config" },
}

local tabContent = {
    rage = {
        { type = "toggle", label = "silent aim", description = "locks shots to the closest resolver target", default = true, binding = "rage.silentAim" },
        { type = "slider", label = "silent fov", description = "limit degrees around the crosshair for target selection", min = 2, max = 35, default = 12, step = 0.5, decimals = 1, binding = "rage.silentAimFov" },
        { type = "toggle", label = "anti aim", description = "spoofs your view angles to break enemy prediction", default = true, binding = "rage.antiAim" },
        { type = "cycle", label = "anti mode", description = "select how yaw updates are generated", options = { "static", "spin", "jitter" }, defaultIndex = 2, binding = "rage.antiAimMode" },
        { type = "slider", label = "yaw offset", description = "base yaw in degrees applied to the fake angle", min = -180, max = 180, default = 120, step = 1, binding = "rage.antiAimYaw" },
        { type = "slider", label = "pitch offset", description = "fake pitch in degrees", min = -89, max = 89, default = 0, step = 1, binding = "rage.antiAimPitch" },
        { type = "slider", label = "jitter range", description = "max random yaw delta for jitter mode", min = 0, max = 90, default = 35, step = 1, binding = "rage.antiAimJitter" },
        { type = "toggle", label = "lag desync", description = "throws your networked capsule to desync the model", default = true, binding = "rage.desync" },
        { type = "slider", label = "desync distance", description = "range of the remote capsule offset", min = 0, max = 18, default = 8, step = 0.5, decimals = 1, binding = "rage.desyncDistance" },
        { type = "slider", label = "desync rate", description = "oscillation speed for the desync ghost", min = 2, max = 30, default = 12, step = 1, binding = "rage.desyncRate" },
        { type = "toggle", label = "double tap", description = "buffers an extra shot shortly after firing", binding = "rage.doubleTap" },
    },
    legit = {
        { type = "toggle", label = "trigger bot", description = "auto fire when silent aim locks a target", binding = "legit.triggerBot" },
        { type = "slider", label = "assist strength", description = "amount of smoothing when assisting aim", min = 0, max = 100, default = 25, binding = "legit.assistStrength" },
        { type = "cycle", label = "hit chance", description = "probability threshold for trigger bot", options = { "low", "medium", "high" }, defaultIndex = 3, binding = "legit.hitChance" },
    },
    visuals = {
        { type = "toggle", label = "esp", description = "draw enemy info panels through walls", default = true, binding = "visuals.esp.enabled" },
        { type = "color", label = "esp color", description = "accent tint used for esp panels", default = Color3.fromRGB(255, 90, 220), binding = "visuals.esp.color" },
        { type = "color", label = "esp outline", description = "border tint for the esp boxes", default = Color3.fromRGB(48, 0, 82), binding = "visuals.esp.outline" },
        { type = "toggle", label = "player chams", description = "project neon fill over enemy avatars", default = true, binding = "visuals.chams.enabled" },
        { type = "color", label = "chams fill", description = "fill tint applied to highlight", default = Color3.fromRGB(255, 120, 255), binding = "visuals.chams.fill" },
        { type = "color", label = "chams outline", description = "outline tint applied to highlight", default = Color3.fromRGB(90, 10, 130), binding = "visuals.chams.outline" },
        { type = "slider", label = "chams fill alpha", description = "opacity of the chams fill (lower is more solid)", min = 0, max = 100, default = 35, step = 1, binding = "visuals.chams.fillAlpha" },
        { type = "slider", label = "chams outline alpha", description = "opacity of the chams outline", min = 0, max = 100, default = 0, step = 1, binding = "visuals.chams.outlineAlpha" },
    },
    misc = {
        { type = "toggle", label = "kill say", description = "trash talk players you eliminate", binding = "misc.killSay" },
        { type = "cycle", label = "trash talk", description = "select the flavour of chat message", options = { "fatality", "friendly", "random" }, defaultIndex = 1, binding = "misc.killSayMode" },
        { type = "toggle", label = "fake lag", description = "choke updates to desync movement", binding = "misc.fakeLag" },
        { type = "slider", label = "fake lag choke", description = "ticks to buffer before releasing packets", min = 1, max = 16, default = 6, binding = "misc.fakeLagChoke" },
        { type = "slider", label = "view fov", description = "override camera field of view", min = 60, max = 120, default = 85, binding = "misc.fov" },
        { type = "toggle", label = "hit logs", description = "print resolver decisions to console", default = true, binding = "misc.hitLogs" },
        { type = "toggle", label = "auto peek", description = "hold C to mark position and snap back on release", binding = "misc.autoPeek" },
        { type = "toggle", label = "auto bhop", description = "spam jumps automatically while space is held", binding = "misc.bhop" },
        { type = "toggle", label = "edge jump", description = "auto hop the frame you leave ledges", binding = "misc.edgeJump" },
        { type = "toggle", label = "air stuck", description = "hold V to freeze mid air until released", binding = "misc.airStuck" },
        { type = "toggle", label = "noclip", description = "walk through geometry while active", binding = "misc.noclip" },
        { type = "toggle", label = "speed boost", description = "override walk speed with the value below", binding = "misc.speedEnabled" },
        { type = "slider", label = "speed amount", description = "target walk speed applied when boost is active", min = 16, max = 34, default = 22, step = 0.5, decimals = 1, binding = "misc.speedAmount" },
    },
    config = {
        { type = "button", label = "save", description = "write current setup to slot 1", onClick = function()
            print("[fatality] configuration saved -> slot 1")
        end },
        { type = "button", label = "load", description = "load slot 1 configuration", onClick = function()
            print("[fatality] configuration loaded <- slot 1")
        end },
        { type = "toggle", label = "cloud sync", description = "sync configs to fatality.win profile", default = true, binding = "config.cloud" },
    },
}

local tabButtons = {}
local activeTab = 1

local indicator = Instance.new("Frame")
indicator.Name = "Indicator"
indicator.AnchorPoint = Vector2.new(0, 1)
indicator.Size = UDim2.new(0, 0, 0, 2)
indicator.Position = UDim2.new(0, 0, 1, 0)
indicator.BackgroundColor3 = style.accent
indicator.BorderSizePixel = 0
indicator.Parent = tabBar
indicator.Visible = false

local container = Instance.new("Frame")
container.Name = "Content"
container.BackgroundColor3 = style.panelContrast
container.BackgroundTransparency = containerHiddenTransparency
container.Position = UDim2.new(0, 20, 0, 120)
container.Size = UDim2.new(1, -40, 1, -140)
container.Parent = mainFrame
container.ClipsDescendants = true

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = container

local containerStroke = Instance.new("UIStroke")
containerStroke.Color = style.stroke
containerStroke.Thickness = 1.25
containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
containerStroke.Parent = container
containerStroke.Transparency = 1

local containerGradient = Instance.new("UIGradient")
containerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, style.panelContrast),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(36, 18, 48)),
    ColorSequenceKeypoint.new(1, style.panelContrast)
})
containerGradient.Rotation = 90
containerGradient.Parent = container

local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingTop = UDim.new(0, 24)
containerPadding.PaddingBottom = UDim.new(0, 24)
containerPadding.PaddingLeft = UDim.new(0, 24)
containerPadding.PaddingRight = UDim.new(0, 24)
containerPadding.Parent = container

local controlTweens = {}

local function registerHover(frame, stroke)
    frame.MouseEnter:Connect(function()
        if controlTweens[frame] then
            controlTweens[frame]:Cancel()
        end
        local tween = TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = style.buttonHover
        })
        controlTweens[frame] = tween
        tween.Completed:Once(function()
            if controlTweens[frame] == tween then
                controlTweens[frame] = nil
            end
        end)
        tween:Play()
        TweenService:Create(stroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = style.accent
        }):Play()
    end)

    frame.MouseLeave:Connect(function()
        if controlTweens[frame] then
            controlTweens[frame]:Cancel()
        end
        local tween = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = style.buttonIdle
        })
        controlTweens[frame] = tween
        tween.Completed:Once(function()
            if controlTweens[frame] == tween then
                controlTweens[frame] = nil
            end
        end)
        tween:Play()
        TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = style.stroke
        }):Play()
    end)
end

local function createToggleControl(containerParent, def)
    local frame = Instance.new("Frame")
    frame.Name = "Toggle"
    frame.BackgroundColor3 = style.buttonIdle
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.Active = true
    frame.Parent = containerParent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = style.stroke
    stroke.Thickness = 1
    stroke.Parent = frame

    registerHover(frame, stroke)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.ZIndex = 2
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = style.textBright
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.upper(def.label)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.6, -16, 0, 18)
    label.Parent = frame

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.ZIndex = 2
    description.Font = Enum.Font.Gotham
    description.TextColor3 = style.textDim
    description.TextSize = 13
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextWrapped = true
    description.Text = def.description or ""
    description.Position = UDim2.new(0, 16, 0, 30)
    description.Size = UDim2.new(0.6, -16, 0, 24)
    description.Parent = frame

    local toggleButton = Instance.new("TextButton")
    toggleButton.AutoButtonColor = false
    toggleButton.BackgroundColor3 = style.buttonIdle
    toggleButton.BorderSizePixel = 0
    toggleButton.Size = UDim2.fromOffset(84, 30)
    toggleButton.Position = UDim2.new(1, -112, 0, 18)
    toggleButton.Text = ""
    toggleButton.ZIndex = 3
    toggleButton.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = style.stroke
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggleButton

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 4, 0.5, 0)
    knob.Size = UDim2.fromOffset(24, 20)
    knob.BackgroundColor3 = style.accent
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = toggleButton

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 10)
    knobCorner.Parent = knob

    local knobGradient = Instance.new("UIGradient")
    knobGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, style.accentAlt),
        ColorSequenceKeypoint.new(1, style.accent)
    })
    knobGradient.Rotation = 45
    knobGradient.Parent = knob

    local stateIndicator = Instance.new("TextLabel")
    stateIndicator.BackgroundTransparency = 1
    stateIndicator.Font = Enum.Font.GothamSemibold
    stateIndicator.TextColor3 = style.textBright
    stateIndicator.TextSize = 14
    stateIndicator.TextXAlignment = Enum.TextXAlignment.Left
    stateIndicator.Text = "ON"
    stateIndicator.Position = UDim2.new(1, -100, 0, 22)
    stateIndicator.Size = UDim2.fromOffset(70, 18)
    stateIndicator.ZIndex = 2
    stateIndicator.Parent = frame

    local state = def.default == true

    local function updateToggleVisual(playTween)
        stateIndicator.Text = state and "ON" or "OFF"
        local goalColor = state and style.accentSoft or style.buttonIdle
        local knobGoal = state and UDim2.new(1, -28, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
        stateIndicator.TextColor3 = state and style.accent or style.textDim
        toggleStroke.Color = state and style.accent or style.stroke
        if playTween then
            TweenService:Create(toggleButton, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = goalColor
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = knobGoal
            }):Play()
        else
            toggleButton.BackgroundColor3 = goalColor
            knob.Position = knobGoal
        end
    end

    local function applyState(newState, playTween, userTriggered)
        state = newState and true or false
        updateToggleVisual(playTween)
        if def.onChanged then
            def.onChanged(state, userTriggered)
        end
        if def.binding then
            setFeatureValue(def.binding, state)
        end
    end

    applyState(state, false, false)

    toggleButton.MouseButton1Click:Connect(function()
        applyState(not state, true, true)
    end)

    local clickOverlay = Instance.new("TextButton")
    clickOverlay.Name = "ClickOverlay"
    clickOverlay.AutoButtonColor = false
    clickOverlay.BackgroundTransparency = 1
    clickOverlay.Size = UDim2.new(1, -112, 1, 0)
    clickOverlay.Text = ""
    clickOverlay.ZIndex = 1
    clickOverlay.Parent = frame
    clickOverlay.MouseButton1Click:Connect(function()
        applyState(not state, true, true)
    end)

    return frame
end

local function createButtonControl(containerParent, def)
    local frame = Instance.new("Frame")
    frame.Name = "Action"
    frame.BackgroundColor3 = style.buttonIdle
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.Active = true
    frame.Parent = containerParent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = style.stroke
    stroke.Thickness = 1
    stroke.Parent = frame

    registerHover(frame, stroke)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = style.textBright
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.upper(def.label)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.6, -16, 0, 18)
    label.Parent = frame

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextColor3 = style.textDim
    description.TextSize = 13
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Text = def.description or ""
    description.Position = UDim2.new(0, 16, 0, 30)
    description.Size = UDim2.new(0.6, -16, 0, 24)
    description.Parent = frame

    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.AutoButtonColor = false
    actionButton.BackgroundColor3 = style.accentSoft
    actionButton.Size = UDim2.fromOffset(110, 36)
    actionButton.Position = UDim2.new(1, -126, 0, 14)
    actionButton.Text = "EXECUTE"
    actionButton.Font = Enum.Font.GothamSemibold
    actionButton.TextSize = 14
    actionButton.TextColor3 = style.textBright
    actionButton.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = actionButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = style.stroke
    buttonStroke.Thickness = 1
    buttonStroke.Parent = actionButton

    actionButton.MouseEnter:Connect(function()
        TweenService:Create(actionButton, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = style.accent
        }):Play()
    end)

    actionButton.MouseLeave:Connect(function()
        TweenService:Create(actionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = style.accentSoft
        }):Play()
    end)

    actionButton.MouseButton1Click:Connect(function()
        TweenService:Create(actionButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(102, 32)
        }):Play()
        task.delay(0.12, function()
            if actionButton then
                TweenService:Create(actionButton, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(110, 36)
                }):Play()
            end
        end)
        if def.onClick then
            def.onClick()
        else
            print("[fatality] action executed:", def.label)
        end
    end)

    return frame
end

local function createCycleControl(containerParent, def)
    local frame = Instance.new("Frame")
    frame.Name = "Cycle"
    frame.BackgroundColor3 = style.buttonIdle
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.Active = true
    frame.Parent = containerParent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = style.stroke
    stroke.Thickness = 1
    stroke.Parent = frame

    registerHover(frame, stroke)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = style.textBright
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.upper(def.label)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.6, -16, 0, 18)
    label.Parent = frame

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextColor3 = style.textDim
    description.TextSize = 13
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Text = def.description or ""
    description.Position = UDim2.new(0, 16, 0, 30)
    description.Size = UDim2.new(0.6, -16, 0, 24)
    description.Parent = frame

    local cycleButton = Instance.new("TextButton")
    cycleButton.AutoButtonColor = false
    cycleButton.BackgroundColor3 = style.buttonActive
    cycleButton.Position = UDim2.new(1, -160, 0, 18)
    cycleButton.Size = UDim2.fromOffset(140, 30)
    cycleButton.Text = ""
    cycleButton.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = cycleButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = style.stroke
    buttonStroke.Thickness = 1
    buttonStroke.Parent = cycleButton

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = style.textBright
    valueLabel.Text = ""
    valueLabel.Size = UDim2.fromScale(1, 1)
    valueLabel.Parent = cycleButton

    local index = def.defaultIndex or 1
    local options = def.options or {"n/a"}

    local function applyOption(playTween, notify)
        if index < 1 or index > #options then
            index = 1
        end
        valueLabel.Text = string.upper(options[index])
        if playTween then
            TweenService:Create(cycleButton, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = (index % 2 == 0) and style.buttonActive or style.buttonHover
            }):Play()
        else
            cycleButton.BackgroundColor3 = (index % 2 == 0) and style.buttonActive or style.buttonHover
        end
        if def.binding then
            setFeatureValue(def.binding, options[index])
        end
        if def.onChanged then
            def.onChanged(options[index], notify)
        end
    end

    applyOption(false, false)

    cycleButton.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then
            index = 1
        end
        applyOption(true, true)
    end)

    return frame
end

local function createSliderControl(containerParent, def)
    local frame = Instance.new("Frame")
    frame.Name = "Slider"
    frame.BackgroundColor3 = style.buttonIdle
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 0, 78)
    frame.Active = true
    frame.Parent = containerParent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = style.stroke
    stroke.Thickness = 1
    stroke.Parent = frame

    registerHover(frame, stroke)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = style.textBright
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.upper(def.label)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.6, -16, 0, 18)
    label.Parent = frame

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextColor3 = style.textDim
    description.TextSize = 13
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Text = def.description or ""
    description.Position = UDim2.new(0, 16, 0, 30)
    description.Size = UDim2.new(0.6, -16, 0, 24)
    description.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 14
    valueLabel.TextColor3 = style.textBright
    valueLabel.Text = ""
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Position = UDim2.new(1, -100, 0, 20)
    valueLabel.Size = UDim2.fromOffset(80, 20)
    valueLabel.Parent = frame

    local sliderArea = Instance.new("Frame")
    sliderArea.BackgroundTransparency = 1
    sliderArea.Size = UDim2.new(1, -32, 0, 18)
    sliderArea.Position = UDim2.new(0, 16, 0, 56)
    sliderArea.Parent = frame

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = style.buttonHover
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0.5, -2)
    bar.Parent = sliderArea

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = style.accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, style.accentAlt),
        ColorSequenceKeypoint.new(1, style.accent)
    })
    fillGradient.Rotation = 0
    fillGradient.Parent = fill

    local knob = Instance.new("ImageLabel")
    knob.BackgroundTransparency = 1
    knob.Image = "rbxassetid://11297479264"
    knob.ImageColor3 = style.accent
    knob.Size = UDim2.fromOffset(18, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Parent = sliderArea

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = style.textBright
    knobStroke.Thickness = 1
    knobStroke.Parent = knob

    local minValue = def.min or 0
    local maxValue = def.max or 100
    if maxValue == minValue then
        maxValue = minValue + 1
    end

    local range = maxValue - minValue
    local step = def.step or 1
    if step <= 0 then
        step = 1
    end

    local decimals = def.decimals or 0

    local function snapValue(value)
        local scaled = (value - minValue) / step
        local snapped = (math.floor(scaled + 0.5) * step) + minValue
        return math.clamp(snapped, minValue, maxValue)
    end

    local function formatValue(value)
        if def.format then
            local ok, formatted = pcall(def.format, value)
            if ok and formatted ~= nil then
                return tostring(formatted)
            end
        end
        if decimals and decimals > 0 then
            return string.format("%." .. tostring(decimals) .. "f", value)
        end
        return tostring(math.floor(value + 0.5))
    end

    local currentValue = snapValue(def.default or minValue)

    local function updateVisual(playTween, notify)
        local alpha = (currentValue - minValue) / range
        alpha = math.clamp(alpha, 0, 1)
        local knobGoal = UDim2.new(alpha, 0, 0.5, 0)
        if playTween then
            TweenService:Create(fill, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(alpha, 0, 1, 0)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = knobGoal
            }):Play()
        else
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = knobGoal
        end
        valueLabel.Text = formatValue(currentValue)
        if def.binding then
            setFeatureValue(def.binding, currentValue)
        end
        if def.onChanged then
            def.onChanged(currentValue, notify)
        end
    end

    updateVisual(false, false)

    local dragging = false

    local function setFromInput(x)
        local absoluteLeft = bar.AbsolutePosition.X
        local width = bar.AbsoluteSize.X
        local position = math.clamp((x - absoluteLeft) / width, 0, 1)
        local raw = minValue + range * position
        currentValue = snapValue(raw)
        updateVisual(false, true)
    end

    sliderArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromInput(input.Position.X)
        end
    end)

    sliderArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            setFromInput(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return frame
end

local function createColorControl(containerParent, def)
    local frame = Instance.new("Frame")
    frame.Name = "Color"
    frame.BackgroundColor3 = style.buttonIdle
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.new(1, 0, 0, 150)
    frame.Active = true
    frame.Parent = containerParent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = style.stroke
    stroke.Thickness = 1
    stroke.Parent = frame

    registerHover(frame, stroke)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = style.textBright
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.upper(def.label)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.6, -16, 0, 18)
    label.Parent = frame

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.TextColor3 = style.textDim
    description.TextSize = 13
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Text = def.description or ""
    description.Position = UDim2.new(0, 16, 0, 32)
    description.Size = UDim2.new(0.6, -16, 0, 32)
    description.Parent = frame

    local preview = Instance.new("Frame")
    preview.Name = "Preview"
    preview.BackgroundColor3 = def.default or style.accent
    preview.BorderSizePixel = 0
    preview.Position = UDim2.new(1, -120, 0, 14)
    preview.Size = UDim2.fromOffset(100, 44)
    preview.Parent = frame

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 12)
    previewCorner.Parent = preview

    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = style.stroke
    previewStroke.Thickness = 1
    previewStroke.Parent = preview

    local previewLabel = Instance.new("TextLabel")
    previewLabel.BackgroundTransparency = 1
    previewLabel.Font = Enum.Font.GothamSemibold
    previewLabel.TextColor3 = style.textBright
    previewLabel.TextSize = 12
    previewLabel.TextWrapped = true
    previewLabel.TextXAlignment = Enum.TextXAlignment.Center
    previewLabel.TextYAlignment = Enum.TextYAlignment.Center
    previewLabel.Size = UDim2.fromScale(1, 1)
    previewLabel.Parent = preview

    local channelContainer = Instance.new("Frame")
    channelContainer.BackgroundTransparency = 1
    channelContainer.Position = UDim2.new(0, 16, 0, 68)
    channelContainer.Size = UDim2.new(1, -32, 0, 72)
    channelContainer.Parent = frame

    local channelLayout = Instance.new("UIListLayout")
    channelLayout.FillDirection = Enum.FillDirection.Vertical
    channelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    channelLayout.Padding = UDim.new(0, 6)
    channelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    channelLayout.Parent = channelContainer

    local defaultColor = def.default or style.accent
    local values = {
        R = math.clamp(math.floor(defaultColor.R * 255 + 0.5), 0, 255),
        G = math.clamp(math.floor(defaultColor.G * 255 + 0.5), 0, 255),
        B = math.clamp(math.floor(defaultColor.B * 255 + 0.5), 0, 255),
    }

    local function updatePreview(notify)
        local color = Color3.fromRGB(values.R, values.G, values.B)
        preview.BackgroundColor3 = color
        previewLabel.Text = string.format("#%02X%02X%02X", values.R, values.G, values.B)
        if def.binding then
            setFeatureValue(def.binding, color)
        end
        if def.onChanged then
            def.onChanged(color, notify)
        end
    end

    local channels = {
        { key = "R", name = "RED", tint = Color3.fromRGB(255, 90, 140) },
        { key = "G", name = "GREEN", tint = Color3.fromRGB(140, 255, 160) },
        { key = "B", name = "BLUE", tint = Color3.fromRGB(150, 180, 255) },
    }

    for order, info in ipairs(channels) do
        local row = Instance.new("Frame")
        row.Name = info.key .. "Row"
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 22)
        row.LayoutOrder = order
        row.Parent = channelContainer

        local rowLabel = Instance.new("TextLabel")
        rowLabel.BackgroundTransparency = 1
        rowLabel.Font = Enum.Font.GothamSemibold
        rowLabel.TextSize = 13
        rowLabel.TextColor3 = style.textDim
        rowLabel.TextXAlignment = Enum.TextXAlignment.Left
        rowLabel.Text = info.name
        rowLabel.Size = UDim2.new(0, 48, 1, 0)
        rowLabel.Parent = row

        local sliderBar = Instance.new("Frame")
        sliderBar.BackgroundColor3 = style.buttonHover
        sliderBar.BorderSizePixel = 0
        sliderBar.Position = UDim2.new(0, 56, 0.5, -3)
        sliderBar.Size = UDim2.new(1, -116, 0, 6)
        sliderBar.Parent = row

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = sliderBar

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = info.tint
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(values[info.key] / 255, 0, 1, 0)
        fill.Parent = sliderBar

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local knob = Instance.new("Frame")
        knob.BackgroundColor3 = info.tint
        knob.BorderSizePixel = 0
        knob.Size = UDim2.fromOffset(12, 12)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(values[info.key] / 255, 0, 0.5, 0)
        knob.Parent = row

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local knobStroke = Instance.new("UIStroke")
        knobStroke.Color = style.textBright
        knobStroke.Thickness = 1
        knobStroke.Parent = knob

        local valueLabel = Instance.new("TextLabel")
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamSemibold
        valueLabel.TextSize = 12
        valueLabel.TextColor3 = style.textBright
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Position = UDim2.new(1, -40, 0, 0)
        valueLabel.Size = UDim2.new(0, 40, 1, 0)
        valueLabel.Text = tostring(values[info.key])
        valueLabel.Parent = row

        local dragging = false

        local function updateChannel(newValue, notify)
            newValue = math.clamp(newValue, 0, 255)
            values[info.key] = newValue
            local alpha = newValue / 255
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = tostring(newValue)
            updatePreview(notify)
        end

        local function setFromInput(x)
            local left = sliderBar.AbsolutePosition.X
            local width = sliderBar.AbsoluteSize.X
            local alpha = math.clamp((x - left) / width, 0, 1)
            updateChannel(math.floor(alpha * 255 + 0.5), true)
        end

        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setFromInput(input.Position.X)
            end
        end)

        sliderBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                setFromInput(input.Position.X)
            end
        end)

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        knob.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                setFromInput(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    updatePreview(false)

    return frame
end

local controlFactory = {
    toggle = createToggleControl,
    button = createButtonControl,
    cycle = createCycleControl,
    slider = createSliderControl,
    color = createColorControl,
}

-- Feature systems ------------------------------------------------------------

math.randomseed(tick())

local defaultFov = Camera and Camera.FieldOfView or 70

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
    if Camera then
        defaultFov = Camera.FieldOfView
    end
end)

local function isEnemy(player)
    if player == LocalPlayer then
        return false
    end
    if LocalPlayer and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function getAliveCharacter(player)
    local character = player.Character
    if not character then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil
    end
    return character, humanoid
end

-- Silent aim -----------------------------------------------------------------

local VirtualUser = game:GetService("VirtualUser")

local targetInfo = {
    part = nil,
    position = nil,
    player = nil,
}

local silentAimEnabled = false
local silentAimFov = 12
local assistStrength = 0
local triggerBotEnabled = false
local hitChanceThreshold = 95
local hitLogsEnabled = true
local silentAimConnection
local lastLockPlayer
local lastTriggerTime = 0
local silentAimHooked = false

local function computeMouseOverride(key)
    if not (silentAimEnabled and targetInfo.part and targetInfo.position) then
        return nil
    end
    if key == "Hit" then
        return CFrame.new(targetInfo.position)
    elseif key == "Target" then
        return targetInfo.part
    elseif key == "UnitRay" then
        local origin = Camera and Camera.CFrame.Position or Vector3.new()
        local direction = targetInfo.position - origin
        return Ray.new(origin, direction.Unit * 999)
    elseif key == "X" or key == "Y" then
        if Camera then
            local viewportPoint, onScreen = Camera:WorldToViewportPoint(targetInfo.position)
            if onScreen then
                if key == "X" then
                    return viewportPoint.X
                else
                    return viewportPoint.Y
                end
            end
        end
    end
    return nil
end

local function simulateClick(positionOverride, cameraCFrame)
    local viewportPosition = positionOverride
    local cameraFrame = cameraCFrame
    if Camera then
        viewportPosition = viewportPosition or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        cameraFrame = cameraFrame or Camera.CFrame
    else
        viewportPosition = viewportPosition or Vector2.new()
        cameraFrame = cameraFrame or CFrame.new()
    end

    if mouse1press and mouse1release then
        local pressed = pcall(mouse1press)
        task.delay(0.02, function()
            pcall(mouse1release)
        end)
        return pressed
    end

    if mouse1click then
        local success = pcall(mouse1click)
        if success then
            return true
        end
    end

    if VirtualUser then
        local ok = pcall(function()
            VirtualUser:ClickButton1(viewportPosition, cameraFrame)
        end)
        if ok then
            return true
        end
    end

    return false
end

local function hookMouse()
    if silentAimHooked or not mouse then
        return
    end
    if hookmetamethod then
        local original
        local ok = pcall(function()
            original = hookmetamethod(mouse, "__index", function(self, key)
                local override = computeMouseOverride(key)
                if override ~= nil then
                    return override
                end
                return original(self, key)
            end)
        end)
        if ok and original then
            silentAimHooked = true
            return
        end
    end

    if getrawmetatable then
        local success, mt = pcall(getrawmetatable, mouse)
        if not success or not mt then
            return
        end
        local originalIndex = mt.__index
        if type(originalIndex) ~= "function" then
            return
        end
        local successReadonly = true
        if setreadonly then
            successReadonly = pcall(setreadonly, mt, false)
        end
        if not successReadonly then
            return
        end
        local newIndex = function(self, key)
            if self == mouse then
                local override = computeMouseOverride(key)
                if override ~= nil then
                    return override
                end
            end
            return originalIndex(self, key)
        end
        if newcclosure then
            newIndex = newcclosure(newIndex)
        end
        mt.__index = newIndex
        if setreadonly then
            pcall(setreadonly, mt, true)
        end
        silentAimHooked = true
    end
end

local function resolveHitChance(mode)
    if mode == "low" then
        return 45
    elseif mode == "medium" then
        return 70
    elseif mode == "high" then
        return 95
    end
    if typeof(mode) == "number" then
        return math.clamp(mode, 1, 100)
    end
    return 95
end

local function findSilentAimTarget()
    if not Camera then
        return nil
    end
    local bestPart
    local bestPosition
    local bestPlayer
    local bestMagnitude = math.huge
    local origin = Camera.CFrame.Position
    local forward = Camera.CFrame.LookVector
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local character, humanoid = getAliveCharacter(player)
            if character and humanoid then
                local part = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
                if part then
                    local worldPosition = part.Position
                    local direction = (worldPosition - origin).Unit
                    local angle = math.deg(math.acos(math.clamp(forward:Dot(direction), -1, 1)))
                    if angle <= silentAimFov then
                        local viewportPoint, onScreen = Camera:WorldToViewportPoint(worldPosition)
                        if onScreen then
                            local screenVector = Vector2.new(viewportPoint.X, viewportPoint.Y)
                            local delta = (screenVector - mouseLocation).Magnitude
                            if delta < bestMagnitude then
                                bestMagnitude = delta
                                bestPart = part
                                bestPosition = worldPosition
                                bestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart, bestPosition, bestPlayer
end

local function updateSilentAim(dt)
    if not silentAimEnabled then
        targetInfo.part = nil
        targetInfo.position = nil
        targetInfo.player = nil
        return
    end

    local part, position, player = findSilentAimTarget()
    if part and hitChanceThreshold < 100 then
        if math.random(1, 100) > hitChanceThreshold then
            part = nil
            position = nil
            player = nil
        end
    end

    targetInfo.part = part
    targetInfo.position = position
    targetInfo.player = player

    if part and position and assistStrength > 0 and Camera then
        local desired = CFrame.new(Camera.CFrame.Position, position)
        local lerpAlpha = math.clamp(assistStrength * dt, 0, 1)
        Camera.CFrame = Camera.CFrame:Lerp(desired, lerpAlpha)
    end

    if hitLogsEnabled then
        if player and player ~= lastLockPlayer then
            lastLockPlayer = player
            print(string.format("[fatality] resolver locked onto %s", player.DisplayName or player.Name))
        elseif not player then
            lastLockPlayer = nil
        end
    end

    if triggerBotEnabled and part and position and Camera then
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local now = tick()
            if now - lastTriggerTime > 0.14 then
                lastTriggerTime = now
                simulateClick(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2), Camera.CFrame)
                if hitLogsEnabled and player then
                    print(string.format("[fatality] trigger fired at %s", player.DisplayName or player.Name))
                end
            end
        end
    end
end

registerBinding("rage.silentAim", function(value)
    silentAimEnabled = value and true or false
    if silentAimEnabled then
        if not silentAimConnection then
            silentAimConnection = RunService.RenderStepped:Connect(updateSilentAim)
        end
        hookMouse()
    else
        if silentAimConnection then
            silentAimConnection:Disconnect()
            silentAimConnection = nil
        end
        targetInfo.part = nil
        targetInfo.position = nil
        targetInfo.player = nil
    end
end)

registerBinding("rage.silentAimFov", function(value)
    silentAimFov = math.clamp(value or 12, 1, 60)
end)

registerBinding("legit.assistStrength", function(value)
    assistStrength = math.clamp((value or 0) / 100, 0, 1)
end)

registerBinding("legit.triggerBot", function(value)
    triggerBotEnabled = value and true or false
end)

registerBinding("legit.hitChance", function(mode)
    hitChanceThreshold = resolveHitChance(mode)
end)

registerBinding("misc.hitLogs", function(value)
    hitLogsEnabled = value ~= false
end)

-- Anti-aim -------------------------------------------------------------------

local antiAimEnabled = true
local antiAimMode = "spin"
local antiAimYaw = 120
local antiAimPitch = 0
local antiAimJitter = 35
local antiAimConnection
local antiAimSpinClock = 0
local antiAimJitterSign = 1

local function applyAntiAim(dt)
    if not antiAimEnabled then
        return
    end
    local character, humanoid = getAliveCharacter(LocalPlayer)
    if not character then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    if humanoid then
        humanoid.AutoRotate = false
    end

    local yawDegrees = antiAimYaw
    dt = dt or 0
    if antiAimMode == "spin" then
        antiAimSpinClock = (antiAimSpinClock + dt * 360) % 360
        yawDegrees = antiAimSpinClock + antiAimYaw
    elseif antiAimMode == "jitter" then
        antiAimJitterSign = -antiAimJitterSign
        yawDegrees = antiAimYaw + antiAimJitterSign * math.random(0, antiAimJitter)
    end

    local yaw = math.rad(yawDegrees)
    local pitch = math.rad(math.clamp(antiAimPitch, -89, 89))
    local position = root.Position
    root.CFrame = CFrame.new(position) * CFrame.Angles(pitch, yaw, 0)
    root.AssemblyAngularVelocity = Vector3.new()
end

local function disableAntiAim()
    local character, humanoid = getAliveCharacter(LocalPlayer)
    if humanoid then
        humanoid.AutoRotate = true
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        local lookVector = Camera and Camera.CFrame.LookVector or root.CFrame.LookVector
        local target = CFrame.lookAt(root.Position, root.Position + lookVector, Vector3.new(0, 1, 0))
        root.CFrame = target
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

registerBinding("rage.antiAim", function(value)
    antiAimEnabled = value and true or false
    if antiAimEnabled then
        if not antiAimConnection then
            antiAimConnection = RunService.Heartbeat:Connect(applyAntiAim)
        end
        applyAntiAim(0)
    else
        if antiAimConnection then
            antiAimConnection:Disconnect()
            antiAimConnection = nil
        end
        disableAntiAim()
        antiAimSpinClock = 0
        antiAimJitterSign = 1
    end
end)

registerBinding("rage.antiAimMode", function(mode)
    antiAimMode = tostring(mode or "spin")
    antiAimSpinClock = 0
    antiAimJitterSign = 1
end)

registerBinding("rage.antiAimYaw", function(value)
    antiAimYaw = math.clamp(value or 0, -180, 180)
end)

registerBinding("rage.antiAimPitch", function(value)
    antiAimPitch = math.clamp(value or 0, -89, 89)
end)

registerBinding("rage.antiAimJitter", function(value)
    antiAimJitter = math.clamp(value or 0, 0, 90)
end)

LocalPlayer.CharacterAdded:Connect(function()
    if antiAimEnabled then
        task.delay(0.2, applyAntiAim)
    end
    if speedEnabled then
        storedWalkSpeed = nil
        task.defer(updateMovementFeatures)
    end
    if noclipEnabled then
        task.defer(updateMovementFeatures)
    end
end)

-- Desync ---------------------------------------------------------------------

local desyncEnabled = true
local desyncDistance = 8
local desyncRate = 12
local desyncClock = 0
local desyncConnection

local function updateDesync(dt)
    if not desyncEnabled then
        return
    end
    local character = LocalPlayer.Character
    if not character then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    desyncClock = desyncClock + dt * desyncRate
    local sway = Vector3.new(
        math.sin(desyncClock) * desyncDistance * 0.1,
        math.cos(desyncClock * 0.5) * desyncDistance * 0.05,
        math.cos(desyncClock) * desyncDistance * 0.12
    )
    local original = root.CFrame
    root.CFrame = original + sway
    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + sway * 18
    task.defer(function()
        if desyncEnabled and root.Parent then
            root.CFrame = original
        end
    end)
end

registerBinding("rage.desync", function(value)
    desyncEnabled = value and true or false
    if desyncEnabled then
        if not desyncConnection then
            desyncConnection = RunService.Heartbeat:Connect(updateDesync)
        end
    else
        if desyncConnection then
            desyncConnection:Disconnect()
            desyncConnection = nil
        end
    end
end)

registerBinding("rage.desyncDistance", function(value)
    desyncDistance = math.clamp(value or 0, 0, 25)
end)

registerBinding("rage.desyncRate", function(value)
    desyncRate = math.clamp(value or 0, 1, 60)
end)

-- Rage extras -----------------------------------------------------------------

local doubleTapEnabled = false
local doubleTapConnection

local function handleDoubleTapInput(input, gameProcessed)
    if gameProcessed or not doubleTapEnabled then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not Camera then
            return
        end
        local viewport = Camera.ViewportSize
        local clickPosition = Vector2.new(viewport.X / 2, viewport.Y / 2)
        task.delay(0.045, function()
            if doubleTapEnabled and Camera then
                simulateClick(clickPosition, Camera.CFrame)
            end
        end)
    end
end

registerBinding("rage.doubleTap", function(value)
    doubleTapEnabled = value and true or false
    if doubleTapEnabled then
        if not doubleTapConnection then
            doubleTapConnection = UserInputService.InputBegan:Connect(handleDoubleTapInput)
        end
    else
        if doubleTapConnection then
            doubleTapConnection:Disconnect()
            doubleTapConnection = nil
        end
    end
end)

-- Visuals --------------------------------------------------------------------

local playerVisuals = {}
local visualsConnection
local espEnabled = true
local chamsEnabled = true
local espColor = Color3.fromRGB(255, 90, 220)
local espOutlineColor = Color3.fromRGB(48, 0, 82)
local chamsFillColor = Color3.fromRGB(255, 120, 255)
local chamsOutlineColor = Color3.fromRGB(90, 10, 130)
local chamsFillTransparency = 0.35
local chamsOutlineTransparency = 0

local function destroyVisualEntry(player)
    local entry = playerVisuals[player]
    if not entry then
        return
    end
    if entry.esp then
        entry.esp:Destroy()
    end
    if entry.highlight then
        entry.highlight:Destroy()
    end
    if entry.connections then
        for _, conn in ipairs(entry.connections) do
            conn:Disconnect()
        end
    end
    playerVisuals[player] = nil
end

local function updateEspColors(entry)
    if entry and entry.frame then
        entry.stroke.Color = espOutlineColor
        entry.accent.BackgroundColor3 = espColor
        entry.name.TextColor3 = espColor
        if entry.accentGlow then
            entry.accentGlow.ImageColor3 = espColor
        end
        if entry.healthFill then
            entry.healthFill.BackgroundColor3 = espColor
        end
        if entry.healthGradient then
            entry.healthGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, espColor),
            })
        end
    end
end

local function updateHighlightColors(entry)
    if entry and entry.highlight then
        entry.highlight.FillColor = chamsFillColor
        entry.highlight.OutlineColor = chamsOutlineColor
        entry.highlight.FillTransparency = math.clamp(chamsFillTransparency, 0, 1)
        entry.highlight.OutlineTransparency = math.clamp(chamsOutlineTransparency, 0, 1)
    end
end

local function ensureEsp(entry, player)
    if not espEnabled then
        if entry.esp then
            entry.esp.Enabled = false
        end
        return
    end
    local character = player.Character
    if not character then
        return
    end
    local head = character:FindFirstChild("Head")
    if not head then
        return
    end
    local billboard = entry.esp
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "FatalityESP"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(220, 72)
        billboard.StudsOffset = Vector3.new(0, 2.4, 0)
        billboard.MaxDistance = 3000
        billboard.Parent = head
        billboard.Adornee = head

        local container = Instance.new("Frame")
        container.BackgroundColor3 = Color3.fromRGB(8, 6, 16)
        container.BackgroundTransparency = 0.12
        container.Size = UDim2.fromScale(1, 1)
        container.ZIndex = 2
        container.Parent = billboard

        local shadow = Instance.new("ImageLabel")
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://6014261993"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.75
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(24, 24, 276, 276)
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.ZIndex = 1
        shadow.Parent = billboard

        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 8)
        containerCorner.Parent = container

        local containerGradient = Instance.new("UIGradient")
        containerGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 12, 36)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 6, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 12, 36)),
        })
        containerGradient.Rotation = 90
        containerGradient.Parent = container

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = container

        local accent = Instance.new("Frame")
        accent.BackgroundColor3 = espColor
        accent.BorderSizePixel = 0
        accent.Size = UDim2.new(1, 0, 0, 2)
        accent.Parent = container

        local accentGlow = Instance.new("ImageLabel")
        accentGlow.BackgroundTransparency = 1
        accentGlow.Image = "rbxassetid://1217159491"
        accentGlow.ImageColor3 = espColor
        accentGlow.ImageTransparency = 0.3
        accentGlow.Size = UDim2.new(1, 0, 0, 40)
        accentGlow.Position = UDim2.new(0, 0, 0, -30)
        accentGlow.ZIndex = 2
        accentGlow.Parent = container

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 16
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextColor3 = espColor
        nameLabel.Position = UDim2.new(0, 10, 0, 8)
        nameLabel.Size = UDim2.new(1, -20, 0, 20)
        nameLabel.Text = player.DisplayName or player.Name
        nameLabel.ZIndex = 3
        nameLabel.Parent = container

        local infoLabel = Instance.new("TextLabel")
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 14
        infoLabel.TextColor3 = style.textBright
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.Position = UDim2.new(0, 10, 0, 34)
        infoLabel.Size = UDim2.new(1, -20, 0, 18)
        infoLabel.Text = ""
        infoLabel.ZIndex = 3
        infoLabel.Parent = container

        local healthBackground = Instance.new("Frame")
        healthBackground.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
        healthBackground.BackgroundTransparency = 0.35
        healthBackground.BorderSizePixel = 0
        healthBackground.Position = UDim2.new(0, 10, 1, -18)
        healthBackground.Size = UDim2.new(1, -20, 0, 6)
        healthBackground.ZIndex = 3
        healthBackground.Parent = container

        local healthCorner = Instance.new("UICorner")
        healthCorner.CornerRadius = UDim.new(0, 3)
        healthCorner.Parent = healthBackground

        local healthFill = Instance.new("Frame")
        healthFill.BackgroundColor3 = espColor
        healthFill.BorderSizePixel = 0
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.ZIndex = 4
        healthFill.Parent = healthBackground

        local healthFillCorner = Instance.new("UICorner")
        healthFillCorner.CornerRadius = UDim.new(0, 3)
        healthFillCorner.Parent = healthFill

        local healthGradient = Instance.new("UIGradient")
        healthGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, espColor)
        })
        healthGradient.Parent = healthFill

        entry.esp = billboard
        entry.shadow = shadow
        entry.frame = container
        entry.stroke = stroke
        entry.accent = accent
        entry.accentGlow = accentGlow
        entry.name = nameLabel
        entry.info = infoLabel
        entry.healthBackground = healthBackground
        entry.healthFill = healthFill
        entry.healthGradient = healthGradient
    else
        if billboard.Parent ~= head then
            billboard.Parent = head
        end
        billboard.Adornee = head
    end
    billboard.Enabled = true
    updateEspColors(entry)
end

local function ensureHighlight(entry, player)
    if not chamsEnabled then
        if entry.highlight then
            entry.highlight.Enabled = false
        end
        return
    end
    local character = player.Character
    if not character then
        return
    end
    local highlight = entry.highlight
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "FatalityHighlight"
        highlight.FillTransparency = math.clamp(chamsFillTransparency, 0, 1)
        highlight.OutlineTransparency = math.clamp(chamsOutlineTransparency, 0, 1)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = parentGui
        entry.highlight = highlight
    elseif highlight.Parent ~= parentGui then
        highlight.Parent = parentGui
    end
    highlight.Adornee = character
    highlight.Enabled = true
    updateHighlightColors(entry)
end

local function refreshVisualEntry(player, entry)
    if not entry then
        return
    end
    if not player.Parent then
        destroyVisualEntry(player)
        return
    end

    if entry.esp and not entry.esp.Parent then
        entry.esp = nil
    end
    if entry.highlight and not entry.highlight.Parent then
        entry.highlight = nil
    end

    if espEnabled then
        ensureEsp(entry, player)
    elseif entry.esp then
        entry.esp.Enabled = false
    end

    if chamsEnabled then
        ensureHighlight(entry, player)
    elseif entry.highlight then
        entry.highlight.Enabled = false
    end

    if entry.esp then
        updateEspColors(entry)
    end
    if entry.highlight then
        updateHighlightColors(entry)
    end
end

local function updateVisuals()
    for player, entry in pairs(playerVisuals) do
        if not player.Parent then
            destroyVisualEntry(player)
        else
            refreshVisualEntry(player, entry)
            if entry.info and entry.esp and entry.esp.Enabled then
                local character, humanoid = getAliveCharacter(player)
                if character and humanoid then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root and Camera then
                        local distance = (Camera.CFrame.Position - root.Position).Magnitude
                        entry.info.Text = string.format("%d HP | %.0f studs", math.floor(humanoid.Health + 0.5), distance)
                    end
                    if entry.healthFill then
                        local maxHealth = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100
                        local ratio = math.clamp(humanoid.Health / maxHealth, 0, 1)
                        entry.healthFill.Size = UDim2.new(ratio, 0, 1, 0)
                    end
                else
                    entry.info.Text = "dead"
                    if entry.healthFill then
                        entry.healthFill.Size = UDim2.new(0, 0, 1, 0)
                    end
                end
            end
        end
    end
end

local function attachCharacter(entry, player, character)
    if entry.esp then
        entry.esp:Destroy()
        entry.esp = nil
    end
    if entry.highlight then
        entry.highlight:Destroy()
        entry.highlight = nil
    end
    refreshVisualEntry(player, entry)
end

local function trackPlayer(player)
    destroyVisualEntry(player)
    local entry = {
        connections = {}
    }
    playerVisuals[player] = entry

    local function onCharacterAdded(character)
        attachCharacter(entry, player, character)
    end

    local charConn = player.CharacterAdded:Connect(onCharacterAdded)
    table.insert(entry.connections, charConn)

    local removingConn = player.CharacterRemoving:Connect(function()
        if entry.esp then
            entry.esp.Enabled = false
        end
        if entry.highlight then
            entry.highlight.Enabled = false
            entry.highlight.Adornee = nil
        end
    end)
    table.insert(entry.connections, removingConn)

    if player.Character then
        onCharacterAdded(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        trackPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        trackPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    destroyVisualEntry(player)
end)

visualsConnection = RunService.RenderStepped:Connect(updateVisuals)

registerBinding("visuals.esp.enabled", function(value)
    espEnabled = value and true or false
    for player, entry in pairs(playerVisuals) do
        refreshVisualEntry(player, entry)
    end
end)

registerBinding("visuals.chams.enabled", function(value)
    chamsEnabled = value and true or false
    for player, entry in pairs(playerVisuals) do
        refreshVisualEntry(player, entry)
    end
end)

registerBinding("visuals.esp.color", function(color)
    if typeof(color) == "Color3" then
        espColor = color
        for _, entry in pairs(playerVisuals) do
            updateEspColors(entry)
        end
    end
end)

registerBinding("visuals.esp.outline", function(color)
    if typeof(color) == "Color3" then
        espOutlineColor = color
        for _, entry in pairs(playerVisuals) do
            updateEspColors(entry)
        end
    end
end)

registerBinding("visuals.chams.fill", function(color)
    if typeof(color) == "Color3" then
        chamsFillColor = color
        for _, entry in pairs(playerVisuals) do
            updateHighlightColors(entry)
        end
    end
end)

registerBinding("visuals.chams.outline", function(color)
    if typeof(color) == "Color3" then
        chamsOutlineColor = color
        for _, entry in pairs(playerVisuals) do
            updateHighlightColors(entry)
        end
    end
end)

registerBinding("visuals.chams.fillAlpha", function(value)
    chamsFillTransparency = math.clamp((value or 35) / 100, 0, 1)
    for _, entry in pairs(playerVisuals) do
        updateHighlightColors(entry)
    end
end)

registerBinding("visuals.chams.outlineAlpha", function(value)
    chamsOutlineTransparency = math.clamp((value or 0) / 100, 0, 1)
    for _, entry in pairs(playerVisuals) do
        updateHighlightColors(entry)
    end
end)

-- Misc systems ---------------------------------------------------------------

local killSayEnabled = false
local killSayMode = "fatality"
local killSayConnections = {}

local killSayPhrases = {
    fatality = {
        "fatality.win - better luck next time",
        "sent to the shadow realm by fatality",
        "your desync just folded",
    },
    friendly = {
        "gg wp",
        "sorry, had to do it 💜",
        "much love from fatality",
    },
    random = {
        "that packet loss looked rough",
        "consider upgrading your anti-aim",
        "fatality supremacy",
    },
}

local function getKillPhrase()
    local bucket = killSayPhrases[killSayMode]
    if killSayMode == "random" then
        local all = {}
        for _, list in pairs(killSayPhrases) do
            for _, value in ipairs(list) do
                table.insert(all, value)
            end
        end
        bucket = all
    end
    if not bucket or #bucket == 0 then
        bucket = killSayPhrases.fatality
    end
    return bucket[math.random(1, #bucket)]
end

local function sendKillMessage(targetName)
    if not killSayEnabled then
        return
    end
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local sayMessage = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")
    if sayMessage then
        local phrase = string.format("%s | %s", targetName, getKillPhrase())
        pcall(function()
            sayMessage:FireServer(phrase, "All")
        end)
    end
end

local function attachKillSay(player)
    if killSayConnections[player] then
        for _, conn in ipairs(killSayConnections[player]) do
            conn:Disconnect()
        end
    end
    killSayConnections[player] = {}

    local function hookCharacter(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid")
        if not humanoid then
            humanoid = character:WaitForChild("Humanoid", 3)
        end
        if humanoid then
            local diedConn
            diedConn = humanoid.Died:Connect(function()
                local creator = humanoid:FindFirstChild("creator")
                local killer = creator and creator.Value
                if killer == LocalPlayer then
                    sendKillMessage(player.DisplayName or player.Name)
                end
            end)
            table.insert(killSayConnections[player], diedConn)
        end
    end

    local addedConn = player.CharacterAdded:Connect(hookCharacter)
    table.insert(killSayConnections[player], addedConn)
    if player.Character then
        hookCharacter(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        attachKillSay(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        attachKillSay(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if killSayConnections[player] then
        for _, conn in ipairs(killSayConnections[player]) do
            conn:Disconnect()
        end
        killSayConnections[player] = nil
    end
end)

registerBinding("misc.killSay", function(value)
    killSayEnabled = value and true or false
end)

registerBinding("misc.killSayMode", function(mode)
    killSayMode = tostring(mode or "fatality")
end)

local fakeLagEnabled = false
local fakeLagChoke = 6
local fakeLagConnection
local fakeLagCounter = 0
local storedVelocity = Vector3.zero

local function updateFakeLag()
    if not fakeLagEnabled then
        return
    end
    local character = LocalPlayer.Character
    if not character then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    fakeLagCounter = fakeLagCounter + 1
    if fakeLagCounter >= fakeLagChoke then
        fakeLagCounter = 0
        storedVelocity = root.AssemblyLinearVelocity
    else
        root.AssemblyLinearVelocity = storedVelocity
        root.AssemblyAngularVelocity = Vector3.new()
    end
end

registerBinding("misc.fakeLag", function(value)
    fakeLagEnabled = value and true or false
    fakeLagCounter = 0
    if fakeLagEnabled then
        if not fakeLagConnection then
            fakeLagConnection = RunService.Heartbeat:Connect(updateFakeLag)
        end
    else
        if fakeLagConnection then
            fakeLagConnection:Disconnect()
            fakeLagConnection = nil
        end
    end
end)

registerBinding("misc.fakeLagChoke", function(value)
    fakeLagChoke = math.clamp(math.floor(value or 1), 1, 30)
end)

registerBinding("misc.fov", function(value)
    if Camera then
        Camera.FieldOfView = value or defaultFov
    end
end)

local autoPeekEnabled = false
local autoPeekKey = Enum.KeyCode.C
local autoPeekConnectionBegan
local autoPeekConnectionEnded
local autoPeekReturnTween
local autoPeekOrigin

local function cachePeekOrigin()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        autoPeekOrigin = root.CFrame
    end
end

local function returnToPeek()
    if not autoPeekOrigin then
        return
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    if autoPeekReturnTween then
        autoPeekReturnTween:Cancel()
    end
    autoPeekReturnTween = TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = autoPeekOrigin
    })
    autoPeekReturnTween:Play()
    autoPeekReturnTween.Completed:Once(function()
        autoPeekReturnTween = nil
    end)
    autoPeekOrigin = nil
end

local function onAutoPeekBegan(input, gameProcessed)
    if gameProcessed or not autoPeekEnabled then
        return
    end
    if input.KeyCode == autoPeekKey then
        cachePeekOrigin()
    end
end

local function onAutoPeekEnded(input)
    if not autoPeekEnabled then
        return
    end
    if input.KeyCode == autoPeekKey then
        returnToPeek()
    end
end

registerBinding("misc.autoPeek", function(value)
    autoPeekEnabled = value and true or false
    if autoPeekEnabled then
        if not autoPeekConnectionBegan then
            autoPeekConnectionBegan = UserInputService.InputBegan:Connect(onAutoPeekBegan)
        end
        if not autoPeekConnectionEnded then
            autoPeekConnectionEnded = UserInputService.InputEnded:Connect(onAutoPeekEnded)
        end
    else
        if autoPeekConnectionBegan then
            autoPeekConnectionBegan:Disconnect()
            autoPeekConnectionBegan = nil
        end
        if autoPeekConnectionEnded then
            autoPeekConnectionEnded:Disconnect()
            autoPeekConnectionEnded = nil
        end
        if autoPeekReturnTween then
            autoPeekReturnTween:Cancel()
            autoPeekReturnTween = nil
        end
        autoPeekOrigin = nil
    end
end)

local bunnyHopEnabled = false
local edgeJumpEnabled = false
local noclipEnabled = false
local speedEnabled = false
local speedAmount = 22
local storedWalkSpeed
local movementConnection
local lastBhopTime = 0
local wasOnGround = false

local function updateMovementFeatures()
    local character, humanoid = getAliveCharacter(LocalPlayer)
    if not character or not humanoid then
        wasOnGround = false
        return
    end

    local onGround = humanoid.FloorMaterial ~= Enum.Material.Air

    if bunnyHopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and onGround then
        local now = tick()
        if now - lastBhopTime > 0.08 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastBhopTime = now
        end
    end

    if edgeJumpEnabled and wasOnGround and not onGround and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if speedEnabled then
        if not storedWalkSpeed then
            storedWalkSpeed = humanoid.WalkSpeed
        end
        if math.abs((humanoid.WalkSpeed or 0) - speedAmount) > 0.05 then
            humanoid.WalkSpeed = speedAmount
        end
    elseif storedWalkSpeed then
        if math.abs((humanoid.WalkSpeed or 0) - storedWalkSpeed) > 0.05 then
            humanoid.WalkSpeed = storedWalkSpeed
        end
    end

    if noclipEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
            end
        end
    end

    wasOnGround = onGround
end

local function ensureMovementConnection()
    local shouldRun = bunnyHopEnabled or edgeJumpEnabled or noclipEnabled or speedEnabled
    if shouldRun and not movementConnection then
        wasOnGround = false
        movementConnection = RunService.RenderStepped:Connect(updateMovementFeatures)
    elseif not shouldRun and movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end
end

registerBinding("misc.bhop", function(value)
    bunnyHopEnabled = value and true or false
    ensureMovementConnection()
end)

registerBinding("misc.edgeJump", function(value)
    edgeJumpEnabled = value and true or false
    ensureMovementConnection()
end)

registerBinding("misc.noclip", function(value)
    noclipEnabled = value and true or false
    if not noclipEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanTouch = true
                end
            end
        end
    end
    updateMovementFeatures()
    ensureMovementConnection()
end)

registerBinding("misc.speedEnabled", function(value)
    speedEnabled = value and true or false
    if speedEnabled then
        local _, humanoid = getAliveCharacter(LocalPlayer)
        storedWalkSpeed = humanoid and humanoid.WalkSpeed or 16
    else
        local _, humanoid = getAliveCharacter(LocalPlayer)
        if humanoid and storedWalkSpeed then
            humanoid.WalkSpeed = storedWalkSpeed
        end
        storedWalkSpeed = nil
    end
    updateMovementFeatures()
    ensureMovementConnection()
end)

registerBinding("misc.speedAmount", function(value)
    speedAmount = math.clamp(value or 22, 16, 120)
    if speedEnabled then
        updateMovementFeatures()
    end
end)

local airStuckEnabled = false
local airStuckKey = Enum.KeyCode.V
local airStuckActive = false
local airStuckBegan
local airStuckEnded

local function setAirStuck(state)
    if airStuckActive == state then
        return
    end
    airStuckActive = state
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = state
        if not state then
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function onAirStuckBegan(input, gameProcessed)
    if gameProcessed or not airStuckEnabled then
        return
    end
    if input.KeyCode == airStuckKey then
        setAirStuck(true)
    end
end

local function onAirStuckEnded(input)
    if input.KeyCode == airStuckKey then
        setAirStuck(false)
    end
end

registerBinding("misc.airStuck", function(value)
    airStuckEnabled = value and true or false
    if airStuckEnabled then
        if not airStuckBegan then
            airStuckBegan = UserInputService.InputBegan:Connect(onAirStuckBegan)
        end
        if not airStuckEnded then
            airStuckEnded = UserInputService.InputEnded:Connect(onAirStuckEnded)
        end
    else
        if airStuckBegan then
            airStuckBegan:Disconnect()
            airStuckBegan = nil
        end
        if airStuckEnded then
            airStuckEnded:Disconnect()
            airStuckEnded = nil
        end
        setAirStuck(false)
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    setAirStuck(false)
    autoPeekOrigin = nil
    if autoPeekReturnTween then
        autoPeekReturnTween:Cancel()
        autoPeekReturnTween = nil
    end
    if speedEnabled then
        storedWalkSpeed = nil
    end
end)

local function createPage(tabId)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page"
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.fromScale(1, 1)
    page.Position = UDim2.fromScale(0, 0)
    page.Visible = false
    page.ZIndex = 1
    page.ScrollBarThickness = 4
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ClipsDescendants = false

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = page

    local controls = tabContent[tabId]
    if controls then
        for index, controlDef in ipairs(controls) do
            local constructor = controlFactory[controlDef.type]
            if constructor then
                local element = constructor(page, controlDef)
                if element then
                    element.LayoutOrder = controlDef.order or index
                end
            end
        end
    end

    return page
end

local pages = {}
for _, tab in ipairs(tabs) do
    local page = createPage(tab.id)
    page.Visible = false
    page.Parent = container
    table.insert(pages, page)
end

local function setIndicator(button)
    indicator.Visible = true
    local goal = {
        Size = UDim2.new(0, button.AbsoluteSize.X, 0, 2),
        Position = UDim2.new(0, button.AbsolutePosition.X - tabBar.AbsolutePosition.X, 1, 0)
    }
    TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

local function switchTab(index)
    if index == activeTab then
        return
    end

    local previousIndex = activeTab
    local previousPage = pages[previousIndex]
    local newPage = pages[index]
    activeTab = index

    for i, button in ipairs(tabButtons) do
        local transparency = (i == index) and 0 or 0.35
        button:SetAttribute("TargetTransparency", transparency)
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = transparency
        }):Play()
    end

    local direction = (index > previousIndex) and 1 or -1
    local capturedIndex = index

    if previousPage then
        TweenService:Create(previousPage, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.fromScale(-direction * 0.25, 0)
        }):Play()
        task.delay(0.25, function()
            if activeTab ~= capturedIndex then
                return
            end
            previousPage.Visible = false
            previousPage.Position = UDim2.fromScale(0, 0)
        end)
    end

    if newPage then
        if newPage:IsA("ScrollingFrame") then
            newPage.CanvasPosition = Vector2.new(0, 0)
        end
        newPage.Visible = true
        newPage.ZIndex = 2
        newPage.Position = UDim2.fromScale(direction, 0)
        TweenService:Create(newPage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0, 0)
        }):Play()
        task.delay(0.3, function()
            if activeTab == capturedIndex then
                newPage.ZIndex = 1
            end
        end)
    end

    setIndicator(tabButtons[index])
end

for index, tab in ipairs(tabs) do
    local button = Instance.new("TextButton")
    button.Name = tab.id
    button.Text = string.upper(tab.label)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.BackgroundTransparency = 1
    button.TextColor3 = style.textBright
    local targetTransparency = (index == activeTab) and 0 or 0.35
    button.TextTransparency = 1
    button:SetAttribute("TargetTransparency", targetTransparency)
    button.AutoButtonColor = false
    button.Parent = tabBar

    button.Size = UDim2.new(0, button.TextBounds.X + 20, 1, 0)

    button.MouseButton1Click:Connect(function()
        switchTab(index)
    end)

    table.insert(tabButtons, button)
end

-- Ensure tabs keep consistent width if text updates
local function updateTabSizes()
    for _, button in ipairs(tabButtons) do
        button.Size = UDim2.new(0, button.TextBounds.X + 20, 1, 0)
    end
    if tabButtons[activeTab] then
        setIndicator(tabButtons[activeTab])
    end
end

for _, button in ipairs(tabButtons) do
    button:GetPropertyChangedSignal("TextBounds"):Connect(updateTabSizes)
end

pages[activeTab].Visible = true
pages[activeTab].Position = UDim2.fromScale(0, 0)
indicator.Visible = false

local isVisible = false
local hasLoaded = false

local finalSizeVector = Vector2.new(720, 480)
local hiddenSizeVector = Vector2.new(680, 440)
local minSizeVector = Vector2.new(560, 360)
local maxSizeVector = Vector2.new(1000, 720)

local openTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local fadeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function updateHiddenSizeVector()
    hiddenSizeVector = Vector2.new(
        math.max(finalSizeVector.X - 40, finalSizeVector.X * 0.85),
        math.max(finalSizeVector.Y - 40, finalSizeVector.Y * 0.85)
    )
end

local function getFinalSize()
    return UDim2.fromOffset(finalSizeVector.X, finalSizeVector.Y)
end

local function getHiddenSize()
    return UDim2.fromOffset(hiddenSizeVector.X, hiddenSizeVector.Y)
end

local function setFinalSize(newSize)
    finalSizeVector = Vector2.new(
        math.clamp(newSize.X, minSizeVector.X, maxSizeVector.X),
        math.clamp(newSize.Y, minSizeVector.Y, maxSizeVector.Y)
    )
    updateHiddenSizeVector()
    if isVisible then
        mainFrame.Size = getFinalSize()
    else
        mainFrame.Size = getHiddenSize()
    end
    if indicator.Visible and tabButtons[activeTab] then
        setIndicator(tabButtons[activeTab])
    end
end

updateHiddenSizeVector()

local function applyTabTransparencies(instant)
    for _, button in ipairs(tabButtons) do
        local target = button:GetAttribute("TargetTransparency")
        if target == nil then
            target = 0.35
        end
        if instant then
            button.TextTransparency = target
        else
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = target
            }):Play()
        end
    end
end

local function showMenu(instant)
    isVisible = true
    mainFrame.Visible = true
    indicator.Visible = false

    if instant then
        mainFrame.Size = getFinalSize()
        mainFrame.BackgroundTransparency = finalBackgroundTransparency
    else
        mainFrame.Size = getHiddenSize()
        mainFrame.BackgroundTransparency = hiddenBackgroundTransparency
        TweenService:Create(mainFrame, openTweenInfo, {
            Size = getFinalSize(),
            BackgroundTransparency = finalBackgroundTransparency
        }):Play()
    end

    if instant then
        container.BackgroundTransparency = containerFinalTransparency
        containerStroke.Transparency = 0
        title.TextTransparency = finalTitleTransparency
        subtitle.TextTransparency = finalSubtitleTransparency
        applyTabTransparencies(true)
    else
        container.BackgroundTransparency = containerHiddenTransparency
        containerStroke.Transparency = 1
        TweenService:Create(container, fadeTweenInfo, {
            BackgroundTransparency = containerFinalTransparency
        }):Play()
        TweenService:Create(containerStroke, fadeTweenInfo, {Transparency = 0}):Play()
        TweenService:Create(title, fadeTweenInfo, {TextTransparency = finalTitleTransparency}):Play()
        TweenService:Create(subtitle, fadeTweenInfo, {TextTransparency = finalSubtitleTransparency}):Play()
        applyTabTransparencies(false)
    end

    task.delay(0.05, function()
        if not mainFrame or not mainFrame.Parent then
            return
        end
        updateTabSizes()
        if isVisible then
            indicator.Visible = true
        end
    end)
end

local function hideMenu()
    if not isVisible then
        return
    end

    isVisible = false
    indicator.Visible = false

    TweenService:Create(container, closeTweenInfo, {
        BackgroundTransparency = containerHiddenTransparency
    }):Play()
    TweenService:Create(containerStroke, closeTweenInfo, {Transparency = 1}):Play()
    TweenService:Create(title, closeTweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(subtitle, closeTweenInfo, {TextTransparency = 1}):Play()

    for _, button in ipairs(tabButtons) do
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1
        }):Play()
    end

    local tween = TweenService:Create(mainFrame, closeTweenInfo, {
        Size = getHiddenSize(),
        BackgroundTransparency = hiddenBackgroundTransparency
    })
    tween.Completed:Once(function()
        if not isVisible then
            mainFrame.Visible = false
        end
    end)
    tween:Play()
end

header.Active = true

local dragging = false
local dragStart
local dragInput
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        dragInput = input
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    end
end)

local resizeHandle = Instance.new("ImageButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.AnchorPoint = Vector2.new(1, 1)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Image = "rbxassetid://3926305904"
resizeHandle.ImageRectOffset = Vector2.new(964, 324)
resizeHandle.ImageRectSize = Vector2.new(36, 36)
resizeHandle.ImageColor3 = style.textDim
resizeHandle.ImageTransparency = 0.25
resizeHandle.Size = UDim2.fromOffset(20, 20)
resizeHandle.Position = UDim2.new(1, -12, 1, -12)
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 5
resizeHandle.Parent = mainFrame

local resizeStroke = Instance.new("UIStroke")
resizeStroke.Color = style.stroke
resizeStroke.Thickness = 1
resizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
resizeStroke.Parent = resizeHandle

local resizing = false
local resizeInput
local resizeStartPosition
local resizeStartSize
local resizeStartUDim

local function updateResize(input)
    local delta = input.Position - resizeStartPosition
    local newSize = Vector2.new(resizeStartSize.X + delta.X, resizeStartSize.Y + delta.Y)
    setFinalSize(newSize)
    if resizeStartUDim then
        local effectiveDelta = Vector2.new(finalSizeVector.X - resizeStartSize.X, finalSizeVector.Y - resizeStartSize.Y)
        mainFrame.Position = UDim2.new(
            resizeStartUDim.X.Scale,
            resizeStartUDim.X.Offset + (effectiveDelta.X / 2),
            resizeStartUDim.Y.Scale,
            resizeStartUDim.Y.Offset + (effectiveDelta.Y / 2)
        )
    end
end

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStartPosition = input.Position
        resizeStartSize = Vector2.new(mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y)
        resizeStartUDim = mainFrame.Position
        resizeInput = input
        TweenService:Create(resizeHandle, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageColor3 = style.accent
        }):Play()
    end
end)

resizeHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        resizeInput = input
    end
end)

resizeHandle.MouseEnter:Connect(function()
    TweenService:Create(resizeHandle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0
    }):Play()
end)

resizeHandle.MouseLeave:Connect(function()
    if not resizing then
        TweenService:Create(resizeHandle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0.25,
            ImageColor3 = style.textDim
        }):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input == resizeInput then
        updateResize(input)
    end
end)

local function endInteraction()
    dragging = false
    dragInput = nil
    if resizing then
        resizing = false
        resizeInput = nil
        resizeStartUDim = nil
        TweenService:Create(resizeHandle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0.25,
            ImageColor3 = style.textDim
        }):Play()
    end
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        endInteraction()
    end
end)

UserInputService.TouchEnded:Connect(function()
    endInteraction()
end)

local loadingUI = {}

loadingUI.overlay = createInstance("Frame", {
    Name = "Loading",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.4,
    Size = UDim2.fromScale(1, 1),
    Parent = rootFrame,
})

loadingUI.container = createInstance("Frame", {
    Name = "LoadingContainer",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(260, 120),
    BackgroundColor3 = style.panelContrast,
    BackgroundTransparency = 0.05,
    Parent = loadingUI.overlay,
})

createInstance("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = loadingUI.container,
})

createInstance("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, style.panelContrast),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 12, 58)),
        ColorSequenceKeypoint.new(1, style.panelContrast),
    }),
    Rotation = -45,
    Parent = loadingUI.container,
})

loadingUI.stroke = createInstance("UIStroke", {
    Color = style.stroke,
    Thickness = 1,
    Parent = loadingUI.container,
})

loadingUI.label = createInstance("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -40, 0, 24),
    Position = UDim2.new(0, 20, 0, 20),
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamSemibold,
    TextSize = 16,
    TextColor3 = style.textBright,
    Text = "loading menu",
    Parent = loadingUI.container,
})

loadingUI.progressOuter = createInstance("Frame", {
    Name = "ProgressOuter",
    BackgroundColor3 = style.buttonIdle,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 20, 0, 70),
    Size = UDim2.new(1, -40, 0, 8),
    Parent = loadingUI.container,
})

createInstance("UICorner", {
    CornerRadius = UDim.new(1, 0),
    Parent = loadingUI.progressOuter,
})

loadingUI.progressStroke = createInstance("UIStroke", {
    Color = style.stroke,
    Thickness = 1,
    Parent = loadingUI.progressOuter,
})

loadingUI.progressFill = createInstance("Frame", {
    Name = "ProgressFill",
    BackgroundColor3 = style.accent,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 0, 1, 0),
    Parent = loadingUI.progressOuter,
})

createInstance("UICorner", {
    CornerRadius = UDim.new(1, 0),
    Parent = loadingUI.progressFill,
})

loadingUI.spinner = createInstance("ImageLabel", {
    Name = "Spinner",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 18),
    Size = UDim2.fromOffset(18, 18),
    Image = "rbxassetid://11255175019",
    ImageColor3 = style.accentAlt,
    Parent = loadingUI.label,
})

local progressTween = TweenService:Create(loadingUI.progressFill, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
})
progressTween:Play()

local spinnerConnection
spinnerConnection = RunService.Heartbeat:Connect(function(step)
    loadingUI.spinner.Rotation = (loadingUI.spinner.Rotation + step * 180) % 360
end)

local function revealMenu()
    loadingUI.overlay.Active = false
    TweenService:Create(loadingUI.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(loadingUI.container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(loadingUI.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    }):Play()
    TweenService:Create(loadingUI.label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(loadingUI.progressOuter, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(loadingUI.progressFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(loadingUI.progressStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    }):Play()
    TweenService:Create(loadingUI.spinner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 1
    }):Play()

    task.delay(0.25, function()
        if spinnerConnection then
            spinnerConnection:Disconnect()
        end
        loadingUI.overlay:Destroy()
    end)

    showMenu(false)
    hasLoaded = true
end

progressTween.Completed:Once(revealMenu)

-- Allow toggle key (Insert) to hide/show menu after load
local toggleKey = Enum.KeyCode.Insert

local function toggleMenu()
    if not hasLoaded then
        return
    end

    if isVisible then
        hideMenu()
    else
        showMenu(false)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == toggleKey then
        toggleMenu()
    end
end)

-- initial indicator update once frame is sized
task.delay(0.1, updateTabSizes)