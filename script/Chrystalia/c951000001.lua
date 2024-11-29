local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- (1 )special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(POS_FACEUP,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

-- (1)
function s.spfilter(c)
	--Debug.Message(c:GetCode())
	--Debug.Message("IsReleasable")
	--Debug.Message(c:IsReleasable())
	--Debug.Message("GetOriginalType")
	--Debug.Message(c:GetOriginalType()&TYPE_MONSTER)
	return c:IsFaceup() and c:IsReleasable() and c:GetSequence()<5
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE+LOCATION_PZONE,LOCATION_SZONE+LOCATION_PZONE,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_SZONE+LOCATION_PZONE,LOCATION_SZONE+LOCATION_PZONE,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	local tc=g:GetFirst()
	if tc:GetOriginalType()&TYPE_MONSTER~=TYPE_MONSTER then return end
	Duel.SendtoGrave(g,REASON_RELEASE)
	g:DeleteGroup()
	-- Select Option
	if tc:IsType(TYPE_PENDULUM) then
		-- (1) Place 1 Pendulum Monster from your Deck/face-up Extra Deck in PZone
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1,{id,1})
		e1:SetValue(s.zones)
		e1:SetTarget(s.pentg)
		e1:SetOperation(s.penop)
		c:RegisterEffect(e1)
	else
		-- (2) Place 1 Monster from your Deck in Spell & Trap Zone as Continuous Spell
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetLabelObject(tc)
		e2:SetCountLimit(1,{id,1})
		e2:SetTarget(s.plstg)
		e2:SetOperation(s.plsop)
		c:RegisterEffect(e2)
		-- (3) Place 1 Monster from your Deck in Spell & Trap Zone as Continuous Trap
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e3:SetLabelObject(tc)
		e3:SetCountLimit(1,{id,1})
		e3:SetTarget(s.plttg)
		e3:SetOperation(s.pltop)
		c:RegisterEffect(e3)
	end
end

-- (2-1)
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	if Duel.IsDuelType(DUEL_SEPARATE_PZONE) then return zone end
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if p0==p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
function s.penfilter(c,code)
	return c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) 
		and not (c:IsForbidden() or c:IsCode(code))
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local tc=e:GetLabelObject()
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,nil,tc:GetCode()) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_EXTRA|LOCATION_DECK,0,1,1,nil,tc:GetCode()):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- (2-2)
function s.plsfilter(c)
	return c:IsMonster() and c:IsSummonableCard() and not (c:IsType(TYPE_PENDULUM) or c:IsForbidden())
end
function s.plstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	if chk==0 then return Duel.IsExistingMatchingCard(s.plsfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.plsop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plsfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--Cannot Special Summon that monster this turn
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,tc:GetCode()))
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end

-- (2-3)
function s.pltfilter(c)
	return c:IsMonster() and c:IsSummonableCard() and not (c:IsType(TYPE_PENDULUM) or c:IsForbidden())
end
function s.plttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	if chk==0 then return Duel.IsExistingMatchingCard(s.pltfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.pltop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pltfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--Cannot Special Summon that monster this turn
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,tc:GetCode()))
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end