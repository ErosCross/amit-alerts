local lastAlertId = 0

-- Function to standardize strings (remove spaces, hyphens, etc.)
local function standardize(str)
    if not str then return "" end
    -- Remove non-alphanumeric characters (equivalent to re.sub(r'[\-\,\(\)\s]+', '', name))
    local s = str:gsub("[%-%s%,%s%(%)%s]", "")
    return s
end

-- Pre-standardize current Lamas data for faster matching
local standardizedLamas = {}
for area, cities in pairs(Config.Lamas) do
    standardizedLamas[area] = {}
    for _, city in ipairs(cities) do
        table.insert(standardizedLamas[area], standardize(city))
    end
end

function checkOrefAlerts()
    PerformHttpRequest(Config.Oref.Url, function(statusCode, responseText, headers)
        if statusCode == 200 and responseText ~= nil and responseText ~= "" then
            local data = json.decode(responseText)
            
            if data and data.id and tonumber(data.id) > lastAlertId then
                lastAlertId = tonumber(data.id)
                
                local alertTitle = data.title or "צבע אדום"
                local rawCities = data.data or {}
                local detectedAreas = {}
                local seenAreas = {}
                
                -- Process each city and find its area
                for _, cityName in ipairs(rawCities) do
                    local stdCity = standardize(cityName)
                    
                    for area, cities in pairs(standardizedLamas) do
                        if not seenAreas[area] then
                            for _, c in ipairs(cities) do
                                if c == stdCity then
                                    table.insert(detectedAreas, area)
                                    seenAreas[area] = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                table.sort(detectedAreas)
                
                -- Construct Areas Text
                local areasText = ""
                if #detectedAreas > 1 then
                    local last = table.remove(detectedAreas)
                    areasText = table.concat(detectedAreas, ", ") .. " ו" .. last
                elseif #detectedAreas == 1 then
                    areasText = detectedAreas[1]
                else
                    areasText = "אזור לא ידוע"
                end
                
                -- Fix specific naming as per Python snippet
                areasText = areasText:gsub("השפלה", "שפלה")

                local icon = Config.Oref.Icons[tonumber(data.cat)] or "fas fa-exclamation-triangle"
                
                print("[Oref] New Alert: " .. alertTitle .. " in " .. areasText)
                
                -- Broadcast to all clients
                TriggerClientEvent('amit-alerts:client:OrefAlert', -1, {
                    title = alertTitle,
                    message = table.concat(rawCities, ", "),
                    areas = detectedAreas, -- Sending the raw list for client-side filtering
                    areasText = areasText,
                    type = 'error', -- Always show as error (red) for alerts
                    icon = icon,
                    duration = 10000
                })
            end
        end
    end, "GET", "", {
        ["Content-Type"] = "application/json",
        ["Referer"] = "https://www.oref.org.il/",
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        ["X-Requested-With"] = "XMLHttpRequest"
    })
end

-- Polling Loop
Citizen.CreateThread(function()
    while true do
        checkOrefAlerts()
         Citizen.Wait(Config.Oref.Interval)
    end
end)

-- Global Trigger for server-side alerts (Backwards compatibility)
RegisterNetEvent('amit-alerts:server:SendAlert', function(target, data)
    if target == -1 then
        TriggerClientEvent('amit-alerts:client:SendAlert', -1, data)
    else
        TriggerClientEvent('amit-alerts:client:SendAlert', target, data)
    end
end)