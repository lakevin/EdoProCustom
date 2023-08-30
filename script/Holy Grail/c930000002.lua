--The Unholy Grail
local SET_HOLYGRAIL=0xAD9C
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_GRAIL)
	c:SetUniqueOnField(1,0,id)
	--add code
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(930000001)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    -- (1) add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ADD_COUNTER+COUNTER_GRAIL)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- (2) Link Summon 1 "Holy Grail" Link monster
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_EXTRA_MATERIAL)
	e4a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e4a:SetRange(LOCATION_SZONE)
	e4a:SetTargetRange(1,0)
	e4a:SetCountLimit(1,{id,1})
	e4a:SetOperation(aux.TRUE)
	e4a:SetValue(s.extraval)
	c:RegisterEffect(e4a)
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_SINGLE)
	e4b:SetCode(EFFECT_ADD_TYPE)
	e4b:SetRange(LOCATION_SZONE)
	e4b:SetTargetRange(LOCATION_SZONE,0)
	e4b:SetCondition(s.addtypecon)
	e4b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e4b:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e4b)
	local e4c=Effect.CreateEffect(c)
	e4c:SetType(EFFECT_TYPE_SINGLE)
	e4c:SetCode(EFFECT_ADD_ATTRIBUTE)
    e4c:SetRange(LOCATION_SZONE)
	e4c:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e4c)
end
s.listed_series={SET_HOLYGRAIL}
s.listed_names={c930000001}

-- (1)
function s.cfilter(c)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:FilterCount(s.cfilter,nil)
	if ct>0 then
		c:AddCounter(COUNTER_GRAIL,ct,true)
	end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetCounter(COUNTER_GRAIL)
	-- 1 or more grail counter
	if cg>=1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_SZONE)
		e1:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetTarget(s.tg)
		e1:SetValue(ATTRIBUTE_DARK)
		Duel.RegisterEffect(e1,tp)
	end
	-- 3 or more grail counter
	if cg>=3 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetTargetRange(0,LOCATION_ONFIELD)
		e2:SetTarget(s.distg)
		e2:SetLabel(c:GetSequence())
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVING)
		e4:SetOperation(s.disop)
		e4:SetLabel(c:GetSequence())
		Duel.RegisterEffect(e4,tp)
	end
	-- 5 or more grail counter
	if cg>=5 then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetCode(EFFECT_CANNOT_ACTIVATE)
		e5:SetTargetRange(0,1)
		e5:SetValue(s.aclimit)
		Duel.RegisterEffect(e5,tp)
	end
end
-- 1 or more grail counter
function s.tg(e,c)
	if not c:IsSetCard(SET_HOLYGRAIL) then return false end
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end
-- 3 or more grail counter
function s.distg(e,c)
	local seq=e:GetLabel()
	if c:IsControler(1-e:GetHandlerPlayer()) then seq=4-seq end
	return c:IsSpellTrap() and seq==c:GetSequence() and c:GetFlagEffect(id)==0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local cseq=e:GetLabel()
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	local rc=re:GetHandler()
	if rc:GetFlagEffect(id)>0 then return end
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if loc&LOCATION_SZONE==0 or rc:IsControler(1-p) then
			if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
				seq=rc:GetSequence()
			else
				seq=rc:GetPreviousSequence()
			end
		end
		if loc&LOCATION_SZONE==0 then
			local val=re:GetValue()
			if val==nil or val==LOCATION_SZONE or val==LOCATION_FZONE or val==LOCATION_PZONE then
				loc=LOCATION_SZONE
			end
		end
	end
	if ep~=e:GetHandlerPlayer() then cseq=4-cseq end
	if loc&LOCATION_SZONE~=0 and cseq==seq then
		Duel.NegateEffect(ev)
	end
end
-- 5 or more grail counter
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end

-- (2)
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_HOLYGRAIL) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc:IsSetCard(SET_HOLYGRAIL)) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end