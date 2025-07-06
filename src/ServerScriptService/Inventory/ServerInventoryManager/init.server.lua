-- // Services // --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players")

local InventoryEvents = ReplicatedStorage.InventoryEvents

local SyncInventory = InventoryEvents.SyncInventory
local EquipEvent = InventoryEvents.EquipItem
local UpdateClient = InventoryEvents.UpdateClient

-- // Variables // --

local playerInventories = {}

-- // Modules // --

local ServerInventoryHandler = require(script.Modules.ServerInventoryHandler)
local Maid = require(ReplicatedStorage.Modules.Shared.Maid).New()

-- // FUNCTIONS // --

-- // Player Joins, loads inventory to server
Player.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()

	-- // Create Inventory
	local playerInventory = ServerInventoryHandler.CreateInventory(player)
	playerInventory:LoadBackpack()

	playerInventories[player.Name] = playerInventory

	-- // Listeners
	Maid:GiveTask(player.Backpack.ChildAdded:Connect(function(item)
		if not playerInventories[player.Name]:GetSlotByItem(item) then
			playerInventories[player.Name]:AddItem(item)
		end
	end))

	Maid:GiveTask(player.Backpack.ChildRemoved:Connect(function(item)
		task.defer(function()
			if item.Parent == player.Character then
				return
			end

			if playerInventories[player.Name]:GetSlotByItem(item) then
				playerInventories[player.Name]:RemoveItem(item)
				local updatedInventory = playerInventories[player.Name].SlotData

				UpdateClient:FireClient(player, updatedInventory)
			end
		end)
	end))

	Maid:GiveTask(player.Character.ChildAdded:Connect(function(item)
		if not playerInventories[player.Name]:GetSlotByItem(item) then
			item.Parent = player.Backpack
		end
	end))

	Maid:GiveTask(player.Character.ChildRemoved:Connect(function(item)
		task.defer(function()
			if item.Parent == player.Backpack then
				return
			end
			warn("Destroying " .. item.Name)

			if playerInventories[player.Name]:GetSlotByItem(item) then
				playerInventories[player.Name]:RemoveItem(item)
				local updatedInventory = playerInventories[player.Name].SlotData

				UpdateClient:FireClient(player, updatedInventory)
			end
		end)
	end))
end)

Player.PlayerRemoving:Connect(function()
	Maid:CleanUp()
end)

-- // LISTENER

-- // Syncs inventory with client
SyncInventory.OnServerInvoke = function(player: Player)
	return playerInventories[player.Name]["SlotData"]
end

EquipEvent.OnServerEvent:Connect(function(player: Player, itemName)
	if itemName then
		playerInventories[player.Name]:EquipItem(itemName)
	else
		playerInventories[player.Name]:UnequipItem()
	end
end)
