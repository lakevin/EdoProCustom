-- Majestal Fractyron
local s,id=GetID()
local SET_MAJESTAL=0x9615
Duel.LoadScript("ReflexxionsAux.lua")
function s.initial_effect(c)
	Reflexxion.AddManifestProcedure(c)
	-- Negate a face-up card if this card was placed by another card's effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_MOVE)
	e1:SetRange(LOCATION_STZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- Set 1 "Majestal" Spell/Trap directly from the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- Place itself in the S/T Zone when a Spell/Trap is sent therefrom to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.plcon)
	e4:SetTarget(s.pltg)
	e4:SetOperation(s.plop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAJESTAL}

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	return eg:IsContains(c) and not c:IsPreviousLocation(LOCATION_SZONE)
end
function s.negfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.negfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.setfilter(c)
	return c:IsSetCard(SET_MAJESTAL) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 then
		local tc=g:GetFirst()
		if tc then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT|RESETS_CANNOT_ACT|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.plfilter(c)
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousTypeOnField(TYPE_SPELL|TYPE_TRAP)
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.plfilter,1,nil)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		c:RegisterEffect(e1)
	end
end
