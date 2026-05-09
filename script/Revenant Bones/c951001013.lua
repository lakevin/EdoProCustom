-- Call of the Revenant Bones
local s,id=GetID()
local SET_REVENTANTS=0x9616
function s.initial_effect(c)
	-- (1) Special Summon 1 Rank 4 DARK Zombie Xyz Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE) -- change to IGNITION if this is a monster effect
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- (2) Add 1 "Revenant Bones" monster from face-up Extra Deck or GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_REVENTANTS}

-- (1)
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and ((c:IsSetCard(SET_REVENTANTS) and c:IsMonster())
			or (c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ZOMBIE)))
end
function s.dkfilter(c)
	return c:IsSetCard(SET_REVENTANTS) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.onlyoppmon(tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local hg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	local dg=Duel.GetMatchingGroup(s.dkfilter,tp,LOCATION_DECK,0,nil)
	local can_deck=s.onlyoppmon(tp)
	-- check the applicable conditions
	local b1=#hg>=2
	local b2=can_deck and #hg>=1 and #dg>=1
	if chk==0 then return b1 or b2 end
	local g=Group.CreateGroup()
	-- handle cost
	if b1 and b2 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g2=Duel.SelectMatchingCard(tp,s.dkfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
			g:Merge(g1)
			g:Merge(g2)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,2,2,nil)
		end
	elseif b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.dkfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
		g:Merge(g1)
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,2,2,nil)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsRank(4)
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (
			c:IsLocation(LOCATION_GRAVE)
			or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (2)
function s.thfilter(c)
	return c:IsSetCard(SET_REVENTANTS)
		and c:IsMonster()
		and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end