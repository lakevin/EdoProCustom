-- Shimmerbane Ragnarok
local s,id=GetID()
local SET_SHIMMERBANE=0x9617
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	--Synchro summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	-- (TRAP) Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (1) immune effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.imcon)
	e3:SetValue(s.imfilter)
	c:RegisterEffect(e3)
	-- (2) --Make the opponent send 1 monster to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local cond=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
		if cond and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,c)
			Duel.Destroy(g,REASON_EFFECT)
			local ct=Duel.GetOperatedGroup():FilterCount(function(c,tp) return c:IsPreviousControler(tp) end,nil,1-tp)
			if ct>0 then
				Duel.Damage(1-tp,ct*200,REASON_EFFECT)
			end
		end
	end
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

-- (1)
function s.imcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.imfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

-- (2)
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.scon0(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
		and Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD|LOCATION_HAND,0)>0
end
function s.stg0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE|LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,0,nil,1,0,LOCATION_MZONE|LOCATION_HAND)
end
function s.sop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsMonster,1-tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
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
		--Can be activated
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTarget(s.osptg)
		e2:SetOperation(s.ospop)
		tc:RegisterEffect(e2)
	end
end
function s.setfilter(c)
	return c:IsSetCard(SET_SHIMMERBANE) and c:IsContinuousTrap() and c:IsSSetable(true)
end
function s.osptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.ospop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		c:NegateEffects(c)
		local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil)
		if Duel.GetLocationCount(1-tp,LOCATION_SZONE,1-tp,LOCATION_REASON_TOFIELD)>0 and #g>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SSet(1-tp,sg)
		end
	end
end