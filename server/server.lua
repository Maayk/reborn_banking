RebornCore = nil

TriggerEvent('RebornCore:GetObject', function(obj) RebornCore = obj end)

RebornCore.Functions.CreateCallback('reborn:banking:gethistorico', function(source, cb)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local RebornData = {
            Faturas = {}
        }

        local faturas = exports.ghmattimysql:executeSync('SELECT * FROM reborn_faturas WHERE citizenid=@citizenid ORDER BY `idfatura` DESC LIMIT 50', {['@citizenid'] = Player.PlayerData.citizenid})
        if faturas[1] ~= nil then
            RebornData.Faturas = faturas
        end
        cb(RebornData)
    end
end)

RegisterServerEvent('reborn_banking:Server:Depositar')
AddEventHandler('reborn_banking:Server:Depositar', function(AddAmount)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(source)
    local rg = Player.PlayerData.citizenid
     
    if Player ~= nil then
        local CurrentCash = Player.PlayerData.money['cash']
        local CurrentBalance = Player.PlayerData.money['bank']
        local Amount = tonumber(AddAmount)
        if CurrentCash >= Amount then
            Player.Functions.RemoveMoney('cash', Amount, 'depositando')
            Player.Functions.AddMoney('bank', Amount, 'recebendo deposito')
            TriggerEvent('reborn:historico:add',rg,Amount,'RebornBanking','Você depositou na conta','3')
            TriggerEvent('reborn_banking:update:balance',src)
            

            TriggerEvent("Reborn:Logs:EnviandoLogs", "depositando", "Depósito Efetuado", "green", "**".. GetPlayerName(src) .. "** (RG: *"..Player.PlayerData.citizenid.."* ) ID Atual:(*"..src.."*) ```Depositou: $"..Amount.." Dinheiro na Mão: $"..CurrentCash.." Saldo no Banco: $"..CurrentBalance.."```",nil,"deposito")

        end
    end
end)

RegisterServerEvent('reborn_banking:Server:Sacar')
AddEventHandler('reborn_banking:Server:Sacar', function(Sacar)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(source)
    local rg = Player.PlayerData.citizenid
     
    if Player ~= nil then
        local CurrentBalance = Player.PlayerData.money['bank']
        local Amount = tonumber(Sacar)
        if CurrentBalance >= Amount then
            Player.Functions.RemoveMoney('bank', Amount, 'sacando')
            Player.Functions.AddMoney('cash', Amount, 'recebendo saque')
            TriggerEvent('reborn:historico:add',rg,Amount,'RebornBanking','Você efetuou um saque','4')
            TriggerEvent('reborn_banking:update:balance',src)
            TriggerEvent("Reborn:Logs:EnviandoLogs", "sacando", "Saque Efetuado", "red", "**".. GetPlayerName(src) .. "** (RG: *"..Player.PlayerData.citizenid.."* ) ID Atual:(*"..src.."*) ```Sacou: $"..Amount.." Saldo Atual: $"..CurrentBalance.." ```",nil,"saque")
        end
    end
end)


RegisterServerEvent('reborn_banking:Server:Transferir')
AddEventHandler('reborn_banking:Server:Transferir', function(iban, amount)
    local src = source
    local sender = RebornCore.Functions.GetPlayer(src)
    local rg = sender.PlayerData.citizenid
    local CurrentBalance = sender.PlayerData.money['bank']
    RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
        if result[1] ~= nil then
            local recieverSteam = RebornCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

            if recieverSteam ~= nil then
                if rg ~= recieverSteam.PlayerData.citizenid then
                    if CurrentBalance >= amount then
                        sender.Functions.RemoveMoney('bank', amount, "dinheiro transferido para "..recieverSteam.PlayerData.citizenid)
                        recieverSteam.Functions.AddMoney('bank', amount, "dinheiro transferido de "..sender.PlayerData.citizenid)
                        TriggerEvent('reborn:historico:add',recieverSteam.PlayerData.citizenid,amount,"Transferencia","Transferencia Recebida","5")
                        TriggerEvent('reborn:historico:add',sender.PlayerData.citizenid,amount,"Transferencia","Transferencia Enviada","6")
                        Wait(500)
                        TriggerClientEvent('reborn:update:banco:historico', recieverSteam.PlayerData.source)
                        TriggerClientEvent('reborn:update:banco:historico', src)
                        
                        TriggerEvent('reborn_banking:update:balance',src)
                        TriggerEvent('reborn_banking:update:balance',recieverSteam.PlayerData.source)
                        TriggerClientEvent('reborn:notify:send',src, "Parabéns","Transferência realizada!","sucesso", 5000)
                        TriggerClientEvent('reborn:notify:send',recieverSteam.PlayerData.source, "RebornBank","Você recebeu uma Transferencia","sucesso", 5000)
                        TriggerEvent("Reborn:Logs:EnviandoLogs", "transferencia", "Transferencia Enviada", "red", "**".. GetPlayerName(src) .. "** (RG: *"..sender.PlayerData.citizenid.."* ) ID Atual:(*"..src.."*) ```Transferiu: $"..Amount.." Saldo Atual: $"..CurrentBalance.." ```",nil,"transferencia")
                        TriggerEvent("Reborn:Logs:EnviandoLogs", "transferencia", "Transferencia Recebida", "green", "**(RG: *"..recieverSteam.PlayerData.citizenid.."* ) ```Recebeu: $"..Amount.." De: "..sender.PlayerData.citizenid.." ```",nil,"transferencia")
                    else
                        TriggerClientEvent('reborn:notify:send',src, "Oops","Você não tem esse valor..","erro", 5000)
                    end
                else
                    TriggerClientEvent('reborn:notify:send',src, "???","Esta é sua conta!","erro", 5000)
                end
            else
                if rg ~= result[1].citizenid then
                    if CurrentBalance >= amount then
                        
                        local moneyInfo = json.decode(result[1].money)
                        moneyInfo.bank = moneyInfo.bank + amount
                        RebornCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                        sender.Functions.RemoveMoney('bank', amount, "transferencia")
                        TriggerEvent('reborn:historico:add',result[1].citizenid,amount,"Transferencia","Transferencia Recebida","5")
                        TriggerEvent('reborn:historico:add',sender.PlayerData.citizenid,amount,"Transferencia","Transferencia Enviada","6")

                        TriggerEvent("Reborn:Logs:EnviandoLogs", "transferencia", "Transferencia Enviada", "red", "**".. GetPlayerName(src) .. "** (RG: *"..sender.PlayerData.citizenid.."* ) ID Atual:(*"..src.."*) ```Transferiu: $"..amount.." Saldo Atual: $"..CurrentBalance.." ```",nil,"transferencia")
                        TriggerEvent("Reborn:Logs:EnviandoLogs", "transferencia", "Transferencia Recebida", "green", "Jogador Estava Offline - (RG: *"..result[1].citizenid.."* ) ```Recebeu: $"..amount.." De: "..sender.PlayerData.citizenid.." Saldo Atual: $"..moneyInfo.bank.." ```",nil,"transferencia")
                        
                        Wait(500)
                        TriggerClientEvent('reborn:update:banco:historico', src)
                        TriggerEvent('reborn_banking:update:balance',src)
                    else
                        TriggerClientEvent('reborn:notify:send',src, "Oops","Você não tem esse valor..","erro", 5000)
                    end
                else
                    TriggerClientEvent('reborn:notify:send',src, "???","Esta é sua conta!","erro", 5000)
                end
            end
        else
            TriggerClientEvent('reborn:notify:send',src, "RebornBank","Esta conta não existe!","erro", 5000)
        end
    end)
end)

RegisterServerEvent('reborn:historico:add')
AddEventHandler('reborn:historico:add', function(citizenid,fvalor,ftitulo,fdescricao,ftipo)
    local date_table = os.date("*t")
    local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
    local hour, minute, second = date_table.hour, date_table.min, date_table.sec
    local year, month, day = date_table.year, date_table.month, date_table.day
    if  day < 10 then
        day = '0'..day
    end

    if  month < 10 then
        month = '0'..month
    end
    if  hour < 10 then
        hour = '0'..hour
    end
    if  minute < 10 then
        minute = '0'..minute
    end

    MySQL.insert('INSERT INTO reborn_faturas (citizenid, valor, titulo, descricao, data, hora, tipo) VALUES (@citizenid, @valor, @titulo, @descricao, @data, @hora, @tipo)', {
        ['@citizenid'] = citizenid,
        ['@valor'] = fvalor,
        ['@titulo'] = ftitulo,
        ['@descricao'] = fdescricao,
        ['@data'] = day..'/'..month,
        ['@hora'] = hour..':'..minute,
        ['@tipo'] = ftipo,
    })

end)

RegisterServerEvent('reborn_banking:update:balance')
AddEventHandler('reborn_banking:update:balance', function(id)
    local Player = RebornCore.Functions.GetPlayer(id)
    local newcash = Player.PlayerData.money['bank']
    TriggerClientEvent('reborn_banking:Client:UpdateSaldo', id, newcash)
end)
