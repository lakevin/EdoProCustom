-- Vitreas, the Possessed Dark Mage
local s,id=GetID()
local SET_REVENTANTS=0x9616
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),4,2)
	-- (1) Pendulum Effect: place 1 Zombie Pendulum Monster from Deck face-up in Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- (3) Place in your Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_REVENTANTS}

-- (1)
function s.penfilter(c)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_PENDULUM)
		and c:IsAbleToExtra()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoExtraP(tc,tp,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		local val=tc:GetLeftScale()
		local cur=c:GetLeftScale()
		local inc=math.min(val,8-cur)
		if inc>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LSCALE)
			e1:SetValue(inc)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_RSCALE)
			c:RegisterEffect(e2)
		end
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
function s.recfilter(c,fc)
	local cond=(c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)) or (c:IsSetCard(SET_REVENTANTS) and c:IsMonster())
	return c~=fc and cond and c:IsAbleToDeck()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED))
		and s.recfilter(chkc,c) end
	if chk==0 then return Duel.CheckPendulumZones(tp) and not c:IsForbidden()
		and Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,c,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,c,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if not Duel.CheckPendulumZones(tp) or c:IsForbidden() then return end
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end