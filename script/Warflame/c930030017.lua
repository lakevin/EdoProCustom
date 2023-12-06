--Warflame's Spirit Ritual
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Ritual.AddProcGreater{handler=c,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg}
	--Add 1 "Warflame" Ritual Monster to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WARFLAME}

-- (1)
function s.ritualfil(c)
	return c:IsSetCard(SET_WARFLAME) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_WARFLAME) and c:IsAbleToDeck()
end
function s.ckfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLinkMonster()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(s.ckfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	end
	return Group.CreateGroup()
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(s.mfilter,nil)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

-- (2)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.thfilter(c)
	return c:IsSetCard(SET_WARFLAME) and c:IsRitualMonster() and c:IsAbleToHand()
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