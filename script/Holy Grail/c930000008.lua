--Holy Grail - Battleground
local SET_HOLYGRAIL=0xAD9C
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- (1) Opponent's monsters must attack Link Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(s.atlimit)
	--e2:SetValue(aux.TargetBoolFunction(s.atkfilter))
	c:RegisterEffect(e2)
	-- (2) Prevent activations during battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- (3) Can treat "Holy Grail" Spell cards as Link Material
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_EXTRA_MATERIAL)
	e4a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e4a:SetRange(LOCATION_SZONE)
	e4a:SetTargetRange(1,0)
	e4a:SetCountLimit(1,{id,2})
	e4a:SetOperation(aux.TRUE)
	e4a:SetValue(s.extraval)
	c:RegisterEffect(e4a)
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_SINGLE)
	e4b:SetCode(EFFECT_ADD_TYPE)
	e4b:SetRange(LOCATION_SZONE)
	e4b:SetTargetRange(LOCATION_SZONE,0)
	e4b:SetCondition(s.addtypecon)
	e4b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e4b:SetValue(TYPE_MONSTER+TYPE_EFFECT)
	c:RegisterEffect(e4b)
	local e4c=Effect.CreateEffect(c)
	e4c:SetType(EFFECT_TYPE_SINGLE)
	e4c:SetCode(EFFECT_ADD_ATTRIBUTE)
    e4c:SetRange(LOCATION_SZONE)
	e4c:SetValue(ATTRIBUTE_FIRE+ATTRIBUTE_DARK)
	c:RegisterEffect(e4c)
	local e4d=Effect.CreateEffect(c)
	e4d:SetType(EFFECT_TYPE_SINGLE)
	e4d:SetCode(EFFECT_ADD_SETCODE)
	e4d:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4d:SetRange(LOCATION_SZONE)
	e4d:SetValue(SET_WARFLAME)
	c:RegisterEffect(e4d)
end
s.listed_series={SET_HOLYGRAIL,SET_WARFLAME}
s.counter_place_list={COUNTER_GRAIL}

-- (1)
function s.atkfilter(c)
	return c:IsLinkMonster() and c:IsSetCard(SET_WARFLAME)
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e)
end
function s.atlimit(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsContains(c)
end

-- (2)
function s.actcon(e)
	local bc=Duel.GetBattleMonster(e:GetHandlerPlayer())
	return bc and bc:IsFaceup() and bc:IsSetCard(SET_WARFLAME)
end

-- (3)
function s.matfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_WARFLAME) or c:IsSetCard(SET_HOLYGRAIL)) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and (sc:IsSetCard(SET_WARFLAME) or sc:IsSetCard(SET_HOLYGRAIL))) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end