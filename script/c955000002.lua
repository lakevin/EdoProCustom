-- Protectrix Halberd
function c955000002.initial_effect(c)
	--1) Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c955000002.spcon)
	e1:SetOperation(c955000002.spop)
	c:RegisterEffect(e1)
	--2) to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85115440,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,955000002+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c955000002.thcon)
	e2:SetTarget(c955000002.thtg)
	e2:SetOperation(c955000002.thop)
	c:RegisterEffect(e2)
end

--1)
function c955000002.spfilter(c)
	return c:IsSetCard(0x9990) and c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function c955000002.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c955000002.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c955000002.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c955000002.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--2)
function c955000002.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function c955000002.thfilter(c)
	return c:IsSetCard(0x9990) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and not c:IsCode(955000002)
end
function c955000002.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c955000002.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c955000002.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c955000002.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c955000002.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end