local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()

-- ================= PENGATURAN SERVICE & REMOTE (VERIFIED SOURCE) =================
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Remote List Lengkap [cite: prompt.txt]
local RF_Charge = net:WaitForChild("RF/ChargeFishingRod")
local RF_Start = net:WaitForChild("RF/RequestFishingMinigameStarted")
local RE_Complete = net:WaitForChild("RE/FishingCompleted")
local RE_Claim = net:WaitForChild("RE/ClaimNotification")
local RF_SellAll = net:WaitForChild("RF/SellAllItems")
local RE_Fav = net:WaitForChild("RE/FavoriteItem")
local RF_Cancel = net:WaitForChild("RF/CancelFishingInputs")
local RE_Reconnect = net:WaitForChild("RE/ReconnectPlayer") -- Dari AFKController
local RF_Redeem = net:WaitForChild("RF/RedeemCode") -- Dari CodeController

-- Helper send() (Xeno Safe + Async)
local function send(remote, ...)
    if remote:IsA("RemoteFunction") then
        local args = {...}
        task.spawn(function() remote:InvokeServer(unpack(args)) end)
    else
        remote:FireServer(...)
    end
end

-- ================= INISIALISASI UI =================
local Window = UI.New({
    Title = "MielHUB",
    Subtitle = "Version 3.00 (Final Master)",
    Theme = "Sunset",
    Size = UDim2.new(0, 580, 0, 420),
    ShowUserInfo = true,
    ConfigName = "MielHUB_v3_Final"
})

local Config = {
    Mode = "None", Sale = false, Fav = false, Kaku = false,
    SkipCutscene = false, AFKMaster = true,
    -- Blatant Source Delays
    B_Reel = 0.05, B_Comp = 0.02, B_Cancel = 0.01,
    -- Legit & Instant
    L_Reel = 1.5, L_Comp = 2.0, I_Reel = 0.15, I_Comp = 0.05,
    -- Farming
    MinRar = "Legendary", Cap = 1000, Interval = 60
}

local currentConn, kakuConn, idleConn, cutsceneConn
local phase, t, busy = 0, 0, false

-- ================= FUNGSI PEMULIHAN (RECOVERY) =================
local function stopAll()
    Config.Mode = "None"
    phase = 0; t = 0; busy = false
    if currentConn then currentConn:Disconnect() currentConn = nil end
    send(RF_Cancel)
    UI.Pill("MielHUB: Semua Fitur Berhasil Direset!")
end

-- ================= TAB MANCING (VERSION 3.00 POWER) =================
local Tab1 = Window:AddTab("Mancing", UI.Icons.Combat)

-- --- 1. LEGIT (AUTO NORMAL) ---
Tab1:AddSection("1. Legit Fishing (Source Delay)")
Tab1:AddInput("Legit Reel", function(v) Config.L_Reel = tonumber(v) or 1.5 end)
local lTog = Tab1:AddToggle("Aktifkan Legit", { Flag = "l_on" }, function(v)
    if currentConn then currentConn:Disconnect() end
    if not v then stopAll() return end
    stopAll(); Config.Mode = "Legit"
    currentConn = RS.Heartbeat:Connect(function(dt)
        t = t + dt
        if phase == 0 then send(RF_Charge); phase = 1; t = 0
        elseif phase == 1 and t >= Config.L_Reel then send(RF_Start, 0, 1, workspace:GetServerTimeNow()); phase = 2; t = 0
        elseif phase == 2 and t >= Config.L_Comp then send(RE_Complete); phase = 0; t = 0 end
    end)
end)
Tab1:AddKeybind("Shortcut Legit", { Default = Enum.KeyCode.J }, function() lTog:Set(not lTog.Value) end)

-- --- 2. INSTANT (NO MINIGAME) ---
Tab1:AddSection("2. Instant Fishing")
local iTog = Tab1:AddToggle("Aktifkan Instant", { Flag = "i_on" }, function(v)
    if currentConn then currentConn:Disconnect() end
    if not v then stopAll() return end
    stopAll(); Config.Mode = "Instant"
    currentConn = RS.Heartbeat:Connect(function(dt)
        t = t + dt
        if phase == 0 then send(RF_Charge); phase = 1; t = 0
        elseif phase == 1 and t >= Config.I_Reel then send(RF_Start, 0, 1, workspace:GetServerTimeNow()); phase = 2; t = 0
        elseif phase == 2 and t >= Config.I_Comp then send(RE_Complete); send(RE_Claim, "Fish"); phase = 0; t = 0 end
    end)
end)
Tab1:AddKeybind("Shortcut Instant", { Default = Enum.KeyCode.K }, function() iTog:Set(not iTog.Value) end)

-- --- 3. BLATANT V7 (SMART SOURCE INTEGRATION) ---
Tab1:AddSection("3. Blatant V7 (Xeno-Safe)")
Tab1:AddInput("Reel Delay", function(v) Config.B_Reel = tonumber(v) or 0.05 end)
Tab1:AddInput("Complete Delay", function(v) Config.B_Comp = tonumber(v) or 0.02 end)

local bTog = Tab1:AddToggle("Aktifkan Blatant", { Flag = "b_on" }, function(v)
    if currentConn then currentConn:Disconnect() end
    if not v then stopAll() return end
    stopAll(); Config.Mode = "Blatant"
    UI.Pill("BLATANT FINAL ACTIVE")
    currentConn = RS.Heartbeat:Connect(function(dt)
        if busy then return end
        t = t + dt
        if phase == 0 then
            busy = true; task.spawn(function() send(RF_Charge); busy = false end)
            phase = 1; t = 0
        elseif phase == 1 and t >= Config.B_Reel then
            busy = true; task.spawn(function() send(RF_Start, 0, 1, workspace:GetServerTimeNow()); busy = false end)
            phase = 2; t = 0
        elseif phase == 2 and t >= Config.B_Comp then
            send(RE_Complete); send(RE_Claim, "Fish")
            phase = 3; t = 0
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
Tab2:AddToggle("Auto Favorite", { Flag = "f_on" }, function(v)
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

Tab2:AddSection("Auto Sale System")
Tab2:AddInput("Kapasitas Tas", function(t) Config.Cap = tonumber(t) or 1000 end)
local sTog = Tab2:AddToggle("Auto Jual Penuh", { Flag = "s_on" }, function(v)
    Config.Sale = v
    task.spawn(function()
        while Config.Sale do
            local cur = 0
            local ui = LP.PlayerGui:FindFirstChild("MainUI") and LP.PlayerGui.MainUI:FindFirstChild("Inventory")
            if ui then cur = tonumber(ui.Text:match("^(%d+)")) or 0 end
            if cur >= Config.Cap then RF_SellAll:InvokeServer() end
            task.wait(15)
        end
    end)
end)
Tab2:AddKeybind("Shortcut Jual", { Default = Enum.KeyCode.P }, function() sTog:Set(not sTog.Value) end)

-- ================= TAB TELEPORT (SEMUA 14 PULAU LENGKAP) =================
local TabT = Window:AddTab("Teleport", UI.Icons.Teleport)
local function tp(x, y, z)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

TabT:AddSection("Pilih Pulau")
local locations = {
    {"Esoteric Depths", 3100.81, -1302.73, 1462.32},
    {"Sandy Bay", 35.82, 9.64, 2803.89},
    {"Frozen Fjord", 1012.64, 23.53, 5077.73},
    {"Kohana Volcano", -596.68, 60.47, 104.55},
    {"Ancient Jungle", 1470.78, 5.37, -326.65},
    {"Sacred Temple", 1477.36, -21.52, -649.19},
    {"The Abyss 1", 6049.66, -538.60, 4358.95},
    {"The Abyss 2", 6100.35, -585.48, 4685.32},
    {"Crater Island", -1514.61, 5.43, 1891.73},
    {"Lost Isle", -2786.48, 8.47, 2128.80},
    {"Coral Reef", -2099.63, 5.95, 3696.73},
    {"Deepwater Cavern", -3696.02, -134.59, -1011.64},
    {"Underground Cellar", -3604.98, -266.76, -1580.89},
    {"Christmas Island", 1136.97, 23.60, 1561.87}
}
for _, loc in ipairs(locations) do
    TabT:AddButton(loc[1], function() tp(loc[2], loc[3], loc[4]) end)
end

-- ================= TAB SISTEM (ADVANCED) =================
local Tab3 = Window:AddTab("Sistem", UI.Icons.Settings)

Tab3:AddSection("Cutscene & Animation Control")
Tab3:AddToggle("Skip Catch Cutscene", { Flag = "sk_cut" }, function(v)
    Config.SkipCutscene = v
    if v then
        cutsceneConn = LP:GetAttributeChangedSignal("InCutscene"):Connect(function()
            if LP:GetAttribute("InCutscene") then LP:SetAttribute("InCutscene", false) end
        end)
    else
        if cutsceneConn then cutsceneConn:Disconnect() cutsceneConn = nil end
    end
end)

Tab3:AddToggle("Kaku Mode", { Flag = "n_on" }, function(v)
    Config.Kaku = v
    if kakuConn then kakuConn:Disconnect() kakuConn = nil end
    if v then
        kakuConn = RS.Heartbeat:Connect(function()
            local anim = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") and LP.Character.Humanoid:FindFirstChildOfClass("Animator")
            if anim then for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end end
        end)
    end
end)

Tab3:AddSection("AFK & Anti-Kick (Source Logic)")
Tab3:AddToggle("AFK Reconnect Master", { Flag = "afk_on" }, function(v)
    Config.AFKMaster = v
    if v then
        if idleConn then idleConn:Disconnect() end
        idleConn = LP.Idled:Connect(function(time)
            if time >= 850 then send(RE_Reconnect) end -- Dari AFKController [cite: prompt.txt]
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.5); game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        UI.Success("Anti-AFK Aktif!")
    else
        if idleConn then idleConn:Disconnect() end
    end
end)

Tab3:AddSection("Code Master")
Tab3:AddInput("Redeem Code", function(t)
    if string.len(t) > 0 then
        local r, m = RF_Redeem:InvokeServer(t)
        UI.Notify({Title = "Redeem", Content = m or "Code Berhasil!", Duration = 3})
    end
end)

Tab3:AddSection("Global Settings")
Tab3:AddKeybind("Buka/Tutup Menu", { Default = Enum.KeyCode.RightControl }, function() Window:Toggle() end)
Tab3:AddKeybind("RECOVERY (Stop All)", { Default = Enum.KeyCode.X }, stopAll)

Tab3:AddDangerButton("Unload MielHUB", function() stopAll(); UI.Unload() end)

if UI.IsMobile then
    UI.FloatingButton({ Icon = UI.Logos.XanBar, Draggable = true, Callback = function() Window:Toggle() end })
end

UI.Splash({ Title = "MielHUB", Subtitle = "v3.00 Source-Integrated Final", Duration = 2 })
