ESX = nil

local playerCars = {}
local playerKeys = {}

local iConcess = {
    theId = {},
    thePlate = {},
}

fellow_conc = {
	catevehi = {},
	listecatevehi = {},
}

local derniervoituresorti = {}
local sortirvoitureacheter = {}
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
if Concess.blips then
        local concessmap = AddBlipForCoord(Concess.pos.blips.position.x, Concess.pos.blips.position.y, Concess.pos.blips.position.z)
        SetBlipSprite(concessmap, 326)
        SetBlipColour(concessmap, 18)
        SetBlipScale(concessmap, 0.90)
        SetBlipAsShortRange(concessmap, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Concessionnaire | Voiture")
        EndTextCommandSetBlipName(concessmap)
end
end)


function MenuF6Concess()
    local f6concess = RageUI.CreateMenu("Concessionnaire", "Interactions")
    f6concess:SetRectangleBanner(11,11,11,1)
    RageUI.Visible(f6concess, not RageUI.Visible(f6concess))
    while f6concess do
        Citizen.Wait(0)
            RageUI.IsVisible(f6concess, true, true, true, function()

                RageUI.Separator("↓ Facture ↓")

                RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→"}, true, function(_,_,s)
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if s then
                        local raison = ""
                        local montant = 0
                        AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then
                                raison = result
                                result = nil
                                AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
                                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
                                while (UpdateOnscreenKeyboard() == 0) do
                                    DisableAllControlActions(0)
                                    Wait(0)
                                end
                                if (GetOnscreenKeyboardResult()) then
                                    result = GetOnscreenKeyboardResult()
                                    if result then
                                        montant = result
                                        result = nil
                                        if player ~= -1 and distance <= 3.0 then
                                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_cardealer', ('Concessionnaire'), montant)
                                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
                                        else
                                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)


                RageUI.Separator("↓ Annonce ↓")



                RageUI.ButtonWithStyle("Annonces d'ouverture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then       
                        TriggerServerEvent('fConcess:Ouvert')
                    end
                end)
        
                RageUI.ButtonWithStyle("Annonces de fermeture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then      
                        TriggerServerEvent('fConcess:Fermer')
                    end
                end)

                RageUI.ButtonWithStyle("Personnalisé", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local msg = KeyboardInput("Message", "", 100)
                        TriggerServerEvent('fConcess:Perso', msg)
                    end
                end)

                end, function() 
                end)
    
                if not RageUI.Visible(f6concess) then
                    f6concess = RMenu:DeleteType("Concessionnaire", true)
        end
    end
end


Keys.Register('F6', 'Concess', 'Ouvrir le menu Concessionnaire', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' then
    	MenuF6Concess()
	end
end)

function CoffreConcess()
	local Coffreconcess = RageUI.CreateMenu("Concessionnaire", "Coffre")
    Coffreconcess:SetRectangleBanner(11,11,11,1)
        RageUI.Visible(Coffreconcess, not RageUI.Visible(Coffreconcess))
            while Coffreconcess do
            Citizen.Wait(0)
            RageUI.IsVisible(Coffreconcess, true, true, true, function()

                RageUI.Separator("↓ Objet ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ConcessRetirerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ConcessDeposerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                end, function()
                end)
            if not RageUI.Visible(Coffreconcess) then
            Coffreconcess = RMenu:DeleteType("Coffreconcess", true)
        end
    end
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' then  
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Concess.pos.coffre.position.x, Concess.pos.coffre.position.y, Concess.pos.coffre.position.z)
            if jobdist <= 10.0 and Concess.marker then
                Timer = 0
                DrawMarker(20, Concess.pos.coffre.position.x, Concess.pos.coffre.position.y, Concess.pos.coffre.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            CoffreConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)

itemstock = {}
function ConcessRetirerobjet()
	local StockConcess = RageUI.CreateMenu("Concessionnaire", "Coffre")
	ESX.TriggerServerCallback('fellow_concess:getStockItems', function(items) 
	itemstock = items
	RageUI.Visible(StockConcess, not RageUI.Visible(StockConcess))
        while StockConcess do
		    Citizen.Wait(0)
		        RageUI.IsVisible(StockConcess, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count ~= 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", '' , 8)
                                    TriggerServerEvent('fellow_concess:getStockItem', v.name, tonumber(count))
                                    ConcessRetirerobjet()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockConcess) then
            StockConcess = RMenu:DeleteType("StockConcess", true)
        end
    end
end)
end

local PlayersItem = {}
function ConcessDeposerobjet()
    local DepositConcess = RageUI.CreateMenu("Concessionnaire", "Coffre")
    ESX.TriggerServerCallback('fellow_concess:getPlayerInventory', function(inventory)
        RageUI.Visible(DepositConcess, not RageUI.Visible(DepositConcess))
    while DepositConcess do
        Citizen.Wait(0)
            RageUI.IsVisible(DepositConcess, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                        RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = KeyboardInput("Combien ?", '' , 8)
                                            TriggerServerEvent('fellow_concess:putStockItems', item.name, tonumber(count))
                                            ConcessDeposerobjet()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(DepositConcess) then
                DepositConcess = RMenu:DeleteType("DepositConcess", true)
            end
        end
    end)
end

function MenuConcess()
    local MConcess = RageUI.CreateMenu("Menu", "Concessionnaire")
    local MConcessSub = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire")
    local MConcessSub1 = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire")
    local MConcessSub2 = RageUI.CreateSubMenu(MConcess, "Menu", "Concessionnaire")
    MConcess:SetRectangleBanner(11,11,11,1)
    MConcessSub:SetRectangleBanner(11,11,11,1)
    MConcessSub1:SetRectangleBanner(11,11,11,1)
    MConcessSub2:SetRectangleBanner(11,11,11,1)
    MConcessSub2.Closed = function()
        supprimervehiculeconcess()
    end
    RageUI.Visible(MConcess, not RageUI.Visible(MConcess))
    while MConcess do
        Wait(0)
            RageUI.IsVisible(MConcess, true, true, true, function()

                RageUI.Separator("~b~"..ESX.PlayerData.job.grade_label.." - "..GetPlayerName(PlayerId()))


                RageUI.Separator("↓ Actions véhicules ↓")

                RageUI.ButtonWithStyle("Liste des véhicules", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                end, MConcessSub)

			end, function()
			end)

            	RageUI.IsVisible(MConcessSub, true, true, true, function()
                
					for i = 1, #fellow_conc.catevehi, 1 do
                        RageUI.ButtonWithStyle("Catégorie - "..fellow_conc.catevehi[i].label, nil, {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nomcategorie = fellow_conc.catevehi[i].label
                                categorievehi = fellow_conc.catevehi[i].name
                                ESX.TriggerServerCallback('fellow_concess:recupererlistevehicule', function(listevehi)
                                        fellow_conc.listecatevehi = listevehi
                                end, categorievehi)
                            end
                        end, MConcessSub1)
                        end
                        end, function()
                        end)

                RageUI.IsVisible(MConcessSub1, true, true, true, function()
			

                    RageUI.Separator("↓ Catégorie : "..nomcategorie.." ↓")
            
                        for i2 = 1, #fellow_conc.listecatevehi, 1 do
                        RageUI.ButtonWithStyle(fellow_conc.listecatevehi[i2].name, "Pour acheter ce véhicule", {RightLabel = fellow_conc.listecatevehi[i2].price.."$"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nomvoiture = fellow_conc.listecatevehi[i2].name
                                prixvoiture = fellow_conc.listecatevehi[i2].price
                                modelevoiture = fellow_conc.listecatevehi[i2].model
                                supprimervehiculeconcess()
                                chargementvoiture(modelevoiture)
            
                                ESX.Game.SpawnVehicle(modelevoiture, {x = Concess.pos.spawnvoiture.position.x, y = Concess.pos.spawnvoiture.position.y, z = Concess.pos.spawnvoiture.position.z}, Concess.pos.spawnvoiture.position.h, function (vehicle)
                                table.insert(derniervoituresorti, vehicle)
                                FreezeEntityPosition(vehicle, true)
                                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                SetModelAsNoLongerNeeded(modelevoiture)
                                end)
                            end
                        end, MConcessSub2)
                        
                        end
                        end, function()
                        end)

                        RageUI.IsVisible(MConcessSub2, true, true, true, function()

                            RageUI.Separator("~r~↓ Vendre le véhicule au joueur le plus proche ↓")

                            RageUI.ButtonWithStyle("Vendre le véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if (Selected) then    
                                        ESX.TriggerServerCallback('fellow_concess:verifsousconcess', function(suffisantsous)
                                        if suffisantsous then
                        
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                        if closestPlayer == -1 or closestDistance > 3.0 then
                                        ESX.ShowNotification('Personne autour')
                                        else
                                        supprimervehiculeconcess()
                                        chargementvoiture(modelevoiture)
                        
                                        ESX.Game.SpawnVehicle(modelevoiture, {x = Concess.pos.spawnvoiture.position.x, y = Concess.pos.spawnvoiture.position.y, z = Concess.pos.spawnvoiture.position.z}, Concess.pos.spawnvoiture.position.h, function (vehicle)
                                        table.insert(sortirvoitureacheter, vehicle)
                                        FreezeEntityPosition(vehicle, true)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        SetModelAsNoLongerNeeded(modelevoiture)
                                        local plaque     = GeneratePlate()
                                        local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                                        vehicleProps.plate = plaque
                                        SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                                        FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)
                        
                                        TriggerServerEvent('fellow_concess:vendrevoiturejoueur', GetPlayerServerId(closestPlayer), vehicleProps, prixvoiture, nomvoiture)
                                        ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(closestPlayer))
                                        TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                        end)
                                        end
                                        else
                                            ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                        end
                        
                                    end, prixvoiture)
                                        end
                                    end)

                                    RageUI.Separator("~b~↓ Acheter le véhicule avec l'argent de la societé ↓")

                                    RageUI.ButtonWithStyle("Acheter le véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                        if (Selected) then   
                                            ESX.TriggerServerCallback('fellow_concess:verifsousconcess', function(suffisantsous)
                                            if suffisantsous then
                                            supprimervehiculeconcess()
                                            chargementvoiture(modelevoiture)
					    ESX.Game.SpawnVehicle(modelevoiture, {x = Concess.pos.spawnvoiture.position.x, y = Concess.pos.spawnvoiture.position.y, z = Concess.pos.spawnvoiture.position.z}, Concess.pos.spawnvoiture.position.h, function (vehicle)                                            table.insert(sortirvoitureacheter, vehicle)
                                            FreezeEntityPosition(vehicle, true)
                                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                            SetModelAsNoLongerNeeded(modelevoiture)
                                            local plaque     = GeneratePlate()
                                            local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                                            vehicleProps.plate = plaque
                                            SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                                            FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)
                        
                                            TriggerServerEvent('shop:vehicule', vehicleProps, prixvoiture, nomvoiture)
                                            ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(PlayerId()))
                                            TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                            end)
                        
                                            else
                                                ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                            end
                            
                                        end, prixvoiture)
                                            end
                                        end)

                        end, function()
                        end)

              if not RageUI.Visible(MConcess) and not RageUI.Visible(MConcessSub) and not RageUI.Visible(MConcessSub1) and not RageUI.Visible(MConcessSub2) then
              MConcess = RMenu:DeleteType("MConcess", true)
        end
    end
end


Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' or ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'cardealer' then  
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Concess.pos.menu.position.x, Concess.pos.menu.position.y, Concess.pos.menu.position.z)
            if jobdist <= 10.0 and Concess.marker then
                Timer = 0
                DrawMarker(20, Concess.pos.menu.position.x, Concess.pos.menu.position.y, Concess.pos.menu.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au menu", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            ESX.TriggerServerCallback('fellow_concess:recuperercategorievehicule', function(catevehi)
                                fellow_conc.catevehi = catevehi
                            end)
                            MenuConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)

function BossConcess()
    local BConcess = RageUI.CreateMenu("Actions Patron", "Concessionnaire")
    BConcess:SetRectangleBanner(11,11,11,1)
  
      RageUI.Visible(BConcess, not RageUI.Visible(BConcess))
  
              while BConcess do
                  Citizen.Wait(0)
                      RageUI.IsVisible(BConcess, true, true, true, function()
  
                      if societycardealermoney ~= nil then
                        RageUI.Info("↓ ~g~Argent Société ~s~↓", {"", societycardealermoney.."$", ""}, {"", "", "","" })
                      end
  
                      RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                          if Selected then
                              local amount = KeyboardInput("Montant", "", 10)
                              amount = tonumber(amount)
                              if amount == nil then
                                  RageUI.Popup({message = "Montant invalide"})
                              else
                                  TriggerServerEvent('five_banque:retraitentreprise', amount, 'cardealer')
                                  RefreshcardealerMoney()
                              end
                          end
                      end)
  
                      RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                          if Selected then
                              local amount = KeyboardInput("Montant", "", 10)
                              amount = tonumber(amount)
                              if amount == nil then
                                  RageUI.Popup({message = "Montant invalide"})
                              else
                                  TriggerServerEvent('five_banque:depotentreprise', amount, 'cardealer')
                                  RefreshcardealerMoney()
                              end
                          end
                      end) 
  
                      RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                          if Selected then
                              MenuBossConcess()
                              RageUI.CloseAll()
                          end
                      end)
                  end, function()
              end)
              if not RageUI.Visible(BConcess) then
              BConcess = RMenu:DeleteType("BConcess", true)
          end
      end
  end

  Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' and ESX.PlayerData.job.grade_name == 'boss' then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Concess.pos.boss.position.x, Concess.pos.boss.position.y, Concess.pos.boss.position.z)
        if dist3 <= 10.0 and Concess.marker then
            Timer = 0
            DrawMarker(20, Concess.pos.boss.position.x, Concess.pos.boss.position.y, Concess.pos.boss.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if dist3 <= 3.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            RefreshcardealerMoney()
                            BossConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function RefreshcardealerMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietycardealerMoney(money)
        end, ESX.PlayerData.job.name)
    end
end

function UpdateSocietycardealerMoney(money)
    societycardealermoney = ESX.Math.GroupDigits(money)
end

function MenuBossConcess()
    TriggerServerCallback('esx_society:getSocietyMoney', 'cardealer')
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function MenuSerrurier()
	local MSerrurier = RageUI.CreateMenu("Menu Serrurier", "Enregistrer des clés")
    MSerrurier:SetRectangleBanner(11,11,11,1)
    ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
        RageUI.Visible(MSerrurier, not RageUI.Visible(MSerrurier))
            while MSerrurier do
            Citizen.Wait(0)
            RageUI.IsVisible(MSerrurier, true, true, true, function()
                RageUI.Separator('~g~Bienvenue '..GetPlayerName(PlayerId()))
                    for i=1, #Vehicles2, 1 do
                        model = Vehicles2[i].model
                        modelname = GetDisplayNameFromVehicleModel(model)
                        Vehicles2[i].model = GetLabelText(modelname)
                    RageUI.ButtonWithStyle(Vehicles2[i].model .. ' [' .. Vehicles2[i].plate .. ']',nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('ddx_vehiclelock:registerkey', Vehicles2[i].plate, 'no')
                            MenuSerrurier()
                        end
                    end)
                end
                end, function()
                end)
            if not RageUI.Visible(MSerrurier) then
            MSerrurier = RMenu:DeleteType("MSerrurier", true)
        end
    end
end)
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Concess.pos.serrurier.position.x, Concess.pos.serrurier.position.y, Concess.pos.serrurier.position.z)
            if jobdist <= 10.0 and Concess.marker then
                Timer = 0
                DrawMarker(20, Concess.pos.serrurier.position.x, Concess.pos.serrurier.position.y, Concess.pos.serrurier.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyer sur ~y~[E]~s~ pour enregistrer des clés.", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            MenuSerrurier()
                            ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
                            end)
                    end   
                end 
        Citizen.Wait(Timer)   
    end
end)

function supprimervehiculeconcess()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end

function chargementvoiture(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName('Chargement du véhicule')
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('ddx_vehiclelock:mykey', function(gotkey)

		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 or locked == 0 then -- if unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				ESX.ShowNotification("Vous avez ~r~fermé~s~ le véhicule.")
			elseif locked == 2 then -- if locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				ESX.ShowNotification("Vous avez ~g~ouvert~s~ le véhicule.")
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustReleased(0,303) then -- Touche K
			OpenCloseVehicle()
		end
	end
end)

Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 303) then -- When you press "U"
             if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
                TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
				StopAnimTask = true
              else
                TriggerEvent("chatMessage", "", { 200, 200, 90 }, "Vous devez être sorti d'un véhicule pour l'utiliser les clés !") -- Shows this message when you are not in a vehicle in the chat
				
             end
        end
    end
end)

Citizen.CreateThread(function()
	RequestIpl('shr_int') -- Load walls and floor

	local interiorID = 7170
	LoadInterior(interiorID)
	EnableInteriorProp(interiorID, 'csr_beforeMission') -- Load large window
	RefreshInterior(interiorID)
end)

local firstplaceshowroomsortie = {}
local secondplaceshowroomsortie = {}
local threeplaceshowroomsortie = {}
local fourplaceshowroomsortie = {}
local fiveplaceshowroomsortie = {}
local sixplaceshowroomsortie = {}

function ShowRoomOpenEnBas()
	local ShowroomMain = RageUI.CreateMenu("ShowRoom", "Concessionnaire")
    ShowroomMain:SetRectangleBanner(11, 11, 11, 1)

        RageUI.Visible(ShowroomMain, not RageUI.Visible(ShowroomMain))
            while ShowroomMain do
            Citizen.Wait(0)
            RageUI.IsVisible(ShowroomMain, true, true, true, function()

                RageUI.Separator("~b~↓ Vitrine ↓")

                if FirstPlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 1", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom1()
                            FirstPlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Emplacement 1", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn1()
                        end
                    end)
                end

                if SecondPlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 2", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom2()
                            SecondPlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Emplacement 2", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn2()
                        end
                    end)
                end

                if ThreePlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 3", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom3()
                            ThreePlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Emplacement 3", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn3()
                        end
                    end)
                end

                if FourPlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 4", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom4()
                            FourPlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Emplacement 4", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn4()
                        end
                    end)
                end

                RageUI.Separator("~b~↓ Promotion ↓")

                if FivePlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 5", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom5()
                            FivePlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Promo", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn5()
                        end
                    end)
                end

                RageUI.Separator("~b~↓ Podium ↓")

                if SixPlaceTake then 
                    RageUI.ButtonWithStyle("~r~Supprimer le 6", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            supprimervehiculeshowroom6()
                            SixPlaceTake = false
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Podium", nil, {RightLabel = "Libre"}, true, function(Hovered, Active, Selected)
                        if Selected then 
                            spawn6()
                        end
                    end)
                end

            end, function()
            end)

            if not RageUI.Visible(ShowroomMain) then
            ShowroomMain = RMenu:DeleteType("ShowroomMain", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' and ESX.PlayerData.job.grade_name == 'boss' then
        local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
        local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Concess.pos.showroom.menu.x, Concess.pos.showroom.menu.y, Concess.pos.showroom.menu.z)
        if jobdist <= 10 then
            Timer = 0
            DrawMarker(6, Concess.pos.showroom.menu.x, Concess.pos.showroom.menu.y, Concess.pos.showroom.menu.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 255, 0, 0, 200)
            end
            if jobdist <= 3.0 then
                Timer = 0   
                RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Showroom", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            ShowRoomOpenEnBas()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function supprimervehiculeshowroom1()
	while #firstplaceshowroomsortie > 0 do
		local vehicle = firstplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(firstplaceshowroomsortie, 1)
	end
end

function supprimervehiculeshowroom2()
	while #secondplaceshowroomsortie > 0 do
        local vehiclede = secondplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehiclede)
		table.remove(secondplaceshowroomsortie, 1)
	end
end

function supprimervehiculeshowroom3()
	while #threeplaceshowroomsortie > 0 do
        local vehicletr = threeplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehicletr)
		table.remove(threeplaceshowroomsortie, 1)
	end
end

function supprimervehiculeshowroom4()
	while #fourplaceshowroomsortie > 0 do
        local vehiclequ = fourplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehiclequ)
		table.remove(fourplaceshowroomsortie, 1)
	end
end

function supprimervehiculeshowroom5()
	while #fiveplaceshowroomsortie > 0 do
        local vehiclefi = fiveplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehiclefi)
		table.remove(fiveplaceshowroomsortie, 1)
	end
end

function supprimervehiculeshowroom6()
	while #sixplaceshowroomsortie > 0 do
        local vehiclesi = sixplaceshowroomsortie[1]

		ESX.Game.DeleteVehicle(vehiclesi)
		table.remove(sixplaceshowroomsortie, 1)
	end
end

function spawn1()
    local modele = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local car = GetHashKey(modele)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local vehicle = CreateVehicle(car, Concess.pos.showroom.show1.x, Concess.pos.showroom.show1.y, Concess.pos.showroom.show1.z, Concess.pos.showroom.show1.h, true)
    FreezeEntityPosition(vehicle, true)
    SetVehicleDoorsLocked(vehicle, 4)
    SetEntityAsMissionEntity(vehicle, true, true) 
    table.insert(firstplaceshowroomsortie, vehicle)
    FirstPlaceTake = true
end

function spawn2()
    local modelede = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local carde = GetHashKey(modelede)
    RequestModel(carde)
    while not HasModelLoaded(carde) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local vehiclede = CreateVehicle(carde, Concess.pos.showroom.show2.x, Concess.pos.showroom.show2.y, Concess.pos.showroom.show2.z, Concess.pos.showroom.show2.h, true)
    FreezeEntityPosition(vehiclede, true)
    SetVehicleDoorsLocked(vehiclede, 4)
    SetEntityAsMissionEntity(vehiclede, true, true) 
    table.insert(secondplaceshowroomsortie, vehiclede)
    SecondPlaceTake = true
end

function spawn3()
    local modeletrois = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local cartr = GetHashKey(modeletrois)
    RequestModel(cartr)
    while not HasModelLoaded(cartr) do
        RequestModel(cartr)
        Citizen.Wait(0)
    end

    local vehicletr = CreateVehicle(cartr, Concess.pos.showroom.show3.x, Concess.pos.showroom.show3.y, Concess.pos.showroom.show3.z, Concess.pos.showroom.show3.h, true)
    FreezeEntityPosition(vehicletr, true)
    SetVehicleDoorsLocked(vehicletr, 4)
    SetEntityAsMissionEntity(vehicletr, true, true) 
    table.insert(threeplaceshowroomsortie, vehicletr)
    ThreePlaceTake = true
end

function spawn4()
    local modelequatre = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local carqu = GetHashKey(modelequatre)
    RequestModel(carqu)
    while not HasModelLoaded(carqu) do
        RequestModel(carqu)
        Citizen.Wait(0)
    end

    local vehiclequ = CreateVehicle(carqu, Concess.pos.showroom.show4.x, Concess.pos.showroom.show4.y, Concess.pos.showroom.show4.z, Concess.pos.showroom.show4.h, true)
    FreezeEntityPosition(vehiclequ, true)
    SetVehicleDoorsLocked(vehiclequ, 4)
    SetEntityAsMissionEntity(vehiclequ, true, true) 
    table.insert(fourplaceshowroomsortie, vehiclequ)
    FourPlaceTake = true
end

function spawn5()
    local modelecinq = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local carfi = GetHashKey(modelecinq)
    RequestModel(carfi)
    while not HasModelLoaded(carfi) do
        RequestModel(carfi)
        Citizen.Wait(0)
    end

    local vehiclefi = CreateVehicle(carfi, Concess.pos.showroom.show5.x, Concess.pos.showroom.show5.y, Concess.pos.showroom.show5.z, Concess.pos.showroom.show5.h, true)
    FreezeEntityPosition(vehiclefi, true)
    SetVehicleDoorsLocked(vehiclefi, 4)
    SetEntityAsMissionEntity(vehiclefi, true, true) 
    table.insert(fiveplaceshowroomsortie, vehiclefi)
    FivePlaceTake = true
end

function spawn6()
    local modelesix = KeyboardInput("Entrez le modèle", "", 100)
    RageUI.Popup({ message = "<C>Chargement du véhicule...", time_display = 1 })
    Wait(500)
    local carsi = GetHashKey(modelesix)
    RequestModel(carsi)
    while not HasModelLoaded(carsi) do
        RequestModel(carsi)
        Citizen.Wait(0)
    end

    local vehiclesi = CreateVehicle(carsi, Concess.pos.showroom.show6.x, Concess.pos.showroom.show6.y, Concess.pos.showroom.show6.z, Concess.pos.showroom.show6.h, true)
    FreezeEntityPosition(vehiclesi, true)
    SetVehicleDoorsLocked(vehiclesi, 4)
    SetEntityAsMissionEntity(vehiclesi, true, true) 
    table.insert(sixplaceshowroomsortie, vehiclesi)
    SixPlaceTake = true
end

function MenuF2Concess()
    local f2concess = RageUI.CreateMenu("Gestion Clé", "Interaction")
    local f2concessSub = RageUI.CreateSubMenu(f2concess, "Gestion Clé", "Informations")
    f2concess:SetRectangleBanner(11,11,11,1)
    f2concessSub:SetRectangleBanner(11,11,11,1)
    ESX.TriggerServerCallback('iConcess:getPlayerVehicles', function(listeKeys)
        playerKeys = listeKeys
    end)
    RageUI.Visible(f2concess, not RageUI.Visible(f2concess))
    while f2concess do
        Citizen.Wait(0)
        RageUI.IsVisible(f2concess, true, true, true, function()
            if #playerKeys > 0 then
                RageUI.Separator("↓ ~g~Vos Clés ~s~↓")
                RageUI.Separator('')
                for i2 = 1, #playerKeys, 1 do
                    RageUI.ButtonWithStyle("~r~→ ~s~"..playerKeys[i2].value, nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            iConcess.thePlate = playerKeys[i2].value
                            iConcess.theId = playerKeys[i2].id

                        end
                    end, f2concessSub)
                end
            else
                RageUI.Separator(" ")
                RageUI.Separator("~r~Aucun Véhicule")
                RageUI.Separator(" ")
            end
        end, function()
        end)

        RageUI.IsVisible(f2concessSub, true, true, true, function()
            RageUI.Separator( "↓ ~b~plaque : "..iConcess.thePlate.."~s~ ↓")
            RageUI.Separator( "↓ ~r~Numéro : "..iConcess.theId.."~s~ ↓")
            RageUI.Separator("")
            RageUI.ButtonWithStyle("~r~→ ~s~Préter les clés",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if Selected then
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        TriggerServerEvent("esx_vehiclelock:preterkey", GetPlayerServerId(closestPlayer), v.value)
                        RageUI.GoBack()
                    else
                        ESX.ShowNotification("Aucun ~b~individus~s~ près de vous.")
                    end
                end
            end)
            RageUI.ButtonWithStyle("~r~→ ~s~Détruire les clés",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("rPersonalmenu:DeleteKey", iConcess.theId)
                    ESX.ShowNotification("- Clés ~r~détruite~s~\n- Plaque : ~y~" ..iConcess.thePlate)
                end
            end)
        end, function()
        end)

        if not RageUI.Visible(f2concess) and not RageUI.Visible(f2concessSub) then
        f2concess = RMenu:DeleteType("f2concess", true)
        end
    end
end

Keys.Register('F2', 'Concess2', 'Ouvrir le menu Gestion des clé', function()
    MenuF2Concess()
end)
