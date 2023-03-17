-- Alliance with the Black Winged Chain
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(id,0))
	--[[e1:SetCondition(s.spcon1)
	c:RegisterEffect(e1)
	-- (2) Activate
	local e2=Ritual.CreateProc({handler=c,filter=s.ritualfil2,lvtype=RITPROC_EQUAL,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup})
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(id,1))
	--e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- (3) Activate
	local e3=Ritual.CreateProc({handler=c,filter=s.ritualfil3,lvtype=RITPROC_EQUAL,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup})
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetDescription(aux.Stringid(id,2))
	--e3:SetCondition(s.spcon3)
	c:RegisterEffect(e3)]]--
end

s.listed_series={0x9999}
s.listed_names={960000011,960000012,960000013}

-- (1)
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(960000001)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ritualfil1(c)
	return c:IsCode(960000011) and c:IsRitualMonster()
end

-- (2)
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(960000002)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ritualfil2(c)
	return c:IsCode(960000012) and c:IsRitualMonster()
end

-- (3)
function s.cfilter3(c)
	return c:IsFaceup() and c:IsCode(960000003)
end
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ritualfil3(c)
	return c:IsCode(960000013) and c:IsRitualMonster()
end

-- Generic
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroup(tp,LOCATION_DECK,0)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	return Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x9999) and c:IsAbleToRemoveAsCost()
end