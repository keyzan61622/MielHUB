local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= OPTIMASI EXTREME TURBO =================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Mencari remote (pake FindFirstChild biar gak infinite yield)
local RF_Charge = net:FindFirstChild("RF/ChargeFishingRod")
local RF_Start = net:FindFirstChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:FindFirstChild("RE/FishingCompleted")
local RF_Sell = net:FindFirstChild("RF/SellFish")

-- Lokalisasi fungsi untuk kecepatan maksimal
local InvokeServer = RF_Charge and RF_Charge.InvokeServer
local FireServer = RE_Complete and RE_Complete.FireServer
local wait = task.wait
local spawn = task.spawn

local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "v11.0(BETA)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_Fishit"
})

-- Default Configuration
local Defaults = { Reel = 0.00001, Catch = 0.57, Instant = 0.5 }
local Config = {
    InstantEnabled = false,
    BlatantEnabled = false,
    AutoSale = false,
    NoAnimEnabled = false,
    -- Favorite Filter
    MinRarity = "Legendary",
    MinRate = 1000,
    FavNames = {"Crystal", "Golden"},
    -- Auto Sale Logic
    SaleInterval = 60, -- default menit
    SaleCapacity = 1000, -- default isi tas
    -- Delays
    InstantDelayComplete = Defaults.Instant,
    BlatantDelayReel = Defaults.Reel,
    BlatantDelayComplete = Defaults.Catch
}

-- Fungsi Deteksi Isi Tas (Membaca angka depan dari UI misal "8/10")
local function getInventoryCount()
    local pGui = LP:FindFirstChild("PlayerGui")
    local mainUI = pGui and pGui:FindFirstChild("MainUI")
    -- Menyesuaikan dengan label di screenshot kamu
    local invLabel = mainUI and mainUI:FindFirstChild("Inventory") 
    if invLabel and invLabel:IsA("TextLabel") then
        local count = invLabel.Text:match("^(%d+)")
        return tonumber(count) or 0
    end
    return 0
end

-- Fix No Animation (Kaku Terus pake Heartbeat)
RS.Heartbeat:Connect(function()
    if Config.NoAnimEnabled then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end
end)

local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- ================= TAB FISHING =================
local FishingTab = Window:AddTab("Fishing", UI.Icons.Combat)

FishingTab:AddSection("Turbo Blatant")
FishingTab:AddInput("Bait Speed (Delay Reel)", function(t) Config.BlatantDelayReel = tonumber(t) or Defaults.Reel end)
FishingTab:AddInput("Catch Speed (Delay Catch)", function(t) Config.BlatantDelayComplete = tonumber(t) or Defaults.Catch end)

FishingTab:AddToggle("Aktifkan Blatant Fishing", { Flag = "blatant_on" }, function(v)
    Config.BlatantEnabled = v
    if v then
        UI.Pill("Extreme Turbo Active!")
        spawn(function()
            while Config.BlatantEnabled do
                if RF_Charge and RF_Start and RE_Complete then
                    InvokeServer(RF_Charge)
                    wait(Config.BlatantDelayReel)
                    InvokeServer(RF_Start, 18.76, 0.5, tick())
                    wait(Config.BlatantDelayComplete)
                    FireServer(RE_Complete)
                    wait(0.0001)
                else
                    wait(1)
                end
            end
        end)
    end
end)

-- ================= TAB FARMING =================
local FarmTab = Window:AddTab("Farming", UI.Icons.Home)

FarmTab:AddSection("Auto Favorite Settings")
FarmTab:AddDropdown("Min Rarity", {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, function(v) 
    Config.MinRarity = v 
end)
FarmTab:AddInput("Min Rate", function(t) Config.MinRate = tonumber(t) or 1000 end)
FarmTab:AddInput("Fav Names (Koma)", function(t) Config.FavNames = string.split(t, ",") end)

FarmTab:AddSection("Auto Sale Control")
FarmTab:AddInput("Sale Every (Menit)", function(t) Config.SaleInterval = tonumber(t) or 60 end)
FarmTab:AddInput("Sale at Count (Isi Tas)", function(t) Config.SaleCapacity = tonumber(t) or 1000 end)

FarmTab:AddToggle("Aktifkan Auto Sale", { Flag = "auto_sale" }, function(v)
    Config.AutoSale = v
    if v then
        UI.Success("Auto Sale ON")
        spawn(function()
            local lastSale = tick()
            while Config.AutoSale do
                local now = tick()
                local timePassed = (now - lastSale) / 60
                local currentBag = getInventoryCount()
                
                -- Trigger Jual: Berdasarkan Waktu ATAU Isi Tas
                if (Config.SaleInterval > 0 and timePassed >= Config.SaleInterval) or 
                   (Config.SaleCapacity > 0 and currentBag >= Config.SaleCapacity) then
                    
                    if RF_Sell then
                        InvokeServer(RF_Sell, "All")
                        lastSale = tick()
                        UI.Pill("Sold: Limit Reached!")
                    end
                end
                wait(10) -- Cek setiap 10 detik
            end
        end)
    end
end)

-- ================= TAB TELEPORT =================
local TPTab = Window:AddTab("Teleport", UI.Icons.Teleport)
TPTab:AddSection("List Pulau Lengkap")
TPTab:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
TPTab:AddButton("Sandy Bay / Hallow", function() tp(35.82, 9.64, 2803.89) end)
TPTab:AddButton("Frozen Fjord / Classic", function() tp(1012.64, 23.53, 5077.73) end)
TPTab:AddButton("Kohana Volcano (Top)", function() tp(-596.68, 60.47, 104.55) end)
TPTab:AddButton("Ancient Jungle (Outer)", function() tp(1470.78, 5.37, -326.65) end)
TPTab:AddButton("Sacred Temple (Inner)", function() tp(1477.36, -21.52, -649.19) end)
TPTab:AddButton("The Abyss (Spot 1)", function() tp(6049.66, -538.60, 4358.95) end)
TPTab:AddButton("The Abyss (Spot 2)", function() tp(6100.35, -585.48, 4685.32) end)
TPTab:AddButton("Crater Island (West)", function() tp(-1514.61, 5.43, 1891.73) end)
TPTab:AddButton("Lost Isle (Far West)", function() tp(-2786.48, 8.47, 2128.80) end)
TPTab:AddButton("Coral Reef (N-West)", function() tp(-2099.63, 5.95, 3696.73) end)
TPTab:AddButton("Deepwater Cavern", function() tp(-3696.02, -134.59, -1011.64) end)
TPTab:AddButton("Underground Cellar", function() tp(-3604.98, -266.76, -1580.89) end)
TPTab:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

-- ================= RECOVERY & SETTINGS =================
local RecTab = Window:AddTab("Recovery", UI.Icons.Refresh)
RecTab:AddButton("Restore Fishing (Reset All)", function()
    Config.BlatantEnabled = false
    Config.AutoSale = false
    Config.BlatantDelayReel = Defaults.Reel
    Config.BlatantDelayComplete = Defaults.Catch
    UI.Notify({ Title = "Restored!", Duration = 3 })
end)

local SettTab = Window:AddTab("Settings", UI.Icons.Settings)
SettTab:AddKeybind("Toggle Menu Key", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
SettTab:AddToggle("No Animation (Extreme Kaku)", { Flag = "no_anim" }, function(v) Config.NoAnimEnabled = v end)
SettTab:AddButton("Aktifkan Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK ON")
end)
SettTab:AddDangerButton("Unload Script", function() UI.Unload() end)

-- MOBILE FLOATING BUTTON
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "SMK Fishing Mod", Subtitle = "Turbo Farm v11.0", Duration = 2 })
