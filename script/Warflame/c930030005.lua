--Warflame Hanso
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	-- must attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- (1) special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.sphcon)
	e2:SetTarget(s.sphtg)
	e2:SetOperation(s.sphop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- (2) Multi Attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	-- (3) to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--[[local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetCondition(s.rmeffcon)
	c:RegisterEffect(e5)]]--
end
s.listed_series={SET_WARFLAME}

-- (1)
function s.sphfilter(c)
	return c:IsSetCard(SET_WARFLAME)
end
function s.sphcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.sphfilter,1,true,1,true,c,c:GetControler(),nil,false,e:GetHandler())
end
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,c)
	if c==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=Duel.SelectReleaseGroup(tp,s.sphfilter,1,1,true,true,true,c,nil,nil,false,e:GetHandler())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.sphop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

-- (2)
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(SET_WARFLAME)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_WARFLAME) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,2,nil)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	local c=e:GetHandler()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if ct>0 and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- (3)
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WARFLAME) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		--Cannot activate its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
	-- or if your opponent activates a monster effect during your Main Phase
function s.rmeffcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ep==1-tp and Duel.IsTurnPlayer(tp) and re:IsActiveType(TYPE_MONSTER) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end