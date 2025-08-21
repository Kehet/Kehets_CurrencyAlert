local CurrencyAlert = LibStub("AceAddon-3.0"):NewAddon("Kehet's CurrencyAlert", "AceEvent-3.0", "AceConsole-3.0")

local TRACKED_CURRENCIES = {
    [395] = "Justice Points",      -- Justice Points
    [396] = "Valor Points",        -- Valor Points
    [3350] = "August Stone Fragments"  -- August Stone Fragments
}

local previousCurrencies = {}

local function InitializeCurrencies()
    for currencyID, name in pairs(TRACKED_CURRENCIES) do
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if currencyInfo then
            previousCurrencies[currencyID] = currencyInfo.quantity or 0
        else
            previousCurrencies[currencyID] = 0
        end
    end
end

local function CheckCurrencyChanges()
    for currencyID, name in pairs(TRACKED_CURRENCIES) do
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if currencyInfo then
            local currentAmount = currencyInfo.quantity or 0
            local previousAmount = previousCurrencies[currencyID] or 0

            if currentAmount > previousAmount then
                local maxAmount = currencyInfo.maxQuantity or 0

                if maxAmount > 1000 and maxAmount - currentAmount < 100 then
                    local message = string.format("%s soon full! (%d/%d)", name, currentAmount, maxAmount)
                    print(message)
                    RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
                    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2)
                elseif maxAmount - currentAmount < 10 then
                    local message = string.format("%s soon full! (%d/%d)", name, currentAmount, maxAmount)
                    print(message)
                    RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
                    PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2)
                end
            end

            previousCurrencies[currencyID] = currentAmount
        end
    end
end

function CurrencyAlert:OnEnable()
    self:Print("Enabled")
    InitializeCurrencies()
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
end

function CurrencyAlert:CURRENCY_DISPLAY_UPDATE()
    CheckCurrencyChanges()
end
