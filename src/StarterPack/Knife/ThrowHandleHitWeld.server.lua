arrow = script.Parent


local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset?id=153647563"
HitSound.Parent = arrow
HitSound.Volume = .5


function stick(hit)
	
	local AV = arrow:findFirstChild("BodyForce")
	local FO = arrow:findFirstChild("BodyAngularVelocity")
	
	if AV ~= nil then AV:remove() end
	if FO ~= nil then FO:remove() end
	
	-- joint myself to the thing i hit

	local weld = Instance.new("Weld")

	weld.Name = "PieWeld"
	weld.Part0 = arrow
	weld.Part1 = hit
	
	local backupweld = Instance.new("Weld")

	backupweld.Name = "PieWeldBackup"
	backupweld.Part0 = arrow
	backupweld.Part1 = hit

	-- correction term to account for average skew between physics update and heartbeat
	local HitPos = arrow.Position --+ (-arrow.Velocity * (1/60)) --+ (arrow.CFrame.lookVector * .5)

	local CJ = CFrame.new(HitPos)
	local C0 = arrow.CFrame:inverse() *CJ
	local C1 = hit.CFrame:inverse() * CJ
	
	weld.C0 = C0
	weld.C1 = C1

	weld.Parent = arrow
	
	backupweld.C0 = C0
	backupweld.C1 = C1

	backupweld.Parent = arrow

end


function onTouched(hit)

	connection:disconnect()

	stick(hit)
	HitSound:Play()

	
end



connection = arrow.Touched:connect(onTouched)



wait(2)

if (arrow:FindFirstChild("PieWeld") ~= nil) then
	arrow.PieWeld:Remove()
end

wait(8)

arrow.Parent = nil