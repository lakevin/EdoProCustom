--Kniguard Warflame
local SET_KNIGUARD=0xB1F3
local SET_WARFLAME=0xBAA1
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GRAIL)
	-- attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e0)
	-- (1) Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- (3) add to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KNIGUARD,SET_WARFLAME}

-- (1)
function s.attfilter(c)
	return c:IsRace(RACE_WARRIOR) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_FIRE))
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.attfilter,1,true,1,true,c,c:GetControler(),nil,false,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.attfilter,1,1,true,true,true,c,nil,nil,false,e:GetHandler())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g<1 then return end
	if Duel.Release(g,REASON_COST)~=0 then
		local sc=g:GetFirst()
		if sc and sc:IsAttribute(ATTRIBUTE_FIRE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetCondition(s.tgcon)
			c:RegisterEffect(e1)
		end
		if sc and sc:IsAttribute(ATTRIBUTE_LIGHT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_KNIGUARD))
			e2:SetValue(500)
			e2:SetCondition(s.tgcon)
			c:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e3)
		end
		g:DeleteGroup()
	end
end
	-- LIGHT and FIRE
function s.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) 
		and e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end

-- (2)
function s.thfilter(c,e)
	return (c:IsSetCard(SET_KNIGUARD) or c:IsSetCard(SET_WARFLAME)) and c:IsAbleToHand() 
		and c:IsMonster() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end