local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= REMOTE ASLI (SIMPLESPY UPDATED) =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Localized Remotes for Absolute Speed
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")

-- Method Localization (Branchless Hot-Path)
local invoke = RF_Charge.InvokeServer
local fire = RE_Complete.FireServer
local twait = task.wait
local clock = os.clock

-- ================= WINDOW INITIALIZATION =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.0",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_Config"
})

local Defaults = { Reel = 0.00001, Catch = 0.57 }
local Config = {
    B = false, -- Fishing Toggle
    S = false, -- Sale Toggle
    F = false, -- Favorite Toggle
    N = false, -- NoAnim Toggle
    Reel = Defaults.Reel,
    Catch = Defaults.Catch,
    Interval = 60,
    Cap = 1000,
    MinRar = "Legendary",
    FavNames = {"Secret", "Crystal", "Golden"}
}

-- ================= LOGIC FUNCTIONS =================

-- Scanner Kapasitas Tas (Smart Pattern)
local function getInvCount()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text:find("/") then
            local count = v.Text:match("^(%d+)")
            if count then return tonumber(count) end
        end
    end
    return 0
end

-- Auto Favorite Logic: Mencari data ikan di inventory
local function autoFavProcess()
    -- Mencoba mencari folder data ikan (biasanya di LP.Data atau LP.Inventory)
    local invPath = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") 
                 or LP:FindFirstChild("Inventory")
    
    if invPath then
        for _, fish in pairs(invPath:GetChildren()) do
            -- Logika: Jika ikan belum di-favorite dan masuk kriteria
            -- (Pengecekan rarity/name tergantung struktur Value di dalam objek fish)
            RE_Fav:FireServer(fish.Name) -- Menggunakan Name/ID sesuai SimpleSpy
        end
    end
end

-- No-Animation (Kaku Total)
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

-- ================= TAB FISHING (TURBO) =================
local reelVal, catchVal = Defaults.Reel, Defaults.Catch
local fishingThread

local function fishingLoop()
    while true do
        invoke(RF_Charge)
        twait(reelVal)

        -- Argumen Posisi, Power, dan Tick sesuai SimpleSpy kamu
        invoke(RF_Start, -139.63, 0.81, clock())
        twait(catchVal)

        fire(RE_Complete)
        RE_Claim:FireServer("Fish") -- Langsung klaim biar notif hilang
        twait() 
    end
end

local Tab1 = Window:AddTab("Fishing", UI.Icons.Combat)
Tab1:AddSection("Turbo Engine Control")
Tab1:AddInput("Bait Speed", function(t) Config.Reel = tonumber(t) or Defaults.Reel end)
Tab1:AddInput("Catch Speed", function(t) Config.Catch = tonumber(t) or Defaults.Catch end)

Tab1:AddToggle("EXTREME SPEED (NO DELAY)", { Flag = "b_on" }, function(v)
    Config.B = v
    if v and not fishingThread then
        reelVal, catchVal = Config.Reel, Config.Catch
        fishingThread = task.spawn(fishingLoop)
        UI.Pill("Turbo Engaged!")
    elseif not v and fishingThread then
        task.cancel(fishingThread)
        fishingThread = nil
        UI.Pill("Turbo Stopped")
    end
end)

-- ================= TAB FARMING (SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (Save Items)")
Tab2:AddDropdown("Min Rarity", {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, function(v) Config.MinRar = v end)
Tab2:AddToggle("Auto Favorite Enabled", { Flag = "f_on" }, function(v) 
    Config.F = v 
    if v then
        task.spawn(function()
            while Config.F do
                autoFavProcess()
                twait(30) -- Scan favorit tiap 30 detik
            end
        end)
    end
end)

Tab2:AddSection("Official Auto Sale")
Tab2:AddInput("Interval (Menit)", function(t) Config.Interval = tonumber(t) or 60 end)
Tab2:AddInput("Kapasitas Tas", function(t) Config.Cap = tonumber(t) or 1000 end)

Tab2:AddToggle("Enable Auto Sale", { Flag = "s_on" }, function(v)
    Config.S = v
    if v then
        UI.Success("Auto Sale Active")
        task.spawn(function()
            local lastS = tick()
            while Config.S do
                local passed = (tick() - lastS) / 60
                -- Jual jika waktu habis ATAU tas penuh sesuai kapasitas input
                if (Config.Interval > 0 and passed >= Config.Interval) or (getInvCount() >= Config.Cap) then
                    RF_SellAll:InvokeServer() -- Menggunakan Remote SellAll asli
                    lastS = tick()
                    UI.Pill("All Items Sold!")
                end
                twait(10)
            end
        end)
    end
end)

-- ================= TAB TELEPORT (LENGKAP) =================
local Tab3 = Window:AddTab("Teleport", UI.Icons.Teleport)
Tab3:AddSection("14 Islands")
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

-- ================= TAB MISC =================
local Tab4 = Window:AddTab("Misc", UI.Icons.Refresh)
Tab4:AddButton("RESTORE FISHING", function()
    Config.B, Config.S, Config.F = false, false, false
    if fishingThread then task.cancel(fishingThread); fishingThread = nil end
    UI.Notify({ Title = "Restored!", Content = "All loops stopped.", Duration = 3 })
end)

Tab4:AddSection("System")
Tab4:AddKeybind("Toggle UI", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab4:AddToggle("Kaku Mode", { Flag = "n_on" }, function(v) Config.N = v end)
Tab4:AddButton("Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        twait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Active")
end)
Tab4:AddDangerButton("Unload Script", function() UI.Unload() end)

-- MOBILE SUPPORT
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "SMK Fishing Mod", Subtitle = "Official Final v16.0", Duration = 2 })
