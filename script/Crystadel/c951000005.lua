-- The Crystadel Tragedy - Bone Appétit
local s,id=GetID()
local SET_REVENTANTS=0x9616
local VITREAS_MEDIUM=951000003
local VITREAS_POSSESSED=951000011
function s.initial_effect(c)
	-- (1) Activate: attach opponent's monster as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	-- (2) GY: Special Summon "Vitreas, the Possessed Dark Mage"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_REVENTANTS}
s.listed_names={VITREAS_MEDIUM,VITREAS_POSSESSED}

-- (1)
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN)
		and c:IsAbleToChangeControler()
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- xyz monster target
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local xyz=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- monster to attach
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local mg=Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,mg,1,0,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local xyz=g:Filter(s.xyzfilter,nil):GetFirst()
	local tc=g:Filter(s.matfilter,nil):GetFirst()
	if xyz and tc and xyz:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(xyz,tc,true)
	end
end

-- (2)
function s.ogfilter(c)
	return c:IsType(TYPE_XYZ)
		and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,VITREAS_MEDIUM)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ogfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsCode(VITREAS_POSSESSED)
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
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- For the rest of this turn, cannot Special Summon except Zombie monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end