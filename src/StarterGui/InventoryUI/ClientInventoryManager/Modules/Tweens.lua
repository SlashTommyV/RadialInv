local TweenService = game:GetService("TweenService")

local Tweens = {}
Tweens.__index = Tweens

-- // Setup tweens for scripts // --
function Tweens.new(Target, tweenInfo: TweenInfo, tweenProperties: {})
	local self = setmetatable({}, Tweens)

	self.Target = Target
	self.tweenInfo = tweenInfo
	self.properties = tweenProperties
	self.tween = TweenService:Create(Target, tweenInfo, tweenProperties)

	return self
end

-- // Play Tween
function Tweens:Play()
	if self.tween then
		self.tween:Play()
	end
end

-- // Play Tween and wait for its completion
function Tweens:PlayAndWait()
	if self.tween then
		self.tween:Play()
		self.tween.Completed:Wait()
	end
end

-- // Play Tween and run a function after its completed
function Tweens:OnCompleted(callback)
	if self.tween then
		self.tween.Completed:Once(callback)
	end
end

return Tweens
