--Pendulum Art of Potential
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end

-- (1)
function s.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (loc&LOCATION_PZONE)==LOCATION_PZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0
end
function s.cfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and not c:IsType(TYPE_EFFECT)
end
function s.check(sg,e,tp,mg)
	return sg:IsExists(Card.GetCode,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	end
end
function s.move_to_pendulum_zone(c,tp,e)
	if not c or not Duel.CheckPendulumZones(tp) then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    local ct=2
    if Duel.CheckLocation(tp,LOCATION_PZONE,0)==false or Duel.CheckLocation(tp,LOCATION_PZONE,1)==false then
        ct=1
    end
    local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.check,1,tp,HINTMSG_TOFIELD)
    if #sg==0 then return end
    for tc in aux.Next(sg) do
        Duel.BreakEffect()
        s.move_to_pendulum_zone(tc,tp,e)
    end
end
