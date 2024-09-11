--V-EYE-RUS - Denial of Service
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	-- (1) Token
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) Destroy 1 "V-EYE-RUS" and cards adjacent to it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- (3) Destroy "V-EYE-RUS Token"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.tkdescon)
	e4:SetOperation(s.tkdesop)
	c:RegisterEffect(e4)
	-- (4) discard effect
    --[[local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)]]--
end
local VYRUS_TOKEN=id+1
s.listed_series={SET_VEYERUS}

-- (1)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>1 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,VYRUS_TOKEN,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetCondition(s.sdescon)
	e1:SetOperation(s.sdesop)
	e:GetHandler():RegisterEffect(e1)
	local ct=math.min(Duel.GetFieldGroupCount(tp,LOCATION_HAND,0),2)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct==0 or ft==0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,VYRUS_TOKEN,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then return end
	ct=math.min(ct,2)
	ft=math.min(ft,ct)
	if ft>1 then
		ft=Duel.AnnounceNumberRange(tp,1,ft)
	end
	Duel.BreakEffect()
	--
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,VYRUS_TOKEN)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1,fid)
		g:AddCard(token)
		--Cannot be used as Link Material
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3312)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(s.lnklimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1)
		--Cannot be used as Synchro Material
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3310)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- discard the same number of cards
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,ft,ft,nil)
	Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
end
function s.lnklimit(e,c)
	if not c then return false end
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE))
end
function s.sdesfilter(c)
	return c:IsType(TYPE_TOKEN) and c:IsCode(VYRUS_TOKEN)
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

-- (2)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.cfilter(c,tc,seq)
	if tc:IsLocation(LOCATION_SZONE) and c:IsControler(tc:GetControler()) then
		if c:IsLocation(LOCATION_MZONE) then return c:IsSequence(seq) end
		return true
	elseif tc:IsLocation(LOCATION_MZONE) then
		if c:IsLocation(LOCATION_SZONE) then
			return tc:IsInMainMZone() and tc:GetColumnGroup():IsContains(c) and c:IsControler(tc:GetControler())
		elseif c:IsLocation(LOCATION_MZONE) then
			if c:IsInExtraMZone() or tc:IsInExtraMZone() then
				return tc:GetColumnGroup():IsContains(c)
			else
				return c:IsSequence(seq-1,seq+1) and c:IsControler(tc:GetControler())
			end
		end
	end
	return false
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and c:IsCode(VYRUS_TOKEN) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCode,VYRUS_TOKEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCode,VYRUS_TOKEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	local g=tc:GetColumnGroup(1,1):Filter(s.cfilter,nil,tc,tc:GetSequence())
	g:Merge(tc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_TOKEN) then
		local g=tc:GetColumnGroup(1,1):Filter(s.cfilter,nil,tc,tc:GetSequence())
		g:Merge(tc)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- (3)
function s.tkdescon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tkdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id+1),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- (4)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    -- 0x4040 => REASON_EFFECT+REASON_DISCARD
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&0x4040)==0x4040
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,VYRUS_TOKEN,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,VYRUS_TOKEN,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,VYRUS_TOKEN)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end