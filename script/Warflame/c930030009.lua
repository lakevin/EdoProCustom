--Warflame Outburst
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Destroy by Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	-- (2) draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WARFLAME}

-- (1)

	-- global filter
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
	-- global function
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
	-- Tribute 1 "Warflame" monster you control
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_WARFLAME) and c:IsReleasable()
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,math.max(0,c:GetTextAttack()))
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,math.max(0,g1:GetFirst():GetTextAttack()))
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_COST+REASON_RELEASE)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
		Duel.Destroy(g,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	end
end
	-- Send 1 "Warflame" monster from your Extra Deck to the GY
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
function s.exfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_WARFLAME) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,math.max(0,c:GetTextAttack()))
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_EXTRA) and chkc:IsControler(tp) and s.exfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g1)
	local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,math.max(0,g1:GetFirst():GetTextAttack()))
	Duel.SetTargetCard(g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_COST+REASON_RELEASE)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
		Duel.Destroy(g,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	end
end


-- (2)
function s.drfilter(c,e)
	return c:IsSetCard(SET_WARFLAME) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and g:GetClassCount(Card.GetCode)>4 end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end