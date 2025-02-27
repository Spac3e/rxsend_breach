include('shared.lua')

ENT.Model = Model("models/shaky/breach/gift.mdl")

function ENT:Initialize()

end

function ENT:OnRemove()
	self:StopParticles()
end

function ENT:Draw()
	if !self.Fire_EFFECT then
		local offset_pos = Vector(math.Rand(-7, 7), math.Rand(-7, 7), 0)

		self.Fire_EFFECT = true
		ParticleEffect("fire_small_01", self:GetPos()+offset_pos, Angle(0, math.Rand(0,360), 0), self)
	end
end