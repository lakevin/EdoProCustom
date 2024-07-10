-- Pact with the Black Winged Chain
local s,id=GetID()
local SET_CONTRACTOR=0x9998
local SET_GRIMM_CHAIN=0x9999
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
	if Duel.IsExistingMatchingCard(s.ckfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) then
		return c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
	end
	return c:IsLocation(LOCATION_ONFIELD)
end
function s.mfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_GRIMM_CHAIN) and c:IsAbleToDeck()
end
function s.ckfilter(c,e,tp)
	return c:IsSetCard(SET_CONTRACTOR)
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(s.ckfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	end
	return Group.CreateGroup()
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED):Filter(s.mfilter,nil)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.rmop)
	Duel.RegisterEffect(e1,tp)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
end