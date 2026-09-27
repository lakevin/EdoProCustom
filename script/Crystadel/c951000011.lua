-- Vitreas, Possessed Dark Mage
local s,id=GetID()
local SET_REVENTANTS=0x9616
function s.initial_effect(c)
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),4,2)
	c:EnableReviveLimit()
	--Must be properly summoned before reviving
	Pendulum.AddProcedure(c,false)
	-- (1) Pendulum Effect: place 1 Zombie Pendulum Monster from Deck face-up in Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spselfcost)
	e1:SetTarget(s.spselftg)
	e1:SetOperation(s.spselfop)
	c:RegisterEffect(e1)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- (3) Attach materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.gyovcon)
	e3:SetTarget(s.gyovtg)
	e3:SetOperation(s.gyovop)
	c:RegisterEffect(e3)
	-- (4) Place this card in the Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_REVENTANTS}
s.pendulum_level=4

-- (1)
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
function s.spselfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>=1 
		and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spselftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spselfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (2)
function s.ovspfilter(c,e,tp)
	return c:IsSetCard(SET_REVENTANTS) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyztgfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.ovspfilter,1,nil,e,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) 
		and s.xyztgfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.xyztgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyztgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local xyz=Duel.GetFirstTarget()
	if not xyz or not xyz:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local og=xyz:GetOverlayGroup():Filter(s.ovspfilter,nil,e,tp)
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=og:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (3)
function s.gyovcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_PZONE) or c:IsSummonLocation(LOCATION_GRAVE)
end
function s.gyovfilter(c,xc,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.gyovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.gyovfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyovfilter,tp,LOCATION_REMOVED,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.gyovfilter,tp,LOCATION_REMOVED,0,1,2,nil,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
function s.gyovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	local g=Duel.GetTargetCards(e):Filter(s.gyovfilter,nil,c,tp):Remove(Card.IsImmuneToEffect,nil,e)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

-- (4)
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
