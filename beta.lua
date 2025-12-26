local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN REMOTE & SERVICE =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Remote Resmi Hasil SimpleSpy
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
    Subtitle = "Version 1.70 (Level Dewa)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1_70"
})

local Config = {
    Mode = "None", Sale = false, Fav = false, Kaku = false,
    -- Blatant Engine Xeno-Safe Delays
    B_Reel = 0.15, B_Complete = 0.08, B_Cancel = 0.04,
    -- Farming & Misc
    MinRarity = "Legendary", Cap = 1000, Interval = 60
}

local fishingThread, blatantConn, kakuConn, idleConn
local phase, t, invoking = 0, 0, false -- Variabel Engine Dewa

-- ================= FUNGSI PEMULIHAN =================
local function stopAll()
    Config.Mode = "None"
    phase = 0; t = 0; invoking = false
    if fishingThread then task.cancel(fishingThread) fishingThread = nil end
    if blatantConn then blatantConn:Disconnect() blatantConn = nil end
    send(RF_Cancel)
    UI.Pill("MielHUB: Semua Sistem Dihentikan!")
end

-- ================= TAB FISHING (LEGIT, INSTANT, BLATANT DEWA) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-- --- 1. LEGIT FISHING ---
Tab1:AddSection("1. Legit Fishing")
local lTog = Tab1:AddToggle("Aktifkan Legit", { Flag = "l_on" }, function(v)
    if v then 
        stopAll(); Config.Mode = "Legit"
        fishingThread = task.spawn(function()
            while Config.Mode == "Legit" do
                send(RF_Charge); task.wait(1.5)
                send(RF_Start, -139.63, 0.81, os.clock()); task.wait(2.0)
                send(RE_Complete); task.wait(1)
            end
        end)
    else stopAll() end
end)
Tab1:AddKeybind("Key J", { Default = Enum.KeyCode.J }, function() lTog:Set(not lTog.Value) end)

-- --- 2. INSTANT FISHING ---
Tab1:AddSection("2. Instant Fishing")
local iTog = Tab1:AddToggle("Aktifkan Instant", { Flag = "i_on" }, function(v)
    if v then
        stopAll(); Config.Mode = "Instant"
        fishingThread = task.spawn(function()
            while Config.Mode == "Instant" do
                send(RF_Charge); task.wait(0.5)
                send(RF_Start, -139.63, 0.81, os.clock()); task.wait(0.1)
                send(RE_Complete); send(RE_Claim, "Fish"); task.wait(0.5)
            end
        end)
    else stopAll() end
end)
Tab1:AddKeybind("Key K", { Default = Enum.KeyCode.K }, function() iTog:Set(not iTog.Value) end)

-- --- 3. BLATANT ENGINE DEWA (XENO-SAFE) ---
Tab1:AddSection("3. Blatant Engine (Level Dewa)")
Tab1:AddInput("Reel Delay", function(v) Config.B_Reel = tonumber(v) or 0.15 end)
Tab1:AddInput("Complete Delay", function(v) Config.B_Complete = tonumber(v) or 0.08 end)
Tab1:AddInput("Cancel Delay", function(v) Config.B_Cancel = tonumber(v) or 0.04 end)

local bTog = Tab1:AddToggle("Aktifkan Blatant", { Flag = "b_on" }, function(v)
    if blatantConn then blatantConn:Disconnect() blatantConn = nil end
    if v then
        stopAll(); Config.Mode = "Blatant"; phase = 0; t = 0; invoking = false
        UI.Pill("Blatant Xeno-Safe Aktif!")
        
        -- Menggunakan Stepped & Async Invoke (Teknik Orang Lain)
        blatantConn = RS.Stepped:Connect(function(_, dt)
            if Config.Mode ~= "Blatant" then return end
            t = t + dt

            -- PHASE 0 : Charge (Invoke Async)
            if phase == 0 and not invoking then
                invoking = true
                task.spawn(function()
                    send(RF_Charge)
                    invoking = false
                end)
                phase = 1; t = 0
            
            -- PHASE 1 : Reel Delay -> Start
            elseif phase == 1 and t >= Config.B_Reel and not invoking then
                invoking = true
                task.spawn(function()
                    send(RF_Start, -139.63, 0.81, os.clock())
                    invoking = false
                end)
                phase = 2; t = 0
            
            -- PHASE 2 : Complete (EVENT)
            elseif phase == 2 and t >= Config.B_Complete then
                send(RE_Complete)
                send(RE_Claim, "Fish")
                phase = 3; t = 0
            
            -- PHASE 3 : Cancel -> Loop
            elseif phase == 3 and t >= Config.B_Cancel then
                send(RF_Cancel)
                phase = 0; t = 0
            end
        end)
    else stopAll() end
end)
Tab1:AddKeybind("Key L", { Default = Enum.KeyCode.L }, function() bTog:Set(not bTog.Value) end)

-- ================= TAB FARMING (SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (6 Rarity)")
Tab2:AddDropdown("Min Rarity Favorit", {"Common", "Uncommon", "Rare", "Legendary", "Mythic", "Secret"}, function(v) Config.MinRarity = v end)
Tab2:AddToggle("Auto Favorite", { Flag = "fav_on" }, function(v)
    Config.Fav = v
    task.spawn(function()
        while Config.Fav do
            local storage = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
            if storage then
                for _, item in ipairs(storage:GetChildren()) do send(RE_Fav, item.Name) end
            end
            task.wait(10)
        end
    end)
end)

Tab2:AddSection("Auto Sale")
local sTog = Tab2:AddToggle("Auto Jual", { Flag = "s_on" }, function(v) Config.Sale = v end)
Tab2:AddKeybind("Key P", { Default = Enum.KeyCode.P }, function() sTog:Set(not sTog.Value) end)

-- ================= TAB TELEPORT (FULL 14 LOKASI) =================
local TabTele = Window:AddTab("Teleport", UI.Icons.Teleport)
local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

TabTele:AddSection("Semua Pulau Tersedia")
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

-- ================= TAB SISTEM =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)
Tab3:AddSection("Global Settings")
Tab3:AddKeybind("Buka/Tutup Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab3:AddKeybind("RECOVERY (Key X)", { Default = Enum.KeyCode.X }, stopAll)

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

Tab3:AddDangerButton("Unload MielHUB", function() stopAll(); UI.Unload() end)

if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v1.70 Level Dewa", Duration = 2 })
