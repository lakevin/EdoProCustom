--Networld Mimicry
local s,id=GetID()
local SET_NETWORLD=0x9DD2
function s.initial_effect(c)
	-- (1) spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- (2) Search 1 "Networld" Spell/Trap card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NETWORLD}

-- (1)
function s.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
		and c:IsAbleToRemoveAsCost() and not c:IsCode(id) and aux.SpElimFilter(c,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=LOCATION_MZONE
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		loc=LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE
	end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetMatchingGroup(s.cfilter,tp,loc,0,c) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=LOCATION_MZONE
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		loc=LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,loc,0,c)
	local og=aux.SelectUnselectGroup(g,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if og and #og>0 then
		local tc=og:GetFirst()
		local ct=Duel.Remove(og,POS_FACEUP,REASON_EFFECT+REASON_DISCARD)
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and ct>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(tc:GetCode())
			c:RegisterEffect(e1)
			if tc:HasLevel() and c:GetLevel()~=tc:GetLevel() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CHANGE_LEVEL)
				e2:SetValue(tc:GetLevel())
				c:RegisterEffect(e2)
			end
		end
	end
end

-- (2)
function s.thfilter(c)
	return c:IsSetCard(SET_NETWORLD) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end