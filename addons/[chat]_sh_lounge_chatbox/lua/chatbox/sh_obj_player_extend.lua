local meta = FindMetaTable("Player")

-- who overrides this?
meta.IsTyping = meta.OldIsTyping or meta.IsTyping

function meta:IsTyping()
	return self:GetNWBool("LOUNGE_CHAT.Typing")
end