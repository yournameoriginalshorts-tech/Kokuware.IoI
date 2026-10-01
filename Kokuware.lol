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

local localPlayer = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local noclipConnection = nil
local function startNoclip()
    noclipConnection = runService.Stepped:Connect(function()
        local character = localPlayer.Character
        if character then
            for _, child in ipairs(character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
            end
        end
    end)
end
startNoclip()

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

    task.spawn(function()
        task.wait(0.5)
        if messageToggles.loading then
            sendChat("Kokuware -Credits to Kokushibo and Echo-")
        end
    end)

    local function sendAlert(msg) for i = 1, 5 do sendChat(msg) task.wait(0.1) end end
    local function getTarget(text)
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

    local function unequipAllTools()
        local char = LocalPlayer.Character
        if not char then return end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                child.Parent = bp
            end
        end
    end

    local function crashSequence()
        if not hasArkenstone() then return end
        equipTool("The Arkenstone")
        sendChat("gear 261439002")
        equipTool("The Arkenstone")
        sendChat("freeze a")
        sendChat("blind o")
        sendChat("bring a")
        for i = 1, 7 do sendChat("clone a") end
        equipTool("Winters Greatsword")
        task.wait(0.2)
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Winters Greatsword")
        if tool then
            local rem = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildOfClass("RemoteFunction")
            if rem then rem:FireServer("Ability") else tool:Activate() end
        end
    end

    local function stopAllMovement()
        if followConnection then followConnection:Disconnect(); followConnection = nil end
        if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
        if lineupConnection then lineupConnection:Disconnect(); lineupConnection = nil end
        if formationConnection then formationConnection:Disconnect(); formationConnection = nil end
        formationActive = false
        if movementPlatform then
            movementPlatform:Destroy()
            movementPlatform = nil
        end
        if mapMovedUp then
            for part, cf in pairs(originalMapCFrames) do
                if part and part.Parent then
                    part.CFrame = cf
                end
            end
            originalMapCFrames = {}
            mapMovedUp = false
        end
        orbitActive = false
        enableAnimations()
    end

    local function moveMapUp()
        if mapMovedUp then return end
        originalMapCFrames = {}
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Anchored and not desc:IsDescendantOf(LocalPlayer.Character or nil) and not desc:IsDescendantOf(movementPlatform or nil) then
                originalMapCFrames[desc] = desc.CFrame
                desc.CFrame = desc.CFrame + Vector3.new(0, 10000, 0)
            end
        end
        mapMovedUp = true
    end

    local function restoreMap()
        if not mapMovedUp then return end
        for part, cf in pairs(originalMapCFrames) do
            if part and part.Parent then
                part.CFrame = cf
            end
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
            local next = i % #points + 1
            local d = (points[next] - points[i]).Magnitude
            distances[i] = d
            perimeter = perimeter + d
        end
        local targetDist = (slot - 1) / total * perimeter
        local acc = 0
        local pos
        for i = 1, #points do
            if targetDist <= acc + distances[i] then
                local t = (targetDist - acc) / distances[i]
                local next = i % #points + 1
                local localPos = points[i]:Lerp(points[next], t)
                pos = leaderRoot.CFrame * localPos
                break
            end
            acc = acc + distances[i]
        end
        return pos
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
        if inplace then
            createPlatform()
            return
        end
        formationActive = true
        formationFollow = follow

        if follow then
            createPlatform()
        end

        local function doTeleport()
            local myChar = LocalPlayer.Character
            local targetChar = target.Character
            if myChar and targetChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if myRoot and targetRoot then
                    local pos, orientCFrame
                    if formationType == "line" then
                        local look = targetRoot.CFrame.LookVector
                        local right = targetRoot.CFrame.RightVector
                        local offset = (slotNumber - (totalBots + 1)/2) * LINE_SPACING
                        local behindOffset = 3
                        pos = targetRoot.Position - look * behindOffset + right * offset
                        orientCFrame = CFrame.lookAt(pos, pos + look)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "lineup" then
                        local look = targetRoot.CFrame.LookVector
                        pos = targetRoot.Position - look * (slotNumber * LINEUP_SPACING)
                        orientCFrame = CFrame.lookAt(pos, pos + look)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "circle" then
                        pos = getCirclePosition(targetRoot, slotNumber, totalBots, ORBIT_DISTANCE)
                        orientCFrame = CFrame.lookAt(pos, targetRoot.Position)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "star" then
                        pos = getStarPosition(targetRoot, slotNumber, totalBots, STAR_SIZE)
                        orientCFrame = CFrame.lookAt(pos, targetRoot.Position)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "wall" then
                        local look = targetRoot.CFrame.LookVector
                        local right = targetRoot.CFrame.RightVector
                        local cols = math.ceil(math.sqrt(totalBots))
                        local rows = math.ceil(totalBots / cols)
                        local col = ((slotNumber - 1) % cols) - (cols - 1) / 2
                        local row = math.floor((slotNumber - 1) / cols) - (rows - 1) / 2
                        pos = targetRoot.Position + look * 10 + right * (col * 4) + Vector3.new(0, row * 4, 0)
                        orientCFrame = CFrame.lookAt(pos, pos + look)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "tower" then
                        local look = targetRoot.CFrame.LookVector
                        local right = targetRoot.CFrame.RightVector
                        local base = math.floor(math.sqrt(totalBots))
                        local level = math.floor((slotNumber - 1) / base)
                        local index = (slotNumber - 1) % base
                        local col = index - (base - 1) / 2
                        local row = level
                        pos = targetRoot.Position - look * 5 + right * (col * 3) + Vector3.new(0, row * 4, 0)
                        orientCFrame = CFrame.lookAt(pos, pos + look)
                        myRoot.CFrame = orientCFrame
                    elseif formationType == "dlh" then
                        local look = targetRoot.CFrame.LookVector
                        local right = targetRoot.CFrame.RightVector
                        local stem = math.floor(totalBots / 2)
                        local horizontal = totalBots - stem
                        if slotNumber <= stem then
                            pos = targetRoot.Position - look * (5 + (slotNumber - 1) * 3) + Vector3.new(0, 0, 0)
                        else
                            local idx = slotNumber - stem
                            pos = targetRoot.Position - look * 5 + right * ((idx - (horizontal - 1)/2) * 3) + Vector3.new(0, 0, 0)
                        end
                        orientCFrame = CFrame.lookAt(pos, pos + look)
                        myRoot.CFrame = orientCFrame
                    end
                    if pos and orientCFrame then
                        disableAnimations()
                    end
                    if movementPlatform then
                        movementPlatform.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 3, 0))
                    end
                end
            end
        end

        if follow then
            formationConnection = RunService.Heartbeat:Connect(function()
                doTeleport()
            end)
            table.insert(allConnections, formationConnection)
        else
            doTeleport()
        end
    end

    local function startOrbit(target, inplace)
        stopAllMovement()
        if inplace then
            createPlatform()
            return
        end
        orbitActive = true
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
                    local orientCFrame = CFrame.lookAt(newPos, targetRoot.Position)
                    myRoot.CFrame = orientCFrame
                    disableAnimations()
                    if movementPlatform then
                        movementPlatform.CFrame = CFrame.new(myRoot.Position - Vector3.new(0, 3, 0))
                    end
                end
            end
        end)
        table.insert(allConnections, orbitConnection)
    end

    task.spawn(function()
        while true do
            if loopActive and loopMsg ~= "" then sendChat(loopMsg) end
            task.wait(0.6)
        end
    end)

    task.spawn(function()
        while true do
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

    task.spawn(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(10000, 10000, 10000)
        RunService.Heartbeat:Connect(function()
            if flinging and flingTarget ~= "" then
                local myChar = LocalPlayer.Character
                local target = Players:FindFirstChild(flingTarget)
                if myChar and target and target.Character then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso")
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
                    local hum = myChar:FindFirstChildOfClass("Humanoid")
                    if myRoot and targetRoot and hum then
                        if hum.Sit then hum.Sit = false end
                        bv.Parent = myRoot
                        myRoot.CFrame = targetRoot.CFrame
                        for _, p in ipairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    end
                end
            else
                if bv.Parent then
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = nil
                end
            end
        end)
        table.insert(allConnections, RunService.Heartbeat:Connect(function() end))
    end)

    RunService.Heartbeat:Connect(function()
        if hiding then
            local char = LocalPlayer.Character
            if char then char:PivotTo(CFrame.new(hidePos + Vector3.new(0, 3, 0))) end
        end
    end)

    local animOverrideActive = false
    local animOverrideLoop = nil

    local function setAnimationOverride(state)
        animOverrideActive = state
        if state then
            if not animOverrideLoop then
                animOverrideLoop = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local anim = hum:FindFirstChildOfClass("Animator")
                                if anim then
                                    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                                        track:AdjustSpeed(0)
                                    end
                                    anim.Parent = nil
                                end
                            end
                        end
                    end)
                end)
            end
        else
            if animOverrideLoop then
                animOverrideLoop:Disconnect()
                animOverrideLoop = nil
            end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local orphan = char:FindFirstChildOfClass("Animator") or game:FindFirstChildOfClass("Animator")
                        if orphan then
                            orphan.Parent = hum
                            for _, track in ipairs(orphan:GetPlayingAnimationTracks()) do
                                track:AdjustSpeed(1)
                            end
                        end
                    end
                end
            end)
        end
    end

    local allCommands = ".say .loopsay .stoploop .dall .adall .stopadall .silent .fling .stopfling .hide .stophide .reset .rejoin .antiafk .crash .form .stopform .line .circle .orbit .lineup .star .stopmove .mod .removemod .alert .credits .cmds .bots .botscheck .mb .raidcalc .unload .shutdown .orbitspeed .raid .prefix .antilag .equip .animations .msgcmds .msgcheck .msg .wall .tower .dlh .follow .tp"

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

        if cmd == Prefix .. Shutdown then
            if isOwner(sender) then
                pcall(function() LocalPlayer:Kick("Shutdown by owner") end)
            end
            return
        end

        if cmd == Prefix .. Unload then
            _G.KokuwareUnloaded = true
            cleanupConnections()
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            if antiLagLoop then antiLagLoop:Disconnect(); antiLagLoop = nil end
            logGui:Destroy()
            sendChat("Unloaded")
            return
        end

        if cmd == Prefix .. AntiLag .. " off" then
            disableAntiLag()
            if messageToggles.antilag then sendChat("Anti-lag off") end
        elseif cmd == Prefix .. AntiLag then
            applyAntiLag()
            if messageToggles.antilag then sendChat("Anti-lag on") end
        elseif cmd == Prefix .. AntiAfk then
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ANTI-AFK-by-gun-265109"))()
            if messageToggles.antiafk then sendChat("Anti-afk on") end
        elseif cmd == Prefix .. AntiAfk .. " off" then
            sendChat("Anti AFK off not supported")
        elseif cmd == Prefix .. Crash then crashSequence()
        elseif cmd == Prefix .. Silent then silentMode = not silentMode
        elseif cmd == Prefix .. Rejoin then
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        elseif cmd == Prefix .. Reset then
            loopActive = false; loopMsg = ""; adallActive = false
            flinging = false; flingTarget = ""
            stopAllMovement()
            restoreMap()
            if hiding then hiding = false; if hidePart then hidePart:Destroy(); hidePart = nil end end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local brick = Instance.new("Part")
                    brick.Size = Vector3.new(5,5,5)
                    brick.Position = char:GetPivot().Position + Vector3.new(0,3,0)
                    brick.Anchored = true
                    brick.Parent = workspace
                    brick.Touched:Connect(function(hit)
                        if hit.Parent == char then
                            hum.Health = 0
                        end
                    end)
                    task.delay(3, function()
                        if hum and hum.Parent then
                            hum.Health = 0
                        end
                    end)
                    hum.Died:Wait()
                    brick:Destroy()
                end
            end
        elseif cmd == Prefix .. Hide then
            if not hiding then
                local char = LocalPlayer.Character
                if char then returnPos = char:GetPivot(); char:PivotTo(CFrame.new(hidePos + Vector3.new(0, 3, 0))) end
                hidePart = Instance.new("Part")
                hidePart.Size = Vector3.new(20, 1, 20)
                hidePart.Position = hidePos
                hidePart.Anchored = true
                hidePart.Parent = workspace
                hiding = true
            end
        elseif cmd == Prefix .. StopHide then
            if hiding then
                hiding = false
                if hidePart then hidePart:Destroy(); hidePart = nil end
                local char = LocalPlayer.Character
                if char and returnPos then char:PivotTo(returnPos) end
            end
        elseif cmd == Prefix .. StopFling then
            flinging = false
            flingTarget = ""
            local bv = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("BodyVelocity")
            if bv then bv.Velocity = Vector3.new(0,0,0); bv:Destroy() end
        elseif cmd == Prefix .. StopForm or cmd == Prefix .. StopMove then
            stopAllMovement()
            restoreMap()
        elseif string.sub(clean, 1, #Prefix + #Form + 1) == Prefix .. Form .. " " then
            local startPos = string.find(message, Form .. " ")
            local argsText = string.sub(message, startPos + #Form + 1)
            local args = {}
            for arg in argsText:gmatch("%S+") do table.insert(args, arg) end
            if #args >= 1 then
                local formType = args[1]:lower()
                local follow = false
                local inplace = false
                local tgtText = nil
                for i = 2, #args do
                    local lower = args[i]:lower()
                    if lower == "follow" then
                        follow = true
                    elseif lower == Inplace then
                        inplace = true
                    else
                        tgtText = args[i]
                    end
                end
                local tgt = getTarget(tgtText or sender.Name)
                if tgt then
                    if formType == "line" or formType == "circle" or formType == "lineup" or formType == "star" or formType == "wall" or formType == "tower" or formType == "dlh" then
                        startFormation(tgt, formType, follow, inplace)
                        if messageToggles.formation then
                            sendChat("formation:" .. formType .. " (" .. (tgtText or tgt.Name) .. ")")
                        end
                    end
                end
            end
        elseif cmd == Prefix .. Form then
            startFormation(sender, "line", false, false)
        elseif string.sub(clean, 1, #Prefix + #Wall + 1) == Prefix .. Wall .. " " then
            local argsText = string.sub(message, string.find(message, Wall .. " ") + #Wall + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local inplace = string.find(argsText:lower(), Inplace) ~= nil
            argsText = argsText:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(argsText or sender.Name)
            if tgt then
                startFormation(tgt, "wall", false, inplace)
                if messageToggles.formation then sendChat("formation:wall (" .. (argsText or tgt.Name) .. ")") end
            end
        elseif cmd == Prefix .. Wall then
            startFormation(sender, "wall", false, false)
            if messageToggles.formation then sendChat("formation:wall (" .. sender.Name .. ")") end
        elseif string.sub(clean, 1, #Prefix + #Tower + 1) == Prefix .. Tower .. " " then
            local argsText = string.sub(message, string.find(message, Tower .. " ") + #Tower + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local inplace = string.find(argsText:lower(), Inplace) ~= nil
            argsText = argsText:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(argsText or sender.Name)
            if tgt then
                startFormation(tgt, "tower", false, inplace)
                if messageToggles.formation then sendChat("formation:tower (" .. (argsText or tgt.Name) .. ")") end
            end
        elseif cmd == Prefix .. Tower then
            startFormation(sender, "tower", false, false)
            if messageToggles.formation then sendChat("formation:tower (" .. sender.Name .. ")") end
        elseif string.sub(clean, 1, #Prefix + #Dlh + 1) == Prefix .. Dlh .. " " then
            local argsText = string.sub(message, string.find(message, Dlh .. " ") + #Dlh + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local inplace = string.find(argsText:lower(), Inplace) ~= nil
            argsText = argsText:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(argsText or sender.Name)
            if tgt then
                startFormation(tgt, "dlh", false, inplace)
                if messageToggles.formation then sendChat("formation:dlh (" .. (argsText or tgt.Name) .. ")") end
            end
        elseif cmd == Prefix .. Dlh then
            startFormation(sender, "dlh", false, false)
            if messageToggles.formation then sendChat("formation:dlh (" .. sender.Name .. ")") end
        elseif string.sub(clean, 1, #Prefix + #Line + 1) == Prefix .. Line .. " " then
            local startPos = string.find(message, Line .. " ")
            local tgtText = string.sub(message, startPos + #Line + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local follow = string.find(tgtText, "follow") ~= nil
            local inplace = string.find(tgtText:lower(), Inplace) ~= nil
            tgtText = tgtText:gsub("follow", ""):gsub(Inplace, ""):gsub("%s+$", ""):gsub("^%s+", "")
            local tgt = getTarget(tgtText or sender.Name)
            if tgt then startFormation(tgt, "line", follow, inplace) end
        elseif cmd == Prefix .. Line then startFormation(sender, "line", false, false)
        elseif string.sub(clean, 1, #Prefix + #Circle + 1) == Prefix .. Circle .. " " then
            local startPos = string.find(message, Circle .. " ")
            local tgtText = string.sub(message, startPos + #Circle + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local follow = string.find(tgtText, "follow") ~= nil
            local inplace = string.find(tgtText:lower(), Inplace) ~= nil
            tgtText = tgtText:gsub("follow", ""):gsub(Inplace, ""):gsub("%s+$", ""):gsub("^%s+", "")
            local tgt = getTarget(tgtText or sender.Name)
            if tgt then startFormation(tgt, "circle", follow, inplace) end
        elseif cmd == Prefix .. Circle then startFormation(sender, "circle", false, false)
        elseif string.sub(clean, 1, #Prefix + #Orbit + 1) == Prefix .. Orbit .. " " then
            local startPos = string.find(message, Orbit .. " ")
            local tgtText = string.sub(message, startPos + #Orbit + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local inplace = string.find(tgtText:lower(), Inplace) ~= nil
            tgtText = tgtText:gsub(Inplace, ""):gsub("%s+$", ""):gsub("^%s+", "")
            local tgt = getTarget(tgtText or sender.Name)
            if tgt then startOrbit(tgt, inplace) end
        elseif cmd == Prefix .. Orbit then startOrbit(sender, false)
        elseif string.sub(clean, 1, #Prefix + #Lineup + 1) == Prefix .. Lineup .. " " then
            local startPos = string.find(message, Lineup .. " ")
            local tgtText = string.sub(message, startPos + #Lineup + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local follow = string.find(tgtText, "follow") ~= nil
            local inplace = string.find(tgtText:lower(), Inplace) ~= nil
            tgtText = tgtText:gsub("follow", ""):gsub(Inplace, ""):gsub("%s+$", ""):gsub("^%s+", "")
            local tgt = getTarget(tgtText or sender.Name)
            if tgt then startFormation(tgt, "lineup", follow, inplace) end
        elseif cmd == Prefix .. Lineup then startFormation(sender, "lineup", false, false)
        elseif string.sub(clean, 1, #Prefix + #Star + 1) == Prefix .. Star .. " " then
            local startPos = string.find(message, Star .. " ")
            local tgtText = string.sub(message, startPos + #Star + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local follow = string.find(tgtText, "follow") ~= nil
            local inplace = string.find(tgtText:lower(), Inplace) ~= nil
            tgtText = tgtText:gsub("follow", ""):gsub(Inplace, ""):gsub("%s+$", ""):gsub("^%s+", "")
            local tgt = getTarget(tgtText or sender.Name)
            if tgt then startFormation(tgt, "star", follow, inplace) end
        elseif cmd == Prefix .. Star then startFormation(sender, "star", false, false)
        elseif string.sub(clean, 1, #Prefix + #Dall + 1) == Prefix .. Dall .. " " then
            local startPos = string.find(message, Dall .. " ")
            local targetText = string.sub(message, startPos + #Dall + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local target = getTarget(targetText or sender.Name)
            local t = getOwnTime()
            if t and t.Value > 1 then
                sendChat(";donate " .. fixUsername(target.Name) .. " " .. (t.Value - 1))
            end
        elseif cmd == Prefix .. Dall then
            local t = getOwnTime()
            if t and t.Value > 1 then
                sendChat(";donate " .. fixUsername(sender.Name) .. " " .. (t.Value - 1))
            end
        elseif string.sub(clean, 1, #Prefix + #Adall + 1) == Prefix .. Adall .. " " then
            local startPos = string.find(message, Adall .. " ")
            local argsText = string.sub(message, startPos + #Adall + 1)
            local args = {}
            for arg in argsText:gmatch("%S+") do table.insert(args, arg) end
            local interval = 1
            local target = sender
            if #args >= 1 then
                if tonumber(args[1]) then
                    interval = tonumber(args[1])
                    if #args >= 2 then
                        target = getTarget(args[2]) or sender
                    end
                else
                    target = getTarget(args[1]) or sender
                    if #args >= 2 and tonumber(args[2]) then
                        interval = tonumber(args[2])
                    end
                end
            end
            adallInterval = interval
            adallTarget = fixUsername(target.Name)
            adallActive = true
        elseif cmd == Prefix .. Adall then
            adallInterval = 1
            adallTarget = fixUsername(sender.Name)
            adallActive = true
        elseif cmd == Prefix .. StopAdall then adallActive = false
        elseif cmd == Prefix .. BotsCheck then
            sendChat(autoMatchMsg)
        elseif string.sub(clean, 1, #Prefix + #MB + 1) == Prefix .. MB .. " " then
            local startPos = string.find(message, MB .. " ")
            local msg = string.sub(message, startPos + #MB + 1):gsub("^%s+", ""):gsub("%s+$", "")
            if msg ~= "" then
                autoMatchMsg = msg
                sendChat("Auto-match message set to: " .. msg)
            end
        elseif cmd == Prefix .. MB then
            autoMatchMsg = "°"
            sendChat("Auto-match message reset to °")
        elseif cmd == Prefix .. RaidCalc then
            local t = getOwnTime()
            local current = t and t.Value or 0
            local target = 1000
            local rate = totalBots + 1
            local needed = math.max(0, target - current)
            local seconds = math.ceil(needed / rate)
            local mins = math.floor(seconds / 60)
            local secs = seconds % 60
            sendChat("RaidCalc: " .. mins .. " minutes and " .. secs .. " seconds to reach " .. target .. " time with " .. totalBots + 1 .. " total players.")
        elseif string.sub(clean, 1, #Prefix + #Fling + 1) == Prefix .. Fling .. " " then
            local startPos = string.find(message, Fling .. " ")
            local targetText = string.sub(message, startPos + #Fling + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local target = getTarget(targetText or sender.Name)
            if target then flingTarget = target.Name; flinging = true end
        elseif cmd == Prefix .. Fling then flingTarget = sender.Name; flinging = true
        elseif string.sub(clean, 1, #Prefix + #Mod + 1) == Prefix .. Mod .. " " then
            local startPos = string.find(message, Mod .. " ")
            local targetText = string.sub(message, startPos + #Mod + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local target = getTarget(targetText or sender.Name)
            if target then ModUsers[string.lower(target.DisplayName)] = true end
        elseif cmd == Prefix .. Mod then ModUsers[string.lower(sender.DisplayName)] = true
        elseif string.sub(clean, 1, #Prefix + #RemoveMod + 1) == Prefix .. RemoveMod .. " " then
            local startPos = string.find(message, RemoveMod .. " ")
            local targetText = string.sub(message, startPos + #RemoveMod + 1):gsub("^%s+", ""):gsub("%s+$", "")
            if targetText:lower() == "a" then
                ModUsers = {}
                sendChat("All mods removed")
            else
                local target = getTarget(targetText or sender.Name)
                if target then
                    local key = string.lower(target.DisplayName)
                    if ModUsers[key] then ModUsers[key] = nil; sendChat("Removed mod " .. target.DisplayName) else sendChat(target.DisplayName .. " is not a mod") end
                end
            end
        elseif cmd == Prefix .. RemoveMod then
            ModUsers[string.lower(sender.DisplayName)] = nil
        elseif string.sub(clean, 1, #Prefix + #Bots + 1) == Prefix .. Bots .. " " then
            local startPos = string.find(message, Bots .. " ")
            local num = tonumber(string.sub(message, startPos + #Bots + 1))
            if num and num > 0 then
                totalBots = num
            end
        elseif string.sub(clean, 1, #Prefix + #Say + 1) == Prefix .. Say .. " " then
            local startPos = string.find(message, Say .. " ")
            local text = string.sub(message, startPos + #Say + 1)
            if text ~= "" then sendChat(text) end
        elseif string.sub(clean, 1, #Prefix + #Loop + 1) == Prefix .. Loop .. " " then
            local startPos = string.find(message, Loop .. " ")
            local text = string.sub(message, startPos + #Loop + 1)
            if text ~= "" then loopMsg = text; loopActive = true end
        elseif cmd == Prefix .. StopLoop then loopActive = false; loopMsg = ""; adallActive = false
        elseif string.sub(clean, 1, #Prefix + #Alert + 1) == Prefix .. Alert .. " " then
            local startPos = string.find(message, Alert .. " ")
            local text = string.sub(message, startPos + #Alert + 1)
            if text ~= "" then sendAlert(text) end
        elseif cmd == Prefix .. Alert then sendAlert("Alert! " .. sender.DisplayName .. " requests your attention!")
        elseif cmd == Prefix .. Credits then
            local creditLines = {
                "Kokuware - Credits to Kokushibo and Echo -",
                "thanks echo :) #echo is tuff",
                "Script features powered by Echo's framework structure.",
                "Original system design & formatting credited to Echo.",
                "Enjoy using Kokuware & Echoware!"
            }
            for _, line in ipairs(creditLines) do
                sendChat(line)
                task.wait(0.3)
            end
        elseif cmd == Prefix .. Cmds then
            local cmds = allCommands:split(" ")
            local half = math.ceil(#cmds / 2)
            sendChat(table.concat(cmds, " ", 1, half))
            task.wait(0.5)
            sendChat(table.concat(cmds, " ", half+1, #cmds))
        elseif string.sub(clean, 1, #Prefix + #OrbitSpeed + 1) == Prefix .. OrbitSpeed .. " " then
            local startPos = string.find(message, OrbitSpeed .. " ")
            local num = tonumber(string.sub(message, startPos + #OrbitSpeed + 1))
            if num and num > 0 then
                orbitSpeed = num
                if messageToggles.orbitspeed then sendChat("orbitspeed set to (" .. num .. ")") end
            end
        elseif cmd == Prefix .. OrbitSpeed then
            if messageToggles.orbitspeed then sendChat("orbitspeed set to (" .. orbitSpeed .. ")") end
        elseif cmd == Prefix .. Raid then
            if isOwner(sender) then
                pcall(function()
                    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ANTI-AFK-by-gun-265109"))()
                end)
                adallTarget = fixUsername(sender.Name)
                adallInterval = 20
                adallActive = true
            end
        elseif string.sub(clean, 1, #Prefix + #PrefixCmd + 1) == Prefix .. PrefixCmd .. " " then
            local startPos = string.find(message, PrefixCmd .. " ")
            local newPrefix = string.sub(message, startPos + #PrefixCmd + 1)
            if newPrefix and newPrefix ~= "" then
                newPrefix = newPrefix:match("^%s*(.-)%s*$")
                if #newPrefix > 0 then
                    Prefix = newPrefix
                end
            end
        elseif cmd == Prefix .. MsgCmds then
            sendChat("Usage: .msg <type> on/off | Types: loading, orbitspeed, formation, antiafk, antilag")
        elseif cmd == Prefix .. MsgCheck then
            local msgs = {
                "loading | " .. (messageToggles.loading and "on" or "off"),
                "orbitspeed | " .. (messageToggles.orbitspeed and "on" or "off"),
                "formation | " .. (messageToggles.formation and "on" or "off"),
                "antilag | " .. (messageToggles.antilag and "on" or "off"),
                "antiafk | " .. (messageToggles.antiafk and "on" or "off")
            }
            for _, m in ipairs(msgs) do
                sendChat(m)
                task.wait(0.2)
            end
        elseif string.sub(clean, 1, #Prefix + #Msg + 1) == Prefix .. Msg .. " " then
            local startPos = string.find(message, Msg .. " ")
            local argsText = string.sub(message, startPos + #Msg + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local args = {}
            for arg in argsText:gmatch("%S+") do table.insert(args, arg:lower()) end
            if #args >= 2 then
                local msgType = args[1]
                local state = args[2]
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
        elseif string.sub(clean, 1, #Prefix + #Follow + 1) == Prefix .. Follow .. " " then
            local argsText = string.sub(message, string.find(message, Follow .. " ") + #Follow + 1):gsub("^%s+", ""):gsub("%s+$", "")
            local inplace = string.find(argsText:lower(), Inplace) ~= nil
            argsText = argsText:gsub(Inplace, ""):gsub("^%s+", ""):gsub("%s+$", "")
            local tgt = getTarget(argsText or sender.Name)
            if tgt then
                stopAllMovement()
                if inplace then createPlatform() return end
                followConnection = RunService.Heartbeat:Connect(function()
                    local myChar = LocalPlayer.Character
                    local targetChar = tgt.Character
                    if myChar and targetChar then
                        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if myRoot and targetRoot then
                            local look = targetRoot.CFrame.LookVector
                            local right = targetRoot.CFrame.RightVector
                            local randomAngle = math.random(-15, 15)
                            local offset = (CFrame.lookAt(Vector3.new(0,0,0), look) * CFrame.Angles(0, math.rad(randomAngle), 0)).LookVector
                            local randomDist = math.random(4, 7)
                            local pos = targetRoot.Position - offset * randomDist + Vector3.new(0, 0, 0)
                            myRoot.CFrame = CFrame.lookAt(pos, targetRoot.Position)
                            disableAnimations()
                        end
                    end
                end)
                table.insert(allConnections, followConnection)
            end
        elseif cmd == Prefix .. Follow then
            stopAllMovement()
        elseif string.sub(clean, 1, #Prefix + #Tp + 1) == Prefix .. Tp .. " " then
            if isOwner(sender) or ModUsers[string.lower(sender.DisplayName)] then
                local tgtText = string.sub(message, string.find(message, Tp .. " ") + #Tp + 1):gsub("^%s+", ""):gsub("%s+$", "")
                local tgt = getTarget(tgtText or sender.Name)
                if tgt then
                    local myChar = LocalPlayer.Character
                    local targetChar = tgt.Character
                    if myChar and targetChar then
                        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if myRoot and targetRoot then
                            myRoot.CFrame = targetRoot.CFrame
                        end
                    end
                end
            end
        elseif cmd == Prefix .. Tp then
            if isOwner(sender) or ModUsers[string.lower(sender.DisplayName)] then
                local myChar = LocalPlayer.Character
                local targetChar = sender.Character
                if myChar and targetChar then
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        myRoot.CFrame = targetRoot.CFrame
                    end
                end
            end
        elseif cmd == Prefix .. Equip then
            sendChat("Usage: .equip <item>")
        elseif cmd == Prefix .. Animations then
            setAnimationOverride(not animOverrideActive)
        end
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
        table.insert(allConnections, conn)
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


