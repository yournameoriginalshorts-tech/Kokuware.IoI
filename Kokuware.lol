_G.KokuwareUnloaded = false

-- Key: "Kokuware-Lua" (each char code + 100)
local encodedKey = {175, 211, 207, 217, 219, 197, 214, 201, 145, 176, 217, 197}
local decodeOffset = 100

local function getRealKey()
    local key = ""
    for _, code in ipairs(encodedKey) do
        key = key .. string.char(code - decodeOffset)
    end
    return key
end

local PERM_OWNER = "ronaldoisthegoat2023"

-- Sign bots (letter order is by UserId, highest first). Accounts not listed here use their slot number.
local BOT_NAMES = {
    "HUBBABUBBABUNGUS2",
    "Spikeymat",
}

local LETTER_DECALS = {
    a = 84739223167918, b = 105539252069147, c = 74294038182490,
    d = 114230329745973, e = 124352099641773, f = 82123842383991,
    g = 139878994521171, h = 101579913315309, i = 124470047460474,
    j = 118110165049919, k = 75749303727717, l = 85466628452197,
    m = 100954977249922, n = 73074635266810, o = 105230115325841,
    p = 112023158405904, q = 111141755063367, r = 84623184773686,
    s = 140550431879504, t = 101463217182491, u = 125145470428911,
    v = 89137330956226, w = 81799978413770, x = 126902038879519,
    y = 97713026151289, z = 114913317499469,

    ["?"] = 107521019153747,
    ["!"] = 88856845587431,
    ["&"] = 85348676666382,
    ["\\"] = 112678560021456,
    ["#"] = 89268294586836,
    ["@"] = 73430094753110,
    ["+"] = 131578044103911,
    ["_"] = 90326334852953,
    ["-"] = 88734632515555,
    ["`"] = 130814762760085,
    ["/"] = 122867449482229,
}

local ACTIVE_USER_FILE = "kokuware_active.dat"
local AGREEMENT_FILE, LICENSE_FILE, SLOT_FILE, BOTS_FILE, MSG_FILE, BL_FILE = "", "", "", "", "", ""

local function setUserFiles(username)
    LICENSE_FILE = "kokuware_license_" .. username .. ".dat"
    SLOT_FILE = "kokuware_slot_" .. username .. ".dat"
    AGREEMENT_FILE = "kokuware_agreed_" .. username .. ".dat"
    BOTS_FILE = "kokuware_bots_" .. username .. ".dat"
    MSG_FILE = "kokuware_msg_" .. username .. ".dat"
    BL_FILE = "kokuware_blacklist_" .. username .. ".dat"
end

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer

local success, guiParent = pcall(function() return game:GetService("CoreGui") end)
if not success or not guiParent then
    guiParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local CREDITS = "Ronaldoisthegoat2023/Kokushibo"

----------------------------------------------------------------------
-- Usage logs (Discord) + remote blacklist
----------------------------------------------------------------------
local WEBHOOK_URL = "https://discord.com/api/webhooks/1548050846531723379/pYq2rImDSm8oqFMNe59F0BzldW4l0NeWBoULmvQ9Be4_EdgYrHaLOLkx4aoQYGhWxhcP"

local REMOTE_BLACKLIST_URL = ""

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local function logToDiscord(title, fields, color)
    if not httpRequest or WEBHOOK_URL == "" then return end
    task.spawn(function()
        pcall(function()
            local placeName = "Unknown"
            pcall(function() placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
            local execName = "Unknown"
            pcall(function() execName = identifyexecutor() end)
            local embedFields = {
                {name = "Username", value = LocalPlayer.Name, inline = true},
                {name = "Display Name", value = LocalPlayer.DisplayName, inline = true},
                {name = "User ID", value = tostring(LocalPlayer.UserId), inline = true},
                {name = "Game", value = tostring(placeName) .. " (" .. tostring(game.PlaceId) .. ")", inline = false},
                {name = "Executor", value = tostring(execName), inline = true},
            }
            for _, f in ipairs(fields or {}) do table.insert(embedFields, f) end
            httpRequest({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    username = "Kokuware Logs",
                    embeds = {{
                        title = title,
                        color = color or 16777215,
                        fields = embedFields,
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    }},
                }),
            })
        end)
    end)
end

local function isRemotelyBlacklisted()
    if REMOTE_BLACKLIST_URL == "" then return false end
    if string.lower(LocalPlayer.Name) == PERM_OWNER then return false end
    local ok, body = pcall(function() return game:HttpGet(REMOTE_BLACKLIST_URL) end)
    if not ok or type(body) ~= "string" then return false end
    local id = tostring(LocalPlayer.UserId)
    local name = string.lower(LocalPlayer.Name)
    for token in body:gmatch("[%w_%.]+") do
        if token == id or string.lower(token) == name then return true end
    end
    return false
end

----------------------------------------------------------------------
-- Anti-tamper
----------------------------------------------------------------------
local EXPECTED_HASH = 2078926153

local function integrityHash(str)
    local h = 5381
    for i = 1, #str do
        h = (h * 33 + string.byte(str, i)) % 4294967296
    end
    return h
end

local function integrityOK()
    local blob = PERM_OWNER .. "|" .. CREDITS .. "|" .. getRealKey() .. "|" .. WEBHOOK_URL
    return integrityHash(blob) == EXPECTED_HASH
end

local function selfDestruct(reason)
    logToDiscord("TAMPER DETECTED - script self-destructed", {
        {name = "Reason", value = tostring(reason), inline = false},
    }, 15158332)
    _G.KokuwareUnloaded = true
    pcall(function()
        for _, f in ipairs(listfiles("")) do
            if string.find(string.lower(f), "kokuware_", 1, true) then pcall(delfile, f) end
        end
    end)
    task.wait(1)
end

if not integrityOK() then
    selfDestruct("Script was modified (startup)")
    return
end

if isRemotelyBlacklisted() then
    logToDiscord("Blacklisted user tried to run the script", {}, 15158332)
    return
end

if queue_on_teleport then
    queue_on_teleport([[
        if not _G.KokuwareUnloaded then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/yournameoriginalshorts-tech/Kokuware.IoI/main/Kokuware.lol"))()
        end
    ]])
end

local noclipConnection = nil
noclipConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
        end
    end
end)

----------------------------------------------------------------------
-- UI helpers
----------------------------------------------------------------------
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)
local GRAY = Color3.fromRGB(170, 170, 170)

local function newGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Parent = guiParent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false
    return gui
end

local function squircle(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 14)
    c.Parent = obj
end

local function outline(obj, thickness)
    local s = Instance.new("UIStroke")
    s.Color = WHITE
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
end

local function makePanel(gui, size, position, anchor)
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.AnchorPoint = anchor or Vector2.new(0.5, 0.5)
    frame.Position = position or UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = size
    frame.BackgroundColor3 = BLACK
    frame.BorderSizePixel = 0
    squircle(frame, 28)
    outline(frame, 2)

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.new(0.5, 0, 0, 12)
    title.Size = UDim2.new(1, -30, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Kokuware"
    title.TextColor3 = WHITE
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Center
    return frame
end

local function makeLabel(parent, text, size, position, textSize, color)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.AnchorPoint = Vector2.new(0.5, 0)
    l.Position = position
    l.Size = size
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.Text = text
    l.TextColor3 = color or GRAY
    l.TextSize = textSize or 12
    l.TextWrapped = true
    return l
end

local function makeButton(parent, text, size, position, filled, anchor)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.AnchorPoint = anchor or Vector2.new(0.5, 0)
    b.Position = position
    b.Size = size
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextSize = 13
    if filled then
        b.BackgroundColor3 = WHITE
        b.TextColor3 = BLACK
    else
        b.BackgroundColor3 = BLACK
        b.TextColor3 = WHITE
        outline(b, 1.5)
    end
    squircle(b, 12)
    return b
end

local function makeBox(parent, size, position, text, placeholder, anchor)
    local t = Instance.new("TextBox")
    t.Parent = parent
    t.AnchorPoint = anchor or Vector2.new(0.5, 0)
    t.Position = position
    t.Size = size
    t.BackgroundColor3 = BLACK
    t.BorderSizePixel = 0
    t.TextColor3 = WHITE
    t.PlaceholderColor3 = GRAY
    t.PlaceholderText = placeholder or ""
    t.Font = Enum.Font.Gotham
    t.TextSize = 14
    t.Text = text or ""
    t.ClearTextOnFocus = false
    squircle(t, 12)
    outline(t, 1.5)
    return t
end

----------------------------------------------------------------------
-- Log GUI
----------------------------------------------------------------------
local logGui = newGui("KokuLog")
local logMain = makePanel(logGui, UDim2.new(0, 300, 0, 400), UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5))

local clearBtn = makeButton(logMain, "Clear", UDim2.new(0, 70, 0, 26), UDim2.new(0, 16, 0, 50), false, Vector2.new(0, 0))
local changeBtn = makeButton(logMain, "Change", UDim2.new(0, 70, 0, 26), UDim2.new(1, -16, 0, 50), false, Vector2.new(1, 0))

local logScroll = Instance.new("ScrollingFrame")
logScroll.Parent = logMain
logScroll.Size = UDim2.new(1, -32, 1, -170)
logScroll.Position = UDim2.new(0, 16, 0, 86)
logScroll.BackgroundColor3 = BLACK
logScroll.BorderSizePixel = 0
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.ScrollBarThickness = 4
logScroll.ScrollBarImageColor3 = WHITE
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
squircle(logScroll, 16)
outline(logScroll, 1)

local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.Padding = UDim.new(0, 4)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder

local bottomBar = Instance.new("Frame")
bottomBar.Parent = logMain
bottomBar.AnchorPoint = Vector2.new(0.5, 1)
bottomBar.Position = UDim2.new(0.5, 0, 1, -14)
bottomBar.Size = UDim2.new(1, -32, 0, 40)
bottomBar.BackgroundTransparency = 1

local slotLabel = Instance.new("TextLabel")
slotLabel.Parent = bottomBar
slotLabel.Size = UDim2.new(0, 40, 1, 0)
slotLabel.BackgroundTransparency = 1
slotLabel.Font = Enum.Font.GothamBold
slotLabel.Text = "Slot"
slotLabel.TextColor3 = WHITE
slotLabel.TextSize = 13
slotLabel.TextXAlignment = Enum.TextXAlignment.Left

local slotBox = makeBox(bottomBar, UDim2.new(0, 90, 0, 32), UDim2.new(0, 50, 0.5, 0), "1", nil, Vector2.new(0, 0.5))
local setSlotBtn = makeButton(bottomBar, "Set", UDim2.new(0, 90, 0, 32), UDim2.new(1, 0, 0.5, 0), true, Vector2.new(1, 0.5))

local function addLogEntry(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = color or WHITE
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = logScroll
    label.LayoutOrder = #logScroll:GetChildren()
end

clearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(logScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end)

----------------------------------------------------------------------
-- Chat spy
----------------------------------------------------------------------
local function SpyOnMessage(sender, text, displayInChat)
    if not sender or sender == LocalPlayer then return end
    if string.sub(text, 1, 1) ~= ";" then return end
    local senderName = sender.Name or "Unknown"
    if displayInChat ~= false and TextChatService and TextChatService.TextChannels then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:DisplaySystemMessage(string.format('<font color="#FFFFFF">[Spy chat] %s: %s</font>', senderName, text))
        end
    end
    addLogEntry("[Spy] " .. senderName .. ": " .. text, WHITE)
end

if TextChatService then
    TextChatService.MessageReceived:Connect(function(m)
        local sender = m.TextSource and Players:GetPlayerByUserId(m.TextSource.UserId)
        if sender then SpyOnMessage(sender, m.Text, false) end
    end)
    pcall(function()
        TextChatService.OnIncomingMessage = function(messageData)
            if not messageData.TextSource then return end
            local sender = Players:GetPlayerByUserId(messageData.TextSource.UserId)
            if sender then SpyOnMessage(sender, messageData.Text, true) end
        end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then plr.Chatted:Connect(function(msg) SpyOnMessage(plr, msg, false) end) end
end
Players.PlayerAdded:Connect(function(plr)
    plr.Chatted:Connect(function(msg) SpyOnMessage(plr, msg, false) end)
end)

----------------------------------------------------------------------
-- Prompts
----------------------------------------------------------------------
local function showTermsPrompt(callback)
    local gui = newGui("TermsPrompt")
    local frame = makePanel(gui, UDim2.new(0, 320, 0, 330))

    makeLabel(frame, "Terms of Use", UDim2.new(1, -30, 0, 18), UDim2.new(0.5, 0, 0, 52), 13, GRAY)
    makeLabel(frame,
        "By using Kokuware, you agree that:\n• You understand that this script is provided 'as is'.\n• You cannot sue or hold the developers liable for any damage.\n• You will not reverse engineer or modify the script.\n• Basic usage info (Roblox username, user ID, game) is logged to the developer.\nIf you do not agree, you will be kicked from the game.",
        UDim2.new(1, -40, 0, 150), UDim2.new(0.5, 0, 0, 78), 12, WHITE)

    local agreeBtn = makeButton(frame, "Agree", UDim2.new(0, 200, 0, 30), UDim2.new(0.5, 0, 0, 242), true)
    local disagreeBtn = makeButton(frame, "Disagree", UDim2.new(0, 200, 0, 30), UDim2.new(0.5, 0, 0, 280), false)

    agreeBtn.MouseButton1Click:Connect(function()
        pcall(writefile, AGREEMENT_FILE, "true")
        gui:Destroy()
        callback()
    end)
    disagreeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        pcall(function() LocalPlayer:Kick("You must agree to the Terms of Use.") end)
    end)
end

local function showInputPrompt(name, subtitleText, buttonText, handler)
    local gui = newGui(name)
    local frame = makePanel(gui, UDim2.new(0, 280, 0, 210))
    makeLabel(frame, subtitleText, UDim2.new(1, -30, 0, 18), UDim2.new(0.5, 0, 0, 52), 12, GRAY)
    local textBox = makeBox(frame, UDim2.new(0, 220, 0, 34), UDim2.new(0.5, 0, 0, 84), "")
    local submitBtn = makeButton(frame, buttonText, UDim2.new(0, 220, 0, 32), UDim2.new(0.5, 0, 0, 130), true)
    local status = makeLabel(frame, "", UDim2.new(1, -20, 0, 18), UDim2.new(0.5, 0, 0, 172), 11, GRAY)

    local function submit()
        local ok, err = handler(textBox.Text, gui)
        if not ok then
            status.Text = err or "Invalid"
            textBox.Text = ""
        end
    end
    submitBtn.MouseButton1Click:Connect(submit)
    textBox.FocusLost:Connect(function(enter) if enter then submit() end end)
end

local function showKeyPrompt(callback)
    showInputPrompt("KeyPrompt", "Key Authentication", "Submit", function(text, gui)
        if text == getRealKey() then
            pcall(writefile, LICENSE_FILE, getRealKey())
            gui:Destroy()
            callback()
            return true
        end
        return false, "Invalid key"
    end)
end

local function showUsernamePrompt(callback)
    showInputPrompt("UserPrompt", "Your Roblox Username", "Save & Next", function(text, gui)
        local user = text:match("^%s*(.-)%s*$")
        if user ~= "" then
            gui:Destroy()
            callback(user)
            return true
        end
        return false, "Enter a username"
    end)
end

local function showSlotPrompt(callback)
    showInputPrompt("SlotPrompt", "Bot Slot Number (1-99)", "Start", function(text, gui)
        local num = tonumber(text)
        if num and num >= 1 and num <= 99 then
            gui:Destroy()
            callback(num)
            return true
        end
        return false, "Enter a number 1-99"
    end)
end

----------------------------------------------------------------------
-- Saved data
----------------------------------------------------------------------
local function isLicenseValid()
    local ok, content = pcall(readfile, LICENSE_FILE)
    return ok and content == getRealKey()
end

local function getActiveUsername()
    local username = nil
    pcall(function()
        local content = readfile(ACTIVE_USER_FILE)
        if content then username = content:match("^%s*(.-)%s*$") end
    end)
    if username == "" then username = nil end
    return username
end

local function saveActiveUsername(username)
    pcall(writefile, ACTIVE_USER_FILE, username)
end

local function loadSavedData()
    local username = getActiveUsername()
    if not username then return nil, nil end
    setUserFiles(username)
    local slot = nil
    pcall(function()
        local content = readfile(SLOT_FILE)
        if content then slot = tonumber(content) end
    end)
    if slot and slot >= 1 and slot <= 99 then return username, slot end
    return nil, nil
end

local function saveData(username, slot)
    setUserFiles(username)
    saveActiveUsername(username)
    pcall(writefile, SLOT_FILE, tostring(slot))
end

local function loadSavedBots()
    local result = 1
    pcall(function()
        local content = readfile(BOTS_FILE)
        local num = content and tonumber(content)
        if num and num > 0 then result = num end
    end)
    return result
end

local defaultMessages = {loading = true, orbitspeed = true, formation = true, antiafk = true, antilag = true}
local messageToggles = {}

local function loadMessages()
    messageToggles = table.clone(defaultMessages)
    pcall(function()
        local content = readfile(MSG_FILE)
        if content then
            local t = HttpService:JSONDecode(content)
            for k, v in pairs(defaultMessages) do
                if t[k] ~= nil then messageToggles[k] = t[k] else messageToggles[k] = v end
            end
        end
    end)
end

local function saveMessages()
    pcall(function() writefile(MSG_FILE, HttpService:JSONEncode(messageToggles)) end)
end

----------------------------------------------------------------------
-- FIXED Blacklist save/load
----------------------------------------------------------------------
local blacklist = {}

local function saveBlacklist()
    if BL_FILE == "" then return end
    local list = {}
    for id in pairs(blacklist) do
        table.insert(list, tonumber(id))
    end
    local encodeOk, encoded = pcall(function()
        return HttpService:JSONEncode(list)
    end)
    if encodeOk and encoded then
        local writeOk, writeErr = pcall(writefile, BL_FILE, encoded)
        if not writeOk then
            addLogEntry("[Blacklist] Save failed: " .. tostring(writeErr), WHITE)
        end
    else
        addLogEntry("[Blacklist] JSON encode failed", WHITE)
    end
end

local function loadBlacklist()
    blacklist = {}
    if BL_FILE == "" then return end
    local readOk, content = pcall(readfile, BL_FILE)
    if not readOk or type(content) ~= "string" or content == "" then return end
    local decodeOk, list = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not decodeOk or type(list) ~= "table" then
        addLogEntry("[Blacklist] Load failed: bad file contents", WHITE)
        return
    end
    for _, id in ipairs(list) do
        local n = tonumber(id)
        if n then blacklist[n] = true end
    end
    local count = 0
    for _ in pairs(blacklist) do count += 1 end
    addLogEntry("[Blacklist] Loaded " .. count .. " entries", WHITE)
end

----------------------------------------------------------------------
-- Connections / anti-lag
----------------------------------------------------------------------
local allConnections = {}
local function cleanupConnections()
    for _, conn in ipairs(allConnections) do
        pcall(function() conn:Disconnect() end)
    end
    allConnections = {}
end

local autoMatchMsg = "°"
local antiLagActive = false
local antiLagLoop = nil

local function hidePart(part)
    if part:IsA("BasePart") then part.Transparency = 1 end
end

local function hideAllParts()
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") then hidePart(desc) end
        if desc:IsA("Light") then desc.Enabled = false end
    end
end

local function applyAntiLag()
    if antiLagActive then return end
    antiLagActive = true

    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)

    hideAllParts()

    local function hideChar(char)
        task.wait(0.1)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then hidePart(part) end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then hideChar(plr.Character) end
        plr.CharacterAdded:Connect(hideChar)
    end
    Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(hideChar) end)

    antiLagLoop = RunService.Heartbeat:Connect(hideAllParts)
end

local function disableAntiLag()
    if not antiLagActive then return end
    antiLagActive = false
    if antiLagLoop then antiLagLoop:Disconnect(); antiLagLoop = nil end

    pcall(function()
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 1
        Lighting.Technology = Enum.Technology.ShadowMap
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    end)

    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") then desc.Transparency = 0 end
        if desc:IsA("Light") then desc.Enabled = true end
    end

    pcall(function() TextChatService.ChatBarEnabled = true end)
    pcall(function()
        local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch.Enabled = true end
    end)
end

local function disableAnimations()
    local char = LocalPlayer.Character
    if char then
        local animController = char:FindFirstChildOfClass("AnimationController")
        if animController then animController.Enabled = false end
    end
end

local function enableAnimations()
    local char = LocalPlayer.Character
    if char then
        local animController = char:FindFirstChildOfClass("AnimationController")
        if animController then animController.Enabled = true end
    end
end

----------------------------------------------------------------------
-- Main
----------------------------------------------------------------------
function main(allowedUsername, slotNumber)
    cleanupConnections()
    if not integrityOK() then
        selfDestruct("Script was modified (main)")
        cleanupConnections()
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        logGui:Destroy()
        return
    end

    setUserFiles(allowedUsername)
    loadMessages()
    loadBlacklist()

    logToDiscord("Script executed", {
        {name = "Owner set", value = tostring(allowedUsername), inline = true},
        {name = "Slot", value = tostring(slotNumber), inline = true},
        {name = "Blacklisted IDs saved", value = tostring((function() local n = 0 for _ in pairs(blacklist) do n += 1 end return n end)()), inline = true},
    }, 3066993)

    _G.KokuwareGen = (_G.KokuwareGen or 0) + 1
    local myGen = _G.KokuwareGen
    _G.KokuwareLast = {}

    local ModUsers = {}
    local Prefix = "."
    local hasOwner = false
    local ownerName = ""

    if allowedUsername and allowedUsername ~= "" then
        hasOwner = true
        ownerName = allowedUsername
    end

    local Inplace = "inplace"

    local TeleportService = game:GetService("TeleportService")

    local loopActive, loopMsg = false, ""
    local adallActive, adallInterval, adallTarget = false, 1, ""
    local silentMode = false
    local hiding, hidePartObj, hidePos, returnPos = false, nil, Vector3.new(0, 5000, 0), nil

    local followConnection, orbitConnection = nil, nil
    local formationConnection = nil
    local orbitAngle = 0
    local movementPlatform = nil
    local mapMovedUp = false
    local originalMapCFrames = {}

    local ORBIT_DISTANCE = 10
    local orbitSpeed = 1.5
    local LINE_SPACING = 7
    local LINEUP_SPACING = 6
    local STAR_SIZE = 10
    local totalBots = loadSavedBots()

    local function fixUsername(name) return string.gsub(name, "_", ".") end

    local function isOwnerName(name)
        local n = string.lower(name)
        if n == PERM_OWNER then return true end
        if hasOwner and n == string.lower(ownerName) then return true end
        return false
    end

    local function isOwner(player)
        if blacklist[player.UserId] then return false end
        if not hasOwner then return true end
        return isOwnerName(player.Name)
    end

    local function isAllowed(player)
        if blacklist[player.UserId] then return false end
        if not hasOwner then return true end
        if isOwnerName(player.Name) then return true end
        if ModUsers[string.lower(player.DisplayName)] then return true end
        return false
    end

    local function sendChat(msg)
        local text = msg
        if silentMode then text = string.gsub(text, "^;", "") end
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(text) end
        else
            local cr = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if cr then
                local sr = cr:FindFirstChild("SayMessageRequest")
                if sr then sr:FireServer(text, "All") end
            end
        end
    end

    task.spawn(function()
        task.wait(0.5)
        if messageToggles.loading then
            sendChat("Kokuware - Credits to " .. CREDITS)
            task.wait(0.6)
            sendChat("Anti crash loaded | Credits to " .. CREDITS)
            task.wait(0.6)
            sendChat("Anti grief loaded | Credits to " .. CREDITS)
        end
    end)

    local function sendAlert(msg) for _ = 1, 5 do sendChat(msg) task.wait(0.1) end end

    local function getTarget(text)
        if not text or text == "" then return nil end
        if text == "me" then return LocalPlayer end
        local s = string.lower(text)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, #s) == s or string.sub(string.lower(p.DisplayName), 1, #s) == s then return p end
        end
        return nil
    end

    local function getOwnTime()
        local stats = LocalPlayer:WaitForChild("leaderstats", 5)
        if stats then
            for _, v in ipairs(stats:GetChildren()) do
                if v:IsA("ValueBase") and v.Name == "Time" then return v end
            end
        end
        return nil
    end

    local function hasArkenstone()
        local c = LocalPlayer.Character
        local b = LocalPlayer:FindFirstChild("Backpack")
        return (c and c:FindFirstChild("The Arkenstone")) or (b and b:FindFirstChild("The Arkenstone"))
    end

    local function equipTool(toolName, quiet)
        local char = LocalPlayer.Character
        if not char then
            if not quiet then sendChat("No character found") end
            return false
        end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then
            if not quiet then sendChat("No backpack found") end
            return false
        end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and string.lower(child.Name) == string.lower(toolName) then
                if not quiet then sendChat(toolName .. " is already equipped") end
                return true
            end
        end
        local found = nil
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") and string.lower(child.Name) == string.lower(toolName) then
                found = child
                break
            end
        end
        if not found then
            if not quiet then sendChat("Item '" .. toolName .. "' not found in backpack") end
            return false
        end
        found.Parent = char
        task.wait(0.2)
        if not quiet then sendChat("Equipped " .. toolName) end
        return true
    end

    ------------------------------------------------------------------
    -- Blacklist punishments
    ------------------------------------------------------------------
    local punished = {}

    local function punish(plr)
        if plr == LocalPlayer or isOwnerName(plr.Name) then return end
        if not hasArkenstone() then return end
        punished[plr.UserId] = true
        equipTool("The Arkenstone", true)
        for _, c in ipairs({"mute", "glitch"}) do
            sendChat(";" .. c .. " " .. plr.Name)
            task.wait(0.4)
        end
        addLogEntry("[Blacklist] punished " .. plr.Name, WHITE)
    end

    task.spawn(function()
        while myGen == _G.KokuwareGen and not _G.KokuwareUnloaded do
            task.wait(3)
            if hasArkenstone() then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if blacklist[plr.UserId] and not punished[plr.UserId] then
                        punish(plr)
                    end
                end
            end
        end
    end)

    table.insert(allConnections, Players.PlayerRemoving:Connect(function(plr)
        punished[plr.UserId] = nil
    end))

    local function resolveUser(text)
        local p = getTarget(text)
        if p then return p.UserId, p.Name end
        local n = tonumber(text)
        if n then
            local ok, nm = pcall(Players.GetNameFromUserIdAsync, Players, n)
            return n, (ok and nm) or tostring(n)
        end
        local ok, id = pcall(Players.GetUserIdFromNameAsync, Players, text)
        if ok and id then return id, text end
        return nil, nil
    end

    ------------------------------------------------------------------
    -- Movement
    ------------------------------------------------------------------
    local function stopAllMovement()
        if followConnection then followConnection:Disconnect(); followConnection = nil end
        if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
        if formationConnection then formationConnection:Disconnect(); formationConnection = nil end
        if movementPlatform then movementPlatform:Destroy(); movementPlatform = nil end
        if mapMovedUp then
            for part, cf in pairs(originalMapCFrames) do
                if part and part.Parent then part.CFrame = cf end
            end
            originalMapCFrames = {}
            mapMovedUp = false
        end
        enableAnimations()
    end

    local function moveMapUp()
        if mapMovedUp then return end
        originalMapCFrames = {}
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Anchored and not desc:IsDescendantOf(LocalPlayer.Character or workspace) and not desc:IsDescendantOf(movementPlatform or workspace) then
                originalMapCFrames[desc] = desc.CFrame
                desc.CFrame = desc.CFrame + Vector3.new(0, 10000, 0)
            end
        end
        mapMovedUp = true
    end

    local function restoreMap()
        if not mapMovedUp then return end
        for part, cf in pairs(originalMapCFrames) do
            if part and part.Parent then part.CFrame = cf end
        end
        originalMapCFrames = {}
        mapMovedUp = false
    end

    local function getCirclePosition(leaderRoot, slot, total, radius)
        local angle = (2 * math.pi * (slot - 1)) / total
        local localOffset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        return leaderRoot.CFrame * localOffset
    end

    local function getStarPosition(leaderRoot, slot, total, size)
        local outer = size
        local inner = size * 0.4
        local points = {}
        for i = 1, 10 do
            local angle = math.pi / 2 + (i - 1) * (math.pi / 5)
            local radius = (i % 2 == 1) and outer or inner
            points[i] = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        end
        local perimeter = 0
        local distances = {}
        for i = 1, #points do
            local nxt = i % #points + 1
            local d = (points[nxt] - points[i]).Magnitude
            distances[i] = d
            perimeter = perimeter + d
        end
        local targetDist = (slot - 1) / total * perimeter
        local acc = 0
        for i = 1, #points do
            if targetDist <= acc + distances[i] then
                local t = (targetDist - acc) / distances[i]
                local nxt = i % #points + 1
                return leaderRoot.CFrame * points[i]:Lerp(points[nxt], t)
            end
            acc = acc + distances[i]
        end
        return leaderRoot.Position
    end

    local function createPlatform()
        if movementPlatform then return movementPlatform end
        local plat = Instance.new("Part")
        plat.Size = Vector3.new(6, 1, 6)
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.4
        plat.Color = Color3.fromRGB(150, 150, 150)
        plat.Parent = workspace
        movementPlatform = plat
        return plat
    end

    local function startFormation(target, formationType, follow, inplace)
        stopAllMovement()
        if inplace then createPlatform() return end
        if follow then createPlatform() end

        local function doTeleport()
            local myChar = LocalPlayer.Character
            local targetChar = target.Character
            if not (myChar and targetChar) then return end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if not (myRoot and targetRoot) then return end

            local look = targetRoot.CFrame.LookVector
            local right = targetRoot.CFrame.RightVector
            local pos, faceTarget = nil, false

            if formationType == "line" then
                local offset = (slotNumber - (totalBots + 1) / 2) * LINE_SPACING
                pos = targetRoot.Position - look * 3 + right * offset
            elseif formationType == "lineup" then
                pos = targetRoot.Position - look * (slotNumber * LINEUP_SPACING)
            elseif formationType == "circle" then
                pos = getCirclePosition(targetRoot, slotNumber, totalBots, ORBIT_DISTANCE)
                faceTarget = true
            elseif formationType == "star" then
                pos = getStarPosition(targetRoot, slotNumber, totalBots, STAR_SIZE)
                faceTarget = true
            elseif formationType == "wall" then
                local cols = math.ceil(math.sqrt(totalBots))
                local rows = math.ceil(totalBots / cols)
                local col = ((slotNumber - 1) % cols) - (cols - 1) / 2
                local row = math.floor((slotNumber - 1) / cols) - (rows - 1) / 2
                pos = targetRoot.Position + look * 10 + right * (col * 4) + Vector3.new(0, row * 4, 0)
            elseif formationType == "tower" then
                local base = math.max(1, math.floor(math.sqrt(totalBots)))
                local level = math.floor((slotNumber - 1) / base)
                local index = (slotNumber - 1) % base
                local col = index - (base - 1) / 2
                pos = targetRoot.Position - look * 5 + right * (col * 3) + Vector3.new(0, level * 4, 0)
            elseif formationType == "dlh" then
                local stem = math.floor(totalBots / 2)
                local horizontal = totalBots - stem
                if slotNumber <= stem then
                    pos = targetRoot.Position - look * (5 + (slotNumber - 1) * 3)
                else
                    local idx = slotNumber - stem
                    pos = targetRoot.Position - look * 5 + right * ((idx - (horizontal - 1) / 2) * 3)
                end
            end

            if pos then
                if faceTarget then
                    myRoot.CFrame = CFrame.lookAt(pos, targetRoot.Position)
                else
                    myRoot.CFrame = CFrame.lookAt(pos, pos + look)
                end
                disableAnimations()
                if movementPlatform then
                    movementPlatform.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 3, 0))
                end
            end
        end

        if follow then
            formationConnection = RunService.Heartbeat:Connect(doTeleport)
            table.insert(allConnections, formationConnection)
        else
            doTeleport()
        end
    end

    local function startOrbit(target, inplace)
        stopAllMovement()
        if inplace then createPlatform() return end
        orbitAngle = math.rad((slotNumber - 1) * (360 / math.max(totalBots, 1)))
        createPlatform()
        moveMapUp()
        orbitConnection = RunService.Heartbeat:Connect(function(dt)
            local myChar = LocalPlayer.Character
            local targetChar = target.Character
            if myChar and targetChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if myRoot and targetRoot then
                    for _, part in ipairs(myChar:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    orbitAngle = orbitAngle + orbitSpeed * dt
                    local newPos = targetRoot.CFrame * Vector3.new(math.cos(orbitAngle) * ORBIT_DISTANCE, 0, math.sin(orbitAngle) * ORBIT_DISTANCE)
                    myRoot.CFrame = CFrame.lookAt(newPos, targetRoot.Position)
                    disableAnimations()
                    if movementPlatform then
                        movementPlatform.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 3, 0))
                    end
                end
            end
        end)
        table.insert(allConnections, orbitConnection)
    end

    ------------------------------------------------------------------
    -- Background loops
    ------------------------------------------------------------------
    task.spawn(function()
        while myGen == _G.KokuwareGen and not _G.KokuwareUnloaded do
            if loopActive and loopMsg ~= "" then sendChat(loopMsg) end
            task.wait(0.6)
        end
    end)

    task.spawn(function()
        while myGen == _G.KokuwareGen and not _G.KokuwareUnloaded do
            if adallActive and adallTarget ~= "" then
                local t = getOwnTime()
                if t and t.Value > 1 then
                    sendChat(";donate " .. adallTarget .. " " .. (t.Value - 1))
                end
                task.wait(adallInterval)
            else
                task.wait(0.1)
            end
        end
    end)

    table.insert(allConnections, RunService.Heartbeat:Connect(function()
        if hiding then
            local char = LocalPlayer.Character
            if char then char:PivotTo(CFrame.new(hidePos + Vector3.new(0, 3, 0))) end
        end
    end))

    local animOverrideActive = false
    local animOverrideLoop = nil

    local function setAnimationOverride(state)
        animOverrideActive = state
        if state then
            if not animOverrideLoop then
                animOverrideLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local anim = hum and hum:FindFirstChildOfClass("Animator")
                        if anim then
                            for _, track in ipairs(anim:GetPlayingAnimationTracks()) do track:AdjustSpeed(0) end
                            anim.Parent = nil
                        end
                    end)
                end)
                table.insert(allConnections, animOverrideLoop)
            end
        else
            if animOverrideLoop then animOverrideLoop:Disconnect(); animOverrideLoop = nil end
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local orphan = char:FindFirstChildOfClass("Animator") or game:FindFirstChildOfClass("Animator")
                    if orphan then
                        orphan.Parent = hum
                        for _, track in ipairs(orphan:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end
                    end
                end
            end)
        end
    end

    ------------------------------------------------------------------
    -- Anti-grief detection
    ------------------------------------------------------------------
    local AG_SCAN_INTERVAL   = 0.05
    local AG_GRIEF_TIME      = 0.85
    local AG_MAX_GAP         = 0.30
    local AG_DETECT_DISTANCE = 50
    local AG_MIN_DELETIONS   = 2
    local AG_WARN_COOLDOWN   = 30

    local agTrackedParts  = {}
    local agPlayerData    = {}
    local agLastWarnings  = {}
    local antiGriefEnabled = true

    local function agIsDeleteTool(tool)
        if not tool:IsA("Tool") then return false end
        local n = tool.Name:lower():gsub("%s+", "")
        return n == "dtool" or n == "deletetool"
            or n:find("delete", 1, true) ~= nil
            or n:find("dtool",  1, true) ~= nil
    end

    local function agHoldingDeleteTool(player)
        local char = player.Character
        if not char then return false end
        for _, obj in ipairs(char:GetChildren()) do
            if agIsDeleteTool(obj) then return true end
        end
        return false
    end

    local function agGetClosestDToolPlayer(position)
        local closest, closestDist = nil, AG_DETECT_DISTANCE
        for _, player in ipairs(Players:GetPlayers()) do
            if agHoldingDeleteTool(player) then
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - position).Magnitude
                    if dist <= closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
        return closest
    end

    local function agRecordDeletion(player)
        if not agPlayerData[player] then
            agPlayerData[player] = {deletions = {}, streakStart = nil, lastDeletion = nil}
        end
        local data = agPlayerData[player]
        local now  = os.clock()
        table.insert(data.deletions, now)
        if data.lastDeletion and (now - data.lastDeletion) > AG_MAX_GAP then
            data.deletions  = {now}
            data.streakStart = nil
        end
        data.lastDeletion = now
        if not data.streakStart and #data.deletions >= AG_MIN_DELETIONS then
            data.streakStart = now
        end
    end

    local function agScanWorkspace()
        local current = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then current[obj] = obj.Position end
        end
        for oldPart, oldPos in pairs(agTrackedParts) do
            if not current[oldPart] then
                local player = agGetClosestDToolPlayer(oldPos)
                if player then agRecordDeletion(player) end
            end
        end
        agTrackedParts = current
    end

    local function agCheckPlayers()
        local now = os.clock()
        for player, data in pairs(agPlayerData) do
            if not player.Parent then
                agPlayerData[player]   = nil
                agLastWarnings[player] = nil
                continue
            end
            if not data.lastDeletion then continue end
            if (now - data.lastDeletion) > AG_MAX_GAP then
                data.streakStart  = nil
                data.deletions    = {}
                data.lastDeletion = nil
                continue
            end
            if data.streakStart then
                local duration = now - data.streakStart
                if duration >= AG_GRIEF_TIME then
                    local lastWarn = agLastWarnings[player] or 0
                    if now - lastWarn >= AG_WARN_COOLDOWN then
                        agLastWarnings[player] = now
                        sendChat(player.Name .. " HAS BEEN DETECTED GRIEFING🚨")
                        addLogEntry("[AntiGrief] " .. player.Name .. " detected griefing", WHITE)
                    end
                    data.streakStart = nil
                    data.deletions   = {}
                end
            end
        end
    end

    -- Seed initial part snapshot
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then agTrackedParts[obj] = obj.Position end
    end

    task.spawn(function()
        while myGen == _G.KokuwareGen and not _G.KokuwareUnloaded do
            if antiGriefEnabled then
                agScanWorkspace()
                agCheckPlayers()
            end
            task.wait(AG_SCAN_INTERVAL)
        end
    end)

    table.insert(allConnections, Players.PlayerRemoving:Connect(function(player)
        agPlayerData[player]   = nil
        agLastWarnings[player] = nil
    end))

    ------------------------------------------------------------------
    -- Commands
    ------------------------------------------------------------------
    local allCommands = ".say .loopsay .stoploop .dall .adall .stopadall .silent .hide .stophide .reset .rejoin .antiafk .form .stopform .line .circle .orbit .lineup .star .stopmove .mod .removemod .alert .credits .cmds .bots .botscheck .mb .raidcalc .unload .shutdown .orbitspeed .raid .prefix .antilag .equip .animations .msgcmds .msgcheck .msg .wall .tower .dlh .follow .tp .blacklist .unblacklist .whitelist .paint .anticrash .sign .antigrief"

    local PAINT_COLORS = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 140, 0),
        Color3.fromRGB(255, 235, 0),
        Color3.fromRGB(0, 200, 60),
        Color3.fromRGB(0, 120, 255),
        Color3.fromRGB(130, 0, 200),
        Color3.fromRGB(255, 105, 180),
        Color3.fromRGB(101, 67, 33),
        Color3.fromRGB(148, 0, 211),
        Color3.fromRGB(0, 220, 220),
        Color3.fromRGB(255, 0, 255),
    }

    local function isMyBlock(part)
        if not part:IsA("BasePart") then return false end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and part:IsDescendantOf(plr.Character) then return false end
        end
        local me, myId = LocalPlayer.Name, LocalPlayer.UserId
        for _, attr in ipairs({"Owner", "Creator", "Builder"}) do
            local a = part:GetAttribute(attr)
            if a and (a == me or a == myId) then return true end
        end
        local node = part
        while node and node ~= workspace do
            for _, key in ipairs({"Owner", "Creator", "Builder"}) do
                local v = node:FindFirstChild(key)
                if v and (v:IsA("StringValue") or v:IsA("ObjectValue") or v:IsA("IntValue")) then
                    local val = v.Value
                    if val == me or val == LocalPlayer or val == myId then return true end
                end
            end
            if node.Name == me then return true end
            node = node.Parent
        end
        return false
    end

    local function paintMyBlocks()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isMyBlock(obj) then
                obj.Color = PAINT_COLORS[math.random(1, #PAINT_COLORS)]
                count += 1
            end
        end
        return count
    end

    local antiCrashOn = true

    local function removeClone(obj)
        if not antiCrashOn or not obj or not obj.Parent then return end
        if not string.find(string.lower(obj.Name), "clone", 1, true) then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and (plr.Character == obj or obj:IsDescendantOf(plr.Character)) then return end
        end
        pcall(function() obj:Destroy() end)
    end

    task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do removeClone(obj) end
    end)
    table.insert(allConnections, workspace.DescendantAdded:Connect(removeClone))

    local function getSignIndex()
        local roster = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            for _, n in ipairs(BOT_NAMES) do
                if plr.Name == n then table.insert(roster, plr) break end
            end
        end
        table.sort(roster, function(a, b) return a.UserId > b.UserId end)
        for i, plr in ipairs(roster) do
            if plr == LocalPlayer then return i end
        end
        return slotNumber
    end

    local formNames = {line = true, circle = true, lineup = true, star = true, wall = true, tower = true, dlh = true}
    local announceForms = {wall = true, tower = true, dlh = true}

    local function handleFormation(sender, formType, argsText, announce)
        local follow, inplace, tgtText = false, false, nil
        for w in argsText:gmatch("%S+") do
            local l = w:lower()
            if l == "follow" then follow = true
            elseif l == Inplace then inplace = true
            else tgtText = w end
        end
        local tgt = getTarget(tgtText or sender.Name)
        if tgt then
            startFormation(tgt, formType, follow, inplace)
            if announce and messageToggles.formation then
                sendChat("formation:" .. formType .. " (" .. (tgtText or tgt.Name) .. ")")
            end
        end
    end

    local function processCommand(sender, message)
        if not sender or not message then return end
        if blacklist[sender.UserId] then return end

        local clean = message:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if string.sub(clean, 1, 6) == "!sign " then clean = Prefix .. clean:sub(2) end
        if string.sub(clean, 1, #Prefix) ~= Prefix and string.sub(clean, 1, 1) ~= ";" then return end
        if string.sub(clean, 1, 1) == ";" then clean = Prefix .. clean:sub(2) end
        if not isAllowed(sender) then return end

        local key = sender.UserId .. ":" .. message
        local now = os.clock()
        local last = _G.KokuwareLast
        if last[key] and now - last[key] < 0.5 then return end
        last[key] = now

        local name = clean:sub(#Prefix + 1):match("^(%S+)")
        if not name then return end
        local rawArgs = message:match("^%s*%S+%s*(.-)%s*$") or ""
        local lowerArgs = rawArgs:lower()

        if name == "shutdown" then
            if isOwner(sender) then pcall(function() LocalPlayer:Kick("Shutdown by owner") end) end

        elseif name == "unload" then
            _G.KokuwareUnloaded = true
            cleanupConnections()
            stopAllMovement()
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            if antiLagLoop then antiLagLoop:Disconnect(); antiLagLoop = nil end
            logGui:Destroy()
            sendChat("Unloaded")

        elseif name == "blacklist" then
            if not isOwner(sender) then return end
            if rawArgs == "" then sendChat("Usage: .blacklist <user>") return end
            local uid, uname = resolveUser(rawArgs)
            if not uid then sendChat("User not found") return end
            if isOwnerName(uname) then sendChat("Can't blacklist an owner") return end
            blacklist[uid] = true
            ModUsers[string.lower(uname)] = nil
            saveBlacklist()
            punished[uid] = nil
            sendChat("Blacklisted " .. uname)
            logToDiscord("Player blacklisted", {
                {name = "Target", value = uname .. " (" .. uid .. ")", inline = true},
                {name = "By", value = sender.Name, inline = true},
            }, 15158332)
            addLogEntry("[Blacklist] added " .. uname .. " (" .. uid .. ")", WHITE)
            local plr = Players:GetPlayerByUserId(uid)
            if plr then task.spawn(punish, plr) end

        elseif name == "unblacklist" then
            if not isOwner(sender) then return end
            if rawArgs == "" then sendChat("Usage: .unblacklist <user>") return end
            local uid, uname = resolveUser(rawArgs)
            if uid and blacklist[uid] then
                blacklist[uid] = nil
                punished[uid] = nil
                saveBlacklist()
                sendChat("Removed " .. uname .. " from blacklist")
            else
                sendChat("That user isn't blacklisted")
            end

        elseif name == "whitelist" then
            if not isOwner(sender) then return end
            if rawArgs == "" then sendChat("Usage: .whitelist <user>") return end
            local uid, uname = resolveUser(rawArgs)
            if not uid then sendChat("User not found") return end
            blacklist[uid] = nil
            punished[uid] = nil
            saveBlacklist()
            sendChat(uname .. " has been whitelisted.")
            sendChat(";Enlighten " .. uname)
            logToDiscord("Player whitelisted", {
                {name = "Target", value = uname .. " (" .. uid .. ")", inline = true},
                {name = "By", value = sender.Name, inline = true},
            }, 3066993)

        elseif name == "sign" then
            local word = lowerArgs:gsub("%s+", "")
            if word == "" then sendChat("Usage: .sign <word>") return end
            local letter = word:sub(getSignIndex(), getSignIndex())
            local decal = LETTER_DECALS[letter]
            sendChat(decal and tostring(decal) or ".")

        elseif name == "paint" then
            if lowerArgs ~= "all" then sendChat("Usage: .paint all") return end
            sendChat("Painted " .. paintMyBlocks() .. " blocks")

        elseif name == "anticrash" then
            if lowerArgs == "off" then
                antiCrashOn = false
                sendChat("Anti crash off")
            else
                antiCrashOn = true
                sendChat("Anti crash on")
            end

        elseif name == "antilag" then
            if lowerArgs == "off" then
                disableAntiLag()
                if messageToggles.antilag then sendChat("Anti-lag off") end
            else
                applyAntiLag()
                if messageToggles.antilag then sendChat("Anti-lag on") end
            end

        elseif name == "antiafk" then
            if lowerArgs == "off" then
                sendChat("Anti AFK off not supported")
            else
                pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ANTI-AFK-by-gun-265109"))() end)
                if messageToggles.antiafk then sendChat("Anti-afk on") end
            end

        elseif name == "silent" then silentMode = not silentMode

        elseif name == "rejoin" then
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

        elseif name == "reset" then
            loopActive = false; loopMsg = ""; adallActive = false
            stopAllMovement()
            restoreMap()
            if hiding then hiding = false; if hidePartObj then hidePartObj:Destroy(); hidePartObj = nil end end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end

        elseif name == "hide" then
            if not hiding then
                local char = LocalPlayer.Character
                if char then returnPos = char:GetPivot(); char:PivotTo(CFrame.new(hidePos + Vector3.new(0, 3, 0))) end
                hidePartObj = Instance.new("Part")
                hidePartObj.Size = Vector3.new(20, 1, 20)
                hidePartObj.Position = hidePos
                hidePartObj.Anchored = true
                hidePartObj.Parent = workspace
                hiding = true
            end

        elseif name == "stophide" then
            if hiding then
                hiding = false
                if hidePartObj then hidePartObj:Destroy(); hidePartObj = nil end
                local char = LocalPlayer.Character
                if char and returnPos then char:PivotTo(returnPos) end
            end

        elseif name == "stopform" or name == "stopmove" then
            stopAllMovement()
            restoreMap()

        elseif name == "form" then
            local first, rest = rawArgs:match("^(%S+)%s*(.*)$")
            if first and formNames[first:lower()] then
                handleFormation(sender, first:lower(), rest, true)
            elseif not first then
                startFormation(sender, "line", false, false)
            end

        elseif formNames[name] then
            handleFormation(sender, name, rawArgs, announceForms[name])

        elseif name == "orbit" then
            local inplace = string.find(lowerArgs, Inplace) ~= nil
            local tgtText = rawArgs:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(tgtText ~= "" and tgtText or sender.Name)
            if tgt then startOrbit(tgt, inplace) end

        elseif name == "dall" then
            local target = (rawArgs ~= "" and getTarget(rawArgs)) or sender
            local t = getOwnTime()
            if t and t.Value > 1 then
                sendChat(";donate " .. fixUsername(target.Name) .. " " .. (t.Value - 1))
            end

        elseif name == "adall" then
            local list = {}
            for a in rawArgs:gmatch("%S+") do table.insert(list, a) end
            local interval, target = 1, sender
            if #list >= 1 then
                if tonumber(list[1]) then
                    interval = tonumber(list[1])
                    if #list >= 2 then target = getTarget(list[2]) or sender end
                else
                    target = getTarget(list[1]) or sender
                    if #list >= 2 and tonumber(list[2]) then interval = tonumber(list[2]) end
                end
            end
            adallInterval = interval
            adallTarget = fixUsername(target.Name)
            adallActive = true

        elseif name == "stopadall" then adallActive = false
        elseif name == "botscheck" then sendChat(autoMatchMsg)

        elseif name == "mb" then
            if rawArgs ~= "" then
                autoMatchMsg = rawArgs
                sendChat("Auto-match message set to: " .. rawArgs)
            else
                autoMatchMsg = "°"
                sendChat("Auto-match message reset to °")
            end

        elseif name == "raidcalc" then
            local t = getOwnTime()
            local current = t and t.Value or 0
            local target = 1000
            local rate = totalBots + 1
            local needed = math.max(0, target - current)
            local seconds = math.ceil(needed / rate)
            sendChat("RaidCalc: " .. math.floor(seconds / 60) .. " minutes and " .. (seconds % 60) .. " seconds to reach " .. target .. " time with " .. (totalBots + 1) .. " total players.")

        elseif name == "mod" then
            local target = (rawArgs ~= "" and getTarget(rawArgs)) or sender
            if target and not blacklist[target.UserId] then ModUsers[string.lower(target.DisplayName)] = true end

        elseif name == "removemod" then
            if lowerArgs == "a" then
                ModUsers = {}
                sendChat("All mods removed")
            else
                local target = (rawArgs ~= "" and getTarget(rawArgs)) or sender
                if target then
                    local k = string.lower(target.DisplayName)
                    if ModUsers[k] then ModUsers[k] = nil; sendChat("Removed mod " .. target.DisplayName)
                    else sendChat(target.DisplayName .. " is not a mod") end
                end
            end

        elseif name == "bots" then
            local num = tonumber(rawArgs)
            if num and num > 0 then totalBots = num end

        elseif name == "say" then
            if rawArgs ~= "" then sendChat(rawArgs) end

        elseif name == "loopsay" then
            if rawArgs ~= "" then loopMsg = rawArgs; loopActive = true end

        elseif name == "stoploop" then loopActive = false; loopMsg = ""; adallActive = false

        elseif name == "alert" then
            if rawArgs ~= "" then sendAlert(rawArgs) else sendAlert("Alert! " .. sender.DisplayName .. " requests your attention!") end

        elseif name == "credits" then
            local creditLines = {
                "Kokuware - Credits to " .. CREDITS,
                "Anti crash | Credits to " .. CREDITS,
                "Anti grief | Credits to " .. CREDITS,
            }
            for _, line in ipairs(creditLines) do sendChat(line) task.wait(0.3) end

        elseif name == "cmds" then
            local cmds = allCommands:split(" ")
            local chunk = ""
            for _, c in ipairs(cmds) do
                local nextChunk = (chunk == "") and c or (chunk .. " | " .. c)
                if #nextChunk > 190 then
                    sendChat(chunk)
                    task.wait(0.5)
                    chunk = c
                else
                    chunk = nextChunk
                end
            end
            if chunk ~= "" then sendChat(chunk) end

        elseif name == "orbitspeed" then
            local num = tonumber(rawArgs)
            if num and num > 0 then orbitSpeed = num end
            if messageToggles.orbitspeed then sendChat("orbitspeed set to (" .. orbitSpeed .. ")") end

        elseif name == "raid" then
            if isOwner(sender) then
                pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ANTI-AFK-by-gun-265109"))() end)
                adallTarget = fixUsername(sender.Name)
                adallInterval = 20
                adallActive = true
            end

        elseif name == "prefix" then
            if rawArgs ~= "" then Prefix = rawArgs end

        elseif name == "msgcmds" then
            sendChat("Usage: .msg <type> on/off | Types: loading, orbitspeed, formation, antiafk, antilag")

        elseif name == "msgcheck" then
            for _, k in ipairs({"loading", "orbitspeed", "formation", "antilag", "antiafk"}) do
                sendChat(k .. " | " .. (messageToggles[k] and "on" or "off"))
                task.wait(0.2)
            end

        elseif name == "msg" then
            local list = {}
            for a in lowerArgs:gmatch("%S+") do table.insert(list, a) end
            if #list >= 2 then
                local msgType, state = list[1], list[2]
                if defaultMessages[msgType] ~= nil then
                    if state == "on" or state == "off" then
                        messageToggles[msgType] = (state == "on")
                        saveMessages()
                        sendChat("Message " .. msgType .. " " .. state)
                    else
                        sendChat("Usage: .msg <type> on/off")
                    end
                else
                    sendChat("Invalid message type")
                end
            else
                sendChat("Usage: .msg <type> on/off")
            end

        elseif name == "follow" then
            stopAllMovement()
            if rawArgs == "" then return end
            local inplace = string.find(lowerArgs, Inplace) ~= nil
            local tgtText = rawArgs:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(tgtText ~= "" and tgtText or sender.Name)
            if tgt then
                if inplace then createPlatform() return end
                followConnection = RunService.Heartbeat:Connect(function()
                    local myChar = LocalPlayer.Character
                    local targetChar = tgt.Character
                    if myChar and targetChar then
                        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if myRoot and targetRoot then
                            local look = targetRoot.CFrame.LookVector
                            local randomAngle = math.random(-15, 15)
                            local offset = (CFrame.lookAt(Vector3.new(0, 0, 0), look) * CFrame.Angles(0, math.rad(randomAngle), 0)).LookVector
                            local pos = targetRoot.Position - offset * math.random(4, 7)
                            myRoot.CFrame = CFrame.lookAt(pos, targetRoot.Position)
                            disableAnimations()
                        end
                    end
                end)
                table.insert(allConnections, followConnection)
            end

        elseif name == "tp" then
            if isOwner(sender) or ModUsers[string.lower(sender.DisplayName)] then
                local tgt = (rawArgs ~= "" and getTarget(rawArgs)) or sender
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and targetRoot then myRoot.CFrame = targetRoot.CFrame end
            end

        elseif name == "equip" then
            if rawArgs == "" then sendChat("Usage: .equip <item>") else equipTool(rawArgs) end

        elseif name == "animations" then
            setAnimationOverride(not animOverrideActive)

        elseif name == "antigrief" then
            if lowerArgs == "off" then
                antiGriefEnabled = false
                sendChat("Anti-grief off")
                addLogEntry("[AntiGrief] disabled", WHITE)
            else
                antiGriefEnabled = true
                sendChat("Anti-grief on")
                addLogEntry("[AntiGrief] enabled", WHITE)
            end
        end
    end

    local function hookPlayer(p)
        table.insert(allConnections, p.Chatted:Connect(function(m) processCommand(p, m) end))
    end

    for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
    table.insert(allConnections, Players.PlayerAdded:Connect(hookPlayer))

    if TextChatService then
        table.insert(allConnections, TextChatService.MessageReceived:Connect(function(m)
            local sender = m.TextSource and Players:GetPlayerByUserId(m.TextSource.UserId)
            if sender then processCommand(sender, m.Text) end
        end))
    end

    slotBox.Text = tostring(slotNumber)
    addLogEntry("Bot started with owner: " .. (hasOwner and ownerName or "anyone") .. " | Slot: " .. slotNumber, WHITE)
end

----------------------------------------------------------------------
-- Log GUI buttons / setup flow
----------------------------------------------------------------------
setSlotBtn.MouseButton1Click:Connect(function()
    local num = tonumber(slotBox.Text)
    if num and num >= 1 and num <= 99 then
        local username = getActiveUsername()
        if not username then
            showUsernamePrompt(function(newUsername)
                saveData(newUsername, num)
                main(newUsername, num)
            end)
        else
            saveData(username, num)
            main(username, num)
        end
    end
end)

changeBtn.MouseButton1Click:Connect(function()
    showUsernamePrompt(function(username)
        showSlotPrompt(function(slot)
            saveData(username, slot)
            main(username, slot)
        end)
    end)
end)

local function performSetup()
    local activeUser = getActiveUsername()
    if not activeUser then
        showUsernamePrompt(function(username)
            saveActiveUsername(username)
            setUserFiles(username)
            performSetup()
        end)
        return
    end

    if not isLicenseValid() then
        showKeyPrompt(performSetup)
        return
    end

    local agreed = false
    pcall(function() if readfile(AGREEMENT_FILE) then agreed = true end end)
    if not agreed then
        showTermsPrompt(performSetup)
        return
    end

    local savedUser, savedSlot = loadSavedData()
    if not savedUser or not savedSlot then
        showSlotPrompt(function(slot)
            saveData(activeUser, slot)
            main(activeUser, slot)
        end)
    else
        main(savedUser, savedSlot)
    end
end

----------------------------------------------------------------------
-- Periodic integrity + remote blacklist check (WITH self-destruct)
----------------------------------------------------------------------
task.spawn(function()
    while not _G.KokuwareUnloaded do
        task.wait(120)
        local tampered = not integrityOK()
        if tampered then selfDestruct("Script was modified (periodic check)") end
        if tampered or isRemotelyBlacklisted() then
            if not tampered then logToDiscord("Blacklisted user was shut off", {}, 15158332) end
            _G.KokuwareUnloaded = true
            cleanupConnections()
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            if antiLagLoop then antiLagLoop:Disconnect(); antiLagLoop = nil end
            logGui:Destroy()
            break
        end
    end
end)

performSetup()
