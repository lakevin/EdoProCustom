-- Sola, Wizard of Crystadel
local s,id=GetID()
local SET_CRYSTADEL=0x9614
function s.initial_effect(c)
	--Add 1 "Crystaldel" monster from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Place 1 "Tainted Treasure" Spell/Trap that is banished or in your GY on the bottom of the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

-- (1)
function s.thfilter(c)
	return c:IsSetCard(SET_CRYSTADEL) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- (2)
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(p,LOCATION_SZONE)
		and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden()) 
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,1-tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
		-- select option
	local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
	e:SetLabel(op)
		-- select monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local og=Duel.SelectTarget(1-tp,s.plfilter,1-tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	if og:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,og,1,0,0)
	end
	e:SetLabelObject(og:GetFirst())
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local oc=e:GetLabelObject()
	if op==1 then
		if oc and Duel.MoveToField(oc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			oc:RegisterEffect(e1)
		end
	elseif op==2 then
		if oc and Duel.MoveToField(oc,1-tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,true) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetCode(EFFECT_CHANGE_TYPE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e2:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			oc:RegisterEffect(e2)
		end
	end
end