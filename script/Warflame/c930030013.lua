--Grand Warflame Tian
local SET_HOLYGRAIL=0xAD9C
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,nil,s.lcheck)
	c:EnableReviveLimit()
    -- (1) multi attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(s.atkfilter)
	c:RegisterEffect(e1)
	-- (2) atk gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- atk lose
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkdowncon)
	e3:SetTarget(s.atkdowntg)
	e3:SetValue(s.atkdownval)
	c:RegisterEffect(e3)
	-- (3) destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_WARFLAME}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_WARFLAME,lc,sumtype,tp)
end

-- (1)
function s.atkfilter(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:IsContains(c)
end

-- (2)
function s.atkval(e,c)
	local g=e:GetHandler():GetMutualLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end

function s.atkdowncon(e)
	return e:GetHandler():GetLinkedGroupCount()>0
end
function s.atkdowntg(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:IsContains(c)
end
function s.atkdownval(e,c)
	local g=e:GetHandler():GetMutualLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)*-1
end

-- (3)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk1=c:GetAttack()
	local tc=Duel.GetFirstTarget()
	local atk2=tc:GetAttack()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and s.desfilter(tc,atk1) then
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.Damage(1-tp,atk1-atk2,REASON_EFFECT)
	end
end