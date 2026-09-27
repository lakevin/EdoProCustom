-- Shimmerbane Ragnarok
local s,id=GetID()
local SET_SHIMMERBANE=0x9617
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	--Synchro summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Set as a Continuous Trap
	Reflexxion.AddAmbushProcedure(c)
	-- (TRAP) Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(Cost.SelfChangePosition(POS_FACEUP))
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	Reflexxion.RegisterAmbushActivation(c,e1)
	-- (TRAP) If this Set card is destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	-- (1) immune effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.imcon)
	e3:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e3)
	-- (2) Set 1 random card from the opponent's hand as a Continuous Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.scon0)
	e4:SetTarget(s.stg0)
	e4:SetOperation(s.sop0)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={SET_SHIMMERBANE}

-- (TRAP)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFacedown() and not c:IsStatus(STATUS_SET_TURN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_DESTROY)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,tp,id)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end

-- (1)
function s.imcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end

-- (2)
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.scon0(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
end
function s.stg0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,1-tp,LOCATION_HAND)
end
function s.sop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=1-tp
	if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFieldGroup(p,LOCATION_HAND,0):RandomSelect(tp,1):GetFirst()
	if tc and Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEDOWN,true) then
		--Treat as Continuous Trap
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		tc:SetStatus(STATUS_SET_TURN,true)
		--Can only be activated by another card's effect
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SET)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_SZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabel(tp)
		e2:SetTarget(s.fatg)
		e2:SetOperation(s.faop)
		Reflexxion.RegisterShimmerbaneForcedActivation(tc,e2,tp)
	end
end
function s.setfilter(c)
	return c:IsSetCard(SET_SHIMMERBANE) and c:IsSSetable(true)
end
function s.fatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.faop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 then
		local sp=e:GetLabel()
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),sp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if Duel.GetLocationCount(sp,LOCATION_SZONE)>0 and #g>0 and Duel.SelectYesNo(sp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_SET)
			local sg=g:Select(sp,1,1,nil)
			Duel.SSet(sp,sg)
		end
	end
end
