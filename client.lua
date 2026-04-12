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

-- Initialize UI with config
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    Wait(1000)
    SendNUIMessage({
        action = 'init',
        position = Config.Position,
        alertTypes = Config.AlertTypes
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
            type = data.type or 'error',
            title = data.title .. " - " .. data.areasText,
            message = data.message,
            duration = data.duration,
            icon = data.icon
        })
        
        if data.type == 'success' then
            PlaySoundFrontend(-1, "Challenge_Passed", "HUD_AWARDS", 1)
        end
    end
end)

-- Test command
RegisterCommand('testalert', function(source, args, rawCommand)
    local testType = args[1] == "green" and "success" or "error"
    local testTitle = testType == "success" and "בדיקת שחרור" or "התרעת בדיקה"
    local testMsg = testType == "success" and "זוהי בדיקה של הודעת סיום אירוע (ירוק)." or "זוהי התרעת ניסיון של מערכת Amit-Alerts (אדום)."

    TriggerEvent('amit-alerts:client:OrefAlert', {
        title = testTitle,
        message = testMsg,
        areas = {"all"},
        areasText = "כל הארץ",
        type = testType,
        icon = testType == "success" and "fas fa-check-circle" or "fas fa-rocket",
        duration = 10000
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
