local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer

-- // Events

local InventoryEvents = ReplicatedStorage.InventoryEvents

local AddItem = InventoryEvents.AddItem
local SyncInventory = InventoryEvents.SyncInventory
local EquipItem = InventoryEvents.EquipItem

-- // Variables // --

local Inventory = {}
local InventoryData = nil

local CurrentHovered = nil
local CurrentSelected = nil
local CurrentEquipped = nil
local LastSelected = nil

local MaxSlots = 4

-- // MODULES // --

local Maid = require(ReplicatedStorage.Modules.Shared.Maid).New()
local TweenHandler = require(script.Parent.Tweens)

--// TWEENINFO //--

local tweenInfoFastOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- // Sets up UI for Inventory
function Inventory:SetupUI(InvFrame: Frame, SlotSelector: Frame): ()	
	InventoryData = SyncInventory:InvokeServer()
	
	for i = 1, MaxSlots do
		local slotUI: ImageButton = InvFrame:FindFirstChild("Slot"..i)
		slotUI.ImageColor3 = Color3.fromRGB(0, 0, 0)
		
		if slotUI then
			local slotData = InventoryData[i]
			local slotImage = InvFrame.SlotImages:FindFirstChild("ItemImage"..i)
			
			Inventory._UpdateUIData(i, slotData, InvFrame)
			
			-- // Functionality // --
			
			-- // SLOT FUNCTIONS
			Maid:GiveTask(slotUI.MouseEnter:Connect(function()
				if CurrentHovered and CurrentHovered.Name == "EmptySlotBTN" then return end

				CurrentHovered = slotUI

				if slotImage.Image == "http://www.roblox.com/asset?id=73945837543192" then
					TweenHandler.new(slotImage, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(0, 0, 0)}):Play()
				end

				TweenHandler.new(slotUI, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end))

			Maid:GiveTask(slotUI.MouseLeave:Connect(function()
				if slotImage.Image == "http://www.roblox.com/asset?id=73945837543192" then
					TweenHandler.new(slotImage, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end

				TweenHandler.new(slotUI, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(0, 0, 0)}):Play()
			end))

			-- // Functionality
			Maid:GiveTask(slotUI.MouseButton1Click:Connect(function()
				-- // UI

				Inventory:EquipSlot(i, InvFrame)
			end))
		end
	end
	
	-- // EMPTY FUNCTIONS
	Maid:GiveTask(InvFrame.EmptySlot.EmptySlotBTN.MouseEnter:Connect(function()
		CurrentHovered = InvFrame.EmptySlot.EmptySlotBTN
		TweenHandler.new(InvFrame.EmptySlot, tweenInfoFastOut, {Size = UDim2.new(0.233, 0, 0.235, 0), Position = UDim2.new(0.5, 0, 0.503, 0)}):Play()
	end))
		
	Maid:GiveTask(InvFrame.EmptySlot.EmptySlotBTN.MouseLeave:Connect(function()
		CurrentHovered = nil
		TweenHandler.new(InvFrame.EmptySlot, tweenInfoFastOut, {Size = UDim2.new(0.206, 0, 0.206, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
	end))
		
		-- // Functionality
	Maid:GiveTask(InvFrame.EmptySlot.EmptySlotBTN.MouseButton1Click:Connect(function()
		Inventory:UnEquipSlot(InvFrame)
	end))
end


-- // Updates Slot Data
function Inventory._UpdateUIData(ID: number, slotData: {}, InvFrame: Frame)
	local slotUI: ImageButton = InvFrame:FindFirstChild("Slot"..ID)
	local slotImage = InvFrame.SlotImages:FindFirstChild("ItemImage"..ID)

	slotUI:SetAttribute("SlotID", ID)
	slotUI:SetAttribute("ItemName", slotData and slotData.ItemName or nil)

	slotImage.Image = slotData and slotData.ItemThumbnail or ""
	InvFrame.ItemName.Text = CurrentEquipped or "Empty"
end


-- // Equips slot based on its ID
function Inventory:EquipSlot(slotId: number, InvFrame: Frame): ()
	local slotUI: ImageButton = InvFrame:FindFirstChild("Slot"..slotId)
	local slotData = InventoryData[slotId]
	
	if not CurrentSelected then
		TweenHandler.new(InvFrame.SlotSelected, tweenInfoFastOut, {ImageTransparency = 0.5}):Play()
		TweenHandler.new(InvFrame.EmptySlot.EmptySlotBTN, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TweenHandler.new(InvFrame.EmptySlot, tweenInfoFastOut, {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
	end

	if CurrentSelected and CurrentSelected.Name == slotUI.Name then return end

	LastSelected = CurrentSelected
	CurrentSelected = slotUI
	CurrentEquipped = slotUI:GetAttribute("ItemName")

	local current = InvFrame.SlotSelected.Rotation
	local target = slotUI.Rotation

	local diff = (target - current + 180) % 360 - 180
	local adjusted = current + diff

	TweenHandler.new(InvFrame.SlotSelected, tweenInfoFastOut, {Rotation = adjusted}):Play()

	-- // Get to player (EQUIP)

	EquipItem:FireServer(slotData and slotData.ItemName or nil)
	InvFrame.ItemName.Text = slotData and slotData.ItemName or "Empty"
end


function Inventory:UnEquipSlot(InvFrame: Frame)
	if CurrentSelected then
		TweenHandler.new(InvFrame.SlotSelected, tweenInfoFastOut, {ImageTransparency = 1}):Play()
		TweenHandler.new(CurrentSelected, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.5}):Play()
		CurrentSelected = nil
		CurrentEquipped = nil
	end

	TweenHandler.new(InvFrame.EmptySlot.EmptySlotBTN, tweenInfoFastOut, {ImageColor3 = Color3.fromRGB(0, 0, 0)}):Play()
	TweenHandler.new(InvFrame.EmptySlot, tweenInfoFastOut, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()

	-- // Functionality
	EquipItem:FireServer(nil)
	InvFrame.ItemName.Text = "Empty"
end


function Inventory:UpdateInventory(newInventoryData: {}, InvFrame, TweenHandler): ()
	InventoryData = newInventoryData

	Maid:CleanUp()
	Inventory:SetupUI(InvFrame, InvFrame.SlotSelector, TweenHandler)
end


-- // Clears RBXScriptConnections and disconnects them
function Inventory:ClearConnections(): ()
	Maid:CleanUp()
end

return Inventory



--[[
⬜⬜⬜⬜⬜⬜⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜⬜⬜
⬜⬜⬜⬜⬜⬛⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬛⬜⬜⬜⬜⬜
⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜
⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬛⬛⬛⬜⬜⬜⬜⬜⬛⬛⬛⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬛⬛⬛⬜⬜⬜⬜⬜⬛⬛⬛⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬛⬛⬛⬜⬜⬛⬜⬜⬛⬛⬛⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬛⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜
⬜⬜⬜⬛⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬛⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜
⬜⬜⬜⬜⬛⬛⬜⬜⬛⬛⬛⬛⬛⬛⬛⬜⬜⬛⬛⬜⬜⬜⬜
⬜⬜⬜⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜⬜⬜⬛⬛⬛⬛⬛⬜⬜⬜
⬜⬜⬛🟦⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🟦⬛⬜⬜
⬜⬛⬛🟦⬛🏻🏻⬛⬜⬜⬜⬛⬜⬜⬜⬛🏻🏻⬛🟦⬛⬛⬜
⬜⬛🟦🟦🟦⬛🏻🏻⬛⬛⬛⬜⬛⬛⬛🏻🏻⬛🟦🟦🟦⬛⬜
⬛🟦🟦⬛⬛🟦⬛⬛⬛⬜⬜⬛⬜⬜⬛⬛⬛🟦⬛⬛🟦🟦⬛
⬛🟦🟦🟦🟦⬛🟦🟦⬛⬜⬜⬜⬜⬜⬛🟦🟦⬛🟦🟦🟦🟦⬛
⬛🟦🟦🟦🟦🟦⬛🟦⬛⬛⬜⬜⬜⬛⬛🟦⬛🟦🟦🟦🟦🟦⬛
⬜⬛🟦🟦🟦⬛🟦🟦⬛⬜⬜⬜⬜⬜⬛🟦🟦⬛🟦🟦🟦⬛⬜
⬜⬜⬛⬛🟦⬛🟦🟦⬛⬛⬛⬛⬛⬛⬛🟦🟦⬛🟦⬛⬛⬜⬜
⬜⬜⬜⬛⬛⬛🟦🟦⬛⬛⬛⬛⬛⬛⬛🟦🟦⬛⬛⬛⬜⬜⬜
⬜⬜⬜⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜
⬜⬜⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜
⬜⬜⬜⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜
⬜⬜⬜⬜⬛⬛⬛⬛⬛⬛⬜⬜⬜⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜
⬜⬜⬛⬛⬛⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬛⬛⬛⬜⬜
⬜⬜⬛⬜⬜⬜⬜⬜⬛⬛⬜⬜⬜⬛⬛⬜⬜⬜⬜⬜⬛⬜⬜
⬜⬜⬜⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜⬜⬜⬛⬛⬛⬛⬛⬜⬜⬜
]]