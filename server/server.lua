local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('reborn_banking:update:balance')
AddEventHandler('reborn_banking:update:balance', function(id)
    local Player = QBCore.Functions.GetPlayer(id)
    local newcash = Player.PlayerData.money['bank']
    TriggerClientEvent('reborn_banking:Client:UpdateSaldo', id, newcash)
end)

QBCore.Functions.CreateCallback('reborn:banking:gethistorico', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local RebornData = {
            Faturas = {}
        }
        local faturas = MySQL.query.await('SELECT * FROM reborn_faturas WHERE citizenid=@citizenid ORDER BY `idfatura` DESC LIMIT 50', {['@citizenid'] = Player.PlayerData.citizenid})
        if faturas[1] ~= nil then
            RebornData.Faturas = faturas
        end
        cb(RebornData)
    end
end)

RegisterServerEvent('reborn_banking:Server:Depositar')
AddEventHandler('reborn_banking:Server:Depositar', function(AddAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local rg = Player.PlayerData.citizenid
     
    if Player ~= nil then
        local CurrentCash = Player.PlayerData.money['cash']
        local CurrentBalance = Player.PlayerData.money['bank']
        local Amount = tonumber(AddAmount)
        if CurrentCash >= Amount then
            Player.Functions.RemoveMoney('cash', Amount, 'deposit')
            Player.Functions.AddMoney('bank', Amount, 'receiving deposit')
            TriggerEvent('reborn:historico:add',rg,Amount,'RebornBanking','You deposited into the account','+','Deposit','#0FA464')
            TriggerEvent('reborn_banking:update:balance',src)
        end
    end
end)

RegisterServerEvent('reborn_banking:Server:Sacar')
AddEventHandler('reborn_banking:Server:Sacar', function(Sacar)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local rg = Player.PlayerData.citizenid
     
    if Player ~= nil then
        local CurrentBalance = Player.PlayerData.money['bank']
        local Amount = tonumber(Sacar)
        if CurrentBalance >= Amount then
            Player.Functions.RemoveMoney('bank', Amount, 'Withdraw')
            Player.Functions.AddMoney('cash', Amount, 'Receiving withdraw')
            TriggerEvent('reborn:historico:add',rg,Amount,'RebornBanking','You made a withdraw','-','Withdraw','red')
            TriggerEvent('reborn_banking:update:balance',src)
        end
    end
end)

RegisterServerEvent('reborn_banking:Server:Transferir')
AddEventHandler('reborn_banking:Server:Transferir', function(iban, amount)
    local src = source
    local sender = QBCore.Functions.GetPlayer(src)
    local reciever = QBCore.Functions.GetPlayer(tonumber(iban))
    local rg = sender.PlayerData.citizenid
    local CurrentBalance = sender.PlayerData.money['bank']

    if reciever and reciever.PlayerData and reciever.PlayerData.citizenid then
        local rg2 = reciever.PlayerData.citizenid
        if CurrentBalance >= amount then
            sender.Functions.RemoveMoney('bank', amount, "money transferred to "..reciever.PlayerData.citizenid)
            reciever.Functions.AddMoney('bank', amount, "money transferred from "..sender.PlayerData.citizenid)

            TriggerEvent('reborn_banking:update:balance',src)
            TriggerEvent('reborn_banking:update:balance',reciever.PlayerData.source)
            
            TriggerEvent('reborn:historico:add',rg,amount,'RebornBanking','You made a transfer','-','Transfer Sent','red')
            TriggerEvent('reborn:historico:add',rg2,amount,'RebornBanking','You received a Transfer','+','Transfer Received','#0FA464')

            TriggerClientEvent('pw:notification:SendAlert', src, {type = "inform", text = "Transfer done!", length = 3500})
            TriggerClientEvent('pw:notification:SendAlert', reciever.PlayerData.source, {type = "inform", text = "You received a Transfer", length = 3500})
        else
            TriggerClientEvent('pw:notification:SendAlert', src, {type = "inform", text = "You do not have this amount to transfer", length = 3500})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', src, {type = "inform", text = "Player not online", length = 3500})
    end
end)

RegisterServerEvent('reborn:historico:add')
AddEventHandler('reborn:historico:add', function(citizenid,fvalor,ftitulo,fdescricao,fsimbolo,ftext,fvaluecolor)
    local date_table = os.date("*t")
    local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
    local hour, minute, second = date_table.hour, date_table.min, date_table.sec
    local year, month, day = date_table.year, date_table.month, date_table.day
    -- Gets the formatted current date
    local formatted_date = os.date("%Y-%m-%d")

    -- Gets the current time in seconds from the epoch and formats it as a string
    local current_time = os.time()
    local formatted_time = os.date("%H:%M:%S", current_time)

    -- Add milliseconds to end of formatted time
    local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
    formatted_time = formatted_time .. "." .. ms

    -- Add leading zeros to values less than 10
    local hour, minute, second = tonumber(formatted_time:sub(1, 2)), tonumber(formatted_time:sub(4, 5)), tonumber(formatted_time:sub(7, 8))
    hour = string.format("%02d", hour)
    minute = string.format("%02d", minute)
    second = string.format("%02d", second)

    -- Combines the formatted date and time into a string
    local formatted_datetime = formatted_date .. " " .. hour .. ":" .. minute .. ":" .. second .. "." .. ms

    MySQL.insert('INSERT INTO reborn_faturas (citizenid, valor, titulo, descricao, data, hora, simbolo, text, color) VALUES (@citizenid, @valor, @titulo, @descricao, @data, @hora, @simbolo, @text, @color)', {
        ['@citizenid'] = citizenid,
        ['@valor'] = fvalor,
        ['@titulo'] = ftitulo,
        ['@descricao'] = fdescricao,
        ['@data'] = day..'/'..month,
        ['@hora'] = hour..':'..minute,
        ['@simbolo'] = fsimbolo,
        ['@text'] = ftext,
        ['@color'] = fvaluecolor,
    })

end)
