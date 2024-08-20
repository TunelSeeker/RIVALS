-- Credits To The Original Devs @xz, @goof
getgenv().Config = {
	Invite = "UeMEvsYyzd",
	Version = "0.1",
}

getgenv().luaguardvars = {
	DiscordName = "bomzaras#0",
}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Other/main/1"))()

library:init() -- Initalizes Library Do Not Delete This

local Window = library.NewWindow({
	title = "farts.pl  //  discord.gg/UeMEvsYyzd",
	size = UDim2.new(0, 525, 0, 650)
})

local tabs = {
    combat = Window:AddTab("combat"),
    visuals = Window:AddTab("visuals"),
    misc = Window:AddTab("misc"),
	Settings = library:CreateSettingsTab(Window),
}

-- 1 = Set Section Box To The Left
-- 2 = Set Section Box To The Right

local sections = {
	aimbot = tabs.combat:AddSection("aimbot", 1),
	--Section2 = tabs.Tab1:AddSection("Section2", 2),
}

-- aimbot

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Initialize default settings
local aimbotEnabled = true
local circleRadius = 100
local circleColor = Color3.new(1, 1, 1)
local targetPart = "Head"

-- Create the circle for the FOV
local circle = Drawing.new("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = circleColor
circle.NumSides = 30
circle.Radius = circleRadius
circle.Filled = false
circle.Visible = true

-- Function to get the closest player based on selected body part
local function getClosestPlayerPart()
    local target
    local distance = math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v == localPlayer or not v.Character then continue end
        
        local character = v.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoid.Health > 0 and humanoidRootPart then
            local teammateLabel = humanoidRootPart:FindFirstChild("TeammateLabel")
            
            if not teammateLabel then -- Only aim at players without the TeammateLabel
                if character:FindFirstChild(targetPart) then
                    local part = character[targetPart]
                    local partPos, onScreen = camera:WorldToScreenPoint(part.Position)

                    if onScreen then
                        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        local mouseDist = (Vector2.new(partPos.X, partPos.Y) - screenCenter).Magnitude

                        if mouseDist < distance and mouseDist <= circleRadius then
                            distance = mouseDist
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Function to aim at the selected part
local function aimAtTarget(target)
    if target then
        local targetPos = camera:WorldToScreenPoint(target.Position)
        mousemoverel((targetPos.X - mouse.X), (targetPos.Y - mouse.Y))
    end
end

-- Update the circle position and other dynamic changes every frame
runService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    circle.Radius = circleRadius
    circle.Color = circleColor
end)

-- Handle input events
uis.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimbotEnabled then
            while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) do
                local closestPart = getClosestPlayerPart()
                aimAtTarget(closestPart)
                runService.RenderStepped:Wait()
            end
        end
    end
end)

-- GUI Section Integration
sections.aimbot:AddToggle({
    enabled = aimbotEnabled,
    text = "aimbot",
    flag = "Toggle_Aimbot",
    tooltip = "",
    callback = function(enabled)
        aimbotEnabled = enabled
        print("Aimbot Enabled: " .. tostring(enabled))
    end
})

sections.aimbot:AddSlider({
    text = "radius", 
    flag = 'Slider_Radius', 
    value = circleRadius,
    min = 10, 
    max = 600,
    increment = 1,
    tooltip = "",
    callback = function(value) 
        circleRadius = value
        print("Circle Radius: " .. value)
    end
})

sections.aimbot:AddColor({
    enabled = true,
    text = "circle color",
    flag = "Color_Circle",
    color = circleColor,
    callback = function(color)
        circleColor = color
        print("Circle Color Updated")
    end
})

sections.aimbot:AddList({
    enabled = true,
    text = "target",
    flag = "List_TargetPart",
    value = targetPart,
    values = {
        "Head",
        "Torso",
        "LowerTorso",
        "UpperTorso",
        "LeftHand",
        "RightHand",
        "LeftFoot",
        "RightFoot"
    },
    callback = function(part)
        targetPart = part
        print("Target Body Part: " .. part)
    end
})
