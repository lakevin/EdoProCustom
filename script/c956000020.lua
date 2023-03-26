-- Draconier Grand Summoner, Rise
local s,id=GetID()
function s.initial_effect(c)
	--Link summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2,s.lcheck)
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
	-- (2) to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
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

-- (1)
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x9992) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
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
	return c:IsLevelBelow(6) and c:IsSetCard(0x9992) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.tffilter(c,e,tp)
	return c:GetLevel()==6 and c:IsSetCard(0x9992) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end