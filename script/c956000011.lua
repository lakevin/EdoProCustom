--Draconier Hunting Grounds
function c956000011.initial_effect(c)
	--1) Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--1)atk & def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9995))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9995))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	--2) SPECIAL SUMMON / ADD TO HAND
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(45803070,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(c956000011.target1)
	e4:SetOperation(c956000011.operation1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetDescription(aux.Stringid(91812341,0))
	e5:SetTarget(c956000011.target2)
	e5:SetOperation(c956000011.operation2)
	c:RegisterEffect(e5)
	--3) BANISH + ADD TO HAND
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(73594093,1))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCondition(aux.exccon)
	e6:SetCountLimit(1,956000011+EFFECT_COUNT_CODE_OATH)
	e6:SetCost(c956000011.drcost)
	e6:SetTarget(c956000011.drtg)
	e6:SetOperation(c956000011.drop)
	c:RegisterEffect(e6)
end

--2)
function c956000011.tdfilter1(c,e,tp)
	return c:IsFaceup() and c:GetLevel()==4 and c:IsSetCard(0x9995) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(c956000011.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function c956000011.spfilter1(c,e,tp,code)
	return c:GetLevel()==4 and c:IsSetCard(0x9995) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c956000011.filter2(c)
	return c:IsSetCard(0x9995) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c956000011.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c956000011.tdfilter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c956000011.tdfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c956000011.tdfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c956000011.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c956000011.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c956000011.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c956000011.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end
function c956000011.operation2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c956000011.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--3)
function c956000011.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c956000011.drfilter(c,e)
	return c:IsSetCard(0x9995) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c956000011.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c956000011.drfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c956000011.drfilter,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c956000011.drfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c956000011.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end