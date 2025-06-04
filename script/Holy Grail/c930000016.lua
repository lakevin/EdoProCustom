--Curse of the Unholy Grail
local SET_HOLYGRAIL=0xAD9C
local COUNTER_GRAIL=0x4041
local CARD_UNHOLY_GRAIL=930000002
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
    -- (1) Activate 1 "Unholy Grail" from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- (2) Change attribute to DARK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
    -- (3) special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.sccon)
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HOLYGRAIL}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_HOLYGRAIL,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp) and not c:IsSummonCode(lc,sumtype,tp,id)
end

-- (1)
function s.attrfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.acfilter(c,tp)
	return c:IsCode(CARD_UNHOLY_GRAIL) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end

-- (2)
function s.atfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.atcon(e)
	local c=e:GetHandler()
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UNHOLY_GRAIL),c:GetControler(),LOCATION_SZONE,0,1,nil)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- (3)
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsCanAddCounter(COUNTER_GRAIL,2) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,nil,COUNTER_GRAIL,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,nil,COUNTER_GRAIL,2)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(COUNTER_GRAIL,2) then
		tc:AddCounter(COUNTER_GRAIL,2)
	end
end