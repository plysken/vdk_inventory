require "resources/essentialmode/lib/MySQL"
MySQL:open(database.host, database.name, database.username, database.password)


RegisterServerEvent("item:getItems")
RegisterServerEvent("item:setItem")
RegisterServerEvent("item:updateQuantity")

local items = {}

AddEventHandler("item:getItems", function()
    items = {}
    TriggerEvent('es:getPlayerFromId', source, function(user)
        local player = user.identifier
        local executed_query = MySQL:executeQuery("SELECT * FROM user_inventory JOIN items ON `user_inventory`.`item_id` = `items`.`id` WHERE identifier = '@username'", { ['@username'] = player })
        local result = MySQL:getResults(executed_query, { 'quantity', 'libelle', 'item_id' }, "item_id")
        if (result) then
            for _, v in ipairs(result) do
                print('-----------------')
                print(v.item_id)
                print(v.libelle)
                print(v.quantity)
                t = { ["quantity"] = v.quantity, ["libelle"] = v.libelle }
                table.insert(items, tonumber(v.item_id), t)
            end
        end
    end)
    TriggerClientEvent("gui:getItems", source, items)
end)

AddEventHandler("item:setItem", function(item, quantity)
    TriggerEvent('es:getPlayerFromId', source, function(user)    --TriggerEvent('es:getPlayerFromId', playerId, function(user)    
        local player = user.identifier    
        MySQL:executeQuery("INSERT INTO user_inventory (`identifier`, `item_id`, `quantity`) VALUES ('@player', @item, @qty)",
            { ['@player'] = player, ['@item'] = item, ['@qty'] = quantity })
    end)
end)

AddEventHandler("item:updateQuantity", function(qty, id)
    TriggerEvent('es:getPlayerFromId', source, function(user)
        local player = user.identifier
        MySQL:executeQuery("UPDATE user_inventory SET `quantity` = @qty WHERE `identifier` = '@username' AND `item_id` = @id", { ['@username'] = player, ['@qty'] = tonumber(qty), ['@id'] = tonumber(id) })
    end)
end)
