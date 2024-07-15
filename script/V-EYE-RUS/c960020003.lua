--V-EYE-RUS - Denial of Service
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	-- (1) Token
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (3) Send to GY
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VEYERUS}

-- (1)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
	local ct=math.min(Duel.GetFieldGroupCount(tp,LOCATION_HAND,0),3)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct==0 or ft==0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then return end
	ct=math.min(ct,3)
	ft=math.min(ft,ct)
	if ft>1 then
		ft=Duel.AnnounceNumberRange(tp,1,ft)
	end
	Duel.BreakEffect()
	--
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1,fid)
		g:AddCard(token)
		--Cannot be used as Link Material
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3312)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
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
	-- Destroy
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetLabel(fid)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e3,tp)
	-- discard the same number of cards
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,ft,ft,nil)
	Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
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
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then return false end
	local tg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,0,nil)
	if #tg==0 then
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,0,nil)
	local dg=g:Clone()
	for token in aux.Next(g) do
		local tg=token:GetColumnGroup(1,1):Filter(s.cfilter,nil,token,token:GetSequence())
		dg:Merge(tg)
	end
	Duel.Destroy(dg,REASON_EFFECT)
end

-- (2)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    -- 0x4040 => REASON_EFFECT+REASON_DISCARD
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&0x4040)==0x4040
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end