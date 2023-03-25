-- Protectrix CR-Suit Apocalyptic
local s,id=GetID()
function s.initial_effect(c)
	-- fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),s.matfilter)
	-- (1) Banish from your opp Field, Hand, GY or Decktop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	-- (2) activate trap in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9990))
	e2:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e2)
	--cannot target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
end

-- (1)
function s.rmfilter(c)
	return c:IsAbleToRemove() and (not c:IsLocation(LOCATION_GRAVE) or aux.SpElimFilter(c))
end
function s.bansc(tp,loc) --Banish check shortcut
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,loc,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,1,nil) end
	local b1=s.bansc(tp,LOCATION_ONFIELD)
	local b2=s.bansc(tp,LOCATION_HAND)
	local b3=(Duel.IsPlayerAffectedByEffect(1-tp,69832741) and s.bansc(tp,LOCATION_MZONE)) or s.bansc(tp,LOCATION_GRAVE)
	local b4=s.bansc(tp,LOCATION_DECK)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==2 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if #g>0 then
			local sg=g:RandomSelect(tp,1)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g
		if Duel.IsPlayerAffectedByEffect(1-tp,69832741) then
			g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
		else
			g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		end
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==4 then
		local g=Duel.GetDecktopGroup(1-tp,1)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--indes
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end