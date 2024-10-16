--Kniguard Shadowblade
local SET_KNIGUARD=0xB1F3
local SET_SHADOWBLADE=0xB64A
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GRAIL)
	-- attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_ALL)
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
	-- (3) send cards to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KNIGUARD,SET_SHADOWBLADE}

-- (1)
function s.attfilter(c)
	return c:IsRace(RACE_WARRIOR) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
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
		if sc and sc:IsAttribute(ATTRIBUTE_LIGHT) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetCategory(CATEGORY_LVCHANGE)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetCountLimit(1,id)
			e1:SetCondition(s.condition)
			e1:SetTarget(s.lvtg)
			e1:SetOperation(s.lvop)
			c:RegisterEffect(e1)
		end
		if sc and sc:IsAttribute(ATTRIBUTE_DARK) then
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,1))
			e2:SetCategory(CATEGORY_POSITION)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
			e2:SetCode(EVENT_SPSUMMON_SUCCESS)
			e2:SetCountLimit(1,id)
			e2:SetCondition(s.condition)
			e2:SetTarget(s.postg)
			e2:SetOperation(s.posop)
			c:RegisterEffect(e2)
		end
		g:DeleteGroup()
	end
end

	-- Condition
function s.condition(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
	-- LIGHT
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,e:GetHandler(),1,tp,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local sel=0
		if c:GetLevel()>1 then
			sel=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if sel==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
	-- DARK
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsFaceup() then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		end
	end
end

-- (2)
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tgfilter(c,e)
	return (c:IsSetCard(SET_KNIGUARD) or c:IsSetCard(SET_SHADOWBLADE)) and c:IsAbleToGrave() 
		and c:IsMonster() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end