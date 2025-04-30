-- Shimmerbane Decoy
local s,id=GetID()
local SET_SHIMMERBANE=0x9617
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	-- (1.1) Change battle target
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- (1.2) Change battle target
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_SHIMMERBANE}

-- (1.1)
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.filter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_SHIMMERBANE,0x21+0x1000,1800,1000,4,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_SHIMMERBANE,0x21+0x1000,1800,1000,4,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP,ATTRIBUTE_DARK,RACE_FIEND,4,1800,1000)
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(c)
	end
end

-- (1.2)
function s.cfilter(c,ft)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(SET_SHIMMERBANE) 
		and (ft>0 or c:GetSequence()<5)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,Duel.GetLocationCount(tp,LOCATION_MZONE))
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local mzone_ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local szone_ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return mzone_ft>0 and szone_ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_SHIMMERBANE,0x21+0x1000,1800,1000,4,RACE_FIEND,ATTRIBUTE_DARK) end
	local g=eg:Filter(s.cfilter,nil,mzone_ft)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local tc=g:GetFirst()
	local spcond=Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_SHIMMERBANE,0x21+0x1000,1800,1000,4,RACE_FIEND,ATTRIBUTE_DARK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if tc:IsRelateToEffect(e) and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true) and spcond then
		Duel.NegateEffect(ev)
		Duel.BreakEffect()
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP,ATTRIBUTE_DARK,RACE_FIEND,4,1800,1000)
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end