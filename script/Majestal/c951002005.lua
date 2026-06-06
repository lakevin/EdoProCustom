-- Majestal Hexagora
local s,id=GetID()
local SET_MAJESTAL=0x9615
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	Reflexxion.AddManifestProcedure(c)
	-- (SPELL) Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e3)
	-- (1) Special summon itself from hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetValue(s.hspval)
	c:RegisterEffect(e4)
	-- (2) Return both to hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.rhtg)
	e5:SetOperation(s.rhop)
	c:RegisterEffect(e5)
    -- (3) Add to hand / Special Summon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_MAJESTAL}

-- (SPELL)
function s.aclimit(e,re,tp)
	local cg=e:GetHandler():GetColumnGroup()
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsLocation(LOCATION_SZONE) and rc:IsFacedown()
		and cg:IsContains(rc)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local cg=e:GetHandler():GetColumnGroup()
	return cg:IsContains(c)
end

-- (1)
function s.cfilter(c)
	return c:IsFaceup() and c:IsSpellTrap()
end
function s.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	local lg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	for tc in aux.Next(lg) do
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,0,0,tp))
	end
	return 0,zone
end

-- (2)
function s.rhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.rhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local rg=Group.FromCards(c,tc)
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end

-- (3)
function s.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_MAJESTAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end