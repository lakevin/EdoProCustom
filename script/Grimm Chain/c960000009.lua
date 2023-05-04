-- Pact with the Black Winged Chain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcEqual{handler=c,filter=s.ritualfil,location=LOCATION_DECK|LOCATION_HAND,matfilter=s.forcedgroup,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg,stage2=s.stage2}
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CONTRACTOR,SET_GRIMM_CHAIN}

function s.ritualfil(c)
	return c:IsSetCard(SET_GRIMM_CHAIN) and c:IsRitualMonster()
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_ONFIELD)
end
function s.mfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_GRIMM_CHAIN) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED):Filter(Card.IsSetCard,nil,SET_GRIMM_CHAIN)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetCondition(s.tdcon)
	e1:SetOperation(s.tdop)
	Duel.RegisterEffect(e1,tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and e:GetLabelObject():GetFlagEffect(id)>0
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
end