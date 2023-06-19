-- Dormouse, Grimm Chain of the Abyss
local s,id=GetID()
local SET_CONTRACTOR=0x9998
local SET_GRIMM_CHAIN=0x9999
function s.initial_effect(c)
	-- (1) draw 1 card and negate effect monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	-- (2) turn set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_CONTRACTOR,SET_GRIMM_CHAIN}

-- (1) draw 1 card and negate effect monster
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp~=tp 
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e3)
		end
	end
end

-- (2)
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end