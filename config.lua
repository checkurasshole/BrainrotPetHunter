-- Configuration Functions
local function loadConfig()
    local success, savedConfig = pcall(function()
        return Rayfield:LoadConfiguration()
    end)

    if success and savedConfig then
        for key, value in pairs(savedConfig) do
            if DEFAULT_CONFIG[key] ~= nil then
                config[key] = value
            end
        end
        print('Configuration loaded successfully!')
    else
        print('Using default configuration')
    end
end

local function saveConfig()
    local success = pcall(function()
        Rayfield:SaveConfiguration(config)
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