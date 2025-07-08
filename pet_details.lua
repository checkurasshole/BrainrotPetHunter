-- Pet Detail Functions
local function getTextLabelText(overhead, name)
    local label = overhead:FindFirstChild(name)
    return label and label:IsA("TextLabel") and label.Text or "N/A"
end

local function getPetDetails()
    local Plots = workspace:WaitForChild("Plots")
    local animals = {}

    for _, plot in ipairs(Plots:GetChildren()) do
        local plotID = plot.Name
        local podiums = plot:FindFirstChild("AnimalPodiums")

        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attachment = spawn and spawn:FindFirstChild("Attachment")
                local overhead = attachment and attachment:FindFirstChild("AnimalOverhead")

                if overhead then
                    local data = {
                        DisplayName = getTextLabelText(overhead, "DisplayName"),
                        Generation = getTextLabelText(overhead, "Generation"),
                        Mutation = getTextLabelText(overhead, "Mutation"),
                        Price = getTextLabelText(overhead, "Price"),
                        Rarity = getTextLabelText(overhead, "Rarity"),
                        PlotID = plotID,
                        Position = spawn.Position
                    }

                    local key = data.DisplayName .. "|" .. data.Generation .. "|" .. data.Mutation .. "|" .. data.Price .. "|" .. data.Rarity

                    if animals[key] then
                        animals[key].count = animals[key].count + 1
                        table.insert(animals[key].positions, data.Position)
                        table.insert(animals[key].plotIDs, plotID)
                    else
                        animals[key] = {
                            count = 1,
                            info = data,
                            positions = {data.Position},
                            plotIDs = {plotID}
                        }
                    end
                end
            end
        end
    end

    return animals
end

return {
    getPetDetails = getPetDetails
}