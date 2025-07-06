local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // EVENTS // --

local InventoryEvents = ReplicatedStorage.InventoryEvents

local UpdateClient = InventoryEvents.UpdateClient

--// INSTANCES //--

local BackpackUI = script.Parent
local InvFrame = BackpackUI.InvFrame

local currentCam = workspace.CurrentCamera

--// VARIABLES //--

local playerInput = "PC"
local Debounce = false

--// MODULES //--

local InventoryHandler = require(script.Modules.InventoryHandler)
local TweenHandler = require(script.Modules.Tweens)
local InventorySettings = require(ReplicatedStorage.Modules.Shared.Settings)

--// TWEENINFO //--

local tweenInfoFastOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- // FUNCTIONS // --

local function getPrefferedInput()
	local preferredInput = UIS.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		playerInput = "Mobile"
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		playerInput = "Console"
	elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		playerInput = "PC"
	end
end

-- // Open System // --
UIS.InputBegan:Connect(function(input, GPE)
	if GPE then
		return
	end

	if input.KeyCode == InventorySettings[playerInput].ToggleInventory then
		if BackpackUI.Enabled then
			BackpackUI.Enabled = false

			TweenHandler.new(Lighting.Blur, tweenInfoFastOut, { Size = 0 }):Play()
			TweenHandler.new(currentCam, tweenInfoFastOut, { FieldOfView = 70 }):Play()

			InventoryHandler:ClearConnections()
		else
			InventoryHandler:SetupUI(InvFrame)

			BackpackUI.Enabled = true
			TweenHandler.new(Lighting.Blur, tweenInfoFastOut, { Size = 16 }):Play()
			TweenHandler.new(currentCam, tweenInfoFastOut, { FieldOfView = 60 }):Play()
		end
	elseif input.KeyCode == InventorySettings[playerInput].UnEquipSlot then
		InventoryHandler:UnEquipSlot(InvFrame)
	end

	for i, key in ipairs(InventorySettings[playerInput].EquipSlots) do
		if input.KeyCode == key and not Debounce then
			Debounce = true
			InventoryHandler:EquipSlot(i, InvFrame)
			task.wait(0.1)
			Debounce = false
		end
	end
end)

-- Gets preffered input on change
UIS:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	getPrefferedInput()
end)

getPrefferedInput()

-- // Listener

UpdateClient.OnClientEvent:Connect(function(newInventoryData)
	InventoryHandler:UpdateInventory(newInventoryData, InvFrame)
end)
