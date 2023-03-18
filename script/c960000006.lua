-- Alliance with the Black Winged Chain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcEqual{handler=c,filter=s.ritualfil,location=LOCATION_HAND|LOCATION_REMOVED,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg}
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x9998,0x9999}
function s.ritualfil(c)
	return c:IsSetCard(0x9999) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not c:IsType(TYPE_RITUAL) and c:IsSetCard(0x9999) and c:HasLevel() and c:IsAbleToRemove()
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
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(Card.IsSetCard,nil,0x9999)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end