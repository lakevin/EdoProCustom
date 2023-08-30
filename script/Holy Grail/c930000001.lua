--The Holy Grail
local SET_HOLYGRAIL=0xAD9C
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_GRAIL)
	c:SetUniqueOnField(1,0,id)
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
    -- (2) negate effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.unacon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.unaval)
	c:RegisterEffect(e3)
	-- (3) Can treat "Holy Grail" Spell cards as Link Material
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_EXTRA_MATERIAL)
	e4a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e4a:SetRange(LOCATION_SZONE)
	e4a:SetTargetRange(1,0)
	e4a:SetCountLimit(1,id)
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
	e4c:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e4c)
end
s.listed_series={SET_HOLYGRAIL}

-- (1)
function s.cfilter(c)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(COUNTER_GRAIL,ct,true)
	end
end

-- (2)
function s.unafilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_HOLYGRAIL)
end
function s.unacon(e)
	return e:GetHandler():GetCounter(COUNTER_GRAIL)<=3
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return not tc:IsAttribute(ATTRIBUTE_LIGHT) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and te:GetActivateLocation()==LOCATION_MZONE
end

-- (3)
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