--Holy Grail - Resurrection
local SET_HOLYGRAIL=0xAD9C
local s,id=GetID()
function s.initial_effect(c)
    -- (1) Activate and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    -- (2) destroy monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- (3) disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAIN_ACTIVATING)
	e4:SetOperation(s.disop)
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	-- (3) Can treat "Holy Grail" Spell cards as Link Material
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_FIELD)
	e5a:SetCode(EFFECT_EXTRA_MATERIAL)
	e5a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e5a:SetRange(LOCATION_SZONE)
	e5a:SetTargetRange(1,0)
	e5a:SetCountLimit(1,{id,1})
	e5a:SetOperation(aux.TRUE)
	e5a:SetValue(s.extraval)
	c:RegisterEffect(e5a)
	local e5b=Effect.CreateEffect(c)
	e5b:SetType(EFFECT_TYPE_SINGLE)
	e5b:SetCode(EFFECT_ADD_TYPE)
	e5b:SetRange(LOCATION_SZONE)
	e5b:SetTargetRange(LOCATION_SZONE,0)
	e5b:SetCondition(s.addtypecon)
	e5b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e5b:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e5b)
	local e5c=Effect.CreateEffect(c)
	e5c:SetType(EFFECT_TYPE_SINGLE)
	e5c:SetCode(EFFECT_ADD_ATTRIBUTE)
    e5c:SetRange(LOCATION_SZONE)
	e5c:SetValue(ATTRIBUTE_ALL)
	c:RegisterEffect(e5c)
end
s.listed_series={SET_HOLYGRAIL}

-- (1)
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.sdescon)
	e1:SetOperation(s.sdesop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		Duel.SpecialSummonComplete()
	end
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

-- (2)
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- (3)
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc then
		local race=tc:GetRace()
		local attribute=tc:GetAttribute()
		local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
		if re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and 
			re:GetHandler():GetAttribute()~=attribute and re:GetHandler():GetRace()~=race then
			Duel.NegateEffect(ev)
		end
	end
end

-- (4)
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_HOLYGRAIL) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc:IsSetCard(SET_HOLYGRAIL)) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end