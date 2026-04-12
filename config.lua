Config = {}

Config.DefaultDuration = 5000 -- ms
Config.DefaultTitle = "ALERT"
Config.Position = "top-right" -- top-right, top-left, bottom-right, bottom-left

Config.AlertTypes = {
    ['success'] = {
        color = "#2ecc71",
        icon = "fas fa-check-circle"
    },
    ['error'] = {
        color = "#e74c3c",
        icon = "fas fa-exclamation-circle"
    },
    ['warning'] = {
        color = "#f1c40f",
        icon = "fas fa-exclamation-triangle"
    },
    ['info'] = {
        color = "#3498db",
        icon = "fas fa-info-circle"
    }
}
