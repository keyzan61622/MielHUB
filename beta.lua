local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN REMOTE & SERVICE =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Localized Remotes
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")
local RF_Cancel = net:WaitForChild("RF/CancelFishingInputs")

-- Fix Method Localization (Handling 'self')
local function invoke(remote, ...) return remote:InvokeServer(...) end
local function fire(remote, ...) remote:FireServer(...) end

-- ================= INISIALISASI UI MielHUB =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.11 (Final Build)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_11"
})

local Config = {
    Brutal = false,
    Safe = false,
    Sale = false,
    Fav = false,
    Kaku = false,
    Reel = 0.00001,
    Catch = 0.57,
    Cap = 1000,
    SpamRate = 0.03
}

-- ================= KONEKSI GLOBAL & FLAGS =================
local brutalConn, kakuConn, idleConn
local isCharged = false -- Flag untuk optimasi RF_Charge

-- ================= LOGIC REFACTORED =================

-- Scanner Inventory (Stable Heuristic)
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

-- Scanner Favorite (UUID Based)
local function massFavorite()
    local storage = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") 
                 or LP:FindFirstChild("Inventory") 
                 or LP:FindFirstChild("Backpack")
    
    if storage then
        for _, item in ipairs(storage:GetChildren()) do
            fire(RE_Fav, item.Name)
        end
    end
end

-- ================= TAB MANCING (FINAL BUILD) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

Tab1:AddSection("Mode Brutal (Maximum Spam)")
Tab1:AddToggle("Aktifkan Brutal Mode", { Flag = "brutal_on" }, function(v)
    Config.Brutal = v
    if brutalConn then brutalConn:Disconnect() brutalConn = nil end
    
    if v then
        UI.Pill("MielHUB: Brutal Mode ON")
        local accumulator = 0
        isCharged = false
        
        brutalConn = RS.Heartbeat:Connect(function(dt)
            accumulator = accumulator + dt
            if accumulator >= Config.SpamRate then
                accumulator = 0
                
                -- Optimasi RF_Charge: Hanya panggil jika belum charged
                if not isCharged then
                    task.spawn(invoke, RF_Charge)
                    isCharged = true
                end
                
                -- FireServer (Non-Blocking) untuk spam tercepat
                fire(RF_Start, -139.63, 0.81, os.clock())
                fire(RE_Complete)
                fire(RE_Claim, "Fish")
                fire(RF_Cancel)
                
                isCharged = false -- Reset flag setelah cancel
            end
        end)
    end
end)

Tab1:AddSection("Mode Aman (Flag-Based Loop)")
Tab1:AddInput("Bait Delay", function(t) Config.Reel = tonumber(t) or 0.00001 end)
Tab1:AddInput("Catch Delay", function(t) Config.Catch = tonumber(t) or 0.57 end)
Tab1:AddToggle("Mancing Normal", { Flag = "safe_on" }, function(v)
    Config.Safe = v -- Menggunakan flag, bukan task.cancel untuk stabilitas
    
    if v then
        task.spawn(function()
            while Config.Safe do
                invoke(RF_Charge)
                task.wait(Config.Reel)
                
                -- Perbaikan: RF_Start menggunakan fire() agar konsisten
                fire(RF_Start, -139.63, 0.81, os.clock())
                task.wait(Config.Catch)
                
                fire(RE_Complete)
                fire(RE_Claim, "Fish")
                fire(RF_Cancel)
                task.wait()
            end
        end)
    end
end)

-- ================= TAB FARMING =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddToggle("Auto Favorite Ikan", { Flag = "fav_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            massFavorite()
            task.wait(10)
        end
    end)
end)

Tab2:AddInput("Batas Isi Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
Tab2:AddToggle("Auto Jual Saat Penuh", { Flag = "sale_on" }, function(v)
    Config.Sale = v
    task.spawn(function()
        while Config.Sale do
            if getInvCount() >= Config.Cap then
                invoke(RF_SellAll)
                UI.Pill("Jual Otomatis Berhasil!")
            end
            task.wait(15)
        end
    end)
end)

-- ================= TAB LAINNYA & TELEPORT =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)

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

Tab3:AddButton("Aktifkan Anti-AFK", function()
    if idleConn then idleConn:Disconnect() end
    idleConn = LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

local Tab4 = Window:AddTab("Pulau", UI.Icons.Teleport)
Tab4:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
Tab4:AddButton("Sandy Bay", function() tp(35.82, 9.64, 2803.89) end)
Tab4:AddButton("Frozen Fjord", function() tp(1012.64, 23.53, 5077.73) end)
Tab4:AddButton("Kohana Volcano", function() tp(-596.68, 60.47, 104.55) end)
Tab4:AddButton("Ancient Jungle", function() tp(1470.78, 5.37, -326.65) end)
Tab4:AddButton("Sacred Temple", function() tp(1477.36, -21.52, -649.19) end)
Tab4:AddButton("The Abyss 1", function() tp(6049.66, -538.60, 4358.95) end)
Tab4:AddButton("The Abyss 2", function() tp(6100.35, -585.48, 4685.32) end)
Tab4:AddButton("Crater Island", function() tp(-1514.61, 5.43, 1891.73) end)
Tab4:AddButton("Lost Isle", function() tp(-2786.48, 8.47, 2128.80) end)
Tab4:AddButton("Coral Reef", function() tp(-2099.63, 5.95, 3696.73) end)
Tab4:AddButton("Deepwater Cavern", function() tp(-3696.02, -134.59, -1011.64) end)
Tab4:AddButton("Underground Cellar", function() tp(-3604.98, -266.76, -1580.89) end)
Tab4:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

-- ================= PEMSIHAN AKHIR =================
Tab3:AddDangerButton("Matikan Script", function() 
    Config.Brutal, Config.Safe, Config.Kaku = false, false, false
    if brutalConn then brutalConn:Disconnect() end
    if kakuConn then kakuConn:Disconnect() end
    UI.Unload() 
end)

-- MOBILE SUPPORT
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "Absolute v1.11 Final Build", Duration = 2 })
