-- ESP Functions
local function findAllBrainrotInstances(brainrotName)
    local instances = {}
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == brainrotName then
            table.insert(instances, child)
        end
    end
    if #instances == 0 then
        local variations = {
            brainrotName:gsub(' ', ''),
            brainrotName:lower(),
            brainrotName:upper(),
        }
        for _, variation in pairs(variations) do
            for _, child in pairs(workspace:GetChildren()) do
                if child.Name == variation then
                    table.insert(instances, child)
                end
            end
        end
    end
    if #instances == 0 then
        for _, child in pairs(workspace:GetChildren()) do
            if child.Name:find(brainrotName) or brainrotName:find(child.Name) then
                table.insert(instances, child)
            end
        end
    end
    return instances
end

local function getBrainrotPosition(brainrotInstance)
    if brainrotInstance:FindFirstChild('HumanoidRootPart') then
        return brainrotInstance.HumanoidRootPart.Position
    elseif brainrotInstance:FindFirstChild('RootPart') then
        return brainrotInstance.RootPart.Position
    elseif brainrotInstance:FindFirstChild('FakeRootPart') then
        return brainrotInstance.FakeRootPart.Position
    elseif brainrotInstance:FindFirstChild('Torso') then
        return brainrotInstance.Torso.Position
    elseif brainrotInstance:FindFirstChild('Head') then
        return brainrotInstance.Head.Position
    elseif brainrotInstance.PrimaryPart then
        return brainrotInstance.PrimaryPart.Position
    else
        local cf, size = brainrotInstance:GetBoundingBox()
        return cf.Position
    end
end

local function createESPForInstance(brainrotInstance, brainrotName, index)
    local line = Drawing.new('Line')
    line.Thickness = 2
    line.Color = Color3.fromRGB(255, 0, 255)
    line.Transparency = 1
    line.Visible = false

    local text = Drawing.new('Text')
    text.Size = 18
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Font = 2
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Visible = false

    local distanceText = Drawing.new('Text')
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)
    distanceText.Font = 2
    distanceText.Color = Color3.fromRGB(255, 255, 0)
    distanceText.Visible = false

    local connection = RunService.RenderStepped:Connect(function()
        if not config.espEnabled or not brainrotInstance or not brainrotInstance:IsDescendantOf(workspace) then
            line.Visible = false
            text.Visible = false
            distanceText.Visible = false
            return
        end

        local success, brainrotPos = pcall(getBrainrotPosition, brainrotInstance)
        if not success then
            return
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(brainrotPos)
        if onScreen and screenPos.Z > 0 then
            local playerPos = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
            local distance = playerPos and math.floor((playerPos.Position - brainrotPos).Magnitude) or 0

            local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local to = Vector2.new(screenPos.X, screenPos.Y)

            line.From = from
            line.To = to
            line.Visible = true

            local displayName = brainrotName
            if index then
                displayName = brainrotName .. ' [' .. index .. ']'
            end

            text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
            text.Text = displayName
            text.Visible = true

            distanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
            distanceText.Text = distance .. 'm'
            distanceText.Visible = true
        else
            line.Visible = false
            text.Visible = false
            distanceText.Visible = false
        end
    end)

    return {
        line = line,
        text = text,
        distanceText = distanceText,
        connection = connection,
        cleanup = function()
            connection:Disconnect()
            line:Remove()
            text:Remove()
            distanceText:Remove()
        end,
    }
end

local function clearAllESP()
    for brainrotName, espObjects in pairs(espLines) do
        for _, espObj in pairs(espObjects) do
            espObj.cleanup()
        end
        espLines[brainrotName] = {}
    end
end

local function updateESP(foundPets)
    clearAllESP()
    if not config.espEnabled then
        return
    end
    for brainrotName, instances in pairs(foundPets) do
        espLines[brainrotName] = {}
        for i, instance in pairs(instances) do
            local espObj = createESPForInstance(instance, brainrotName, #instances > 1 and i or nil)
            table.insert(espLines[brainrotName], espObj)
        end
    end
end

return {
    findAllBrainrotInstances = findAllBrainrotInstances,
    clearAllESP = clearAllESP,
    updateESP = updateESP
}