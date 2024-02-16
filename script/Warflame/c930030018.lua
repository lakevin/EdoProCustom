--Warflame Huxian
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- (2) ritual material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetCondition(s.con)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WARFLAME}

-- (1)
function s.cfilter(c,tp)
	return c:IsReason(REASON_RELEASE) and c:IsSetCard(SET_WARFLAME) and c:IsPreviousControler(tp)
		and (c:IsPreviousPosition(POS_FACEUP) or not c:IsPreviousLocation(LOCATION_MZONE))
end
function s.spfilter(c,e,tp,turn)
	return c:IsReason(REASON_RELEASE) and c:GetTurnID()==turn and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local turn=Duel.GetTurnCount()
	local g=eg:Filter(s.spfilter,nil,e,tp,turn)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g+c,#g+1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	local turn=Duel.GetTurnCount()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP)
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			if #g>ft then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g=g:Select(tp,ft,ft,nil)
			end
			for tc in g:Iter() do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	Duel.SpecialSummonComplete()
end

-- (2)
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741)
end