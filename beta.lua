local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= ABSOLUTE THROUGHPUT LOCALS =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Localize Remotes for Maximum Speed
local RF_C = net:WaitForChild("RF/ChargeFishingRod")
local RF_S = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Cm = net:WaitForChild("RE/FishingCompleted")
local RF_Sl = net:FindFirstChild("RF/SellFish")

-- Method Localization (Branchless Path)
local invoke = RF_C.InvokeServer
local fire = RE_Cm.FireServer
local twait = task.wait
local clock = os.clock

-- ================= WINDOW INITIALIZATION =================
local Window = UI.New({
    Title = "SMK Fishing Mod",
    Subtitle = "Absolute v15.0",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "SMK_Absolute_v15"
})

local Defaults = { Reel = 0.00001, Catch = 0.57 }
local Config = {
    B = false, -- High Throughput Flag
    S = false, -- Auto Sale Flag
    N = false, -- No Animation Flag
    Reel = Defaults.Reel,
    Catch = Defaults.Catch,
    Interval = 60,
    Cap = 1000,
    MinRar = "Legendary",
    FavNames = {"Secret", "Crystal", "Golden"}
}

-- ================= 1. BRANCHLESS FISHING ENGINE =================
local reelDelay = Defaults.Reel
local catchDelay = Defaults.Catch
local fishingThread

local function fishingLoop()
    while true do
        invoke(RF_C)
        twait(reelDelay)

        invoke(RF_S, 18.76, 0.5, clock())
        twait(catchDelay)

        fire(RE_Cm)
        twait() -- Prevent engine freeze
    end
end

-- ================= 2. EVENT-DRIVEN AUTO SALE =================
local lastSell = 0
local capacityLabel

-- One-time UI Scan for Capacity Label
local function findCapacityLabel()
    for _, v in ipairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text:match("^%d+/%d+") then
            return v
        end
    end
end

capacityLabel = findCapacityLabel()

if capacityLabel then
    capacityLabel:GetPropertyChangedSignal("Text"):Connect(function()
        if not Config.S then return end

        local cur, max = capacityLabel.Text:match("^(%d+)%/(%d+)")
        cur = tonumber(cur)
        max = tonumber(max) or Config.Cap

        if cur >= max then
            local now = clock()
            if (now - lastSell) / 60 >= Config.Interval then
                if RF_Sl then
                    invoke(RF_Sl, "All")
                end
                lastSell = now
                UI.Pill("Capacity Reached: Inventory Sold!")
            end
        end
    end)
end

-- ================= UTILITIES =================
RS.Heartbeat:Connect(function()
    if Config.N then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then
            for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
        end
    end
end)

local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- ================= TAB FISHING =================
local Tab1 = Window:AddTab("Fishing", UI.Icons.Combat)

Tab1:AddSection("Branchless Turbo")
Tab1:AddInput("Bait Speed", function(t) Config.Reel = tonumber(t) or Defaults.Reel end)
Tab1:AddInput("Catch Speed", function(t) Config.Catch = tonumber(t) or Defaults.Catch end)

Tab1:AddToggle("EXTREME THROUGHPUT", { Flag = "b_on" }, function(v)
    Config.B = v
    if v and not fishingThread then
        -- Snapshot tunables into upvalues for the loop
        reelDelay = Config.Reel
        catchDelay = Config.Catch
        fishingThread = task.spawn(fishingLoop)
        UI.Pill("Turbo Engaged: Branchless Loop Active")
    elseif not v and fishingThread then
        task.cancel(fishingThread)
        fishingThread = nil
        UI.Pill("Turbo Disengaged")
    end
end)

-- ================= TAB FARMING =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite Filter")
Tab2:AddDropdown("Exclusion Rarity", {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, function(v) Config.MinRar = v end)
Tab2:AddInput("Fav Names (Comma)", function(t) Config.FavNames = string.split(t, ",") end)

Tab2:AddSection("Market Control")
Tab2:AddInput("Sale Interval (Min)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Max Capacity", function(t) Config.Cap = tonumber(t) or 1000 end)

Tab2:AddToggle("Auto Cleanup (Event-Driven)", { Flag = "s_on" }, function(v)
    Config.S = v
    if v then 
        UI.Success("Auto Sale Active")
        if not capacityLabel then UI.Error("UI Scanner", "Capacity Label not found!") end
    end
end)

-- ================= TAB TELEPORT (FULL 14 LOCATIONS) =================
local Tab3 = Window:AddTab("Teleport", UI.Icons.Teleport)
Tab3:AddSection("Islands")
Tab3:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
Tab3:AddButton("Sandy Bay", function() tp(35.82, 9.64, 2803.89) end)
Tab3:AddButton("Frozen Fjord", function() tp(1012.64, 23.53, 5077.73) end)
Tab3:AddButton("Kohana Volcano", function() tp(-596.68, 60.47, 104.55) end)
Tab3:AddButton("Ancient Jungle", function() tp(1470.78, 5.37, -326.65) end)
Tab3:AddButton("Sacred Temple", function() tp(1477.36, -21.52, -649.19) end)
Tab3:AddButton("The Abyss 1", function() tp(6049.66, -538.60, 4358.95) end)
Tab3:AddButton("The Abyss 2", function() tp(6100.35, -585.48, 4685.32) end)
Tab3:AddButton("Crater Island", function() tp(-1514.61, 5.43, 1891.73) end)
Tab3:AddButton("Lost Isle", function() tp(-2786.48, 8.47, 2128.80) end)
Tab3:AddButton("Coral Reef", function() tp(-2099.63, 5.95, 3696.73) end)
Tab3:AddButton("Deepwater Cavern", function() tp(-3696.02, -134.59, -1011.64) end)
Tab3:AddButton("Underground Cellar", function() tp(-3604.98, -266.76, -1580.89) end)
Tab3:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

-- ================= TAB SETTINGS =================
local Tab4 = Window:AddTab("Settings", UI.Icons.Settings)
Tab4:AddSection("Menu & Device")
Tab4:AddKeybind("Toggle UI Key", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab4:AddToggle("Force Rigid Animations", { Flag = "n_on" }, function(v) Config.N = v end)
Tab4:AddButton("Enable Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        twait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Enabled")
end)
Tab4:AddDangerButton("Unload Script", function() UI.Unload() end)

-- MOBILE SUPPORT
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "SMK Fishing Mod", Subtitle = "v15.0 Absolute Optimization", Duration = 2 })
