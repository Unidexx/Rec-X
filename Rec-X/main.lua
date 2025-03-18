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

-- Function to send recording commands to external software
local function sendRecordingCommand(command)
    local url = "http://localhost:5000/record?command=" .. command -- Change URL for your setup
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
RecordingButton.Image = "rbxassetid://123456" -- Green circle image (Replace with actual ID)
RecordingButton.BackgroundTransparency = 1
RecordingButton.Active = true

local MicButton = Instance.new("ImageButton")
MicButton.Parent = RecordingButton -- Now it's a child of RecordingButton
MicButton.Position = UDim2.new(1.1, 0, 0, 0)
MicButton.Size = UDim2.new(0, 40, 0, 40)
MicButton.Image = "rbxassetid://654321" -- Microphone icon (Replace with actual ID)
MicButton.BackgroundTransparency = 1
MicButton.Active = true
MicButton.Visible = false -- Hidden until recording starts

local isRecording = false
local isMicOn = true

-- Toggle Recording
RecordingButton.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        RecordingButton.Image = "rbxassetid://789012" -- Red circle image
        MicButton.Visible = true
        sendRecordingCommand("start")
    else
        RecordingButton.Image = "rbxassetid://123456" -- Green circle image
        -- Hide all children when stopping recording
        for _, child in pairs(RecordingButton:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        sendRecordingCommand("stop")
    end
end)

-- Toggle Microphone
MicButton.MouseButton1Click:Connect(function()
    isMicOn = not isMicOn
    if isMicOn then
        MicButton.Image = "rbxassetid://654321" -- Normal mic icon
        sendRecordingCommand("mic_on")
    else
        MicButton.Image = "rbxassetid://654322" -- Strikethrough mic icon
        sendRecordingCommand("mic_off")
    end
end)
