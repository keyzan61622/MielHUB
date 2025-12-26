local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= LAYANAN & REMOTE UTAMA =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Mencari Remote
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")
local RF_Cancel = net:WaitForChild("RF/CancelFishingInputs")

-- Helper send() Otomatis (Anti-Error RemoteFunction/Event)
local function send(remote, ...)
    if remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    else
        remote:FireServer(...)
    end
end

-- ================= INISIALISASI MielHUB v1.25 =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.25 (Absolute Spam)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_25"
})

local Config = {
    Mode = "None",
    Sale = false,
    Fav = false,
    Kaku = false,
    -- Spam Rate Controller
    SpamRate = 0.03,
    acc = 0,
    -- Legit & Instant Delays
    L_Reel = 1.5, L_Minigame = 2.0,
    I_Reel = 0.5, I_Catch = 0.1,
    -- Farming
    MinRar = "Legendary",
    Cap = 1000,
    Interval = 60
}

local fishingThread, spamConn, kakuConn

-- ================= FUNGSI PEMULIHAN & RESET =================
local function stopAll()
    Config.Mode = "None"
    Config.acc = 0
    if fishingThread then task.cancel(fishingThread) fishingThread = nil end
    if spamConn then spamConn:Disconnect() spamConn = nil end
    UI.Pill("Semua Aktivitas Pancing Dihentikan!")
end

-- ================= SISTEM FARMING & UI DETECTOR =================

-- Scanner Kapasitas Tas
local function getInv()
    local pGui = LP:FindFirstChild("PlayerGui")
    local mainUI = pGui and pGui:FindFirstChild("MainUI")
    local inv = mainUI and mainUI:FindFirstChild("Inventory")
    if inv and inv:IsA("TextLabel") then
        local c = inv.Text:match("^(%d+)")
        return tonumber(c) or 0
    end
    return 0
end

-- Auto Favorite (6 Rarity)
local function doFav()
    local invPath = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
    local rarities = {["Common"]=1, ["Uncommon"]=2, ["Rare"]=3, ["Legendary"]=4, ["Mythic"]=5, ["Secret"]=6}
    
    if invPath then
        for _, item in ipairs(invPath:GetChildren()) do
            -- Cek rarity item (asumsi tersimpan di atribut/value)
            local itemRarity = item:FindFirstChild("Rarity") and item.Rarity.Value or "Common"
            if rarities[itemRarity] and rarities[itemRarity] >= rarities[Config.MinRar] then
                send(RE_Fav, item.Name)
            end
        end
    end
end

-- ================= TAB FISHING (3 MODE UTAMA) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-- 1. LEGIT FISHING
Tab1:AddSection("1. Legit Fishing (Mancing Standar)")
Tab1:AddInput("Bait Delay", function(t) Config.L_Reel = tonumber(t) or 1.5 end)
Tab1:AddInput("Minigame Delay", function(t) Config.L_Minigame = tonumber(t) or 2.0 end)
Tab1:AddToggle("Legit Mode", { Flag = "l_on" }, function(v)
    if v then
        stopAll()
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
    else stopAll() end
end)

-- 2. INSTANT FISHING
Tab1:AddSection("2. Instant Fishing (Tanpa Minigame)")
Tab1:AddInput("Instant Reel", function(t) Config.I_Reel = tonumber(t) or 0.5 end)
Tab1:AddInput("Instant Catch", function(t) Config.I_Catch = tonumber(t) or 0.1 end)
Tab1:AddToggle("Instant Mode", { Flag = "i_on" }, function(v)
    if v then
        stopAll()
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
    else stopAll() end
end)

-- 3. BLATANT FISHING (TRUE SPAM RATE)
Tab1:AddSection("3. Blatant Fishing (Super Spam)")
Tab1:AddInput("Spam Rate (0.01 = Brutal)", function(t) Config.SpamRate = tonumber(t) or 0.03 end)

Tab1:AddToggle("Blatant Mode", { Flag = "b_on" }, function(v)
    if v then
        stopAll()
        Config.Mode = "Blatant"
        UI.Pill("Blatant Spam Aktif!")
        
        -- Arsitektur Heartbeat Accumulator (Tanpa task.wait Internal)
        spamConn = RS.Heartbeat:Connect(function(dt)
            if Config.Mode ~= "Blatant" then spamConn:Disconnect() return end
            Config.acc = Config.acc + dt
            
            if Config.acc >= Config.SpamRate then
                Config.acc = 0
                
                -- ZERO DELAY ACTION
                task.spawn(send, RF_Charge)
                send(RF_Start, -139.63, 0.81, os.clock())
                send(RE_Complete)
                send(RE_Claim, "Fish")
                send(RF_Cancel)
            end
        end)
    else stopAll() end
end)

-- ================= TAB FARMING (SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (6 Rarity)")
Tab2:AddDropdown("Min Rarity Favorit", {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Secret"}, function(v) 
    Config.MinRar = v 
end)

Tab2:AddToggle("Aktifkan Auto Favorite", { Flag = "f_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            doFav()
            task.wait(10)
        end
    end)
end)

Tab2:AddSection("Sistem Jual Otomatis")
Tab2:AddInput("Interval Jual (Menit)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Jual Saat Tas Isi", function(t) Config.Cap = tonumber(t) or 1000 end)

Tab2:AddToggle("Aktifkan Auto Jual", { Flag = "s_on" }, function(v)
    Config.Sale = v
    if v then
        task.spawn(function()
            local lastS = tick()
            while Config.Sale do
                local p = (tick() - lastS) / 60
                if p >= Config.Interval or getInv() >= Config.Cap then
                    send(RF_SellAll)
                    lastS = tick()
                    UI.Pill("Inventaris Berhasil Terjual!")
                end
                task.wait(15)
            end
        end)
    end
end)

-- ================= TAB SISTEM & RECOVERY =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)

Tab3:AddSection("Pemulihan")
Tab3:AddButton("RECOVERY FISHING (Stop All)", stopAll)

Tab3:AddSection("Kustomisasi & Keamanan")
Tab3:AddToggle("Kaku Mode (No-Anim)", { Flag = "n_on" }, function(v)
    Config.Kaku = v
    if kakuConn then kakuConn:Disconnect() kakuConn = nil end
    if v then
        kakuConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local anim = hum and hum:FindFirstChildOfClass("Animator")
            if anim then
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end)
    end
end)

Tab3:AddKeybind("Buka/Tutup Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)

Tab3:AddButton("Aktifkan Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

local Tab4 = Window:AddTab("Pulau", UI.Icons.Teleport)
Tab4:AddSection("Travel")
Tab4:AddButton("Esoteric Depths", function() 
    LP.Character.HumanoidRootPart.CFrame = CFrame.new(3100.81, -1302.73, 1462.32) 
end)
Tab4:AddButton("The Abyss 1", function() 
    LP.Character.HumanoidRootPart.CFrame = CFrame.new(6049.66, -538.60, 4358.95) 
end)

Tab3:AddDangerButton("Unload MielHUB", function() stopAll() UI.Unload() end)

-- MOBILE FLOATING BUTTON
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v1.25 Absolute Spam", Duration = 2 })
