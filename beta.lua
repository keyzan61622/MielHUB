local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN REMOTE & SERVICE =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Remote Sesuai SimpleSpy
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")
local RF_Cancel = net:WaitForChild("RF/CancelFishingInputs")

-- Helper Anti-Error (Mendeteksi RF atau RE)
local function send(remote, ...)
    if remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    else
        remote:FireServer(...)
    end
end

-- ================= INISIALISASI UI =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.21 (Custom Turbo)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_21"
})

local Config = {
    Mode = "None",
    Sale = false,
    Fav = false,
    Kaku = false,
    -- Custom Delays
    L_Reel = 1.5, L_Minigame = 2.0,
    I_Reel = 0.5, I_Catch = 0.1,
    B_Reel = 0.05, B_Catch = 0.05, -- Default Blatant (Adjustable)
    -- Farming
    MinRarity = "Legendary",
    Cap = 1000,
    Interval = 60
}

local fishingThread

-- ================= LOGIC UTAMA =================

local function stopAllFishing()
    Config.Mode = "None"
    if fishingThread then task.cancel(fishingThread) fishingThread = nil end
    UI.Pill("Semua Fitur Mancing Dihentikan!")
end

-- Deteksi Isi Tas
local function getInvCount()
    local pGui = LP:FindFirstChild("PlayerGui")
    local mainUI = pGui and pGui:FindFirstChild("MainUI")
    local invLabel = mainUI and mainUI:FindFirstChild("Inventory")
    if invLabel and invLabel:IsA("TextLabel") then
        local count = invLabel.Text:match("^(%d+)")
        return tonumber(count) or 0
    end
    return 0
end

-- Auto Favorite (6 Rarity)
local function massFavorite()
    local storage = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
    local rarityList = {["Common"]=1, ["Uncommon"]=2, ["Rare"]=3, ["Legendary"]=4, ["Mythic"]=5, ["Secret"]=6}
    
    if storage then
        for _, item in ipairs(storage:GetChildren()) do
            local itemRarity = item:FindFirstChild("Rarity") and item.Rarity.Value or "Common"
            if rarityList[itemRarity] and rarityList[itemRarity] >= rarityList[Config.MinRarity] then
                send(RE_Fav, item.Name)
            end
        end
    end
end

-- Kaku Mode
RS.Heartbeat:Connect(function()
    if Config.Kaku then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local anim = hum and hum:FindFirstChildOfClass("Animator")
        if anim then for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end end
    end
end)

local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- ================= TAB FISHING (ADJUSTABLE) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-- 1. LEGIT
Tab1:AddSection("1. Legit Fishing (Mancing Aman)")
Tab1:AddInput("Delay Lempar", function(t) Config.L_Reel = tonumber(t) or 1.5 end)
Tab1:AddInput("Delay Minigame", function(t) Config.L_Minigame = tonumber(t) or 2.0 end)
Tab1:AddToggle("Aktifkan Legit", { Flag = "legit_on" }, function(v)
    if v then 
        stopAllFishing()
        Config.Mode = "Legit"
        fishingThread = task.spawn(function()
            while Config.Mode == "Legit" do
                send(RF_Charge)
                task.wait(Config.L_Reel)
                send(RF_Start, -139.63, 0.81, os.clock())
                task.wait(Config.L_Minigame)
                send(RE_Complete)
                task.wait(1)
            end
        end)
    else stopAllFishing() end
end)

-- 2. INSTANT
Tab1:AddSection("2. Instant Fishing (No Minigame)")
Tab1:AddInput("Delay Reel", function(t) Config.I_Reel = tonumber(t) or 0.5 end)
Tab1:AddInput("Delay Catch", function(t) Config.I_Catch = tonumber(t) or 0.1 end)
Tab1:AddToggle("Aktifkan Instant", { Flag = "inst_on" }, function(v)
    if v then
        stopAllFishing()
        Config.Mode = "Instant"
        fishingThread = task.spawn(function()
            while Config.Mode == "Instant" do
                send(RF_Charge)
                task.wait(Config.I_Reel)
                send(RF_Start, -139.63, 0.81, os.clock())
                task.wait(Config.I_Catch)
                send(RE_Complete)
                send(RE_Claim, "Fish")
                task.wait(0.5)
            end
        end)
    else stopAllFishing() end
end)

-- 3. BLATANT (SPAM ADJUSTABLE)
Tab1:AddSection("3. Blatant Fishing (Turbo Spam)")
Tab1:AddInput("Blatant Reel Delay", function(t) Config.B_Reel = tonumber(t) or 0.05 end)
Tab1:AddInput("Blatant Catch Delay", function(t) Config.B_Catch = tonumber(t) or 0.05 end)
Tab1:AddToggle("Aktifkan Blatant (SPAM)", { Flag = "brutal_on" }, function(v)
    if v then
        stopAllFishing()
        Config.Mode = "Blatant"
        UI.Pill("Mode Spam Aktif!")
        fishingThread = task.spawn(function()
            while Config.Mode == "Blatant" do
                task.spawn(send, RF_Charge)
                task.wait(Config.B_Reel) -- Menggunakan input user agar tidak narik angin
                send(RF_Start, -139.63, 0.81, os.clock())
                task.wait(Config.B_Catch) -- Menggunakan input user agar pas saat complete
                send(RE_Complete)
                send(RE_Claim, "Fish")
                send(RF_Cancel)
                task.wait() 
            end
        end)
    else stopAllFishing() end
end)

-- ================= TAB FARMING =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (6 Kelangkaan)")
Tab2:AddDropdown("Min Rarity Untuk Simpan", {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Secret"}, function(v) 
    Config.MinRarity = v 
end)
Tab2:AddToggle("Aktifkan Auto Favorite", { Flag = "fav_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            massFavorite()
            task.wait(10)
        end
    end)
end)

Tab2:AddSection("Auto Jual (Market)")
Tab2:AddInput("Jual Tiap (Menit)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Jual Saat Isi Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
Tab2:AddToggle("Aktifkan Auto Jual", { Flag = "sale_on" }, function(v)
    Config.Sale = v
    if v then
        task.spawn(function()
            local lastS = tick()
            while Config.Sale do
                if (tick() - lastS) / 60 >= Config.Interval or getInvCount() >= Config.Cap then
                    send(RF_SellAll)
                    lastS = tick()
                    UI.Pill("Ikan Berhasil Terjual!")
                end
                task.wait(15)
            end
        end)
    end
end)

-- ================= TAB SISTEM =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)

Tab3:AddSection("Pemulihan")
Tab3:AddButton("RECOVERY FISHING (Reset)", stopAllFishing)

Tab3:AddSection("Utility")
Tab3:AddToggle("Kaku Mode", { Flag = "n_on" }, function(v) Config.Kaku = v end)
Tab3:AddKeybind("Buka Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab3:AddButton("Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

local Tab4 = Window:AddTab("Pulau", UI.Icons.Teleport)
Tab4:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
Tab4:AddButton("The Abyss 1", function() tp(6049.66, -538.60, 4358.95) end)
Tab4:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

Tab3:AddDangerButton("Matikan MielHUB", function() UI.Unload() end)

-- MOBILE
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v1.21 Custom Turbo", Duration = 2 })
