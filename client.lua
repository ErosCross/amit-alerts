-- Custom Export for other scripts
exports('SendAlert', function(data)
    SendNUIMessage({
        action = 'showAlert',
        type = data.type or 'info',
        title = data.title or Config.DefaultTitle,
        message = data.message or 'No message specified',
        duration = data.duration or Config.DefaultDuration
    })
end)

-- Event handler for server-side alerts
RegisterNetEvent('amit-alerts:client:SendAlert', function(data)
    SendNUIMessage({
        action = 'showAlert',
        type = data.type or 'info',
        title = data.title or Config.DefaultTitle,
        message = data.message or 'No message specified',
        duration = data.duration or Config.DefaultDuration
    })
end)

-- Receive Oref Alert
RegisterNetEvent('amit-alerts:client:OrefAlert', function(data)
    local selectedArea = GetResourceKvpString("selected_area") or "all"
    
    local shouldShow = false
    if selectedArea == "all" then
        shouldShow = true
    else
        for _, area in ipairs(data.areas) do
            if area == selectedArea then
                shouldShow = true
                break
            end
        end
    end
    
    if shouldShow then
        SendNUIMessage({
            action = 'showAlert',
            type = 'error',
            title = data.title .. " - " .. data.areasText,
            message = data.message,
            duration = data.duration,
            icon = data.icon
        })
        
        -- Optional: Play sound
        PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", 1)
    end
end)

-- Test command
RegisterCommand('testalert', function(source, args, rawCommand)
    local alertType = args[1] or 'info'
    local message = args[2] or 'This is a test alert from Amit-Alerts!'
    
    exports['amit-alerts']:SendAlert({
        type = alertType,
        title = "SYSTEM",
        message = message,
        duration = 5000
    })
end, false)

-- Menu Command
RegisterCommand('alerts', function()
    local areas = {}
    for area, _ in pairs(Config.Lamas) do
        table.insert(areas, area)
    end
    table.sort(areas)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        areas = areas,
        currentArea = GetResourceKvpString("selected_area") or "all"
    })
end, false)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    SetResourceKvp("selected_area", data.area)
    cb('ok')
end)
