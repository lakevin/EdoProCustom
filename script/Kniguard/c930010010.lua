--Kniguard - Blessing of Gods
local SET_KNIGUARD=0xB1F3
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_GRAIL)
	-- (1) Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- (2) set counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.sectcost)
	e2:SetTarget(s.secttg)
	e2:SetOperation(s.sectop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KNIGUARD}
s.counter_place_list={COUNTER_GRAIL}

-- (1)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.immfilter(chkc) end
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(s.thop)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.immop)
		Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsMonster() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.immfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsMonster()
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		--Cannot be destroyed by battle or card effect
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3008)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

-- (2)
function s.cfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsAbleToRemoveAsCost()
end
function s.sectfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsType(TYPE_MONSTER) and c:IsCanAddCounter(COUNTER_GRAIL,2)
end
function s.sectcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.secttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsCanAddCounter(COUNTER_GRAIL,2) end
	if chk==0 then return Duel.IsExistingTarget(s.sectfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.sectfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,2,0,0)
end
function s.sectop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(COUNTER_GRAIL,2) then
		tc:AddCounter(COUNTER_GRAIL,2)
	end
end
