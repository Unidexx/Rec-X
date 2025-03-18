-- Roblox Top NavBar Recording Button (MacOS Only) - Works with OBS/External Recording Software
-- Adds a recording button + mic toggle to the CoreGui navigation bar

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- OS Detection (Only allow macOS)
local isMacOS = false
if UserInputService:GetPlatform() == Enum.Platform.OSX then
    isMacOS = true
else
    warn("This script only works on macOS!")
    return
end

-- Function to send recording commands to OBS WebSocket API
local function sendRecordingCommand(command)
    local url = "http://localhost:4455/obs/record?command=" .. command -- Adjust for OBS WebSocket API
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        print("Command Sent: " .. command)
    else
        warn("Failed to send command.")
    end
end

-- Create Recording Button in Top NavBar
StarterGui:SetCore("TopbarEnabled", true)

local RecordingButton = Instance.new("ImageButton")
RecordingButton.Parent = CoreGui
RecordingButton.Position = UDim2.new(0.85, 0, 0, 5)
RecordingButton.Size = UDim2.new(0, 40, 0, 40)
RecordingButton.Image = "rbxassetid://89021804444400" -- Green circle image (Replace with actual ID)
RecordingButton.BackgroundTransparency = 1
RecordingButton.Active = true

local MicButton = Instance.new("ImageButton")
MicButton.Parent = RecordingButton -- Now it's a child of RecordingButton
MicButton.Position = UDim2.new(1.1, 0, 0, 0)
MicButton.Size = UDim2.new(0, 40, 0, 40)
MicButton.Image = "rbxassetid://74487332033317" -- Microphone icon (Replace with actual ID)
MicButton.BackgroundTransparency = 1
MicButton.Active = true
MicButton.Visible = false -- Hidden until recording starts

-- Create Pop-up Message
local PopupFrame = Instance.new("Frame")
PopupFrame.Parent = CoreGui
PopupFrame.Size = UDim2.new(0, 300, 0, 100)
PopupFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
PopupFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PopupFrame.BackgroundTransparency = 0.2
PopupFrame.Visible = true
PopupFrame.Active = true
PopupFrame.BorderSizePixel = 0
PopupFrame.ZIndex = 10

local PopupText = Instance.new("TextLabel")
PopupText.Parent = PopupFrame
PopupText.Size = UDim2.new(1, -40, 1, 0)
PopupText.Position = UDim2.new(0, 20, 0, 0)
PopupText.Text = "Script by Den. You need OBS Studio to use this script. Thanks for using!"
PopupText.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText.BackgroundTransparency = 1
PopupText.TextScaled = true
PopupText.TextWrapped = true
PopupText.Font = Enum.Font.SourceSansBold
PopupText.ZIndex = 11

-- Create Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = PopupFrame
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextScaled = true
CloseButton.ZIndex = 12

CloseButton.MouseButton1Click:Connect(function()
    for i = 0.2, 1, 0.1 do
        PopupFrame.BackgroundTransparency = i
        PopupText.TextTransparency = i
        CloseButton.TextTransparency = i
        wait(0.07) -- Slightly longer fade-out for smooth effect
    end
    PopupFrame.Visible = false
end)

local isRecording = false
local isMicOn = true

-- Toggle Recording
RecordingButton.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        RecordingButton.Image = "rbxassetid://111579370672666" -- Red circle image
        MicButton.Visible = true
        sendRecordingCommand("start")
        if isMicOn then
            sendRecordingCommand("enable_mic") -- Enable both game and user audio
        else
            sendRecordingCommand("disable_mic") -- Only capture game audio
        end
    else
        RecordingButton.Image = "rbxassetid://89021804444400" -- Green circle image
        -- Hide all children when stopping recording
        for _, child in pairs(RecordingButton:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        sendRecordingCommand("stop")
        sendRecordingCommand("save_mp4") -- Save recording as an MP4 file on desktop
    end
end)

-- Toggle Microphone
MicButton.MouseButton1Click:Connect(function()
    isMicOn = not isMicOn
    if isMicOn then
        MicButton.Image = "rbxassetid://74487332033317" -- Normal mic icon
        sendRecordingCommand("enable_mic") -- Enable both game and user audio
    else
        MicButton.Image = "rbxassetid://119219199727898" -- Strikethrough mic icon
        sendRecordingCommand("disable_mic") -- Only capture game audio
    end
end)
