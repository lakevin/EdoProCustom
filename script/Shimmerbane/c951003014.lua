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
	e1:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	c:RegisterEffect(e1)
	-- (2) Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- (2.1) If Special Summoned, force the activation of 1 Set Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.forcetg)
	e3:SetOperation(s.forceop)
	c:RegisterEffect(e3)
	-- (2.2) Can be treated as a Level 2 or 4 monster for the Synchro Summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.synop)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SSET)
		ge:SetOperation(s.operation)
		Duel.RegisterEffect(ge,0)
	end)
end
s.listed_names={id}
s.listed_series={SET_SHIMMERBANE}

-- (1) Track cards Set by a "Shimmerbane" effect
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(SET_SHIMMERBANE) then return end
	for ec in eg:Iter() do
		ec:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end

-- (2)
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,0,1,RACE_FIEND,ATTRIBUTE_DARK)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,0,1,RACE_FIEND,ATTRIBUTE_DARK)) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	--Treat this card as a Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CAN_BE_TUNER)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:AddMonsterAttributeComplete()
	Duel.SpecialSummonComplete()
end

-- (2.1)
function s.actfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.forcetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.actfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.actfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
end
function s.forceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		local c=e:GetHandler()
		Reflexxion.ShimmerbaneForceActivation(c,e,tp,eg,ep,ev,re,r,rp,tc)
	end
end

-- (2.2)
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local c=e:GetHandler()
	local sum=(sg-c):GetSum(Card.GetSynchroLevel,sc)
	if sum+c:GetSynchroLevel(sc)==lv then return true,true end
	return sc:IsSetCard(SET_SHIMMERBANE) and ((sum+2==lv) or (sum+4==lv)),true
end
