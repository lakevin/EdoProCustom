--Owl
local s,id=GetID()
Duel.LoadScript("GrimmChainAux.lua")
local SET_CONTRACTOR=0x9998
local SET_GRIMM_CHAIN=0x9999
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	GrimmChain.AddContractorSearch(c,id,960000030,2)
	-- (1) Banish card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- (2) Ritual Summon
	local e2=Ritual.CreateProc(c,RITPROC_EQUAL,aux.FilterBoolFunction(Card.IsSetCard,SET_GRIMM_CHAIN),nil,aux.Stringid(id,1),nil,nil,nil,nil,LOCATION_REMOVED)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.ritcon)
	c:RegisterEffect(e2)
end
s.listed_names={960000030}
s.listed_series={SET_GRIMM_CHAIN}

-- (1)
function s.rmfilter(c)
	return c:IsSetCard(SET_GRIMM_CHAIN) and c:IsRitualMonster() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- (2)
function s.ritcon()
	return Duel.IsMainPhase()
end
