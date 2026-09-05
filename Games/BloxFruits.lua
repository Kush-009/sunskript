--[[
    ╔═══════════════════════════════════════════════════════╗
    ║              SUN SKRIPT — BLOX FRUITS                 ║
    ║         Auto Farm • ESP • Teleport • Misc             ║
    ╚═══════════════════════════════════════════════════════╝
]]--

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive()
    local hum = GetHumanoid()
    return hum and hum.Health > 0
end

local tweening = false
local noclipConn = nil

local function TweenTo(cf, speed)
    speed = speed or 275 -- Reduced speed to bypass Blox Fruits anticheat
    local hrp = GetHRP()
    if not hrp then return end
    
    local dist = (hrp.Position - cf.Position).Magnitude
    local t = dist / speed
    if t < 0.1 then t = 0.1 end
    
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    tweening = true
    if not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            if tweening and Player.Character then
                for _, v in ipairs(Player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
    
    tw:Play()
    tw.Completed:Wait()
    
    tweening = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if bv then bv:Destroy() end
end

local function Teleport(cf)
    local hrp = GetHRP()
    if hrp then
        local dist = (hrp.Position - cf.Position).Magnitude
        if dist < 250 then
            hrp.CFrame = cf
        else
            if State.InstantTP then
                -- Reset Bypass: reset character, move hrp before respawn
                local hum = GetHumanoid()
                if hum then
                    hum.Health = 0
                    hrp.CFrame = cf
                    Player.CharacterAdded:Wait()
                    local newChar = Player.Character or Player.CharacterAdded:Wait()
                    local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
                    if newHrp then
                        newHrp.CFrame = cf
                        task.wait(0.5) -- Wait for physics to settle
                    end
                end
            else
                TweenTo(cf, 275)
            end
        end
    end
end

local function GetDistance(pos)
    local hrp = GetHRP()
    if not hrp then return math.huge end
    return (hrp.Position - pos).Magnitude
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Sun Skript",
            Text = text or "",
            Duration = dur or 4,
        })
    end)
end

local function FireRemote(remoteName, ...)
    local remote = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(remoteName)
    if remote then
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        end
    end
end

-- ═══════════════════════════════════════════════
-- GAME DATA — ISLANDS
-- ═══════════════════════════════════════════════

local Islands = {
    ["First Sea"] = {
        { Name = "Starter Island",       CFrame = CFrame.new(-687, 15, 1583) },
        { Name = "Middle Town",          CFrame = CFrame.new(-691, 15, 1582) },
        { Name = "Jungle",              CFrame = CFrame.new(-1249, 15, 357) },
        { Name = "Pirate Village",      CFrame = CFrame.new(-1139, 15, 3825) },
        { Name = "Desert",              CFrame = CFrame.new(961, 15, 4392) },
        { Name = "Frozen Village",      CFrame = CFrame.new(1158, 128, -1272) },
        { Name = "Marine Fortress",     CFrame = CFrame.new(-4914, 15, 4281) },
        { Name = "Skylands",            CFrame = CFrame.new(-4861, 836, -2627) },
        { Name = "Prison",              CFrame = CFrame.new(4875, 15, 735) },
        { Name = "Colosseum",           CFrame = CFrame.new(-1428, 15, -3014) },
        { Name = "Magma Village",       CFrame = CFrame.new(-5243, 15, 8503) },
        { Name = "Underwater City",     CFrame = CFrame.new(3856, -200, 1173) },
        { Name = "Fountain City",       CFrame = CFrame.new(5252, 52, 4053) },
    },
    ["Second Sea"] = {
        { Name = "Kingdom of Rose",     CFrame = CFrame.new(-289, 80, 11712) },
        { Name = "Usopp's Island",      CFrame = CFrame.new(-1756, 60, 10901) },
        { Name = "Green Zone",          CFrame = CFrame.new(-2440, 75, 10572) },
        { Name = "Graveyard",           CFrame = CFrame.new(-5296, 74, 8502) },
        { Name = "Snow Mountain",       CFrame = CFrame.new(599, 400, -5381) },
        { Name = "Hot and Cold",        CFrame = CFrame.new(-6044, 15, -4825) },
        { Name = "Cursed Ship",         CFrame = CFrame.new(916, 120, 33162) },
        { Name = "Ice Castle",          CFrame = CFrame.new(6124, 395, -6784) },
        { Name = "Forgotten Island",    CFrame = CFrame.new(-3053, 240, -10047) },
        { Name = "Dark Arena",          CFrame = CFrame.new(-500, 120, -11600) },
        { Name = "Cafe",                CFrame = CFrame.new(-385, 75, 6561) },
    },
    ["Third Sea"] = {
        { Name = "Port Town",           CFrame = CFrame.new(-289, 47, 5566) },
        { Name = "Hydra Island",        CFrame = CFrame.new(5229, 15, 369) },
        { Name = "Great Tree",          CFrame = CFrame.new(2175, 15, -6783) },
        { Name = "Floating Turtle",     CFrame = CFrame.new(-13232, 509, -7558) },
        { Name = "Castle on the Sea",   CFrame = CFrame.new(-5059, 310, -3050) },
        { Name = "Haunted Castle",      CFrame = CFrame.new(-9516, 175, 5663) },
        { Name = "Sea of Treats",       CFrame = CFrame.new(-2834, 74, -10564) },
        { Name = "Tiki Outpost",        CFrame = CFrame.new(-12116, 393, -7560) },
        { Name = "Mansion",             CFrame = CFrame.new(-12842, 405, -7565) },
    },
}

-- ═══════════════════════════════════════════════
-- GAME DATA — QUESTS / NPCS / MOBS BY LEVEL
-- ═══════════════════════════════════════════════

local QuestData = {
    -- First Sea
    { Level = {1, 10},      QuestNPC = "BanditQuest1",    MobName = "Bandit",           Area = "Starter Island",    Sea = 1 },
    { Level = {10, 20},     QuestNPC = "BanditQuest2",    MobName = "Monkey",            Area = "Starter Island",    Sea = 1 },
    { Level = {20, 35},     QuestNPC = "PirateQuest1",    MobName = "Pirate",            Area = "Middle Town",       Sea = 1 },
    { Level = {35, 50},     QuestNPC = "JungleQuest",     MobName = "Gorilla King",      Area = "Jungle",            Sea = 1 },
    { Level = {50, 75},     QuestNPC = "BuggyQuest1",     MobName = "Buggy Pirate",      Area = "Pirate Village",    Sea = 1 },
    { Level = {75, 100},    QuestNPC = "DesertQuest",     MobName = "Desert Bandit",     Area = "Desert",            Sea = 1 },
    { Level = {100, 125},   QuestNPC = "DesertQuest2",    MobName = "Desert Officer",    Area = "Desert",            Sea = 1 },
    { Level = {125, 150},   QuestNPC = "FrozenQuest",     MobName = "Snow Bandit",       Area = "Frozen Village",    Sea = 1 },
    { Level = {150, 175},   QuestNPC = "FrozenQuest2",    MobName = "Snowman",           Area = "Frozen Village",    Sea = 1 },
    { Level = {175, 225},   QuestNPC = "MarineQuest1",    MobName = "Marine Lieutenant",  Area = "Marine Fortress",   Sea = 1 },
    { Level = {225, 275},   QuestNPC = "MarineQuest2",    MobName = "Marine Captain",    Area = "Marine Fortress",   Sea = 1 },
    { Level = {275, 325},   QuestNPC = "SkyQuest1",       MobName = "Sky Bandit",        Area = "Skylands",          Sea = 1 },
    { Level = {325, 375},   QuestNPC = "SkyQuest2",       MobName = "Dark Master",       Area = "Skylands",          Sea = 1 },
    { Level = {375, 425},   QuestNPC = "PrisonQuest",     MobName = "Prisoner",          Area = "Prison",            Sea = 1 },
    { Level = {425, 475},   QuestNPC = "ColosseumQuest",  MobName = "Gladiator",         Area = "Colosseum",         Sea = 1 },
    { Level = {475, 525},   QuestNPC = "MagmaQuest",      MobName = "Military Soldier",  Area = "Magma Village",     Sea = 1 },
    { Level = {525, 575},   QuestNPC = "MagmaQuest2",     MobName = "Military Spy",      Area = "Magma Village",     Sea = 1 },
    { Level = {575, 625},   QuestNPC = "FishmanQuest",    MobName = "Fishman Warrior",   Area = "Underwater City",   Sea = 1 },
    { Level = {625, 675},   QuestNPC = "FishmanQuest2",   MobName = "Fishman Captain",   Area = "Underwater City",   Sea = 1 },
    { Level = {675, 700},   QuestNPC = "FountainQuest",   MobName = "Galley Pirate",     Area = "Fountain City",     Sea = 1 },

    -- Second Sea
    { Level = {700, 750},   QuestNPC = "RoseQuest1",      MobName = "Swan Pirate",       Area = "Kingdom of Rose",   Sea = 2 },
    { Level = {750, 800},   QuestNPC = "RoseQuest2",      MobName = "Factory Staff",     Area = "Kingdom of Rose",   Sea = 2 },
    { Level = {800, 850},   QuestNPC = "GreenQuest",      MobName = "Green Zone Pirate", Area = "Green Zone",        Sea = 2 },
    { Level = {850, 925},   QuestNPC = "GraveQuest1",     MobName = "Zombie",            Area = "Graveyard",         Sea = 2 },
    { Level = {925, 975},   QuestNPC = "GraveQuest2",     MobName = "Vampire",           Area = "Graveyard",         Sea = 2 },
    { Level = {975, 1050},  QuestNPC = "SnowMtnQuest",    MobName = "Snow Trooper",      Area = "Snow Mountain",     Sea = 2 },
    { Level = {1050, 1100}, QuestNPC = "HotColdQuest",    MobName = "Magma Ninja",       Area = "Hot and Cold",      Sea = 2 },
    { Level = {1100, 1175}, QuestNPC = "IceCastleQuest",  MobName = "Ice Viking",        Area = "Ice Castle",        Sea = 2 },
    { Level = {1175, 1250}, QuestNPC = "ForgottenQuest",  MobName = "Forest Pirate",     Area = "Forgotten Island",  Sea = 2 },
    { Level = {1250, 1325}, QuestNPC = "DarkArenaQuest",  MobName = "Awakened",          Area = "Dark Arena",        Sea = 2 },

    -- Third Sea
    { Level = {1325, 1400}, QuestNPC = "PortQuest1",      MobName = "Pirate Millionaire", Area = "Port Town",        Sea = 3 },
    { Level = {1400, 1475}, QuestNPC = "HydraQuest",      MobName = "Dragon Crew",       Area = "Hydra Island",      Sea = 3 },
    { Level = {1475, 1525}, QuestNPC = "TreeQuest",       MobName = "Jungle Pirate",     Area = "Great Tree",        Sea = 3 },
    { Level = {1525, 1575}, QuestNPC = "TurtleQuest",     MobName = "Musketeer Pirate",  Area = "Floating Turtle",   Sea = 3 },
    { Level = {1575, 1625}, QuestNPC = "CastleQuest",     MobName = "Marine Commodore",  Area = "Castle on the Sea", Sea = 3 },
    { Level = {1625, 1700}, QuestNPC = "HauntedQuest",    MobName = "Cursed Captain",    Area = "Haunted Castle",    Sea = 3 },
    { Level = {1700, 1775}, QuestNPC = "TreatsQuest",     MobName = "Cookie Crafter",    Area = "Sea of Treats",     Sea = 3 },
    { Level = {1775, 1825}, QuestNPC = "TikiQuest",       MobName = "Jungle Islander",   Area = "Tiki Outpost",      Sea = 3 },
    { Level = {1825, 2550}, QuestNPC = "MansionQuest",    MobName = "Mansion Guard",     Area = "Mansion",           Sea = 3 },
}

-- ═══════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════

local State = {
    -- Auto Farm
    AutoFarm = false,
    AutoQuest = true,
    BringMobs = false,
    FarmSpeed = 200,
    SelectedQuest = nil,
    AttackMethod = "Melee",   -- Melee, Sword, Fruit

    -- Teleport
    InstantTP = false,

    -- ESP
    FruitESP = false,
    PlayerESP = false,
    ChestESP = false,
    MobESP = false,

    -- Misc
    AntiAFK = true,
    FastAttack = false,
    NoClip = false,
    InfiniteJump = false,
    AutoStats = false,
    StatPriority = "Melee",  -- Melee, Defense, Sword, Gun, Blox Fruit
    FruitSniper = false,
    AutoRejoin = false,

    -- Internal
    _connections = {},
    _espObjects = {},
    _running = true,
}

-- ═══════════════════════════════════════════════
-- CLEANUP PREVIOUS INSTANCES
-- ═══════════════════════════════════════════════

pcall(function()
    if getgenv().SunSkriptLoaded then
        getgenv().SunSkriptState._running = false
        task.wait(0.2)
    end
end)
pcall(function()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name == "SunSkriptMain" then gui:Destroy() end
    end
end)
pcall(function()
    if gethui then
        for _, gui in ipairs(gethui():GetChildren()) do
            if gui.Name == "SunSkriptMain" then gui:Destroy() end
        end
    end
end)

getgenv().SunSkriptLoaded = true
getgenv().SunSkriptState = State

-- ═══════════════════════════════════════════════
-- UI LIBRARY (Minimal Glassmorphism)
-- ═══════════════════════════════════════════════

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

local UI = {}

-- Colors
UI.Colors = {
    Bg = Color3.fromRGB(12, 12, 18),
    Card = Color3.fromRGB(22, 22, 32),
    CardHover = Color3.fromRGB(30, 30, 42),
    Accent = Color3.fromRGB(255, 180, 50),
    AccentDim = Color3.fromRGB(200, 140, 40),
    AccentGlow = Color3.fromRGB(255, 210, 100),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(120, 120, 140),
    Divider = Color3.fromRGB(40, 40, 55),
    Success = Color3.fromRGB(80, 200, 120),
    Error = Color3.fromRGB(230, 75, 75),
    ToggleOff = Color3.fromRGB(55, 55, 70),
    TabActive = Color3.fromRGB(255, 180, 50),
    TabInactive = Color3.fromRGB(80, 80, 100),
}

local C = UI.Colors

local function Tw(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SunSkriptMain"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ProtectGui(ScreenGui)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.BackgroundColor3 = C.Bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = C.Divider
MainStroke.Thickness = 1
MainStroke.Transparency = 0.4

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = C.Card
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 12)

-- Sun icon in top bar
local TopSun = Instance.new("TextLabel")
TopSun.Name = "Sun"
TopSun.Size = UDim2.new(0, 30, 0, 30)
TopSun.Position = UDim2.new(0, 12, 0.5, -15)
TopSun.BackgroundColor3 = C.Accent
TopSun.BackgroundTransparency = 0
TopSun.Text = "☀"
TopSun.TextColor3 = C.Bg
TopSun.TextSize = 16
TopSun.Font = Enum.Font.GothamBold
TopSun.ZIndex = 6
TopSun.Parent = TopBar
Instance.new("UICorner", TopSun).CornerRadius = UDim.new(1, 0)

local TopTitle = Instance.new("TextLabel")
TopTitle.Name = "Title"
TopTitle.Size = UDim2.new(0, 200, 1, 0)
TopTitle.Position = UDim2.new(0, 50, 0, 0)
TopTitle.BackgroundTransparency = 1
TopTitle.Text = "Sun Skript"
TopTitle.TextColor3 = C.Text
TopTitle.TextSize = 16
TopTitle.Font = Enum.Font.GothamBold
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.ZIndex = 6
TopTitle.Parent = TopBar

local TopVersion = Instance.new("TextLabel")
TopVersion.Name = "Version"
TopVersion.Size = UDim2.new(0, 100, 1, 0)
TopVersion.Position = UDim2.new(0, 160, 0, 0)
TopVersion.BackgroundTransparency = 1
TopVersion.Text = "v1.0.0"
TopVersion.TextColor3 = C.TextDim
TopVersion.TextSize = 11
TopVersion.Font = Enum.Font.Gotham
TopVersion.TextXAlignment = Enum.TextXAlignment.Left
TopVersion.ZIndex = 6
TopVersion.Parent = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = C.Divider
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.TextDim
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 7
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "Minimize"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = C.Divider
MinBtn.BackgroundTransparency = 0.5
MinBtn.Text = "—"
MinBtn.TextColor3 = C.TextDim
MinBtn.TextSize = 12
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 7
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Hover effects
for _, btn in ipairs({CloseBtn, MinBtn}) do
    btn.MouseEnter:Connect(function()
        Tw(btn, { BackgroundTransparency = 0.2 }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, { BackgroundTransparency = 0.5 }, 0.15)
    end)
end

-- Tab sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = C.Card
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 4
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

-- Content area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -136, 1, -50)
Content.Position = UDim2.new(0, 134, 0, 46)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 4
Content.ClipsDescendants = true
Content.Parent = MainFrame

-- Tab system
local Tabs = {}
local ActiveTab = nil
local TabPages = {}

function UI.AddTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. name
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C.Card
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BackgroundColor3 = C.Accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 6
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 24, 1, 0)
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "•"
    iconLabel.TextColor3 = C.TabInactive
    iconLabel.TextSize = 14
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = 6
    iconLabel.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -38, 1, 0)
    label.Position = UDim2.new(0, 36, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.TabInactive
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = btn

    -- Page
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Accent
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 5
    page.Parent = Content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 6)
    pagePadding.PaddingLeft = UDim.new(0, 8)
    pagePadding.PaddingRight = UDim.new(0, 8)
    pagePadding.PaddingBottom = UDim.new(0, 12)
    pagePadding.Parent = page

    local tab = {
        Button = btn,
        Page = page,
        Indicator = indicator,
        IconLabel = iconLabel,
        Label = label,
    }
    table.insert(Tabs, tab)
    TabPages[name] = page

    local function Select()
        for _, t in ipairs(Tabs) do
            Tw(t.Indicator, { BackgroundTransparency = 1 }, 0.2)
            Tw(t.IconLabel, { TextColor3 = C.TabInactive }, 0.2)
            Tw(t.Label, { TextColor3 = C.TabInactive }, 0.2)
            Tw(t.Button, { BackgroundTransparency = 1 }, 0.2)
            t.Page.Visible = false
        end
        Tw(indicator, { BackgroundTransparency = 0 }, 0.2)
        Tw(iconLabel, { TextColor3 = C.Accent }, 0.2)
        Tw(label, { TextColor3 = C.Text }, 0.2)
        Tw(btn, { BackgroundTransparency = 0.7 }, 0.2)
        page.Visible = true
        ActiveTab = tab
    end

    btn.MouseButton1Click:Connect(Select)

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= tab then
            Tw(btn, { BackgroundTransparency = 0.8 }, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= tab then
            Tw(btn, { BackgroundTransparency = 1 }, 0.15)
        end
    end)

    -- Select first tab by default
    if #Tabs == 1 then Select() end

    return page, Select
end

-- UI Element: Section Header
function UI.AddSection(page, text)
    local section = Instance.new("TextLabel")
    section.Name = "Section"
    section.Size = UDim2.new(1, 0, 0, 22)
    section.BackgroundTransparency = 1
    section.Text = text:upper()
    section.TextColor3 = C.AccentDim
    section.TextSize = 10
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.ZIndex = 6
    section.Parent = page
    return section
end

-- UI Element: Toggle
function UI.AddToggle(page, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. text
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.ZIndex = 6
    frame.Parent = page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = frame

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = default and C.Accent or C.ToggleOff
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 7
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob.Parent = toggleBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local toggled = default

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 9
    btn.AutoButtonColor = false
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        Tw(toggleBg, { BackgroundColor3 = toggled and C.Accent or C.ToggleOff }, 0.2)
        Tw(knob, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2)
        if callback then callback(toggled) end
    end)

    frame.MouseEnter:Connect(function()
        Tw(frame, { BackgroundTransparency = 0.2 }, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        Tw(frame, { BackgroundTransparency = 0.4 }, 0.15)
    end)

    return {
        Set = function(val)
            toggled = val
            Tw(toggleBg, { BackgroundColor3 = toggled and C.Accent or C.ToggleOff }, 0.2)
            Tw(knob, { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2)
        end,
        Get = function() return toggled end
    }
end

-- UI Element: Button
function UI.AddButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. text
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.Card
    btn.BackgroundTransparency = 0.4
    btn.Text = text
    btn.TextColor3 = C.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.ZIndex = 7
    btn.AutoButtonColor = false
    btn.Parent = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    btn.MouseEnter:Connect(function()
        Tw(btn, { BackgroundTransparency = 0.2, TextColor3 = C.Accent }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, { BackgroundTransparency = 0.4, TextColor3 = C.Text }, 0.15)
    end)
    return btn
end

-- UI Element: Dropdown
function UI.AddDropdown(page, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. text
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.ZIndex = 6
    frame.ClipsDescendants = true
    frame.Parent = page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -8, 0, 34)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = frame

    local selected = default or options[1]

    local selectBtn = Instance.new("TextButton")
    selectBtn.Name = "Select"
    selectBtn.Size = UDim2.new(0.5, -12, 0, 26)
    selectBtn.Position = UDim2.new(0.5, 4, 0, 4)
    selectBtn.BackgroundColor3 = C.Divider
    selectBtn.BackgroundTransparency = 0.3
    selectBtn.Text = tostring(selected) .. "  ▾"
    selectBtn.TextColor3 = C.AccentGlow
    selectBtn.TextSize = 11
    selectBtn.Font = Enum.Font.GothamMedium
    selectBtn.ZIndex = 8
    selectBtn.AutoButtonColor = false
    selectBtn.Parent = frame
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)

    local expanded = false

    -- Option list
    local optionContainer = Instance.new("Frame")
    optionContainer.Name = "Options"
    optionContainer.Size = UDim2.new(0.5, -12, 0, #options * 26)
    optionContainer.Position = UDim2.new(0.5, 4, 0, 32)
    optionContainer.BackgroundColor3 = C.Card
    optionContainer.BackgroundTransparency = 0.1
    optionContainer.BorderSizePixel = 0
    optionContainer.ZIndex = 10
    optionContainer.Visible = false
    optionContainer.Parent = frame
    Instance.new("UICorner", optionContainer).CornerRadius = UDim.new(0, 6)

    local optLayout = Instance.new("UIListLayout")
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Parent = optionContainer

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name = "Opt_" .. tostring(opt)
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = C.Divider
        optBtn.BackgroundTransparency = 0.8
        optBtn.Text = tostring(opt)
        optBtn.TextColor3 = C.Text
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.Gotham
        optBtn.ZIndex = 11
        optBtn.AutoButtonColor = false
        optBtn.Parent = optionContainer

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selectBtn.Text = tostring(selected) .. "  ▾"
            expanded = false
            optionContainer.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 34)
            if callback then callback(opt) end
        end)
        optBtn.MouseEnter:Connect(function()
            Tw(optBtn, { BackgroundTransparency = 0.4, TextColor3 = C.Accent }, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            Tw(optBtn, { BackgroundTransparency = 0.8, TextColor3 = C.Text }, 0.1)
        end)
    end

    selectBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionContainer.Visible = expanded
        frame.Size = expanded and UDim2.new(1, 0, 0, 34 + #options * 26 + 4) or UDim2.new(1, 0, 0, 34)
    end)

    return {
        Get = function() return selected end,
        Set = function(val)
            selected = val
            selectBtn.Text = tostring(selected) .. "  ▾"
        end
    }
end

-- UI Element: Label (info text)
function UI.AddLabel(page, text)
    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = page
    return label
end

-- ═══════════════════════════════════════════════
-- CORE FUNCTIONS
-- ═══════════════════════════════════════════════

local function GetPlayerLevel()
    local stats = Player:FindFirstChild("Data") or Player:FindFirstChild("Stats")
    if stats then
        local lvl = stats:FindFirstChild("Level")
        if lvl then return lvl.Value end
    end
    -- Fallback: try to read from leaderstats
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local lvl = ls:FindFirstChild("Level")
        if lvl then return lvl.Value end
    end
    return 1
end

local function GetBestQuest()
    local lvl = GetPlayerLevel()
    local best = nil
    for _, q in ipairs(QuestData) do
        if lvl >= q.Level[1] and lvl <= q.Level[2] then
            best = q
            break
        end
    end
    -- If level exceeds all quests, use the last one
    if not best then
        best = QuestData[#QuestData]
    end
    return best
end

local function FindNearestMob(mobName)
    local nearest = nil
    local nearestDist = math.huge
    local hrp = GetHRP()
    if not hrp then return nil end

    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, mob in ipairs(folder:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid") then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    if hum.Health > 0 then
                        local nameMatch = (mobName == nil) or (mob.Name == mobName) or (mob.Name:find(mobName))
                        if nameMatch then
                            local dist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = mob
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

local function GetQuestNPC(npcName)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == npcName and (obj:IsA("Model") or obj:IsA("Part")) then
            local part = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if part then
                return part
            end
        end
    end
    return nil
end

local function HasActiveQuest()
    local questUI = Player.PlayerGui:FindFirstChild("Main")
    if questUI then
        local quest = questUI:FindFirstChild("Quest", true)
        if quest and quest.Visible then
            return true
        end
    end
    return false
end

local function AcceptQuest(questNPCName)
    -- Try multiple remote patterns used by Blox Fruits
    pcall(function()
        local remotes = RS:FindFirstChild("Remotes")
        if remotes then
            local questRemote = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
            if questRemote then
                questRemote:InvokeServer("StartQuest", questNPCName, 1)
            end
        end
    end)
end

local function AttackNearest()
    -- Simulate mouse click for melee / sword / fruit attacks
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(
            Mouse.X, Mouse.Y, 0, true, game, 0
        )
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(
            Mouse.X, Mouse.Y, 0, false, game, 0
        )
    end)
end

local function EquipBestWeapon(method)
    local bp = Player.Backpack
    local char = GetCharacter()
    if not bp or not char then return end

    -- Find and equip weapon based on method
    if method == "Melee" then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:find("Combat") or tool.Name:find("Fist") or tool.Name:find("Fighting")) then
                char.Humanoid:EquipTool(tool)
                return
            end
        end
    elseif method == "Sword" then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("ToolTip") then
                local tip = tool.ToolTip
                if tip and (tip:lower():find("sword") or tip:lower():find("blade") or tip:lower():find("cutlass")) then
                    char.Humanoid:EquipTool(tool)
                    return
                end
            end
        end
        -- Fallback: equip any tool
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                char.Humanoid:EquipTool(tool)
                return
            end
        end
    elseif method == "Fruit" then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and not (tool.Name:find("Combat") or tool.Name:find("Sword") or tool.Name:find("Blade")) then
                char.Humanoid:EquipTool(tool)
                return
            end
        end
    end
end

local function BringMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local hrp = GetHRP()
    if not hrp then return end
    mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
end

-- ═══════════════════════════════════════════════
-- AUTO FARM LOOP
-- ═══════════════════════════════════════════════

task.spawn(function()
    while State._running do
        if State.AutoFarm and IsAlive() then
            local quest = State.SelectedQuest or GetBestQuest()
            if quest then
                -- Step 1: Accept quest if needed
                if State.AutoQuest and not HasActiveQuest() then
                    local npc = GetQuestNPC(quest.QuestNPC)
                    if npc then
                        local npcPos = npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.CFrame or npc.CFrame
                        if GetDistance(npcPos.Position) > 15 then
                            Teleport(npcPos + Vector3.new(0, 5, 0))
                            task.wait(0.5)
                        end
                        AcceptQuest(quest.QuestNPC)
                        task.wait(0.5)
                    end
                end

                -- Step 2: Find and attack mob
                local mob, dist = FindNearestMob(quest.MobName)
                if mob then
                    EquipBestWeapon(State.AttackMethod)

                    if State.BringMobs then
                        BringMob(mob)
                    else
                        if dist > 15 then
                            local mobCF = mob.HumanoidRootPart.CFrame
                            Teleport(mobCF * CFrame.new(0, 5, -5))
                        end
                    end

                    -- Attack
                    AttackNearest()
                else
                    -- No mob found, teleport to area
                    for seaName, islandList in pairs(Islands) do
                        for _, island in ipairs(islandList) do
                            if island.Name == quest.Area then
                                if GetDistance(island.CFrame.Position) > 300 then
                                    Teleport(island.CFrame)
                                    task.wait(1)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- ═══════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════

local function CreateESPBillboard(parent, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Name = "SunESP"
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 2000
    bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bb.Adornee = parent
    bb.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lbl.BackgroundTransparency = 0.6
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.6
    lbl.Parent = bb
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)

    table.insert(State._espObjects, bb)
    return bb
end

local function ClearESP()
    for _, obj in ipairs(State._espObjects) do
        pcall(function() obj:Destroy() end)
    end
    State._espObjects = {}
end

-- Fruit ESP loop
task.spawn(function()
    while State._running do
        if State.FruitESP then
            -- Find fruits in workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Handle" and obj.Parent and obj.Parent:IsA("Tool") and not obj.Parent.Parent:IsA("Backpack") and not obj.Parent.Parent:IsA("Model") then
                    if not obj:FindFirstChild("SunESP") then
                        CreateESPBillboard(obj, "🍎 " .. obj.Parent.Name, Color3.fromRGB(255, 200, 50))
                    end
                end
            end
        end

        if State.ChestESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:find("Chest") and obj:IsA("Model") or (obj:IsA("BasePart") and obj.Name:find("Chest")) then
                    local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
                    if part and not part:FindFirstChild("SunESP") then
                        CreateESPBillboard(part, "📦 Chest", Color3.fromRGB(100, 200, 255))
                    end
                end
            end
        end

        if State.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
                    local head = plr.Character.Head
                    if not head:FindFirstChild("SunESP") then
                        local dist = GetDistance(head.Position)
                        CreateESPBillboard(head, plr.DisplayName .. " [" .. math.floor(dist) .. "m]", Color3.fromRGB(255, 100, 100))
                    end
                end
            end
        end

        if not State.FruitESP and not State.ChestESP and not State.PlayerESP and not State.MobESP then
            ClearESP()
        end

        task.wait(2)
    end
end)

-- ═══════════════════════════════════════════════
-- FRUIT SNIPER
-- ═══════════════════════════════════════════════

task.spawn(function()
    while State._running do
        if State.FruitSniper then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Handle" and obj.Parent and obj.Parent:IsA("Tool") then
                    local tool = obj.Parent
                    if not tool.Parent:IsA("Backpack") and not tool.Parent:IsA("Model") then
                        local dist = GetDistance(obj.Position)
                        if dist > 20 then
                            Teleport(obj.CFrame * CFrame.new(0, 5, 0))
                            task.wait(0.5)
                        end
                        -- Try to pick up
                        pcall(function()
                            firetouchinterest(GetHRP(), obj, 0)
                            task.wait(0.15)
                            firetouchinterest(GetHRP(), obj, 1)
                        end)
                        Notify("Sun Skript", "🍎 Found fruit: " .. tool.Name .. "!", 5)
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════
-- MISC LOOPS
-- ═══════════════════════════════════════════════

-- Anti-AFK
task.spawn(function()
    while State._running do
        if State.AntiAFK then
            pcall(function()
                local con
                con = Player.Idled:Connect(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                end)
                table.insert(State._connections, con)
            end)
        end
        task.wait(30)
    end
end)

-- No Clip
task.spawn(function()
    while State._running do
        if State.NoClip and IsAlive() then
            pcall(function()
                local char = GetCharacter()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Infinite Jump
do
    local jumpConn
    jumpConn = UserInputService.JumpRequest:Connect(function()
        if State.InfiniteJump and IsAlive() then
            pcall(function()
                GetHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
    table.insert(State._connections, jumpConn)
end

-- Fast Attack
task.spawn(function()
    while State._running do
        if State.FastAttack and IsAlive() then
            pcall(function()
                local char = GetCharacter()
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    -- Speed up animations
                    for _, anim in ipairs(char:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
                        if anim.Speed < 2 then
                            anim:AdjustSpeed(3)
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Auto Stats
task.spawn(function()
    while State._running do
        if State.AutoStats then
            pcall(function()
                local remotes = RS:FindFirstChild("Remotes")
                if remotes then
                    local remote = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommF")
                    if remote then
                        remote:InvokeServer("AddPoint", State.StatPriority, 1)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ═══════════════════════════════════════════════
-- BUILD UI TABS
-- ═══════════════════════════════════════════════

-- TAB 1: Auto Farm
local farmPage = UI.AddTab("Farm", "⚔")
UI.AddSection(farmPage, "Auto Farm")
UI.AddToggle(farmPage, "Auto Farm", false, function(v) State.AutoFarm = v end)
UI.AddToggle(farmPage, "Auto Quest", true, function(v) State.AutoQuest = v end)
UI.AddToggle(farmPage, "Bring Mobs", false, function(v) State.BringMobs = v end)

UI.AddSection(farmPage, "Combat")
UI.AddDropdown(farmPage, "Attack Method", {"Melee", "Sword", "Fruit"}, "Melee", function(v)
    State.AttackMethod = v
end)

local questInfo = UI.AddLabel(farmPage, "Quest: Auto-detect (Level " .. tostring(GetPlayerLevel()) .. ")")

UI.AddSection(farmPage, "Stats")
UI.AddToggle(farmPage, "Auto Stats", false, function(v) State.AutoStats = v end)
UI.AddDropdown(farmPage, "Stat Priority", {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}, "Melee", function(v)
    State.StatPriority = v
end)

-- TAB 2: ESP
local espPage = UI.AddTab("ESP", "👁")
UI.AddSection(espPage, "Visuals")
UI.AddToggle(espPage, "Fruit ESP", false, function(v) State.FruitESP = v end)
UI.AddToggle(espPage, "Player ESP", false, function(v) State.PlayerESP = v end)
UI.AddToggle(espPage, "Chest ESP", false, function(v) State.ChestESP = v end)
UI.AddToggle(espPage, "Mob ESP", false, function(v) State.MobESP = v end)

UI.AddSection(espPage, "Fruit Sniper")
UI.AddToggle(espPage, "Fruit Sniper", false, function(v) State.FruitSniper = v end)
UI.AddLabel(espPage, "Auto-teleports to nearby fruits")

-- TAB 3: Teleport
local tpPage = UI.AddTab("Teleport", "📍")

UI.AddSection(tpPage, "Settings")
UI.AddToggle(tpPage, "Instant TP (Reset Bypass)", false, function(v) State.InstantTP = v end)
UI.AddLabel(tpPage, "Instantly teleports you by resetting your character.")

for seaName, islandList in pairs(Islands) do
    UI.AddSection(tpPage, seaName)
    for _, island in ipairs(islandList) do
        UI.AddButton(tpPage, island.Name, function()
            if IsAlive() then
                Teleport(island.CFrame)
                Notify("Sun Skript", "Teleported to " .. island.Name)
            end
        end)
    end
end

-- TAB 4: Misc
local miscPage = UI.AddTab("Misc", "⚙")
UI.AddSection(miscPage, "Movement")
UI.AddToggle(miscPage, "No Clip", false, function(v) State.NoClip = v end)
UI.AddToggle(miscPage, "Infinite Jump", false, function(v) State.InfiniteJump = v end)

UI.AddSection(miscPage, "Combat")
UI.AddToggle(miscPage, "Fast Attack", false, function(v) State.FastAttack = v end)

UI.AddSection(miscPage, "Utility")
UI.AddToggle(miscPage, "Anti-AFK", true, function(v) State.AntiAFK = v end)
UI.AddButton(miscPage, "Rejoin Server", function()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end)
end)
UI.AddButton(miscPage, "Server Hop", function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
        if servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                    break
                end
            end
        end
    end)
end)
UI.AddButton(miscPage, "Copy HWID", function()
    pcall(function()
        local hwid = "Unknown"
        if gethwid then hwid = gethwid()
        elseif get_hwid then hwid = get_hwid()
        else hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end
        if setclipboard then setclipboard(hwid) end
        Notify("Sun Skript", "HWID copied!")
    end)
end)

UI.AddSection(miscPage, "World")
UI.AddButton(miscPage, "Full Bright", function()
    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end
        Notify("Sun Skript", "Full Bright enabled")
    end)
end)
UI.AddButton(miscPage, "Reset Character", function()
    pcall(function()
        GetHumanoid().Health = 0
    end)
end)

-- ═══════════════════════════════════════════════
-- DRAGGABLE TOP BAR
-- ═══════════════════════════════════════════════

do
    local dragging = false
    local dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tw(MainFrame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.06, Enum.EasingStyle.Quad)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- KEYBIND & MOBILE TOGGLE
-- ═══════════════════════════════════════════════

local uiVisible = true
local lastPos = UDim2.new(0.5, 0, 0.5, 0) -- Corrected default center position for AnchorPoint(0.5, 0.5)

local MobileBtn = Instance.new("TextButton")
MobileBtn.Name = "MobileToggle"
MobileBtn.Size = UDim2.new(0, 46, 0, 46)
MobileBtn.Position = UDim2.new(0, 15, 0.5, -23)
MobileBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MobileBtn.BackgroundTransparency = 0.2
MobileBtn.Text = "☀"
MobileBtn.TextColor3 = Color3.fromRGB(255, 180, 50)
MobileBtn.TextSize = 24
MobileBtn.Font = Enum.Font.GothamBold
MobileBtn.ZIndex = 50
MobileBtn.Active = true
MobileBtn.Draggable = true
MobileBtn.Parent = ScreenGui

local MobileBtnCorner = Instance.new("UICorner", MobileBtn)
MobileBtnCorner.CornerRadius = UDim.new(1, 0)
local MobileBtnStroke = Instance.new("UIStroke", MobileBtn)
MobileBtnStroke.Color = Color3.fromRGB(255, 180, 50)
MobileBtnStroke.Thickness = 2
MobileBtnStroke.Transparency = 0.5

local function ToggleUI()
    uiVisible = not uiVisible
    if uiVisible then
        MainFrame.Visible = true
        Tw(MainFrame, {
            Size = UDim2.new(0, 560, 0, 380),
            Position = lastPos,
            BackgroundTransparency = 0.05
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        lastPos = MainFrame.Position
        
        -- Target the center of the Sun Logo
        local targetPos = UDim2.new(
            MobileBtn.Position.X.Scale, MobileBtn.Position.X.Offset + (MobileBtn.Size.X.Offset/2),
            MobileBtn.Position.Y.Scale, MobileBtn.Position.Y.Offset + (MobileBtn.Size.Y.Offset/2)
        )
        
        -- Fly into the Sun Logo like a meteor
        Tw(MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = targetPos,
            BackgroundTransparency = 1
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.4, function()
            if not uiVisible then MainFrame.Visible = false end
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUI()
    end
end)

MobileBtn.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- ═══════════════════════════════════════════════
-- CLOSE / MINIMIZE
-- ═══════════════════════════════════════════════

local closeConfirm = false
CloseBtn.MouseButton1Click:Connect(function()
    if not closeConfirm then
        closeConfirm = true
        CloseBtn.Text = "Sure?"
        CloseBtn.TextColor3 = Color3.fromRGB(240, 80, 80)
        task.delay(3, function()
            if closeConfirm then
                closeConfirm = false
                CloseBtn.Text = "✕"
                CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end)
        return
    end

    State._running = false
    ClearESP()
    for _, conn in ipairs(State._connections) do
        pcall(function() conn:Disconnect() end)
    end
    Tw(MainFrame, { Size = UDim2.new(0, 560, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.35)
    ScreenGui:Destroy()
    getgenv().SunSkriptLoaded = false
end)

MinBtn.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- ═══════════════════════════════════════════════
-- INTRO ANIMATION
-- ═══════════════════════════════════════════════

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1

task.spawn(function()
    Tw(MainFrame, {
        Size = UDim2.new(0, 560, 0, 380),
        BackgroundTransparency = 0.05,
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.wait(0.6)
end)

-- ═══════════════════════════════════════════════
-- DONE
-- ═══════════════════════════════════════════════

Notify("Sun Skript", "Blox Fruits module loaded! Press RightControl or tap the Sun icon to toggle.")
print("[Sun Skript] Blox Fruits v1.0.0 loaded — " .. #QuestData .. " quest levels mapped.")
