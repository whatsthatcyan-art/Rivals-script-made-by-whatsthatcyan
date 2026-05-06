local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Pro Hub | Mobile Optimized", HidePremium = true, SaveConfig = true, ConfigFolder = "ProHubConfig"})

-- Variables
local AimbotEnabled = false
local Aiming = false
local Smoothness = 0.25
local FOVRadius = 100
local InfiniteJump = false
local Noclip = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Helper Functions
local function GetNearestEnemy()
    local ClosestTarget = nil
    local MaxDistance = FOVRadius

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
            local Head = Player.Character.Head
            local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)

            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if Distance < MaxDistance then
                    MaxDistance = Distance
                    ClosestTarget = Player
                end
            end
        end
    end
    return ClosestTarget
end

-- Main Loops
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    if AimbotEnabled and Aiming then
        local Target = GetNearestEnemy()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local TargetPos = Target.Character.Head.Position
            local CurrentCF = Camera.CFrame
            local AimCF = CFrame.new(CurrentCF.Position, TargetPos)
            Camera.CFrame = CurrentCF:Lerp(AimCF, Smoothness)
        end
    end

    if Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

-- GUI
local MainTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MoveTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddToggle({
    Name = "Aimbot Master Toggle",
    Default = false,
    Callback = function(Value) AimbotEnabled = Value end
})

MainTab:AddToggle({
    Name = "Aimbot Lock (Mobile Toggle)",
    Default = false,
    Callback = function(Value) Aiming = Value end
})

MainTab:AddSlider({
    Name = "Smoothness",
    Min = 1, Max = 10, Default = 5, Color = Color3.fromRGB(255,255,255), Increment = 1,
    Callback = function(Value) Smoothness = 1 / Value end
})

MainTab:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(Value) FOVCircle.Visible = Value end
})

MainTab:AddSlider({
    Name = "FOV Size",
    Min = 10, Max = 500, Default = 100, Color = Color3.fromRGB(255,255,255), Increment = 1,
    Callback = function(Value) 
        FOVRadius = Value
        FOVCircle.Radius = Value 
    end
})

MoveTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value) InfiniteJump = Value end
})

MoveTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value) Noclip = Value end
})

OrionLib:Init()
