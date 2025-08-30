local key = "VWweaCuMUFavHVIVHrtOYAEsSUEDsORF"
if key ~= "VWweaCuMUFavHVIVHrtOYAEsSUEDsORF" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createGui()
    if playerGui:FindFirstChild("ToolsGui") then
        playerGui.ToolsGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ToolsGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 215)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    title.Text = "SVO TOOLS"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame

    local function createButton(text, posY, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 40)
        btn.Position = UDim2.new(0, 15, 0, posY)
        btn.BackgroundColor3 = color or Color3.fromRGB(70,70,70)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = text
        btn.Parent = frame
        return btn
    end

    return frame, createButton
end

local frame, createButton = createGui()

local flyBtn = createButton("FLOAT OFF", 60, Color3.fromRGB(50,150,50))
local deleteFirstBtn = createButton("Delete the 2nd floor", 110, Color3.fromRGB(150,50,50))
local deleteSizeBtn = createButton("Delete the 3rd floor", 160, Color3.fromRGB(200,50,50))

local OFFSET_Y = 3
local TARGET_HEIGHT = 10.5
local PLATFORM_SIZE = Vector3.new(6,1,6)
local SPEED = 20
local MAX_FALL_OFFSET = 5

local platform
local enabled = false
local targetY = nil

local function createPlatform(root)
    if platform and platform.Parent then
        platform:Destroy()
    end
    platform = Instance.new("Part")
    platform.Name = "ClientFloatPlatform"
    platform.Size = PLATFORM_SIZE
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.TopSurface = Enum.SurfaceType.Smooth
    platform.BottomSurface = Enum.SurfaceType.Smooth
    platform.Parent = workspace
    platform.Position = root.Position - Vector3.new(0, OFFSET_Y, 0)
    targetY = platform.Position.Y + TARGET_HEIGHT
end

local function toggleFloat()
    enabled = not enabled
    local char = player.Character
    if enabled and char then
        flyBtn.Text = "FLOAT ON"
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            createPlatform(root)
        end
    else
        flyBtn.Text = "FLOAT OFF"
        if platform and platform.Parent then
            platform:Destroy()
            platform = nil
            targetY = nil
        end
    end
end

flyBtn.MouseButton1Click:Connect(toggleFloat)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFloat()
    end
end)

local function sizeEquals(a, b, eps)
    eps = eps or 0.1
    return math.abs(a.X - b.X) <= eps and math.abs(a.Y - b.Y) <= eps and math.abs(a.Z - b.Z) <= eps
end

local function isAllowedPosition(pos, allowedList)
    for _, allowed in ipairs(allowedList) do
        if (pos - allowed).Magnitude < 0.5 then
            return true
        end
    end
    return false
end

local allowedPositionsFirst = {
    Vector3.new(-503.75174, 8.89893341, -100.392876),
    Vector3.new(-315.440033, 8.89893627, -100.39312),
    Vector3.new(-315.440002, 8.89893436, 6.60688019),
    Vector3.new(-315.440002, 8.89893436, 113.60688),
    Vector3.new(-315.440277, 8.89879608, 220.606873),
    Vector3.new(-503.75174, 8.89893341, 6.60712433),
    Vector3.new(-503.75174, 8.89893341, 113.607124),
    Vector3.new(-503.75174, 8.89893341, 220.607117)
}

local allowedPositionsSize = {
    Vector3.new(-315.440308, 25.8987846, 206.606873),
    Vector3.new(-503.751709, 25.898922, 234.607117),
    Vector3.new(-503.751709, 25.898922, 127.607124),
    Vector3.new(-315.440033, 25.898922, 99.6068802),
    Vector3.new(-315.440033, 25.898922, -114.39312),
    Vector3.new(-503.751709, 25.898922, 20.6071243),
    Vector3.new(-503.751709, 25.898922, -86.3928757),
    Vector3.new(-315.440033, 25.898922, -7.39311981)
}

local removedFirstParts = {}
local removedSizeParts = {}
local toggleFirst = false
local toggleSize = false

deleteFirstBtn.MouseButton1Click:Connect(function()
    toggleFirst = not toggleFirst
    if toggleFirst then
        removedFirstParts = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and sizeEquals(obj.Size, Vector3.new(45,45,2))
               and isAllowedPosition(obj.Position, allowedPositionsFirst) then
                table.insert(removedFirstParts, {Size=obj.Size, CFrame=obj.CFrame})
                obj:Destroy()
            end
        end
        deleteFirstBtn.Text = "Delete the 2nd floor ON"
    else
        for _, data in ipairs(removedFirstParts) do
            local part = Instance.new("Part")
            part.Size = data.Size
            part.CFrame = data.CFrame
            part.Anchored = true
            part.CanCollide = true
            part.Material = Enum.Material.SmoothPlastic
            part.BrickColor = BrickColor.new("Dark stone grey")
            part:SetAttribute("Restored", true)
            part.Parent = workspace
        end
        removedFirstParts = {}
        deleteFirstBtn.Text = "Delete the 2nd floor OFF"
    end
end)

deleteSizeBtn.MouseButton1Click:Connect(function()
    toggleSize = not toggleSize
    if toggleSize then
        removedSizeParts = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and sizeEquals(obj.Size, Vector3.new(45,17,2))
               and isAllowedPosition(obj.Position, allowedPositionsSize) then
                table.insert(removedSizeParts, {Size=obj.Size, CFrame=obj.CFrame})
                obj:Destroy()
            end
        end
        deleteSizeBtn.Text = "Delete the 3rd floor ON"
    else
        for _, data in ipairs(removedSizeParts) do
            local part = Instance.new("Part")
            part.Size = data.Size
            part.CFrame = data.CFrame
            part.Anchored = true
            part.CanCollide = true
            part.Material = Enum.Material.SmoothPlastic
            part.BrickColor = BrickColor.new("Dark stone grey")
            part:SetAttribute("Restored", true)
            part.Parent = workspace
        end
        removedSizeParts = {}
        deleteSizeBtn.Text = "Delete the 3rd floor OFF"
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not enabled or not platform or not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if root.Position.Y - platform.Position.Y < -MAX_FALL_OFFSET then
        platform.Position = root.Position - Vector3.new(0, OFFSET_Y, 0)
    end

    if targetY then
        local currentY = platform.Position.Y
        local newY = currentY + math.clamp(targetY - currentY, -SPEED*dt, SPEED*dt)
        platform.Position = Vector3.new(root.Position.X, newY, root.Position.Z)
    end
end)
