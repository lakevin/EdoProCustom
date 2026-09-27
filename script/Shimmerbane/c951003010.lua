-- Shimmerbane Ruin
local s,id=GetID()
local SET_SHIMMERBANE=0x9617
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	--Synchro summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTuner(nil),1,99)
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
	-- (1) Double attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- (2) Set destroyed monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Hint(HINT_CARD,tp,id)
		--Cannot activate cards/effects when your Shimmerbane Monster attacks
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.chainop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,1,aux.Stringid(id,1),nil)
	end
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(SET_SHIMMERBANE) and ep==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,ep,tp)
	return tp==ep
end

-- (2)
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return not bc:IsType(TYPE_TOKEN) and not bc:IsSpellTrap() end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	if Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
		Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
	elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEDOWN,tc:IsMonsterCard()) then
		--Treat as Continuous Trap
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		tc:SetStatus(STATUS_SET_TURN,true)
		--Can be activated by another card's effect
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_SZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetTarget(s.osptg)
		e2:SetOperation(s.ospop)
		Reflexxion.RegisterShimmerbaneForcedActivation(tc,e2,tp)
	end
end
function s.osptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local p=e:GetHandler():GetOwner()
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,p,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-p,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.ospop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local p=c:GetOwner()
		if Duel.DiscardHand(p,Card.IsDiscardable,1,1,REASON_EFFECT|REASON_DISCARD)>0 then
			Duel.Draw(1-p,1,REASON_EFFECT)
		end
	end
end
