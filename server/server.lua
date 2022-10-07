-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

Framework = nil

if GetResourceState('es_extended') == 'started' or GetResourceState('es_extended') == 'starting' then
    Framework = 'ESX'
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' or GetResourceState('qb-core') == 'starting' then
    Framework = 'qb'
    QBCore = exports['qb-core']:GetCoreObject()
else
    print("^0[^1ERROR^0] The framework could not be initialised!^0")
    print("^0[^1ERROR^0] For Support: https://discord.gg/wasabiscripts^0")
end

MySQL.ready(function()
    if Framework == "ESX" then
        MySQL.Sync.execute(
            "CREATE TABLE IF NOT EXISTS `boombox_songs` (" ..
                "`identifier` varchar(64) NOT NULL, " ..
                "`label` varchar(30) NOT NULL, " ..
                "`link` longtext NOT NULL " ..
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; "
        )
    elseif Framework == "QB" then
        MySQL.Sync.execute(
            "CREATE TABLE IF NOT EXISTS `boombox_songs` (" ..
                "`citizenid` varchar(64) NOT NULL, " ..
                "`label` varchar(30) NOT NULL, " ..
                "`link` longtext NOT NULL " ..
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; "
        )
    end
end)

if Framework == "ESX" then
    ESX.RegisterUsableItem(Config.BoomboxItem, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('wasabi_boombox:useBoombox', source)
        xPlayer.removeInventoryItem(Config.BoomboxItem, 1)
    end)
elseif Framework == "QB" then
    QBCore.Functions.CreateUseableItem(Config.BoomboxItem, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('wasabi_boombox:useBoombox', source)
        Player.Functions.RemoveItem(Config.BoomboxItem, 1)
    end)
end

RegisterServerEvent('wasabi_boombox:deleteObj', function(netId)
    TriggerClientEvent('wasabi_boombox:deleteObj', -1, netId)
end)

if Framework == "ESX" then
    RegisterServerEvent('wasabi_boombox:objDeleted', function()
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(Config.BoomboxItem, 1)
    end)
elseif Framework == "QB" then
    RegisterServerEvent('wasabi_boombox:objDeleted', function()
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem(Config.BoomboxItem, 1)
    end)
end

RegisterNetEvent("wasabi_boombox:soundStatus")
AddEventHandler("wasabi_boombox:soundStatus", function(type, musicId, data)
    TriggerClientEvent("wasabi_boombox:soundStatus", -1, type, musicId, data)
end)

RegisterNetEvent("wasabi_boombox:syncActive")
AddEventHandler("wasabi_boombox:syncActive", function(activeRadios)
    TriggerClientEvent("wasabi_boombox:syncActive", -1, activeRadios)
end)

if Framework == "ESX" then
    RegisterServerEvent('wasabi_boombox:save')
    AddEventHandler('wasabi_boombox:save', function(name, link)
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.insert('INSERT INTO `boombox_songs` (`identifier`, `label`, `link`) VALUES (@identifier, @label, @link)', {
            ['@identifier'] = xPlayer.identifier,
            ['@label'] = name,
            ['@link'] = link
        })
    end)
elseif Framework == "QB" then
    RegisterServerEvent('wasabi_boombox:save')
    AddEventHandler('wasabi_boombox:save', function(name, link)
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.Async.insert('INSERT INTO `boombox_songs` (`citizenid`, `label`, `link`) VALUES (@citizenid, @label, @link)', {
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@label'] = name,
            ['@link'] = link
        })
    end)
end

if Framework == "ESX" then
    RegisterServerEvent('wasabi_boombox:deleteSong')
    AddEventHandler('wasabi_boombox:deleteSong', function(data)
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.execute('DELETE FROM `boombox_songs` WHERE `identifier` = @identifier AND label = @label AND link = @link', {
            ["@identifier"] = xPlayer.identifier,
            ["@label"] = data.label,
            ["@link"] = data.link,
        })
    end)
elseif Framework == "QB" then
    RegisterServerEvent('wasabi_boombox:deleteSong')
    AddEventHandler('wasabi_boombox:deleteSong', function(data)
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.Async.execute('DELETE FROM `boombox_songs` WHERE `citizenid` = @citizenid AND label = @label AND link = @link', {
            ["@citizenid"] = Player.PlayerData.citizenid,
            ["@label"] = data.label,
            ["@link"] = data.link,
        })
    end)
end

if Framework == "ESX" then
    ESX.RegisterServerCallback('wasabi_boombox:getSavedSongs', function(source, cb)
        local savedSongs = {}
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.fetchAll('SELECT label, link FROM boombox_songs WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if result[1] then
                for i=1, #result do
                    table.insert(savedSongs, {label = result[i].label, link = result[i].link})
                end
            end
            if savedSongs then
                cb(savedSongs)
            else
                cb(false)
            end
        end)
    end)
elseif Framework == "QB" then
    QBCore.Functions.CreateCallback('wasabi_boombox:getSavedSongs', function(source, cb)
        local savedSongs = {}
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.Async.fetchAll('SELECT label, link FROM boombox_songs WHERE citizenid = @citizenid', {
            ['@citizenid'] = Player.PlayerData.citizenid
        }, function(result)
            if result[1] then
                for i=1, #result do
                    table.insert(savedSongs, {label = result[i].label, link = result[i].link})
                end
            end
            if savedSongs then
                cb(savedSongs)
            else
                cb(false)
            end
        end)
    end)
end