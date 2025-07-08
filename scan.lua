-- Main Scanning Function
local function performScan(forceSend)
    sessionStats.scans = sessionStats.scans + 1
    local foundPets = {}
    local totalFinds = 0
    local hasNewFinds = false

    -- Get pet details
    local petDetails = PetDetailsModule.getPetDetails()

    for _, brainrotName in pairs(brainrots) do
        local instances = ESPModule.findAllBrainrotInstances(brainrotName)
        if #instances > 0 then
            foundPets[brainrotName] = instances
            totalFinds = totalFinds + #instances
            local lastCount = lastScanResults[brainrotName] or 0
            if #instances > lastCount then
                hasNewFinds = true
            end
            lastScanResults[brainrotName] = #instances
        else
            lastScanResults[brainrotName] = 0
        end
    end

    sessionStats.totalFinds = totalFinds
    updateStatsDisplay()
    ESPModule.updateESP(foundPets)

    if (hasNewFinds or forceSend) and totalFinds > 0 then
        WebhookModule.sendConsolidatedWebhook(foundPets, totalFinds, petDetails)
    end
end

-- Auto Scan Loop
spawn(function()
    while true do
        if config.autoScanEnabled then
            performScan(false)
        end
        wait(config.scanInterval)
    end
end)

-- Auto Server Hop Loop
spawn(function()
    while true do
        if config.autoServerHopEnabled then
            wait(config.serverHopInterval)
            local success, errorMsg = pcall(ServerHopModule.performEnhancedServerHop)
            if not success then
                Rayfield:Notify({
                    Title = 'Auto Server Hop Failed',
                    Content = 'Failed to hop servers: ' .. tostring(errorMsg),
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        else
            wait(1)
        end
    end
end)

return {
    performScan = performScan
}