-- Configuration Functions
local function loadConfig(config, brainrots)
    local success, savedConfig = pcall(function()
        return Rayfield:LoadConfiguration()
    end)

    if success and savedConfig then
        for key, value in pairs(savedConfig) do
            if DEFAULT_CONFIG[key] ~= nil then
                config[key] = value
            end
        end
        -- Ensure petToggles are initialized
        for _, petName in pairs(brainrots) do
            if config.petToggles[petName] == nil then
                config.petToggles[petName] = true
            end
        end
        print('Configuration loaded successfully!')
    else
        print('Using default configuration')
        -- Initialize petToggles if no config exists
        for _, petName in pairs(brainrots) do
            config.petToggles[petName] = true
        end
    end
end

local function saveConfig(config)
    local success = pcall(function()
        local configToSave = {}
        for key, value in pairs(config) do
            configToSave[key] = value
        end
        Rayfield:SaveConfiguration(configToSave)
    end)

    if success then
        print('Configuration saved successfully!')
    else
        warn('Failed to save configuration')
    end
end

return {
    loadConfig = loadConfig,
    saveConfig = saveConfig
}
