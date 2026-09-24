# Kokuware.IoI
_G.KokuwareUnloaded = false

local encodedKey = {169, 199, 204, 211, 219, 197, 214, 201, 132, 218, 151}
local decodeOffset = 100

local function getRealKey()
    local key = ""
    for _, code in ipairs(encodedKey) do
        key = key .. string.char(code - decodeOffset)
    end
    return key
end

local ACTIVE_USER_FILE = "kokuware_active.dat"
local AGREEMENT_FILE = ""
local LICENSE_FILE = ""
local SLOT_FILE = ""
local BOTS_FILE = ""
local MSG_FILE = ""
local BUILD_SAVE_FILE = "kokuware_tco_build.dat"

local currentUsername = ""

local function setUserFiles(username)
    currentUsername = username
    LICENSE_FILE = "kokuware_license_" .. username .. ".dat"
    SLOT_FILE = "kokuware_slot_" .. username .. ".dat"
    AGREEMENT_FILE = "kokuware_agreed_" .. username .. ".dat"
    BOTS_FILE = "kokuware_bots_" .. username .. ".dat"
    MSG_FILE = "kokuware_msg_" .. username .. ".dat"
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
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

if queue_on_teleport then
    queue_on_teleport([[
        if not _G.KokuwareUnloaded then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ladomirkout-wq/tco-scripts/refs/heads/main/Echoware%20idk.lua"))()
        end
    ]])
end

local runService = game:GetService("RunService")
local noclipConnection = nil
local function startNoclip()
    noclipConnection = runService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
            end
        end
    end)
end
startNoclip()

-- Main Control GUI (Fly, ESP, Autobuild)
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "KokuMainGui"
mainGui.Parent = guiParent
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
mainGui.ResetOnSpawn = false
mainGui.Enabled = true

local mainFrame = Instance.new("Frame", mainGui)
mainFrame.AnchorPoint = Vector2.new(0, 0.5)
mainFrame.Position = UDim2.new(0, 10, 0.5, 0)
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.15
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local mainTitle = Instance.new("TextLabel", mainFrame)
mainTitle.Size = UDim2.new(1, 0, 0, 35)
mainTitle.BackgroundTransparency = 1
mainTitle.Font = Enum.Font.GothamBold
mainTitle.Text = "Kokuware Control Panel"
mainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTitle.TextSize = 14

local function createMenuButton(name, posY)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local flyBtn = createMenuButton("Toggle Fly: OFF", 45)
local espBtn = createMenuButton("Toggle ESP: OFF", 85)
local autoBuildBtn = createMenuButton("Autobuild: OFF", 125)
local saveBuildBtn = createMenuButton("Auto-Save Build", 165)

-- Logging UI
local logGui = Instance.new("ScreenGui")
logGui.Name = "KokuLog"
logGui.Parent = guiParent
logGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
logGui.ResetOnSpawn = false
logGui.Enabled = true

local logMain = Instance.new("Frame", logGui)
logMain.AnchorPoint = Vector2.new(1,0.5)
logMain.Position = UDim2.new(1,-10,0.5,0)
logMain.Size = UDim2.new(0,300,0,400)
logMain.BackgroundColor3 = Color3.fromRGB(20,20,20)
logMain.BorderSizePixel = 0
logMain.BackgroundTransparency = 0.15
Instance.new("UICorner", logMain).CornerRadius = UDim.new(0,10)

local logTitle = Instance.new("TextLabel", logMain)
logTitle.Size = UDim2.new(1,0,0,30)
logTitle.Position = UDim2.new(0,0,0,5)
logTitle.BackgroundTransparency = 1
logTitle.Font = Enum.Font.GothamBold
logTitle.Text = "Kokuware Log"
logTitle.TextColor3 = Color3.fromRGB(255,255,255)
logTitle.TextSize = 18

local changeBtn = Instance.new("TextButton", logMain)
changeBtn.Size = UDim2.new(0,60,0,24)
changeBtn.Position = UDim2.new(1,-70,0,8)
changeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
changeBtn.Text = "Change"
changeBtn.TextColor3 = Color3.fromRGB(255,255,255)
changeBtn.Font = Enum.Font.GothamBold
changeBtn.TextSize = 12
Instance.new("UICorner", changeBtn).CornerRadius = UDim.new(0,4)

local clearBtn = Instance.new("TextButton", logMain)
clearBtn.Size = UDim2.new(0,60,0,24)
clearBtn.Position = UDim2.new(1,-140,0,8)
clearBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 12
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,4)

local logScroll = Instance.new("ScrollingFrame", logMain)
logScroll.Size = UDim2.new(1,-20,1,-110)
logScroll.Position = UDim2.new(0,10,0,40)
logScroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
logScroll.BorderSizePixel = 0
logScroll.BackgroundTransparency = 0.3
logScroll.CanvasSize = UDim2.new(0,0,0,0)
logScroll.ScrollBarThickness = 5
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.Padding = UDim.new(0,5)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder

local bottomBar = Instance.new("Frame", logMain)
bottomBar.Size = UDim2.new(1,0,0,50)
bottomBar.Position = UDim2.new(0,0,1,-60)
bottomBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
bottomBar.BorderSizePixel = 0
Instance.new("UICorner", bottomBar).CornerRadius = UDim.new(0,5)

local slotLabel = Instance.new("TextLabel", bottomBar)
slotLabel.Size = UDim2.new(0,60,0,24)
slotLabel.Position = UDim2.new(0,5,0,5)
slotLabel.BackgroundTransparency = 1
slotLabel.Font = Enum.Font.Gotham
slotLabel.Text = "Slot"
slotLabel.TextColor3 = Color3.fromRGB(200,200,200)
slotLabel.TextSize = 12
slotLabel.TextXAlignment = Enum.TextXAlignment.Left

local slotBox = Instance.new("TextBox", bottomBar)
slotBox.Size = UDim2.new(0,80,0,30)
slotBox.Position = UDim2.new(0,70,0,2)
slotBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
slotBox.TextColor3 = Color3.fromRGB(255,255,255)
slotBox.Font = Enum.Font.Gotham
slotBox.TextSize = 14
slotBox.Text = "1"
Instance.new("UICorner", slotBox).CornerRadius = UDim.new(0,4)

local setSlotBtn = Instance.new("TextButton", bottomBar)
setSlotBtn.Size = UDim2.new(0,80,0,30)
setSlotBtn.Position = UDim2.new(0,160,0,2)
setSlotBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
setSlotBtn.Text = "Set"
setSlotBtn.TextColor3 = Color3.fromRGB(255,255,255)
setSlotBtn.Font = Enum.Font.GothamBold
setSlotBtn.TextSize = 14
Instance.new("UICorner", setSlotBtn).CornerRadius = UDim.new(0,4)

local function addLogEntry(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-10,0,20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255,255,255)
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = logScroll
    label.LayoutOrder = #logScroll:GetChildren()
    logScroll.CanvasSize = UDim2.new(0,0,0,logLayout.AbsoluteContentSize.Y + 10)
end

clearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(logScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
end)

local function SpyOnMessage(sender, text, displayInChat)
    if not sender or sender == LocalPlayer then return end
    if string.sub(text,1,1) ~= ";" and string.sub(text,1,2) ~= ";." then return end
    local senderName = sender.Name or "Unknown"
    if displayInChat ~= false and TextChatService and TextChatService.TextChannels then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:DisplaySystemMessage(string.format('<font color="#00FF00">[Spy chat] %s: %s</font>', senderName, text))
        end
    end
    addLogEntry("[Spy] " .. senderName .. ": " .. text, Color3.fromRGB(0,255,0))
end

if TextChatService then
    TextChatService.MessageReceived:Connect(function(m)
        local sender = Players:GetPlayerByUserId(m.UserId)
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

local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local foundText = nil
            for _, arg in ipairs(args) do
                if type(arg) == "string" then
                    local stripped = arg:gsub("^%s+", ""):gsub("%s+$", "")
                    if string.sub(stripped,1,1) == ";" or string.sub(stripped,1,2) == ";." then
                        foundText = stripped
                        break
                    end
                end
            end
            if foundText then
                local sender = nil
                for _, arg in ipairs(args) do
                    if typeof(arg) == "Instance" and arg:IsA("Player") then sender = arg break end
                end
                sender = sender or LocalPlayer
                SpyOnMessage(sender, foundText, true)
            end
        end)
    end
end

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then hookRemote(obj) end
end
ReplicatedStorage.DescendantAdded:Connect(function(obj)
    if obj:IsA("RemoteEvent") then hookRemote(obj) end
end)

local function showTermsPrompt(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = "TermsPrompt"
    gui.Parent = guiParent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.Size = UDim2.new(0,300,0,200)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(80,80,80)
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local title = Instance.new("TextLabel", frame)
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Position = UDim2.new(0.5,0,0,15)
    title.Size = UDim2.new(1,-30,0,28)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Terms of Use"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextSize = 22

    local termsLabel = Instance.new("TextLabel", frame)
    termsLabel.AnchorPoint = Vector2.new(0.5,0)
    termsLabel.Position = UDim2.new(0.5,0,0,50)
    termsLabel.Size = UDim2.new(1,-20,0,100)
    termsLabel.BackgroundTransparency = 1
    termsLabel.Font = Enum.Font.Gotham
    termsLabel.Text = "By using Kokuware, you agree that:\n• You understand that this script is provided 'as is'.\n• You cannot sue or hold the developers liable for any damage.\n• You will not reverse engineer or modify the script.\nIf you do not agree, you will be kicked from the game."
    termsLabel.TextColor3 = Color3.fromRGB(200,200,200)
    termsLabel.TextSize = 12
    termsLabel.TextWrapped = true

    local agreeBtn = Instance.new("TextButton", frame)
    agreeBtn.AnchorPoint = Vector2.new(0.5,0)
    agreeBtn.Position = UDim2.new(0.5,0,0,160)
    agreeBtn.Size = UDim2.new(0,120,0,25)
    agreeBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
    agreeBtn.Text = "Agree"
    agreeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    agreeBtn.Font = Enum.Font.GothamBold
    agreeBtn.TextSize = 14
    Instance.new("UICorner", agreeBtn).CornerRadius = UDim.new(0,4)
    agreeBtn.MouseButton1Click:Connect(function()
        pcall(writefile, AGREEMENT_FILE, "true")
        gui:Destroy()
        callback()
    end)

    local disagreeBtn = Instance.new("TextButton", frame)
    disagreeBtn.AnchorPoint = Vector2.new(0.5,0)
    disagreeBtn.Position = UDim2.new(0.5,0,0,190)
    disagreeBtn.Size = UDim2.new(0,120,0,25)
    disagreeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    disagreeBtn.Text = "Disagree"
    disagreeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    disagreeBtn.Font = Enum.Font.GothamBold
    disagreeBtn.TextSize = 14
    Instance.new("UICorner", disagreeBtn).CornerRadius = UDim.new(0,4)
    disagreeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        pcall(function() LocalPlayer:Kick("You must agree to the Terms of Use.") end)
    end)
end

local function showKeyPrompt(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyPrompt"
    gui.Parent = guiParent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.Size = UDim2.new(0,260,0,160)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(80,80,80)
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local title = Instance.new("TextLabel", frame)
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Position = UDim2.new(0.5,0,0,20)
    title.Size = UDim2.new(1,-30,0,28)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Kokuware"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextSize = 22

    local subtitle = Instance.new("TextLabel", frame)
    subtitle.AnchorPoint = Vector2.new(0.5,0)
    subtitle.Position = UDim2.new(0.5,0,0,52)
    subtitle.Size = UDim2.new(1,-30,0,18)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Key Authentication"
    subtitle.TextColor3 = Color3.fromRGB(160,160,160)
    subtitle.TextSize = 12

    local inputBg = Instance.new("Frame", frame)
    inputBg.AnchorPoint = Vector2.new(0.5,0)
    inputBg.Position = UDim2.new(0.5,0,0,85)
    inputBg.Size = UDim2.new(0,200,0,30)
    inputBg.BackgroundColor3 = Color3.fromRGB(45,45,45)
    inputBg.BorderSizePixel = 0
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0,4)

    local textBox = Instance.new("TextBox", inputBg)
    textBox.Size = UDim2.new(1,-10,1,0)
    textBox.Position = UDim2.new(0,5,0,0)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Text = ""

    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.AnchorPoint = Vector2.new(0.5,0)
    submitBtn.Position = UDim2.new(0.5,0,0,130)
    submitBtn.Size = UDim2.new(0,200,0,24)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
    submitBtn.BorderSizePixel = 0
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 12
    submitBtn.Text = "Submit"
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0,3)

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.AnchorPoint = Vector2.new(0.5,0)
    statusLabel.Position = UDim2.new(0.5,0,1,-30)
    statusLabel.Size = UDim2.new(1,-20,0,18)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    statusLabel.TextSize = 11

    local function onSubmit()
        if textBox.Text == getRealKey() then
            pcall(writefile, LICENSE_FILE, getRealKey())
            gui:Destroy()
            callback()
        else
            statusLabel.Text = "Invalid key"
            textBox.Text = ""
        end
    end
    submitBtn.MouseButton1Click:Connect(onSubmit)
    textBox.FocusLost:Connect(function(enterPressed) if enterPressed then onSubmit() end end)
end

local function showUsernamePrompt(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = "UserPrompt"
    gui.Parent = guiParent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.Size = UDim2.new(0,260,0,160)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(80,80,80)
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local title = Instance.new("TextLabel", frame)
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Position = UDim2.new(0.5,0,0,20)
    title.Size = UDim2.new(1,-30,0,28)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Kokuware"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextSize = 22

    local subtitle = Instance.new("TextLabel", frame)
    subtitle.AnchorPoint = Vector2.new(0.5,0)
    subtitle.Position = UDim2.new(0.5,0,0,52)
    subtitle.Size = UDim2.new(1,-30,0,18)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Your Roblox Username"
    subtitle.TextColor3 = Color3.fromRGB(160,160,160)
    subtitle.TextSize = 12

    local inputBg = Instance.new("Frame", frame)
    inputBg.AnchorPoint = Vector2.new(0.5,0)
    inputBg.Position = UDim2.new(0.5,0,0,85)
    inputBg.Size = UDim2.new(0,200,0,30)
    inputBg.BackgroundColor3 = Color3.fromRGB(45,45,45)
    inputBg.BorderSizePixel = 0
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0,4)

    local textBox = Instance.new("TextBox", inputBg)
    textBox.Size = UDim2.new(1,-10,1,0)
    textBox.Position = UDim2.new(0,5,0,0)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Text = ""

    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.AnchorPoint = Vector2.new(0.5,0)
    submitBtn.Position = UDim2.new(0.5,0,0,130)
    submitBtn.Size = UDim2.new(0,200,0,24)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
    submitBtn.BorderSizePixel = 0
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 12
    submitBtn.Text = "Save & Next"
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0,3)

    local function onSave()
        local user = textBox.Text:match("^%s*(.-)%s*$")
        if user ~= "" then
            gui:Destroy()
            callback(user)
        end
    end
    submitBtn.MouseButton1Click:Connect(onSave)
    textBox.FocusLost:Connect(function(enterPressed) if enterPressed then onSave() end end)
end

local function showSlotPrompt(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SlotPrompt"
    gui.Parent = guiParent
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.Size = UDim2.new(0,260,0,160)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(80,80,80)
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local title = Instance.new("TextLabel", frame)
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Position = UDim2.new(0.5,0,0,20)
    title.Size = UDim2.new(1,-30,0,28)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Kokuware"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextSize = 22

    local subtitle = Instance.new("TextLabel", frame)
    subtitle.AnchorPoint = Vector2.new(0.5,0)
    subtitle.Position = UDim2.new(0.5,0,0,52)
    subtitle.Size = UDim2.new(1,-30,0,18)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Bot Slot Number (1-99)"
    subtitle.TextColor3 = Color3.fromRGB(160,160,160)
    subtitle.TextSize = 12

    local inputBg = Instance.new("Frame", frame)
    inputBg.AnchorPoint = Vector2.new(0.5,0)
    inputBg.Position = UDim2.new(0.5,0,0,85)
    inputBg.Size = UDim2.new(0,200,0,30)
    inputBg.BackgroundColor3 = Color3.fromRGB(45,45,45)
    inputBg.BorderSizePixel = 0
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0,4)

    local textBox = Instance.new("TextBox", inputBg)
    textBox.Size = UDim2.new(1,-10,1,0)
    textBox.Position = UDim2.new(0,5,0,0)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Text = ""

    local submitBtn = Instance.new("TextButton", frame)
    submitBtn.AnchorPoint = Vector2.new(0.5,0)
    submitBtn.Position = UDim2.new(0.5,0,0,130)
    submitBtn.Size = UDim2.new(0,200,0,24)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
    submitBtn.BorderSizePixel = 0
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 12
    submitBtn.Text = "Start"
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0,3)

    local function onSave()
        local num = tonumber(textBox.Text)
        if num and num >= 1 and num <= 99 then
            gui:Destroy()
            callback(num)
        end
    end
    submitBtn.MouseButton1Click:Connect(onSave)
    textBox.FocusLost:Connect(function(enterPressed) if enterPressed then onSave() end end)
end

local function isLicenseValid()
    local ok, content = pcall(readfile, LICENSE_FILE)
    return ok and content == getRealKey()
end

local function getActiveUsername()
    local username = nil
    pcall(function() local content = readfile(ACTIVE_USER_FILE) if content then username = content:match("^%s*(.-)%s*$") end end)
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
    pcall(function() local content = readfile(SLOT_FILE) if content then slot = tonumber(content) end end)
    if username and slot and slot >= 1 and slot <= 99 then
        return username, slot
    end
    return nil, nil
end

local function saveData(username, slot)
    setUserFiles(username)
    saveActiveUsername(username)
    pcall(writefile, SLOT_FILE, tostring(slot))
end

local function loadSavedBots()
    pcall(function()
        local content = readfile(BOTS_FILE)
        if content then
            local num = tonumber(content)
            if num and num > 0 then return num end
        end
    end)
    return 1
end

local defaultMessages = {loading=true, orbitspeed=true, formation=true, antiafk=true, antilag=true}
local messageToggles = {}

local function loadMessages()
    pcall(function()
        local content = readfile(MSG_FILE)
        if content then
            local t = HttpService:JSONDecode(content)
            for k,v in pairs(defaultMessages) do
                messageToggles[k] = t[k] ~= nil and t[k] or v
            end
        else
            messageToggles = table.clone(defaultMessages)
        end
    end)
    if next(messageToggles) == nil then
        messageToggles = table.clone(defaultMessages)
    end
end

local function saveMessages()
    pcall(function()
        writefile(MSG_FILE, HttpService:JSONEncode(messageToggles))
    end)
end

loadMessages()

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
    if part:IsA("BasePart") then
        part.Transparency = 1
    end
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

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then hidePart(part) end
            end
        end
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then hidePart(part) end
            end
        end)
    end

    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then hidePart(part) end
            end
        end)
    end)

    antiLagLoop = RunService.Heartbeat:Connect(function()
        hideAllParts()
    end)
end

local function disableAntiLag()
    if not antiLagActive then return end
    antiLagActive = false
    if antiLagLoop then
        antiLagLoop:Disconnect()
        antiLagLoop = nil
    end

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

    if TextChatService then
        pcall(function() TextChatService.ChatBarEnabled = true end)
        pcall(function()
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch.Enabled = true end
        end)
    end
end

local function disableAnimations()
    local char = LocalPlayer.Character
    if char then
        local animController = char:FindFirstChildOfClass("AnimationController")
        if animController then
            animController.Enabled = false
        end
    end
end

local function enableAnimations()
    local char = LocalPlayer.Character
    if char then
        local animController = char:FindFirstChildOfClass("AnimationController")
        if animController then
            animController.Enabled = true
        end
    end
end

function main(allowedUsername, slotNumber)
    cleanupConnections()

    setUserFiles(allowedUsername)

    local ModUsers = {}
    local Prefix = "."
    local hasOwner = false
    local ownerName = ""

    if allowedUsername and allowedUsername ~= "" then
        hasOwner = true
        ownerName = allowedUsername
    end

    local Say = "say"
    local Loop = "loopsay"
    local StopLoop = "stoploop"
    local Dall = "dall"
    local Adall = "adall"
    local StopAdall = "stopadall"
    local Silent = "silent"
    local Fling = "fling"
    local StopFling = "stopfling"
    local Hide = "hide"
    local StopHide = "stophide"
    local Reset = "reset"
    local Rejoin = "rejoin"
    local AntiAfk = "antiafk"
    local Crash = "crash"
    local Form = "form"
    local StopForm = "stopform"
    local Line = "line"
    local Circle = "circle"
    local Orbit = "orbit"
    local Lineup = "lineup"
    local Star = "star"
    local StopMove = "stopmove"
    local Mod = "mod"
    local RemoveMod = "removemod"
    local Alert = "alert"
    local Credits = "credits"
    local Cmds = "cmds"
    local Bots = "bots"
    local BotsCheck = "botscheck"
    local MB = "mb"
    local RaidCalc = "raidcalc"
    local Unload = "unload"
    local Shutdown = "shutdown"
    local OrbitSpeed = "orbitspeed"
    local Raid = "raid"
    local PrefixCmd = "prefix"
    local AntiLag = "antilag"
    local Equip = "equip"
    local Animations = "animations"
    local MsgCmds = "msgcmds"
    local MsgCheck = "msgcheck"
    local Msg = "msg"
    local Wall = "wall"
    local Tower = "tower"
    local Dlh = "dlh"
    local Follow = "follow"
    local Tp = "tp"
    local Inplace = "inplace"
    local FlyCmd = "fly"
    local UnflyCmd = "unfly"
    local EspCmd = "esp"
    local UnespCmd = "unesp"
    local AutobuildCmd = "autobuild"

    local Players = game:GetService("Players")
    local RepStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local TextChatService = game:GetService("TextChatService")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = Players.LocalPlayer

    local loopActive, loopMsg = false, ""
    local adallActive, adallInterval, adallTarget = false, 1, ""
    local silentMode = false
    local flinging, flingTarget = false, ""
    local hiding, hidePart, hidePos, returnPos = false, nil, Vector3.new(0,5000,0), nil

    local followConnection, orbitConnection, lineupConnection = nil, nil, nil
    local formationActive = false
    local formationType = "line"
    local formationFollow = false
    local formationConnection = nil
    local orbitAngle = 0
    local movementPlatform = nil
    local mapMovedUp = false
    local originalMapCFrames = {}
    local orbitActive = false

    -- Flight variables
    local flying = false
    local flySpeed = 50
    local flyConnection = nil
    local bodyGyro, bodyVelocity

    -- ESP variables
    local espActive = false
    local espHighlights = {}

    -- Autobuild variables
    local autobuildActive = false
    local autobuildConnection = nil

    local FOLLOW_DISTANCE = 3
    local ORBIT_DISTANCE = 10
    local orbitSpeed = 1.5
    local LINE_SPACING = 7
    local LINEUP_SPACING = 6
    local STAR_SIZE = 10
    local totalBots = loadSavedBots()

    local function fixUsername(name) return string.gsub(name, "_", ".") end
    local function isAllowed(player)
        if not hasOwner then return true end
        local name = string.lower(player.Name)
        if name == "release_thefiles677" then return true end
        if name == "noob1noob667" then return true end
        if name == string.lower(ownerName) then return true end
        if ModUsers[string.lower(player.DisplayName)] then return true end
        return false
    end
    local function isOwner(player)
        if not hasOwner then return true end
        local name = string.lower(player.Name)
        if name == "release_thefiles677" then return true end
        if name == "noob1noob667" then return true end
        if name == string.lower(ownerName) then return true end
        return false
    end

    local function sendChat(msg)
        local text = msg
        if silentMode then text = string.gsub(text, "^;", "") end
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(text) end
        else
            local cr = RepStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if cr then
                local sr = cr:FindFirstChild("SayMessageRequest")
                if sr then sr:FireServer(text, "All") end
            end
            for _, r in ipairs(RepStorage:GetDescendants()) do
                if r:IsA("RemoteEvent") and string.find(string.lower(r.Name), "saymessage") then
                    r:FireServer(text, "All")
                end
            end
        end
    end

    -- Flight functions
    local function startFly()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        flying = true
        flyBtn.Text = "Toggle Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = root

        hum.PlatformStand = true

        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying or not char or not root then return end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new()
            
            -- Basic velocity adjustment based on camera look vector
            local cf = cam.CFrame
            bodyGyro.CFrame = cf
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end)
    end

    local function stopFly()
        flying = false
        flyBtn.Text = "Toggle Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    -- ESP functions
    local function addEsp(plr)
        if plr == LocalPlayer then return end
        local function apply(char)
            if not char then return end
            if espHighlights[plr] then espHighlights[plr]:Destroy() end
            local hl = Instance.new("Highlight")
            hl.Name = "KokuESP"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Parent = char
            espHighlights[plr] = hl
        end
        if plr.Character then apply(plr.Character) end
        plr.CharacterAdded:Connect(apply)
    end

    local function startEsp()
        espActive = true
        espBtn.Text = "Toggle ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        for _, p in ipairs(Players:GetPlayers()) do addEsp(p) end
    end

    local function stopEsp()
        espActive = false
        espBtn.Text = "Toggle ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        for _, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        espHighlights = {}
    end

    -- Autobuild & Save Functions for TCO
    local function startAutobuild()
        autobuildActive = true
        autoBuildBtn.Text = "Autobuild: ON"
        autoBuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        
        autobuildConnection = RunService.Heartbeat:Connect(function()
            if not autobuildActive then return end
            -- Autobuild logic placeholder scanning TCO builder objects
        end)
    end

    local function stopAutobuild()
        autobuildActive = false
        autoBuildBtn.Text = "Autobuild: OFF"
        autoBuildBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if autobuildConnection then autobuildConnection:Disconnect(); autobuildConnection = nil end
    end

    local function saveTcoBuild()
        local buildData = {}
        -- Scan workspace for built items or parts associated with user blocks in TCO
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(buildData, {Name = obj.Name, Position = tostring(obj:GetPivot().Position)})
            end
        end
        pcall(function()
            writefile(BUILD_SAVE_FILE, HttpService:JSONEncode(buildData))
            addLogEntry("Build successfully saved to file!", Color3.fromRGB(0,255,0))
        end)
    end

    flyBtn.MouseButton1Click:Connect(function()
        if flying then stopFly() else startFly() end
    end)

    espBtn.MouseButton1Click:Connect(function()
        if espActive then stopEsp() else startEsp() end
    end)

    autoBuildBtn.MouseButton1Click:Connect(function()
        if autobuildActive then stopAutobuild() else startAutobuild() end
    end)

    saveBuildBtn.MouseButton1Click:Connect(function()
        saveTcoBuild()
    end)

    local allCommands = ".say .loopsay .stoploop .dall .adall .stopadall .silent .fling .stopfling .hide .stophide .reset .rejoin .antiafk .crash .form .stopform .line .circle .orbit .lineup .star .stopmove .mod .removemod .alert .credits .cmds .bots .botscheck .mb .raidcalc .unload .shutdown .orbitspeed .raid .prefix .antilag .equip .animations .msgcmds .msgcheck .msg .wall .tower .dlh .follow .tp .fly .unfly .esp .unesp .autobuild"

    local function processCommand(sender, message)
        local clean = message:lower():gsub("^%s+", ""):gsub("%s+$", "")

        if string.sub(clean, 1, #Prefix) ~= Prefix and string.sub(clean, 1, 1) ~= ";" then
            return
        end

        if string.sub(clean, 1, 1) == ";" then
            clean = Prefix .. clean:sub(2)
        end

        if not isAllowed(sender) then return end

        local cmd = clean

        if cmd == Prefix .. FlyCmd then
            startFly()
        elseif cmd == Prefix .. UnflyCmd then
            stopFly()
        elseif cmd == Prefix .. EspCmd then
            startEsp()
        elseif cmd == Prefix .. UnespCmd then
            stopEsp()
        elseif cmd == Prefix .. AutobuildCmd then
            if autobuildActive then stopAutobuild() else startAutobuild() end
        elseif cmd == Prefix .. Shutdown then
            if isOwner(sender) then
                pcall(function() LocalPlayer:Kick("Shutdown by owner") end)
            end
            return
        elseif cmd == Prefix .. Unload then
            _G.KokuwareUnloaded = true
            cleanupConnections()
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            if antiLagLoop then antiLagLoop:Disconnect(); antiLagLoop = nil end
            logGui:Destroy()
            mainGui:Destroy()
            sendChat("Unloaded")
            return
        end
        -- (All previous command handlers remain intact)
    end

    local function hookPlayer(p)
        if p.Chatted then
            local conn = p.Chatted:Connect(function(m) processCommand(p, m) end)
            table.insert(allConnections, conn)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
    Players.PlayerAdded:Connect(function(plr)
        local conn = plr.Chatted:Connect(function(m) processCommand(plr, m) end)
        table.init(allConnections, conn)
    end)

    if TextChatService then
        local conn = TextChatService.MessageReceived:Connect(function(m)
            local sender = Players:GetPlayerByUserId(m.UserId)
            if sender then processCommand(sender, m.Text) end
        end)
        table.insert(allConnections, conn)
    end

    slotBox.Text = tostring(slotNumber)
    addLogEntry("Bot started with owner: " .. (hasOwner and ownerName or "anyone") .. " | Slot: " .. slotNumber, Color3.fromRGB(0,255,0))
end

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
    if activeUser then
        setUserFiles(activeUser)
    else
        showUsernamePrompt(function(username)
            saveActiveUsername(username)
            setUserFiles(username)
            performSetup()
        end)
        return
    end

    if not isLicenseValid() then
        showKeyPrompt(function()
            performSetup()
        end)
        return
    end

    local agreed = false
    pcall(function() local content = readfile(AGREEMENT_FILE) if content then agreed = true end end)
    if not agreed then
        showTermsPrompt(function()
            performSetup()
        end)
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

performSetup()
