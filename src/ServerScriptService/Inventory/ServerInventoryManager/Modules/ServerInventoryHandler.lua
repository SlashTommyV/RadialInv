local ServerInventory = {}
ServerInventory.__index = ServerInventory

-- // Creates player inventory on the server
function ServerInventory.CreateInventory(player: Player): ()
	local self = setmetatable({}, ServerInventory)

	self.Owner = player
	self.SlotData = {}

	self.MaxSlots = 4
	self.CurrentEquipped = nil

	return self
end

-- // Adds item to players inventory
function ServerInventory:AddItem(item: Tool): ()
	local slotId = nil
	local itemImage
	
	for i = 1, self.MaxSlots do
		if not self.SlotData[i] or next(self.SlotData[i]) == nil then
			slotId = i
			break
		end
	end

	if not slotId then
		return warn("No available slots")
	end

	if item.TextureId ~= "" then
		itemImage = item.TextureId
	else
		itemImage = "http://www.roblox.com/asset?id=73945837543192"
	end
	
	local ItemData = {
		ItemName = item.Name,
		ItemThumbnail = itemImage,
		AssignedId = slotId
	}
	
	self.SlotData[slotId] = ItemData
end

-- // Removes item from players inventory
function ServerInventory:RemoveItem(item: Tool): ()
	local slotToRemove = self:GetSlotByItem(item)
	
	if not slotToRemove then return end
	self.SlotData[slotToRemove.AssignedId] = nil
	self.CurrentEquipped = nil
	print(self.SlotData)
end

-- // Equips player item
function ServerInventory:EquipItem(item: string): ()
	if self.CurrentEquipped and self.CurrentEquipped.ItemName == item then return end
	
	local slotData = self:GetSlotByItem(item)
	local itemToEquip = self.Owner.Backpack:FindFirstChild(item)
	
	if slotData and itemToEquip then
		if self.CurrentEquipped then
			self:UnequipItem(self.CurrentEquipped.ItemName)
		end
		
		self.CurrentEquipped = slotData
		itemToEquip.Parent = self.Owner.Character
	end
end

-- // Unequips item
function ServerInventory:UnequipItem(item: string): ()
	if not self.CurrentEquipped then return end
	
	local itemToHide = self.Owner.Character:FindFirstChild(self.CurrentEquipped.ItemName)
	itemToHide.Parent = self.Owner.Backpack
	self.CurrentEquipped = nil
end

-- // Returns slot by item / Verifies if item exists
function ServerInventory:GetSlotByItem(item): ()
	for slot, data in pairs(self.SlotData) do
		if data.ItemName == item.Name then -- Tool
			return self.SlotData[slot]
		elseif data.ItemName == item then -- String
			return self.SlotData[slot]
		end
	end
	
	return false
end

-- // Loads player backpack from server
function ServerInventory:LoadBackpack(): ()
	for _, item in pairs(self.Owner.Backpack:GetChildren()) do
		if not item:IsA("Tool") then return end

		self:AddItem(item)

		if not self.Owner.Backpack:FindFirstChild(item.Name) then
			self:RemoveItem(item)
		end
	end
end

return ServerInventory
