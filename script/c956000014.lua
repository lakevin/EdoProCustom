--Draconier Swordsman
function c956000014.initial_effect(c)
	--1) Special Summon Success
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c956000014.indescon)
	e1:SetOperation(c956000014.indesop)
	c:RegisterEffect(e1)
	--2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23571046,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c956000014.sptg)
	e2:SetOperation(c956000014.spop)
	c:RegisterEffect(e2)
	--3) Return To Hand + Search
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c956000014.thcon)
	e3:SetTarget(c956000014.thtg)
	e3:SetOperation(c956000014.thop)
	c:RegisterEffect(e3)
end

--1)
function c956000014.indescon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x9995)
end
function c956000014.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(c956000014.efilter)
		e4:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e4)
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
function c956000014.efilter(e,te)
	if not te:IsActiveType(TYPE_MONSTER) then return false end
	local c=e:GetHandler()
	local ec=te:GetHandler()
	if ec:IsHasCardTarget(c) then return true end
	return te:IsHasType(EFFECT_TYPE_ACTIONS) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsRelateToEffect(te)
end

--2)
function c956000014.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c956000014.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e5:SetReset(RESET_EVENT+0x47e0000)
		e5:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e5,true)
	end
end

--3)
function c956000014.thfilter(c,e,tp)
	return c:IsSetCard(0x9995) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function c956000014.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE
end
function c956000014.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c956000014.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c956000014.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.IsExistingTarget(c956000014.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,c956000014.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function c956000014.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
