--Chosen by the Holy Grail
local SET_HOLYGRAIL=0xAD9C
local SET_KNIGUARD=0xB1F3
local SET_SHADOWBLADE=0xB64A
local SET_WARFLAME=0xBAA1
local CARD_UNHOLY_GRAIL=930000002
local s,id=GetID()
function s.initial_effect(c)
	--Activate (1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate (2)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HOLYGRAIL,SET_KNIGUARD,SET_SHADOWBLADE,SET_WARFLAME}

-- (1)
function s.thfilter(c,e,tp,rc,att)
	return c:IsRace(rc) and c:IsAttribute(att) and c:IsAbleToHand()
end
function s.cfilter(c,e,tp)
	local rc=c:GetOriginalRace()
	local att=c:GetOriginalAttribute()
	local eff4064256={Duel.GetPlayerEffect(tp,4064256)}
	for _,te in ipairs(eff4064256) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then rc=val(te,c,e,1) end
	end
	return (c:IsSetCard(SET_KNIGUARD) or c:IsSetCard(SET_SHADOWBLADE) or c:IsSetCard(SET_WARFLAME)) and c:IsMonster()
		and c:IsDiscardable() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,rc,att)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsLocation(LOCATION_GRAVE) or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetRace(),tc:GetAttribute())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--[[local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit(tc))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)]]--
end
function s.splimit(tc)
	return function(e,c,sump,sumtype,sumpos,targetp,se)
		return not c:IsRace(tc:GetRace()) or not c:IsAttribute(tc:GetAttribute())
	end
end

-- (2)
function s.condition2(e,tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_UNHOLY_GRAIL),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cfilter2(c,e,tp)
	local rc=c:GetOriginalRace()
	local att=c:GetOriginalAttribute()
	local eff4064256={Duel.GetPlayerEffect(tp,4064256)}
	for _,te in ipairs(eff4064256) do
		local val=te:GetValue()
		if val and val(te,c,e,0) then rc=val(te,c,e,1) end
	end
	return (c:IsSetCard(SET_KNIGUARD) or c:IsSetCard(SET_SHADOWBLADE) or c:IsSetCard(SET_WARFLAME)) and c:IsMonster()
		and c:IsDestructable() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,rc,att)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.Destroy(tc,REASON_COST)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end