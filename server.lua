local lastAlertHash = ""
local function DebugPrint(msg)
    if Config.Debug then
        print(msg)
    end
end

DebugPrint("^2[Amit-Alerts] Server script loaded and starting...^7")

-- Function to standardize strings (remove spaces, hyphens, etc.)
local function standardize(str)
    if not str then return "" end
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
        if statusCode ~= 200 and statusCode ~= 304 then
            if statusCode == 403 then
                print("^1[Amit-Alerts] Error 403: Server IP Geoblocked by Oref!^7")
            end
            return
        end

        if responseText ~= nil then
            -- Clean BOM and whitespace which frequently break json.decode
            local cleanResp = responseText:gsub("^%s+", ""):gsub("%s+$", "")
            if cleanResp == "" then return end -- No alerts active

            -- Strip UTF-8 BOM
            if string.byte(cleanResp, 1) == 239 and string.byte(cleanResp, 2) == 187 and string.byte(cleanResp, 3) == 191 then
                cleanResp = string.sub(cleanResp, 4)
            end

            -- Instead of ID matching (which misses extending alerts), compare the whole string hash
            if cleanResp == lastAlertHash then return end
            
            -- Ensure it's a valid JSON start character to avoid decode errors on empty/HTML responses
            if not cleanResp:match("^[%{%[]") then
                return 
            end

            local data = json.decode(cleanResp)
            if not data then 
                DebugPrint("^1[Amit-Alerts] JSON Decode Failed! Raw string:^7 " .. cleanResp:sub(1, 100))
                return 
            end

            lastAlertHash = cleanResp -- Update hash

            -- Handle both single object and array of objects
            local alerts = {}
            if data.id then 
                alerts = { data } 
            elseif type(data) == "table" and #data > 0 then 
                alerts = data 
            end

            for _, alertData in ipairs(alerts) do
                if alertData and alertData.id then
                    local alertTitle = alertData.title or "צבע אדום"
                    local rawCities = alertData.data or {}
                    local detectedAreas = {}
                    local seenAreas = {}
                    
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
                    local areasText = ""
                    if #detectedAreas > 1 then
                        local last = table.remove(detectedAreas)
                        areasText = table.concat(detectedAreas, ", ") .. " ו" .. last
                    elseif #detectedAreas == 1 then
                        areasText = detectedAreas[1]
                    else
                        areasText = "אזור לא ידוע"
                    end
                    
                    areasText = areasText:gsub("השפלה", "שפלה")
                    local icon = Config.Oref.Icons[tonumber(alertData.cat)] or "fas fa-exclamation-triangle"
                    local alertType = (tonumber(alertData.cat) == 10) and 'success' or 'error'

                    print("^2[Amit-Alerts] ALERT: " .. alertTitle .. " in " .. areasText .. " (" .. tostring(alertData.id) .. ")^7")
                    
                    TriggerClientEvent('amit-alerts:client:OrefAlert', -1, {
                        title = alertTitle,
                        message = table.concat(rawCities, ", "),
                        areas = detectedAreas,
                        areasText = areasText,
                        type = alertType,
                        icon = icon,
                        duration = 10000
                    })
                end
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
    DebugPrint("^2[Amit-Alerts] Polling loop started...^7")
    while true do
        checkOrefAlerts()
        Citizen.Wait(Config.Oref.Interval)
    end
end)

-- Global Trigger for server-side alerts
RegisterNetEvent('amit-alerts:server:SendAlert', function(target, data)
    if target == -1 then
        TriggerClientEvent('amit-alerts:client:SendAlert', -1, data)
    else
        TriggerClientEvent('amit-alerts:client:SendAlert', target, data)
    end
end)