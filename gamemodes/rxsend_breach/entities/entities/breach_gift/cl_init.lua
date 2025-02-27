include('shared.lua')

ENT.Model = Model("models/shaky/breach/gift.mdl")

function ENT:Initialize()

	self.csMdl = ClientsideModel(self.Model)

	self.csMdl:SetRenderMode(RENDERMODE_TRANSCOLOR)

end

function ENT:OnRemove()
	if IsValid(self.csMdl) then self.csMdl:Remove() end
end

function ENT:Draw()

	local ang = (SysTime() * 25) % 360
	local pos = (math.sin(SysTime()*2)*2)

	self.csMdl:SetColor(self:GetColor())

	self.csMdl:SetAngles(Angle(0,ang,0))
	self.csMdl:SetPos(self:GetPos() + Vector(0,0,pos+2))

end