ENT.Base = "base_ai"
ENT.Type = "ai"
   
ENT.PrintName = "Вертолет"
ENT.Category	= "Breach"
  
ENT.AutomaticFrameAdvance = true
   
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
  self.AutomaticFrameAdvance = bUsingAnim
end  