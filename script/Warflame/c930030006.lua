--Warflame Xiangling
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	-- must attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- (1) special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spicon)
	e2:SetTarget(s.spitg)
	e2:SetOperation(s.spiop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- (2) Banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	-- (3) Negate
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_WARFLAME}

-- (1)
function s.spifilter(c)
	return c:IsSetCard(SET_WARFLAME)
end
function s.spicon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.spifilter,1,true,1,true,c,c:GetControler(),nil,false,e:GetHandler())
end
function s.spitg(e,tp,eg,ep,ev,re,r,rp,c)
	if c==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=Duel.SelectReleaseGroup(tp,s.spifilter,1,1,true,true,true,c,nil,nil,false,e:GetHandler())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spiop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

-- (2)
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(SET_WARFLAME)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- (3)
function s.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (not e or c:IsCanBeEffectTarget(e))
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return ct>0 and Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,ct,nil)
	Duel.Release(g,REASON_COST)
	local og=Duel.GetOperatedGroup()
	e:SetLabel(#og)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,#og,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,nil)
	if #sg<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=sg:Select(tp,ct,ct,nil)
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end