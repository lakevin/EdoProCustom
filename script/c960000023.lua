--alyss
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x9998),9,2,nil,aux.Stringid(id,0),5,nil)
	-- (1) cannot disable spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.effcon)
	c:RegisterEffect(e1)
	-- (2) atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- (3) def
	local e3=e1:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(s.defval)
	c:RegisterEffect(e3)
	-- (4) special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	-- (5) indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--remove
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0xff,0xff)
	e6:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e6)
end
-- (1)
function s.effcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end
-- (2)+(3)
function s.atkfilter(c)
	return ( c:IsSetCard(0x9998) or c:IsSetCard(0x9999) )  and c:GetAttack()>=0
end
function s.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.atkfilter,nil)
	return g:GetSum(Card.GetAttack)/2
end
function s.deffilter(c)
	return ( c:IsSetCard(0x9998) or c:IsSetCard(0x9999) ) and c:GetDefense()>=0
end
function s.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.deffilter,nil)
	return g:GetSum(Card.GetDefense)/2
end

-- (4)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (5)
function s.indcon(e)
	return e:GetHandler():GetOverlayCount()~=0
end