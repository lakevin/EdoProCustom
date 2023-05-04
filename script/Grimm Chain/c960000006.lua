-- Alliance with the Black Winged Chain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcEqual{handler=c,filter=s.ritualfil,location=LOCATION_HAND|LOCATION_REMOVED,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg}
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CONTRACTOR,SET_GRIMM_CHAIN}

function s.ritualfil(c)
	return c:IsSetCard(SET_GRIMM_CHAIN) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not c:IsType(TYPE_RITUAL) and c:IsSetCard(SET_GRIMM_CHAIN) and c:HasLevel() and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
	else
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil):Filter(aux.nvfilter,nil)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(Card.IsSetCard,nil,SET_GRIMM_CHAIN)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end