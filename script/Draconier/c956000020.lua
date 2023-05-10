-- Draconier Grand Summoner, Rise
local s,id=GetID()
function s.initial_effect(c)
	--Link summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	--Cannot be Link Material the turn it's Link Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetCondition(s.lkcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Cards this points to cannot be targeted
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(function(e,c) return e:GetHandler():GetLinkedGroup():IsContains(c) end)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- (1) Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- (2) atkup
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- link summon
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x9992,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER,lc,sumtype,tp)
end
function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end

-- (1)
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9992) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM) 
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp,zone)
		return ct>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp,zone)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP,zone)
	--[[local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)]]--
end
function s.splimit(e,c)
	return not c:IsSetCard(0x9992)
end

-- (2)
function s.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9992) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9992)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local hc=g:GetFirst()
	local tc=g:GetNext()
	if hc~=e:GetLabelObject() then tc,hc=hc,tc end
	if hc:IsFaceup() and tc:IsFaceup() and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 then
		local sg=Duel.GetOperatedGroup()
		local atk=hc:GetBaseAttack()
		if not sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end