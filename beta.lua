local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= REMOTE ASLI (SIMPLESPY UPDATED) =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Localized Remotes
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")
local RF_Cancel = net:WaitForChild("RF/CancelFishingInputs")

local invoke = RF_Charge.InvokeServer
local fire = RE_Complete.FireServer
local wait = task.wait
local clock = os.clock

-- ================= WINDOW MielHUB v1.00 =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.00",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_Config"
})

local Config = {
    B = false, -- Fishing
    S = false, -- Sale
    F = false, -- Favorite
    N = false, -- NoAnim
    Reel = 0.00001,
    Catch = 0.57,
    Cap = 1000
}

-- ================= LOGIC AUTO FAVORITE & SALE =================

-- Fungsi mencari ID Ikan secara massal untuk Auto Favorite
local function massFavorite()
    -- Scanner mencari folder data replion atau backpack
    local inventoryData = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") 
                       or LP:FindFirstChild("Backpack")
    
    if inventoryData then
        for _, item in pairs(inventoryData:GetChildren()) do
            -- Mengirim UUID ikan ke server sesuai log SimpleSpy
            -- UUID biasanya disimpan di properti Name atau Value ikan tersebut
            RE_Fav:FireServer(item.Name)
        end
    end
end

-- Scanner isi tas dari UI
local function getInvCount()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text:find("/") then
            local count = v.Text:match("^(%d+)")
            if count then return tonumber(count) end
        end
    end
    return 0
end

-- Kaku Mode (No-Animation)
RS.Heartbeat:Connect(function()
    if Config.N then
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

-- ================= TAB FISHING (SPAM NO DELAY) =================
local fishingThread

local function fishingLoop()
    while true do
        invoke(RF_Charge)
        wait(Config.Reel)
        
        -- Spam RequestFishing tanpa delay sesuai permintaanmu
        invoke(RF_Start, -139.63, 0.81, clock())
        wait(Config.Catch)
        
        fire(RE_Complete)
        RE_Claim:FireServer("Fish")
        invoke(RF_Cancel) -- Menghapus input fishing agar bisa spam ulang lebih cepat
        wait() 
    end
end

local Tab1 = Window:AddTab("Fishing", UI.Icons.Combat)
Tab1:AddSection("Turbo Fishing Engine")
Tab1:AddInput("Bait Speed", function(t) Config.Reel = tonumber(t) or 0.00001 end)
Tab1:AddInput("Catch Speed", function(t) Config.Catch = tonumber(t) or 0.57 end)

Tab1:AddToggle("Aktifkan Mancing (No Delay)", { Flag = "b_on" }, function(v)
    Config.B = v
    if v and not fishingThread then
        fishingThread = task.spawn(fishingLoop)
        UI.Pill("MielHUB Fishing Aktif!")
    elseif not v and fishingThread then
        task.cancel(fishingThread)
        fishingThread = nil
        UI.Pill("MielHUB Fishing Mati")
    end
end)

-- ================= TAB FARMING (AUTO SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Auto Favorite (Multiple Select)")
Tab2:AddToggle("Otomatis Favorit Ikan Baru", { Flag = "f_on" }, function(v)
    Config.F = v
    if v then
        task.spawn(function()
            while Config.F do
                massFavorite()
                wait(5) -- Scan setiap 5 detik agar tidak lag
            end
        end)
    end
end)

Tab2:AddSection("Auto Sale System")
Tab2:AddInput("Kapasitas Tas (Jual Saat Penuh)", function(t) Config.Cap = tonumber(t) or 1000 end)
Tab2:AddToggle("Aktifkan Auto Jual", { Flag = "s_on" }, function(v)
    Config.S = v
    if v then
        UI.Success("Auto Sale Aktif")
        task.spawn(function()
            while Config.S do
                if getInvCount() >= Config.Cap then
                    RF_SellAll:InvokeServer()
                    UI.Pill("Tas Penuh, Berhasil Jual Semua!")
                end
                wait(10)
            end
        end)
    end
end)

-- ================= TAB TELEPORT (14 PULAU) =================
local Tab3 = Window:AddTab("Teleport", UI.Icons.Teleport)
Tab3:AddSection("Daftar Pulau")
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

-- ================= TAB MISC & SETTINGS =================
local Tab4 = Window:AddTab("Misc", UI.Icons.Settings)
Tab4:AddSection("Pengaturan")
Tab4:AddToggle("Mode Kaku (No Anim)", { Flag = "n_on" }, function(v) Config.N = v end)
Tab4:AddKeybind("Tombol Buka UI", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)

Tab4:AddButton("Aktifkan Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

Tab4:AddDangerButton("Matikan Script", function() UI.Unload() end)

-- MOBILE SUPPORT
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "Absolute v1.00 Loaded", Duration = 2 })
