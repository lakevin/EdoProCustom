-- Vitreas, the Medium of Crystadel
local s,id=GetID()
local SET_CRYSTADEL=0x9614
local SET_REVENTANTS=0x9616
local CARD_VITREAS_CRYSTADEL=951000003
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	-- (1) Send 1 face-up Zombie Pendulum Monster from your Extra Deck to your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- (2) Special Summon this card from your hand to either field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- (3) This card's owner adds 1 "Revenant Bones" Spell/Trap from their Deck to their hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,6))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CRYSTADEL,SET_REVENTANTS}
s.listed_names={CARD_VITREAS_CRYSTADEL}

-- (1)
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() 
		and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:GetLeftScale()>0
		and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		--Increase this card's Pendulum Scale by the sent monster's
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(tc:GetLeftScale())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		c:RegisterEffect(e2)
	end
end

-- (2)
function s.spcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4)
		and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	e:SetLabelObject(rc) -- important
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetLabelObject()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)}
	)
	if not op then return end
	local target_player=op==1 and tp or 1-tp
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,target_player,false,false,POS_FACEUP)>0 then
		if target_player==1-tp and rc and rc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and rc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- (3)
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,e:GetHandler():GetOwner(),LOCATION_DECK)
end
function s.thfilter(c)
	return ((c:IsSetCard(SET_CRYSTADEL) and c:IsSpell() and c:ListsCode(CARD_VITREAS_CRYSTADEL)) 
		or (c:IsSetCard(SET_REVENTANTS) and c:IsSpellTrap()))
		and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(p,s.thfilter,p,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,p,REASON_EFFECT)
		Duel.ConfirmCards(1-p,g)
	end
end