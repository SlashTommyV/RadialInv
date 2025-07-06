local Tool = script.Parent

function OnButton1Down(mouse)
	if Tool.Enabled then
		mouse.Icon = 'http://www.roblox.com/asset/?id=54019936'
	else
		mouse.Icon = 'http://www.roblox.com/asset/?id=54019936'
	end
	while not Tool.Enabled do
		Tool.Changed:wait()
	end
	if Tool.Enabled then
		mouse.Icon = 'http://www.roblox.com/asset/?id=54019936'
	end
end

function OnEquipped(mouse)
	if mouse == nil then
		return 
	end

	mouse.Icon = 'http://www.roblox.com/asset/?id=54019936'
	mouse.Button1Down:connect(function() OnButton1Down(mouse) end)
end


Tool.Equipped:connect(OnEquipped)
