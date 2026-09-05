--[[
    ╔═══════════════════════════════════════════════════════╗
    ║                   SUN SKRIPT HUB                      ║
    ║         Clean • Minimal • Glassmorphism               ║
    ║                                                       ║
    ║   Game Support: Blox Fruits                           ║
    ║   No Key System — Free & Open                         ║
    ╚═══════════════════════════════════════════════════════╝
]]--

-- ═══════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════

local HUB_NAME = "Sun Skript"
local HUB_VERSION = "1.0.0"

local Directory = "https://raw.githubusercontent.com/Kush-009/sunskript/refs/heads/main/SunSkript.lua"

local Scripts = {
    Free = {
        [2753915549] = Directory .. "/BloxFruits.lua",  -- Blox Fruits (main place)
    },
}

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameId = game.GameId
local PlaceId = game.PlaceId

-- ═══════════════════════════════════════════
-- EXECUTOR COMPATIBILITY
-- ═══════════════════════════════════════════

local HttpRequest = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request
    or (fluxus and fluxus.request)
    or (delta and delta.request)

local IsFileFunc = isfile or function() return false end
local ReadFileFunc = readfile or function() return "" end
local WriteFileFunc = writefile or function() end
local MakeFolderFunc = makefolder or function() end
local IsFolderFunc = isfolder or function() return false end

local function GetExecutorName()
    if identifyexecutor then return identifyexecutor() end
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "Krnl" end
    if fluxus then return "Fluxus" end
    if is_sirhurt_closure then return "SirHurt" end
    if delta then return "Delta" end
    return "Unknown"
end

local function GetHWID()
    local hwid = nil
    if gethwid then
        pcall(function() hwid = gethwid() end)
    elseif get_hwid then
        pcall(function() hwid = get_hwid() end)
    end
    if not hwid or tostring(hwid) == "" then
        pcall(function()
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end
    if not hwid or tostring(hwid) == "" then
        hwid = "FB-" .. tostring(LocalPlayer.UserId) .. "-" .. tostring(PlaceId)
    end
    return tostring(hwid)
end

-- ═══════════════════════════════════════════
-- UI UTILITY
-- ═══════════════════════════════════════════

local function Tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
    tween:Play()
    return tween
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" and k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            pcall(function() child.Parent = inst end)
        end
    end
    inst.Parent = props.Parent or parent
    return inst
end

local function ProtectGui(gui)
    local env = (getgenv and getgenv()) or _G
    if env.HIDEUI then
        gui.Parent = env.HIDEUI
    elseif gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    else
        gui.Parent = CoreGui
    end
end

local function Notify(title, desc, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or HUB_NAME,
            Text = desc or "",
            Duration = duration or 5,
        })
    end)
end

local function CircleRipple(btn, mx, my)
    task.spawn(function()
        btn.ClipsDescendants = true
        local nx = mx - btn.AbsolutePosition.X
        local ny = my - btn.AbsolutePosition.Y
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
        local ripple = New("ImageLabel", {
            Name = "Ripple",
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.82,
            BackgroundTransparency = 1,
            ZIndex = btn.ZIndex + 5,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, nx, 0, ny),
        }, btn)
        Tween(ripple, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2) }, 0.45, Enum.EasingStyle.Quad)
        Tween(ripple, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
        task.wait(0.5)
        ripple:Destroy()
    end)
end

-- ═══════════════════════════════════════════
-- COLORS — Warm sun palette, minimal
-- ═══════════════════════════════════════════

local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Glass = Color3.fromRGB(25, 25, 35),
    GlassStroke = Color3.fromRGB(55, 55, 70),
    Accent = Color3.fromRGB(255, 180, 50),       -- warm sun gold
    AccentSoft = Color3.fromRGB(255, 200, 100),
    AccentDim = Color3.fromRGB(180, 120, 30),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 160),
    Success = Color3.fromRGB(80, 200, 120),
    Error = Color3.fromRGB(240, 80, 80),
    CardBg = Color3.fromRGB(20, 20, 28),
}

-- ═══════════════════════════════════════════
-- CLEANUP PREVIOUS INSTANCES
-- ═══════════════════════════════════════════

pcall(function()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name == "SunSkriptHub" then gui:Destroy() end
    end
end)
pcall(function()
    if gethui then
        for _, gui in ipairs(gethui():GetChildren()) do
            if gui.Name == "SunSkriptHub" then gui:Destroy() end
        end
    end
end)

-- ═══════════════════════════════════════════
-- MAIN UI CONSTRUCTION
-- ═══════════════════════════════════════════

local ScreenGui = New("ScreenGui", {
    Name = "SunSkriptHub",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
})
ProtectGui(ScreenGui)

-- Background overlay (dim)
local Overlay = New("Frame", {
    Name = "Overlay",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 1,
}, ScreenGui)

-- Main card
local CardWidth = 380
local CardHeight = 420

local MainCard = New("Frame", {
    Name = "MainCard",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, CardWidth, 0, CardHeight),
    BackgroundColor3 = Colors.Glass,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 10,
    ClipsDescendants = true,
}, ScreenGui)

New("UICorner", { CornerRadius = UDim.new(0, 14) }, MainCard)

New("UIStroke", {
    Color = Colors.GlassStroke,
    Thickness = 1,
    Transparency = 0.5,
}, MainCard)

-- Subtle inner glow at top (frosted glass feel)
local TopGlow = New("Frame", {
    Name = "TopGlow",
    Size = UDim2.new(1, 0, 0, 120),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 11,
}, MainCard)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 80)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 90,
}, TopGlow)
TopGlow.BackgroundTransparency = 0

New("UICorner", { CornerRadius = UDim.new(0, 14) }, TopGlow)

-- ═══════════════════════════════════════════
-- HEADER SECTION
-- ═══════════════════════════════════════════

local Header = New("Frame", {
    Name = "Header",
    Size = UDim2.new(1, -40, 0, 80),
    Position = UDim2.new(0, 20, 0, 24),
    BackgroundTransparency = 1,
    ZIndex = 15,
}, MainCard)

-- Sun icon (circle glow)
local SunIcon = New("Frame", {
    Name = "SunIcon",
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.Accent,
    BackgroundTransparency = 0,
    ZIndex = 16,
}, Header)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, SunIcon)

local SunGlow = New("UIStroke", {
    Color = Colors.Accent,
    Thickness = 2,
    Transparency = 0.4,
}, SunIcon)

New("TextLabel", {
    Name = "SunSymbol",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "☀",
    TextColor3 = Colors.Background,
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    ZIndex = 17,
}, SunIcon)

-- Title
New("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -60, 0, 28),
    Position = UDim2.new(0, 56, 0, 2),
    BackgroundTransparency = 1,
    Text = HUB_NAME,
    TextColor3 = Colors.Text,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
}, Header)

-- Subtitle
New("TextLabel", {
    Name = "Subtitle",
    Size = UDim2.new(1, -60, 0, 18),
    Position = UDim2.new(0, 56, 0, 30),
    BackgroundTransparency = 1,
    Text = "v" .. HUB_VERSION .. "  •  " .. GetExecutorName(),
    TextColor3 = Colors.TextDim,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
}, Header)

-- Close button
local CloseBtn = New("TextButton", {
    Name = "CloseBtn",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -30, 0, 0),
    BackgroundColor3 = Colors.CardBg,
    BackgroundTransparency = 0.5,
    Text = "✕",
    TextColor3 = Colors.TextDim,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ZIndex = 18,
    AutoButtonColor = false,
}, Header)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, CloseBtn)

CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, { BackgroundTransparency = 0.2, TextColor3 = Colors.Error }, 0.2)
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, { BackgroundTransparency = 0.5, TextColor3 = Colors.TextDim }, 0.2)
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainCard, { Size = UDim2.new(0, CardWidth, 0, 0), BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(Overlay, { BackgroundTransparency = 1 }, 0.3)
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════
-- DIVIDER
-- ═══════════════════════════════════════════

New("Frame", {
    Name = "Divider",
    Size = UDim2.new(1, -40, 0, 1),
    Position = UDim2.new(0, 20, 0, 112),
    BackgroundColor3 = Colors.GlassStroke,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 15,
}, MainCard)

-- ═══════════════════════════════════════════
-- INFO SECTION
-- ═══════════════════════════════════════════

local InfoSection = New("Frame", {
    Name = "InfoSection",
    Size = UDim2.new(1, -40, 0, 60),
    Position = UDim2.new(0, 20, 0, 124),
    BackgroundTransparency = 1,
    ZIndex = 15,
}, MainCard)

New("TextLabel", {
    Name = "PlayerName",
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "Welcome, " .. LocalPlayer.DisplayName,
    TextColor3 = Colors.Text,
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
}, InfoSection)

-- Game status
local gameName = "Unknown Game"
local gameSupported = false

if Scripts.Free[PlaceId] then
    gameName = "Blox Fruits"
    gameSupported = true
elseif Scripts.Free[GameId] then
    gameName = "Blox Fruits"
    gameSupported = true
end

local statusColor = gameSupported and Colors.Success or Colors.Error
local statusText = gameSupported and ("✓  " .. gameName .. " — Supported") or ("✗  Unsupported Game (ID: " .. tostring(PlaceId) .. ")")

New("TextLabel", {
    Name = "GameStatus",
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = statusText,
    TextColor3 = statusColor,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
}, InfoSection)

New("TextLabel", {
    Name = "HWID",
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 0, 44),
    BackgroundTransparency = 1,
    Text = "HWID: " .. string.sub(GetHWID(), 1, 16) .. "...",
    TextColor3 = Colors.TextDim,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
}, InfoSection)

-- ═══════════════════════════════════════════
-- ACTION BUTTONS
-- ═══════════════════════════════════════════

local ButtonSection = New("Frame", {
    Name = "ButtonSection",
    Size = UDim2.new(1, -40, 0, 140),
    Position = UDim2.new(0, 20, 0, 200),
    BackgroundTransparency = 1,
    ZIndex = 15,
}, MainCard)

-- Execute / Load button
local ExecBtn = New("TextButton", {
    Name = "ExecuteBtn",
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.Accent,
    BackgroundTransparency = 0,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 16,
    ClipsDescendants = true,
}, ButtonSection)
New("UICorner", { CornerRadius = UDim.new(0, 10) }, ExecBtn)

local ExecLabel = New("TextLabel", {
    Name = "Label",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = gameSupported and "☀  Load Script" or "☀  No Script Available",
    TextColor3 = Colors.Background,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    ZIndex = 17,
}, ExecBtn)

local StatusLabel = New("TextLabel", {
    Name = "StatusLabel",
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 52),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Colors.TextDim,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ZIndex = 16,
}, ButtonSection)

if gameSupported then
    ExecBtn.MouseEnter:Connect(function()
        Tween(ExecBtn, { BackgroundColor3 = Colors.AccentSoft }, 0.2)
    end)
    ExecBtn.MouseLeave:Connect(function()
        Tween(ExecBtn, { BackgroundColor3 = Colors.Accent }, 0.2)
    end)
else
    ExecBtn.BackgroundTransparency = 0.6
    ExecLabel.TextColor3 = Colors.TextDim
end

ExecBtn.MouseButton1Click:Connect(function()
    if not gameSupported then
        StatusLabel.Text = "This game is not supported yet."
        StatusLabel.TextColor3 = Colors.Error
        return
    end

    CircleRipple(ExecBtn, Mouse.X, Mouse.Y)

    local scriptUrl = Scripts.Free[PlaceId] or Scripts.Free[GameId]
    if not scriptUrl then
        StatusLabel.Text = "Script URL not found."
        StatusLabel.TextColor3 = Colors.Error
        return
    end

    StatusLabel.Text = "Loading script..."
    StatusLabel.TextColor3 = Colors.AccentSoft
    Tween(ExecBtn, { BackgroundColor3 = Colors.AccentDim }, 0.15)
    ExecLabel.Text = "⏳  Loading..."

    task.spawn(function()
        local success, err = pcall(function()
            if HttpRequest then
                local response = HttpRequest({
                    Url = scriptUrl,
                    Method = "GET",
                })
                if response and response.Body then
                    loadstring(response.Body)()
                else
                    error("Empty response from server")
                end
            elseif game and game.HttpGet then
                local body = game:HttpGet(scriptUrl, true)
                loadstring(body)()
            else
                error("No HTTP method available")
            end
        end)

        if success then
            StatusLabel.Text = "✓  Script loaded successfully!"
            StatusLabel.TextColor3 = Colors.Success
            ExecLabel.Text = "✓  Loaded"
            Tween(ExecBtn, { BackgroundColor3 = Colors.Success }, 0.25)
            Notify(HUB_NAME, "Script loaded for " .. gameName .. "!")
            task.wait(2)
            Tween(MainCard, { Size = UDim2.new(0, CardWidth, 0, 0), BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(Overlay, { BackgroundTransparency = 1 }, 0.3)
            task.wait(0.4)
            ScreenGui:Destroy()
        else
            StatusLabel.Text = "✗  Failed: " .. tostring(err):sub(1, 60)
            StatusLabel.TextColor3 = Colors.Error
            ExecLabel.Text = "☀  Retry"
            Tween(ExecBtn, { BackgroundColor3 = Colors.Accent }, 0.25)
        end
    end)
end)

-- ═══════════════════════════════════════════
-- SECONDARY BUTTONS
-- ═══════════════════════════════════════════

-- Copy HWID
local CopyHWIDBtn = New("TextButton", {
    Name = "CopyHWID",
    Size = UDim2.new(0.48, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundColor3 = Colors.CardBg,
    BackgroundTransparency = 0.3,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 16,
    ClipsDescendants = true,
}, ButtonSection)
New("UICorner", { CornerRadius = UDim.new(0, 8) }, CopyHWIDBtn)
New("UIStroke", { Color = Colors.GlassStroke, Thickness = 1, Transparency = 0.6 }, CopyHWIDBtn)

New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "Copy HWID",
    TextColor3 = Colors.TextDim,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    ZIndex = 17,
}, CopyHWIDBtn)

CopyHWIDBtn.MouseEnter:Connect(function()
    Tween(CopyHWIDBtn, { BackgroundTransparency = 0.1 }, 0.2)
end)
CopyHWIDBtn.MouseLeave:Connect(function()
    Tween(CopyHWIDBtn, { BackgroundTransparency = 0.3 }, 0.2)
end)
CopyHWIDBtn.MouseButton1Click:Connect(function()
    CircleRipple(CopyHWIDBtn, Mouse.X, Mouse.Y)
    pcall(function()
        if setclipboard then
            setclipboard(GetHWID())
        elseif toclipboard then
            toclipboard(GetHWID())
        end
    end)
    StatusLabel.Text = "HWID copied to clipboard."
    StatusLabel.TextColor3 = Colors.AccentSoft
end)

-- Rejoin Server
local RejoinBtn = New("TextButton", {
    Name = "Rejoin",
    Size = UDim2.new(0.48, 0, 0, 36),
    Position = UDim2.new(0.52, 0, 0, 80),
    BackgroundColor3 = Colors.CardBg,
    BackgroundTransparency = 0.3,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 16,
    ClipsDescendants = true,
}, ButtonSection)
New("UICorner", { CornerRadius = UDim.new(0, 8) }, RejoinBtn)
New("UIStroke", { Color = Colors.GlassStroke, Thickness = 1, Transparency = 0.6 }, RejoinBtn)

New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "Rejoin Server",
    TextColor3 = Colors.TextDim,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    ZIndex = 17,
}, RejoinBtn)

RejoinBtn.MouseEnter:Connect(function()
    Tween(RejoinBtn, { BackgroundTransparency = 0.1 }, 0.2)
end)
RejoinBtn.MouseLeave:Connect(function()
    Tween(RejoinBtn, { BackgroundTransparency = 0.3 }, 0.2)
end)
RejoinBtn.MouseButton1Click:Connect(function()
    CircleRipple(RejoinBtn, Mouse.X, Mouse.Y)
    StatusLabel.Text = "Rejoining server..."
    StatusLabel.TextColor3 = Colors.AccentSoft
    task.wait(0.5)
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
    end)
end)

-- ═══════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════

New("TextLabel", {
    Name = "Footer",
    Size = UDim2.new(1, -40, 0, 16),
    Position = UDim2.new(0, 20, 1, -28),
    BackgroundTransparency = 1,
    Text = HUB_NAME .. " • Free & Open",
    TextColor3 = Colors.TextDim,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextTransparency = 0.4,
    ZIndex = 16,
}, MainCard)

-- ═══════════════════════════════════════════
-- INTRO ANIMATION
-- ═══════════════════════════════════════════

MainCard.Size = UDim2.new(0, CardWidth, 0, 0)
MainCard.BackgroundTransparency = 1
Overlay.BackgroundTransparency = 1

task.spawn(function()
    Tween(Overlay, { BackgroundTransparency = 0.55 }, 0.35)
    task.wait(0.1)

    Tween(MainCard, {
        Size = UDim2.new(0, CardWidth, 0, CardHeight),
        BackgroundTransparency = 0.12,
    }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.wait(0.5)

    -- Subtle sun icon pulse loop
    task.spawn(function()
        while SunIcon and SunIcon.Parent do
            Tween(SunGlow, { Transparency = 0.1 }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            Tween(SunGlow, { Transparency = 0.6 }, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end)
end)

-- ═══════════════════════════════════════════
-- DRAGGABLE
-- ═══════════════════════════════════════════

do
    local dragging = false
    local dragStart, startPos

    MainCard.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainCard.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tween(MainCard, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.08, Enum.EasingStyle.Quad)
        end
    end)
end

-- ═══════════════════════════════════════════
-- TOGGLE KEYBIND (RightShift)
-- ═══════════════════════════════════════════

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        Tween(MainCard, { BackgroundTransparency = uiVisible and 0.12 or 1 }, 0.25)
        Tween(Overlay, { BackgroundTransparency = uiVisible and 0.55 or 1 }, 0.25)
        for _, child in ipairs(MainCard:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                Tween(child, { TextTransparency = uiVisible and 0 or 1 }, 0.25)
            end
            if child:IsA("Frame") and child.Name ~= "MainCard" then
                Tween(child, { BackgroundTransparency = uiVisible and (child:GetAttribute("OrigTransparency") or child.BackgroundTransparency) or 1 }, 0.25)
            end
        end
        MainCard.Active = uiVisible
    end
end)

-- ═══════════════════════════════════════════
-- DONE
-- ═══════════════════════════════════════════

Notify(HUB_NAME, "Hub loaded! Press RightShift to toggle UI.")
print("[" .. HUB_NAME .. "] v" .. HUB_VERSION .. " loaded successfully.")
