local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN REMOTE & OPTIMASI =================
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

-- Penyingkat Fungsi (Zero Latency)
local inv = RF_Charge.InvokeServer
local fire = RE_Complete.FireServer
local wait = task.wait
local clock = os.clock

-- ================= INISIALISASI UI MielHUB =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 1.00",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v1"
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
    SpamRate = 0.03 -- Kecepatan Spam Heartbeat
}

-- ================= LOGIC FITUR UTAMA =================

-- Scanner Inventory (Deteksi Ikan di Tas)
local function getInvCount()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and v.Text:find("/") then
            local count = v.Text:match("^(%d+)")
            if count then return tonumber(count) end
        end
    end
    return 0
end

-- Scanner Folder Ikan (Mencari UUID Ikan untuk Favorite)
local function massFavorite()
    -- Mencari di folder Data, Inventory, atau Backpack
    local storage = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Inventory") 
                 or LP:FindFirstChild("Inventory") 
                 or LP:FindFirstChild("Backpack")
    
    if storage then
        for _, item in pairs(storage:GetChildren()) do
            -- Kirim UUID Ikan ke server sesuai log SimpleSpy
            RE_Fav:FireServer(item.Name)
        end
    end
end

-- Kaku Mode (No-Animation)
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

-- ================= TAB FISHING (MODE BRUTAL & SAFE) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

Tab1:AddSection("Mode Brutal (Super Spam No Delay)")
Tab1:AddToggle("Aktifkan Brutal Mode", { Flag = "brutal_on" }, function(v)
    Config.Brutal = v
    if v then
        UI.Pill("MielHUB: Mode Brutal Aktif!")
        task.spawn(function()
            -- Menjalankan loop di setiap frame Heartbeat (Paling Cepat)
            local connection
            connection = RS.Heartbeat:Connect(function()
                if not Config.Brutal then connection:Disconnect() return end
                
                inv(RF_Charge)
                inv(RF_Start, -139.63, 0.81, clock()) -- Sesuai argumen SimpleSpy kamu
                fire(RE_Complete)
                RE_Claim:FireServer("Fish")
                inv(RF_Cancel)
            end)
        end)
    end
end)

Tab1:AddSection("Mode Standar (Bisa Diatur)")
Tab1:AddInput("Bait Delay", function(t) Config.Reel = tonumber(t) or 0.00001 end)
Tab1:AddInput("Catch Delay", function(t) Config.Catch = tonumber(t) or 0.57 end)
Tab1:AddToggle("Mancing Normal", { Flag = "safe_on" }, function(v)
    Config.Safe = v
    if v then
        task.spawn(function()
            while Config.Safe do
                inv(RF_Charge)
                wait(Config.Reel)
                inv(RF_Start, -139.63, 0.81, clock())
                wait(Config.Catch)
                fire(RE_Complete)
                RE_Claim:FireServer("Fish")
                inv(RF_Cancel)
                wait()
            end
        end)
    end
end)

-- ================= TAB FARMING (AUTO SALE & FAV) =================
local Tab2 = Window:AddTab("Farming", UI.Icons.Home)

Tab2:AddSection("Otomatis Favorit (Multi-Select)")
Tab2:AddToggle("Auto Favorite Ikan", { Flag = "fav_on" }, function(v)
    Config.Fav = v
    if v then
        task.spawn(function()
            while Config.Fav do
                massFavorite()
                wait(10) -- Scan setiap 10 detik agar tidak lag
            end
        end)
    end
end)

Tab2:AddSection("Otomatis Jual (Smart Inventory)")
Tab2:AddInput("Batas Isi Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
Tab2:AddToggle("Auto Jual Saat Penuh", { Flag = "sale_on" }, function(v)
    Config.Sale = v
    if v then
        UI.Success("Auto Jual Aktif")
        task.spawn(function()
            while Config.Sale do
                if getInvCount() >= Config.Cap then
                    RF_SellAll:InvokeServer() -- Menggunakan remote SellAll
                    UI.Pill("Tas Penuh! Ikan Berhasil Terjual.")
                end
                wait(15)
            end
        end)
    end
end)

-- ================= TAB TELEPORT (LENGKAP) =================
local Tab3 = Window:AddTab("Pulau", UI.Icons.Teleport)
Tab3:AddSection("Teleport Lokasi")
Tab3:AddButton("Esoteric Depths", function() tp(3100.81, -1302.73, 1462.32) end)
Tab3:AddButton("Sandy Bay", function() tp(35.82, 9.64, 2803.89) end)
Tab3:AddButton("Frozen Fjord", function() tp(1012.64, 23.53, 5077.73) end)
Tab3:AddButton("Kohana Volcano", function() tp(-596.68, 60.47, 104.55) end)
Tab3:AddButton("Sacred Temple", function() tp(1477.36, -21.52, -649.19) end)
Tab3:AddButton("The Abyss 1", function() tp(6049.66, -538.60, 4358.95) end)
Tab3:AddButton("Crater Island", function() tp(-1514.61, 5.43, 1891.73) end)
Tab3:AddButton("Lost Isle", function() tp(-2786.48, 8.47, 2128.80) end)
Tab3:AddButton("Coral Reef", function() tp(-2099.63, 5.95, 3696.73) end)
Tab3:AddButton("Christmas Island", function() tp(1136.97, 23.60, 1561.87) end)

-- ================= TAB PENGATURAN =================
local Tab4 = Window:AddTab("Lainnya", UI.Icons.Settings)
Tab4:AddToggle("Kaku Mode (No-Anim)", { Flag = "n_on" }, function(v) Config.Kaku = v end)
Tab4:AddKeybind("Tombol Buka Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)

Tab4:AddButton("Aktifkan Anti-AFK", function()
    LP.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    UI.Success("Anti-AFK Aktif")
end)

Tab4:AddButton("Pulihkan Semua (Reset)", function()
    Config.Brutal, Config.Safe, Config.Fav, Config.Sale = false, false, false, false
    UI.Notify({ Title = "MielHUB Restored", Content = "Semua loop telah dimatikan.", Duration = 3 })
end)

Tab4:AddDangerButton("Matikan Script", function() UI.Unload() end)

-- MOBILE FLOATING BUTTON
if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "Absolute Version 1.00", Duration = 2 })
