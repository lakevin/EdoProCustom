--V-EYE-RUS Web-Spider Overlord
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),6,2,s.ovfilter,aux.Stringid(id,0),2)
	c:EnableReviveLimit()
	-- (1) reduce level/rank
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RANK)
	c:RegisterEffect(e2)
	-- (2) Reset Rank to its original Rank
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.rkcost)
	e3:SetOperation(s.rkop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	-- (3) Take control of monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e4:SetCountLimit(2,id)
	e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_VEYERUS}

--Xyz Summon
function s.ovfilter(c,tp,xyzc)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsSetCard(SET_VEYERUS,xyzc,SUMMON_TYPE_XYZ,tp)
	       and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and (rk==10 or rk==11)
end

-- (1)
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	--Debug.Message("IsHasCategory: " .. tostring(re:IsHasCategory(CATEGORY_LVCHANGE)))
	--Debug.Message("IsSetCard: " .. tostring(re:GetHandler():IsSetCard(SET_VEYERUS)))
	return re and re:IsHasCategory(CATEGORY_LVCHANGE) and re:GetHandler():IsSetCard(SET_VEYERUS)
		and not re:GetHandler():IsCode(id) and e:GetHandler():IsRankAbove(1) and e:GetHandler():IsRankBelow(11)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:IsRankAbove(12) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_RANK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end

-- (2)
function s.rkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e.GetHandler()
	if c and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RANK)
		e1:SetValue(c:GetOriginalRank())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

-- (3)
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRankAbove(2) and not e:GetHandler():IsStatus(STATUS_CHAINING) 
end
function s.ctfilter(c,rank)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and 
		((c:HasLevel() and c:GetLevel()<rank) or (c:IsType(TYPE_XYZ) and c:GetRank()<rank))
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rank=e:GetHandler():GetRank()
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,rank) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rank=c:GetRank()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(1-tp,s.ctfilter,1-tp,LOCATION_MZONE,0,1,1,nil,rank)
	local tc=g:GetFirst()
	if not tc then return end
	local reduce=0
	if tc:IsType(TYPE_XYZ) then
		reduce=math.abs(tc:GetRank())*-1
	else 
		reduce=math.abs(tc:GetLevel())*-1
	end
	-- reduce level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetCode(EFFECT_UPDATE_RANK)
	e1:SetValue(reduce)
	c:RegisterEffect(e1)
	-- take control
	if Duel.GetControl(tc,tp,nil,nil,nil,1-tp)~=0 then
		--Negate effect(s)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end