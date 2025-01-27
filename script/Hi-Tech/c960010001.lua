--Hi-Tech Security Center
local s,id=GetID()
local SET_HI_TECH=0x9DD4
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HI_TECH))
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- (3) Negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HI_TECH}

-- (1)
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_HI_TECH) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- (2)
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end

-- (3)
function s.check(ev,re)
	return function(category,checkloc)
		if not checkloc and re:IsHasCategory(category) then return true end
		local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,category)
		local ex2,g2,gc2,dp2,dv2=Duel.GetPossibleOperationInfo(ev,category)
		if not (ex1 or ex2) then return false end
		local g=Group.CreateGroup()
		if g1 then g:Merge(g1) end
		if g2 then g:Merge(g2) end
		return (((dv1 or 0)|(dv2 or 0))&LOCATION_REMOVED)~=0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED))
	end
end
function s.disfilter(c)
	return c:IsSetCard(SET_HI_TECH) and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsDisabled() or re:GetHandler():IsCode(960010003) or re:GetHandler():IsCode(960010004)
		or not Duel.IsChainDisablable(ev) then return false end
	local checkfunc=s.check(ev,re)
	return (checkfunc(CATEGORY_TOHAND,true) or checkfunc(CATEGORY_SPECIAL_SUMMON,true)
		or checkfunc(CATEGORY_TOGRAVE,true) or checkfunc(CATEGORY_TODECK,true))
		and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end