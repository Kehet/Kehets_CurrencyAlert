local CurrencyAlert = LibStub("AceAddon-3.0"):NewAddon("Kehet's CurrencyAlert", "AceEvent-3.0", "AceConsole-3.0")

local KNOWN_CURRENCIES = {
    ["Archaeology"] = {
        [384] = "Dwarf Archaeology Fragment",
        [385] = "Troll Archaeology Fragment",
        [393] = "Fossil Archaeology Fragment",
        [394] = "Night Elf Archaeology Fragment",
        [397] = "Orc Archaeology Fragment",
        [398] = "Draenei Archaeology Fragment",
        [399] = "Vrykul Archaeology Fragment",
        [400] = "Nerubian Archaeology Fragment",
        [401] = "Tol'vir Archaeology Fragment",
        [676] = "Pandaren Archaeology Fragment",
        [677] = "Mogu Archaeology Fragment",
        [754] = "Mantid Archaeology Fragment",
    },

    ["Dungeon"] = {
        [395] = "Justice Points",
        [396] = "Valor Points",
        [3148] = "Fissure Stone Fragment",
        [3350] = "August Stone Fragment",
        [697] = "Elder Charm of Good Fortune",
    },

    ["PvP"] = {
        [1901] = "Honor Points",
    },
};

-- Database defaults
local defaults = {
    profile = {
        currencies = {}
    }
}

-- Initialize currency defaults
for categoryName, currencies in pairs(KNOWN_CURRENCIES) do
    for currencyID, name in pairs(currencies) do
        local maxQuantity = (C_CurrencyInfo.GetCurrencyInfo(currencyID).maxQuantity or 0);
        local threshold = maxQuantity;

        if maxQuantity > 1000 then
            threshold = maxQuantity - 500;
        elseif maxQuantity > 100 then
            threshold = maxQuantity - 50;
        elseif maxQuantity > 10 then
            threshold = maxQuantity - 10;
        else
            threshold = maxQuantity - 2;
        end

        defaults.profile.currencies[currencyID] = {
            enabled = true,
            threshold = threshold
        }
    end
end

defaults.profile.currencies[396].enabled = false  -- Valor Points

-- AceConfig options table
local options = {
    type = "group",
    name = "Kehet's CurrencyAlert",
    handler = CurrencyAlert,
    args = {
        desc = {
            type = "description",
            name = "Configure which currencies to track and their alert thresholds.",
            order = 1,
        },
        currencies = {
            type = "group",
            name = "Currencies",
            order = 2,
            args = {}
        }
    }
}

-- Populate currency options
local categoryOrder = 1
for categoryName, currencies in pairs(KNOWN_CURRENCIES) do
    options.args.currencies.args[categoryName:lower()] = {
        type = "group",
        name = categoryName,
        order = categoryOrder,
        args = {}
    }

    for currencyID, name in pairs(currencies) do
        options.args.currencies.args[categoryName:lower()].args["currency_" .. currencyID] = {
            type = "group",
            name = name,
            order = currencyID,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable Tracking",
                    desc = "Enable tracking for " .. name,
                    order = 1,
                    get = function(info) return CurrencyAlert.db.profile.currencies[currencyID].enabled end,
                    set = function(info, value) CurrencyAlert.db.profile.currencies[currencyID].enabled = value end,
                },
                threshold = {
                    type = "range",
                    name = "Alert Threshold",
                    desc = "Alert when currency is within this many of being full",
                    order = 2,
                    min = 0,
                    max =  C_CurrencyInfo.GetCurrencyInfo(currencyID).maxQuantity or 0,
                    step = 1,
                    get = function(info) return CurrencyAlert.db.profile.currencies[currencyID].threshold end,
                    set = function(info, value) CurrencyAlert.db.profile.currencies[currencyID].threshold = value end,
                    disabled = function() return not CurrencyAlert.db.profile.currencies[currencyID].enabled end,
                }
            }
        }
    end

    categoryOrder = categoryOrder + 1
end

local previousCurrencies = {}

local function InitializeCurrencies()
    for currencyID, settings in pairs(CurrencyAlert.db.profile.currencies) do
        if settings.enabled then
            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
            if currencyInfo then
                previousCurrencies[currencyID] = currencyInfo.quantity or 0
            else
                previousCurrencies[currencyID] = 0
            end
        end
    end
end

local function CheckCurrencyChanges()
    for currencyID, settings in pairs(CurrencyAlert.db.profile.currencies) do
        if settings.enabled then
            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
            if currencyInfo then
                local currentAmount = currencyInfo.quantity or 0
                local previousAmount = previousCurrencies[currencyID] or 0
                local maxAmount = currencyInfo.maxQuantity or 0
                local name = nil

                -- Find currency name in the new structure
                for categoryName, currencies in pairs(KNOWN_CURRENCIES) do
                    if currencies[currencyID] then
                        name = currencies[currencyID]
                        break
                    end
                end
                name = name or ("Currency " .. currencyID)

                local threshold = settings.threshold or 100

                if currentAmount > previousAmount then
                    if maxAmount > 0 and maxAmount - currentAmount <= threshold then
                        local message = string.format("%s soon full! (%d/%d)", name, currentAmount, maxAmount)
                        CurrencyAlert:Print(message)
                        RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
                        PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2)
                    end
                elseif maxAmount > 0 and currentAmount == maxAmount and currentAmount == previousAmount then
                    local message = string.format("%s is full! (%d/%d)", name, currentAmount, maxAmount)
                    CurrencyAlert:Print(message)
                    RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
                    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3)
                end

                previousCurrencies[currencyID] = currentAmount
            end
        end
    end
end

function CurrencyAlert:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CurrencyAlertDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("CurrencyAlert", options, {"currencyalert", "ca"})
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CurrencyAlert", "Kehet's CurrencyAlert")
end

function CurrencyAlert:OnEnable()
    self:Print("Enabled -- /currencyalert or /ca")
    InitializeCurrencies()
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
end

function CurrencyAlert:CURRENCY_DISPLAY_UPDATE()
    CheckCurrencyChanges()
end
