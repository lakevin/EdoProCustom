--Kniguard Richard, the Templar
local SET_KNIGUARD=0xB1F3
local COUNTER_GRAIL=0x4041
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GRAIL)
	--xyz summon
	Xyz.AddProcedure(c,s.matfilter,4,2,nil,nil,99)
	c:EnableReviveLimit()
    -- (1) Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.dxmcostgen(2,2,nil))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_KNIGUARD}
function s.matfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(SET_KNIGUARD,xyz,sumtype,tp)
end

-- (1)
function s.thfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsMonster() and c:IsAbleToHand() and c:GetOriginalLevel()>0
end
function s.ctfilter(c)
	return c:IsSetCard(SET_KNIGUARD) and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		for i=1,e:GetLabel() do
			local sg=g:Select(tp,1,1,nil)
			sg:GetFirst():AddCounter(COUNTER_GRAIL,1)
		end
	end
end

-- (2)
function s.filter(c,e,tp)
	return c:IsSetCard(SET_KNIGUARD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

