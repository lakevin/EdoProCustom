--Draconier Gravekeeper
local s,id=GetID()
function s.initial_effect(c)
	-- (1) to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	-- (2) Copy Effect
	local e3=Effect.CreateEffect(c)
	e3:SetCountLimit(1,{id,1})
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	-- (3) Return To Hand
	local e4=Effect.CreateEffect(c)
	e4:SetCountLimit(1,{id,2})
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_HAND)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

-- (1)
function s.thfilter(c,e,tp)
	return c:GetLevel()==6 and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSetCard(0x9992) and c:IsAbleToHand() 
		and not c:IsCode(id) 
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- (2)
function s.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_EFFECT) and c:IsSetCard(0x9992) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)~=nil and c:CheckActivateEffect(false,true,false):GetOperation()~=nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chain=Duel.GetCurrentChain()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,chk,chain) end
	chain=chain-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,chk,chain)
	local te,teg,tep,tev,tre,tr,trp=g:GetFirst():CheckActivateEffect(false,true,true)
	if not te then te=g:GetFirst():GetActivateEffect() end
	if te:GetCode()==EVENT_CHAINING then
		if chain<=0 then return false end
		local te2,p=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		teg,tep,tev,tre,tr,trp=g,p,chain,te2,REASON_EFFECT,p
	end
	s[Duel.GetCurrentChain()]=te
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetTarget(s.targetchk(teg,tep,tev,tre,tr,trp))
	e:SetOperation(s.operationchk(teg,tep,tev,tre,tr,trp))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabelObject(e)
	e1:SetOperation(s.resetop)
	Duel.RegisterEffect(e1,tp)
end
function s.targetchk(teg,tep,tev,tre,tr,trp)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local te=s[Duel.GetCurrentChain()]
				if chkc then
					local tg=te:GetTarget()
					return tg(e,tp,teg,tep,tev,tre,tr,trp,0,true)
				end
				if chk==0 then return true end
				if not te then return end
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				local tg=te:GetTarget()
				if tg then tg(e,tp,teg,tep,tev,tre,tr,trp,1) end
			end
end
function s.operationchk(teg,tep,tev,tre,tr,trp)
	return function(e,tp,eg,ep,ev,re,r,rp)
				local te=s[Duel.GetCurrentChain()]
				if not te then return end
				local op=te:GetOperation()
				if op then op(e,tp,teg,tep,tev,tre,tr,trp) end
			end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		te:SetTarget(s.target)
		te:SetOperation(s.operation)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=s[Duel.GetCurrentChain()]
	if chkc then
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,true)
	end
	if chk==0 then return true end
	if not te then return end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=s[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

-- (3)
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9992) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
