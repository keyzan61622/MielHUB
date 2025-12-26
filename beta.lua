local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN REMOTE & SERVICE =================
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
    Subtitle = "Version 1.30 (Final Fix)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_30"
})

local Config = {
    Mode = "None",
    Sale = false,
    Fav = false,
    Kaku = false,
    -- Legit Delays
    L_Reel = 1.5, L_Minigame = 2.0,
    -- Instant Delays
    I_Reel = 0.5, I_Catch = 0.1,
    -- Blatant Delays (Dua Delay Sesuai Foto)
    B_Complete = 0.7, 
    B_Cancel = 0.3,
    -- Farming
    MinRar = "Legendary",
    Cap = 1000,
    Interval = 60
}

local fishingThread, blatantConn, kakuConn

-- ================= FUNGSI PEMULIHAN (RECOVERY) =================
local function stopAllFishing()
    Config.Mode = "None"
    if fishingThread then task.cancel(fishingThread) fishingThread = nil end
    if blatantConn then blatantConn:Disconnect() blatantConn = nil end
    -- Memaksa stop input jika masih nyangkut
    send(RF_Cancel)
    UI.Pill("Recovery: Semua Fitur Mancing Berhenti!")
end

-- ================= TAB FISHING =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-- 1. LEGIT
Tab1:AddSection("1. Legit Fishing")
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
Tab1:AddSection("2. Instant Fishing")
Tab1:AddInput("Instant Reel", function(t) Config.I_Reel = tonumber(t) or 0.5 end)
Tab1:AddInput("Instant Catch", function(t) Config.I_Catch = tonumber(t) or 0.1 end)
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

-- 3. BLATANT (DENGAN 2 DELAY)
Tab1:AddSection("3. Blatant V2 (Super Spam)")
Tab1:AddInput("Complete Delay", function(t) Config.B_Complete = tonumber(t) or 0.7 end)
Tab1:AddInput("Cancel Delay", function(t) Config.B_Cancel = tonumber(t) or 0.3 end)

Tab1:AddToggle("Aktifkan Blatant Mode", { Flag = "brutal_on" }, function(v)
    if v then
        stopAllFishing()
        Config.Mode = "Blatant"
        UI.Pill("Mode Blatant Aktif!")
        
        -- Menggunakan Loop Task.Spawn agar Delay Akurat & Bisa Berhenti Sempurna
        fishingThread = task.spawn(function()
            while Config.Mode == "Blatant" do
                task.spawn(send, RF_Charge)
                send(RF_Start, -139.63, 0.81, os.clock())
                
                task.wait(Config.B_Complete) -- Delay sebelum narik ikan
                send(RE_Complete)
                send(RE_Claim, "Fish")
                
                task.wait(Config.B_Cancel) -- Delay sebelum reset pancingan
                send(RF_Cancel)
                task.wait()
            end
        end)
    else 
        stopAllFishing() 
    end
end)

-- ================= TAB TELEPORT (FULL 14 PULAU) =================
local TabTele = Window:AddTab("Teleport", UI.Icons.Teleport)
TabTele:AddSection("Daftar Pulau Lengkap")

local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- Daftar Pulau Berdasarkan Koordinat Berhasil Disimpan
TabTele:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
TabTele:AddButton("Sandy Bay", function() tp(35.82, 9.64, 2803.89) end)
TabTele:AddButton("Frozen Fjord", function() tp(1012.64, 23.53, 5077.73) end)
TabTele:AddButton("Kohana Volcano", function() tp(-596.68, 60.47, 104.55) end)
TabTele:AddButton("Ancient Jungle", function() tp(1470.78, 5.37, -326.65) end)
TabTele:AddButton("Sacred Temple", function() tp(1477.36, -21.52, -649.19) end)
TabTele:AddButton("The Abyss 1", function() tp(6049.66, -538.60, 4358.95) end)
TabTele:AddButton("The Abyss 2", function() tp(6100.35, -585.48, 4685.32) end)
TabTele:AddButton("Crater Island", function() tp(-1514.61, 5.43, 1891.73) end)
TabTele:AddButton("Lost Isle", function() tp(-2786.48, 8.47, 2128.80) end)
TabTele:AddButton("Coral Reef", function() tp(-2099.63, 5.95, 3696.73) end)
TabTele:AddButton("Deepwater Cavern", function() tp(-3696.02, -134.59, -1011.64) end)
TabTele:AddButton("Underground Cellar", function() tp(-3604.98, -266.76, -1580.89) end)
TabTele:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

-- ================= TAB FARMING =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (6 Rarity)")
Tab2:AddDropdown("Min Rarity Favorit", {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Secret"}, function(v) 
    Config.MinRar = v 
end)
Tab2:AddToggle("Aktifkan Auto Favorite", { Flag = "fav_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            -- Scanner massal favorit item
            local inv = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
            if inv then
                for _, item in ipairs(inv:GetChildren()) do
                    send(RE_Fav, item.Name)
                end
            end
            task.wait(10)
        end
    end)
end)

Tab2:AddSection("Auto Sale (Improved)")
Tab2:AddInput("Jual Tiap (Menit)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Kapasitas Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
Tab2:AddToggle("Aktifkan Auto Jual", { Flag = "sale_on" }, function(v)
    Config.Sale = v
    if v then
        task.spawn(function()
            local lastS = tick()
            while Config.Sale do
                local p = (tick() - lastS) / 60
                -- Pengecekan isi tas dari UI
                local current = 0
                local ui = LP.PlayerGui:FindFirstChild("MainUI") and LP.PlayerGui.MainUI:FindFirstChild("Inventory")
                if ui then current = tonumber(ui.Text:match("^(%d+)")) or 0 end
                
                if p >= Config.Interval or current >= Config.Cap then
                    send(RF_SellAll)
                    lastS = tick()
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

Tab3:AddSection("Lainnya")
Tab3:AddToggle("Kaku Mode", { Flag = "n_on" }, function(v)
    Config.Kaku = v
    if kakuConn then kakuConn:Disconnect() kakuConn = nil end
    if v then
        kakuConn = RS.Heartbeat:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local anim = hum and hum:FindFirstChildOfClass("Animator")
            if anim then for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end end
        end)
    end
end)

Tab3:AddKeybind("Tombol Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)

Tab3:AddButton("Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

Tab3:AddDangerButton("Matikan MielHUB", function() stopAllFishing() UI.Unload() end)

-- MOBILE
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v1.30 Final Fixed", Duration = 2 })
