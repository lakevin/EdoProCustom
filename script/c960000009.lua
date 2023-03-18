-- Pact with the Black Winged Chain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcEqual{handler=c,filter=s.ritualfil,location=LOCATION_DECK|LOCATION_REMOVED,matfilter=s.mfilter,stage2=s.stage2}
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x9998,0x9999}

function s.mfilter(c)
	return c:IsLocation(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED) and c:HasLevel() and c:IsSetCard(0x9999) and c:IsAbleToDeck()
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
	Duel.Remove(sc,FACE_UP,SEQ_DECKSHUFFLE,REASON_EFFECT)
end