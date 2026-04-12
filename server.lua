-- Global Trigger for server-side alerts
RegisterNetEvent('amit-alerts:server:SendAlert', function(target, data)
    if target == -1 then
        TriggerClientEvent('amit-alerts:client:SendAlert', -1, data)
    else
        TriggerClientEvent('amit-alerts:client:SendAlert', target, data)
    end
end)

-- Example: Command to send alert to all players (admin only check can be added)
RegisterCommand('alertall', function(source, args, rawCommand)
    local message = table.concat(args, " ")
    if message == "" then message = "Global Alert!" end
    
    TriggerEvent('amit-alerts:server:SendAlert', -1, {
        type = 'warning',
        title = 'GLOBAL',
        message = message,
        duration = 10000
    })
end, true) -- true requires Ace permission 'command.alertall'
