local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('banco',function(source,args,rawCommand)
	local jogador1 = PlayerPedId()
	if jogador1 then
        if IsNearAnyBank() then
		    TriggerEvent('RebornBanking:OpenBank')
        elseif IsNearAtm() then
            TriggerEvent('RebornBanking:OpenAtm')
        end
	end	
end)

RegisterNetEvent('RebornBanking:OpenBank')
AddEventHandler('RebornBanking:OpenBank', function()
    Citizen.SetTimeout(450, function()
        OpenBank(true)
    end)
end)

RegisterNetEvent('RebornBanking:OpenAtm')
AddEventHandler('RebornBanking:OpenAtm', function()
    Citizen.SetTimeout(450, function()
        OpenBank(false)
    end)
end)

RegisterNUICallback('ClickSound', function(data)
    if data.success == 'bank-error' then
        PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
    elseif data.success == 'click' then
        PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    else
        return
    end
end)

RegisterNUICallback('Depositar', function(data)
    if IsNearAnyBank() then
      TriggerServerEvent('reborn_banking:Server:Depositar', data.AddAmount) 
    elseif IsNearAtm() then
        TriggerServerEvent('reborn_banking:Server:Depositar', data.AddAmount)
    end
end)

RegisterNUICallback('Sacar', function(data)
    if IsNearAnyBank() then
      TriggerServerEvent('reborn_banking:Server:Sacar', data.Sacar) 
    elseif IsNearAtm() then
        TriggerServerEvent('reborn_banking:Server:Sacar', data.Sacar)
    end
end)

RegisterNUICallback('Transferir', function(data)
    if IsNearAnyBank() then
      TriggerServerEvent('reborn_banking:Server:Transferir', data.Conta,data.Transferir) 
    else 
        TriggerEvent('reborn:notify:send',"Oops..","Você não está no Banco","erro", 5000)
        PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
    end
end)

RegisterNetEvent('reborn_banking:Client:UpdateSaldo')
AddEventHandler('reborn_banking:Client:UpdateSaldo', function(newsaldo)
    SendNUIMessage({
        action = 'Atualizando',
        novosaldo = newsaldo,
      })
      UpdateFaturas()
end)

function UpdateFaturas()
    QBCore.Functions.TriggerCallback('reborn:banking:gethistorico', function(pData)
        SendNUIMessage({
            action = 'updatefatura',
            historico = pData.Faturas
        })
    end) 
end  

RegisterNUICallback('CloseApp', function()
    SetNuiFocus(false, false)
end)

function OpenBank(CanDeposit, UseAnim)
    QBCore.Functions.TriggerCallback('reborn:banking:gethistorico', function(pData)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openbank',
            candeposit = CanDeposit,
            chardata = QBCore.Functions.GetPlayerData(),
            historico = pData.Faturas
        })
    end)   
end

function IsNearAtm()
    local PlayerCoords = GetEntityCoords(GetPlayerPed(-1))
    for k, v in pairs(Config.AtmObject) do
        local AtmObject = GetClosestObjectOfType(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, 3.0, v, false, 0, 0)
        local ObjectCoords = GetEntityCoords(AtmObject)
        local Distance = GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, ObjectCoords.x, ObjectCoords.y, ObjectCoords.z, true)
        if Distance < 2.0 then
            return true
        end
    end
end

function IsNearAnyBank()
    for k, v in pairs(Config.Banks) do
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        local Distance = GetDistanceBetweenCoords(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, v['X'], v['Y'], v['Z'], true)
        if Distance < 2.5 then
            return true
        end
    end
end
