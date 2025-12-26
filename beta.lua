local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= LAYANAN & REMOTE (OFFICIAL) =================
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

-- Helper send() Otomatis (Anti-Error RemoteFunction/Event)
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
    Subtitle = "Version 1.80 (Absolute Final)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_80"
})

local Config = {
    Mode = "None", Sale = false, Fav = false, Kaku = false,
    -- Legit Config
    L_Reel = 1.5, L_Complete = 2.0,
    -- Instant Config
    I_Reel = 0.15, I_Complete = 0.05,
    -- Blatant Config
    B_Reel = 0.05, B_Complete = 0.02, B_Cancel = 0.01,
    -- Farming
    MinRarity = "Legendary", Cap = 1000, Interval = 60
}

local legitConn, instantConn, blatantConn, kakuConn, idleConn

-- ================= FUNGSI PEMULIHAN (RECOVERY) =================
local function stopAll()
    Config.Mode = "None"
    if legitConn then legitConn:Disconnect() legitConn = nil end
    if instantConn then instantConn:Disconnect() instantConn = nil end
    if blatantConn then blatantConn:Disconnect() blatantConn = nil end
    send(RF_Cancel)
    UI.Pill("MielHUB: Semua Sistem Dihentikan!")
end

-- ================= TAB MANCING (VERSION FINAL XENO-SAFE) =================
-- Diintegrasikan langsung dari struktur mesin pancing terbaru
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-------------------------------------------------
-- 1. LEGIT (AUTO NORMAL)
-------------------------------------------------
Tab1:AddSection("1. Legit Fishing (Auto Normal)")
Tab1:AddInput("Legit Reel Delay", function(v) Config.L_Reel = tonumber(v) or 1.5 end)
Tab1:AddInput("Legit Complete Delay", function(v) Config.L_Complete = tonumber(v) or 2.0 end)

local lTog = Tab1:AddToggle("Aktifkan Legit", { Flag = "l_on" }, function(v)
    if legitConn then legitConn:Disconnect() legitConn = nil end
    if not v then stopAll() return end

    stopAll()
    Config.Mode = "Legit"

    local phase, t = 0, 0
    legitConn = RS.Heartbeat:Connect(function(dt)
        if Config.Mode ~= "Legit" then return end
        t = t + dt

        if phase == 0 then
            send(RF_Charge); phase = 1; t = 0
        elseif phase == 1 and t >= Config.L_Reel then
            send(RF_Start, -139.63, 0.81, os.clock()); phase = 2; t = 0
        elseif phase == 2 and t >= Config.L_Complete then
            send(RE_Complete); phase = 0; t = 0
        end
    end)
end)
Tab1:AddKeybind("Shortcut Legit", { Default = Enum.KeyCode.J }, function() lTog:Set(not lTog.Value) end)

-------------------------------------------------
-- 2. INSTANT (NO MINIGAME)
-------------------------------------------------
Tab1:AddSection("2. Instant Fishing (No Minigame)")
Tab1:AddInput("Instant Reel Delay", function(v) Config.I_Reel = tonumber(v) or 0.15 end)
Tab1:AddInput("Instant Complete Delay", function(v) Config.I_Complete = tonumber(v) or 0.05 end)

local iTog = Tab1:AddToggle("Aktifkan Instant", { Flag = "i_on" }, function(v)
    if instantConn then instantConn:Disconnect() instantConn = nil end
    if not v then stopAll() return end

    stopAll()
    Config.Mode = "Instant"

    local phase, t = 0, 0
    instantConn = RS.Heartbeat:Connect(function(dt)
        if Config.Mode ~= "Instant" then return end
        t = t + dt

        if phase == 0 then
            send(RF_Charge); phase = 1; t = 0
        elseif phase == 1 and t >= Config.I_Reel then
            send(RF_Start, -139.63, 0.81, os.clock()); phase = 2; t = 0
        elseif phase == 2 and t >= Config.I_Complete then
            send(RE_Complete); send(RE_Claim, "Fish"); phase = 0; t = 0
        end
    end)
end)
Tab1:AddKeybind("Shortcut Instant", { Default = Enum.KeyCode.K }, function() iTog:Set(not iTog.Value) end)

-------------------------------------------------
-- 3. BLATANT (BRUTAL HEARTBEAT ENGINE)
-------------------------------------------------
Tab1:AddSection("3. Blatant Fishing (Brutal Configurable)")
Tab1:AddInput("Blatant Reel Delay", function(v) Config.B_Reel = tonumber(v) or 0.05 end)
Tab1:AddInput("Blatant Complete Delay", function(v) Config.B_Complete = tonumber(v) or 0.02 end)
Tab1:AddInput("Blatant Cancel Delay", function(v) Config.B_Cancel = tonumber(v) or 0.01 end)

local bTog = Tab1:AddToggle("Aktifkan Blatant", { Flag = "b_on" }, function(v)
    if blatantConn then blatantConn:Disconnect() blatantConn = nil end
    if not v then stopAll() return end

    stopAll()
    Config.Mode = "Blatant"
    UI.Pill("BLATANT BRUTAL AKTIF")

    local phase, t = 0, 0
    blatantConn = RS.Heartbeat:Connect(function(dt)
        if Config.Mode ~= "Blatant" then return end
        t = t + dt

        if phase == 0 then
            send(RF_Charge); phase = 1; t = 0
        elseif phase == 1 and t >= Config.B_Reel then
            send(RF_Start, -139.63, 0.81, os.clock()); phase = 2; t = 0
        elseif phase == 2 and t >= Config.B_Complete then
            send(RE_Complete); send(RE_Claim, "Fish"); phase = 3; t = 0
        elseif phase == 3 and t >= Config.B_Cancel then
            send(RF_Cancel); phase = 0; t = 0
        end
    end)
end)
Tab1:AddKeybind("Shortcut Blatant", { Default = Enum.KeyCode.L }, function() bTog:Set(not bTog.Value) end)

-- ================= TAB FARMING (SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (6 Rarity)")
Tab2:AddDropdown("Min Rarity Favorit", {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Secret"}, function(v) Config.MinRarity = v end)
Tab2:AddToggle("Aktifkan Auto Favorite", { Flag = "f_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            local inv = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
            if inv then
                for _, item in ipairs(inv:GetChildren()) do send(RE_Fav, item.Name) end
            end
            task.wait(10)
        end
    end)
end)

Tab2:AddSection("Auto Jual (Smart Market)")
Tab2:AddInput("Jual Tiap (Menit)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Batas Isi Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
local sTog = Tab2:AddToggle("Aktifkan Auto Jual", { Flag = "s_on" }, function(v) Config.Sale = v end)
Tab2:AddKeybind("Shortcut Jual", { Default = Enum.KeyCode.P }, function() sTog:Set(not sTog.Value) end)

-- ================= TAB TELEPORT (FULL 14 LOKASI) =================
local TabTele = Window:AddTab("Teleport", UI.Icons.Teleport)
local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

TabTele:AddSection("Pilih Pulau")
local islands = {
    {"Esoteric Depths", 3100.81, -1302.73, 1462.32}, {"Sandy Bay", 35.82, 9.64, 2803.89},
    {"Frozen Fjord", 1012.64, 23.53, 5077.73}, {"Kohana Volcano", -596.68, 60.47, 104.55},
    {"Ancient Jungle", 1470.78, 5.37, -326.65}, {"Sacred Temple", 1477.36, -21.52, -649.19},
    {"The Abyss 1", 6049.66, -538.60, 4358.95}, {"The Abyss 2", 6100.35, -585.48, 4685.32},
    {"Crater Island", -1514.61, 5.43, 1891.73}, {"Lost Isle", -2786.48, 8.47, 2128.80},
    {"Coral Reef", -2099.63, 5.95, 3696.73}, {"Deepwater Cavern", -3696.02, -134.59, -1011.64},
    {"Underground Cellar", -3604.98, -266.76, -1580.89}, {"Christmas Island", 1136.97, 23.60, 1561.87}
}
for _, data in ipairs(islands) do
    TabTele:AddButton(data[1], function() tp(data[2], data[3], data[4]) end)
end

-- ================= TAB SISTEM =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)
Tab3:AddSection("Global & Security")
Tab3:AddKeybind("Buka/Tutup Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab3:AddKeybind("Recovery Fishing (X)", { Default = Enum.KeyCode.X }, stopAll)

Tab3:AddToggle("Kaku Mode", { Flag = "n_on" }, function(v)
    Config.Kaku = v
    if kakuConn then kakuConn:Disconnect() kakuConn = nil end
    if v then
        kakuConn = RS.Heartbeat:Connect(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            local anim = hum and hum:FindFirstChildOfClass("Animator")
            if anim then for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end end
        end)
    end
end)

Tab3:AddButton("Anti-AFK", function()
    if idleConn then idleConn:Disconnect() end
    idleConn = LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

Tab3:AddDangerButton("Matikan MielHUB", function() stopAll(); UI.Unload() end)

if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v1.80 Absolute Final", Duration = 2 })
