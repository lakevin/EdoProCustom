--Malware Core Component
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	-- (1) Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) change level
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.select_option)
	c:RegisterEffect(e2)
	-- (3) Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VEYERUS}

-- (1)
function s.filter(c,e,tp)
	return c:IsSetCard(SET_VEYERUS) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp) -- Add to hand
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- (2) Select Option
function s.select_option(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- (1) "V-EYE-RUS" monster that has a Level
	local b1=s.lvtg1(e,tp,eg,ep,ev,re,r,rp,0)
	-- (2) "V-EYE-RUS" XYZ monster
	local b2=s.lvtg2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=0
	else
		op=1
	end
	e:SetCategory(CATEGORY_LVCHANGE)
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	if op==0 then
		e:SetOperation(s.lvop1)
		s.lvtg1(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetOperation(s.lvop2)
		s.lvtg2(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
-- Option 1
function s.lvfilter1(c)
	return c:IsSetCard(SET_VEYERUS) and c:IsFaceup() and c:HasLevel()
end
function s.lvtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvop1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetMatchingGroupCount(s.lvfilter1,tp,LOCATION_MZONE,0,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct)
		tc:RegisterEffect(e1)
	end
end
-- Option 2
function s.lvfilter2(c)
	return c:IsSetCard(SET_VEYERUS) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvop2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetMatchingGroupCount(s.lvfilter2,tp,LOCATION_MZONE,0,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_RANK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct)
		tc:RegisterEffect(e1)
	end
end

-- (3)
function s.thfilter(c,turn)
	return c:IsSetCard(SET_VEYERUS) and c:IsReason(0x4040) and c:GetTurnID()==turn
		and c:IsPreviousLocation(LOCATION_HAND) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local turn=Duel.GetTurnCount()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc,turn) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,turn) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,turn)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end