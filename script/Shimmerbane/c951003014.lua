-- Shimmerbane Awakening
local s,id=GetID()
local SET_SHIMMERBANE=0x9617
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	-- (1) Can be activated during the turn it was Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	-- (2) Activation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_SHIMMERBANE}

-- (1)
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MMZONE,0)==0
end

-- (2)
function s.actfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.actfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.actfilter,tp,LOCATION_SZONE,0,1,c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_SHIMMERBANE,0x21+0x1000,1000,1000,3,RACE_FIEND,ATTRIBUTE_DARK) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and s.target(e,tp,eg,ep,ev,re,r,rp,0) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TUNER,ATTRIBUTE_DARK,RACE_FIEND,3,1000,1000)
		Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
		-- (1.1) Force activation
		if tc then
			Duel.Hint(HINT_CARD,0,id)
			Duel.BreakEffect()
			Reflexxion.ShimmerbaneForceActivation(c,e,tp,eg,ep,ev,re,r,rp,tc)
		end
		-- (1.2) Can be treated as a non-tuner
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_NONTUNER)
		e2:SetValue(s.ntval)
		c:RegisterEffect(e2)
		c:AddMonsterAttributeComplete()
	end
	Duel.SpecialSummonComplete()
end

-- (1.2)
function s.ntval(c,sc,tp)
	return sc and sc:IsRace(RACE_FIEND)
end