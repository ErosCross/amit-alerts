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
