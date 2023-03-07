--Nevercrow
function c956000005.initial_effect(c)
	--1) Search Spell Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43797906,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c956000005.cost)
	e1:SetTarget(c956000005.target)
	e1:SetOperation(c956000005.operation)
	c:RegisterEffect(e1)
	--2) Special Summon Success
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c956000005.spcon)
	e2:SetTarget(c956000005.sptg)
	e2:SetOperation(c956000005.spop)
	c:RegisterEffect(e2)	
	--3) To Hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c956000005.thcon)
	e3:SetTarget(c956000005.thtg)
	e3:SetOperation(c956000005.thop)
	c:RegisterEffect(e3)
end

--1)
function c956000005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c956000005.filter(c)
	return c:IsSetCard(0x9995) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c956000005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c956000005.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c956000005.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,c956000005.filter,tp,LOCATION_DECK,0,1,1,nil)
	if tg then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end

--2)
function c956000005.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x9995)
end
function c956000005.spfilter(c,e,tp)
	return c:GetLevel()==4 and c:IsSetCard(0x9995) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(956000005)
end
function c956000005.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c956000005.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c956000005.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c956000005.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

--3)
function c956000005.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE
end
function c956000005.thfilter(c)
	return ( c:GetSequence()==6 or c:GetSequence()==7 ) and c:IsAbleToDeck()
end
function c956000005.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c956000005.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c956000005.thfilter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c956000005.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c956000005.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end