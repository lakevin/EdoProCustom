--The Intention of the Abyss
local s,id=GetID()
local SET_GRIMM_CHAIN=0x9999
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned by its own procedure.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Manifest from the hand or face-up banishment; no Summon count limit.
	local sp=Effect.CreateEffect(c)
	sp:SetDescription(aux.Stringid(id,0))
	sp:SetType(EFFECT_TYPE_FIELD)
	sp:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	sp:SetCode(EFFECT_SPSUMMON_PROC)
	sp:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	sp:SetCondition(s.spcon)
	sp:SetTarget(s.spproctg)
	sp:SetOperation(s.spprocop)
	c:RegisterEffect(sp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.statval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Call back a Chain, then optionally recover a different Chain.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function() return Duel.IsMainPhase() end)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GRIMM_CHAIN}
function s.matfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_GRIMM_CHAIN)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToDeckOrExtraAsCost()
end
function s.matcheck(g,e,tp)
	return aux.dncheck(g) and g:IsExists(Card.IsRitualMonster,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,c)
	return aux.SelectUnselectGroup(g,e,tp,3,3,s.matcheck,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED,0,c)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.matcheck,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #sg==0 then return false end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
function s.spprocop(e,tp)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
	e:SetLabelObject(nil)
end
function s.countfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GRIMM_CHAIN) and c:IsRitualMonster()
end
function s.statval(e,c)
	local g=Duel.GetMatchingGroup(s.countfilter,c:GetControler(),LOCATION_MZONE+LOCATION_REMOVED,0,c)
	return g:GetClassCount(Card.GetCode)*1000
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_GRIMM_CHAIN)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c,code)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_GRIMM_CHAIN)
		and not c:IsCode(code) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.operation(e,tp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local code=tc:GetCode()
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil,code)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil,code)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
