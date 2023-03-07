--Draga
function c956000001.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--1) return target to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c956000001.thtg)
	e1:SetOperation(c956000001.thop)
	c:RegisterEffect(e1)
	--2) negate destruction by effect
	--local e2=Effect.CreateEffect(c)
	--e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	--e2:SetType(EFFECT_TYPE_FIELD)
	--e2:SetRange(LOCATION_PZONE)
	--e2:SetTargetRange(LOCATION_MZONE,0)
	--e2:SetTarget(c956000001.target)
	--e2:SetValue(1)
	--c:RegisterEffect(e2)	
end

--1)
function c956000001.thfilter(c,tp)
	return c:GetLevel()==4 and c:IsSetCard(0x9995) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c956000001.spfilter(c,e,tp)
	return c:GetLevel()==6 and c:IsSetCard(0x9995) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c956000001.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c956000001.thfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(c956000001.thfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c956000001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c956000001.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c956000001.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c956000001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--2)
--function c956000001.target(e,c)
--	return c~=e:GetHandler() and c:IsSetCard(0x9995)
--end