-- Use this to fetch current status of currencies in game

print("=== All Known Currencies ===")

local currencyCount = 0

-- Iterate through a reasonable range of currency IDs
-- Most WoW currency IDs are within this range
for currencyID = 1, 5000 do
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)

    if currencyInfo and currencyInfo.name then
        local quantity = currencyInfo.quantity or 0
        local maxQuantity = currencyInfo.maxQuantity or 0

        if maxQuantity > 0 then
            currencyCount = currencyCount + 1

            local maxDisplay = maxQuantity > 0 and ("/" .. maxQuantity) or ""
            print(string.format("[%d] %s: %d%s", currencyID, currencyInfo.name, quantity, maxDisplay))
        end
    end
end

print(string.format("=== Total: %d currencies ===", currencyCount))
