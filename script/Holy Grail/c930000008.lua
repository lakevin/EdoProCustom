--Holy Grail - Battleground
local s,id=GetID()
local SET_HOLYGRAIL=0xAD9C
local SET_WARFLAME=0xBAA1
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	-- Unique on field
	c:SetUniqueOnField(1,0,id)
	-- Can treat "Holy Grail" Spell cards as Link Material
	Reflexxion.SpellTrapAsLinkMaterial(c,s.matfilter,s.lnkfilter,ATTRIBUTE_FIRE+ATTRIBUTE_DARK,SET_WARFLAME)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- (1) Opponent's monsters must attack your "Warflame" monster with the highest ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	-- (2) Prevent activations during battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_series={SET_HOLYGRAIL,SET_WARFLAME}
s.counter_place_list={COUNTER_GRAIL}

-- Spell as Link material
function s.matfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_WARFLAME) or c:IsSetCard(SET_HOLYGRAIL)) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.lnkfilter(c)
	return c:IsSetCard(SET_WARFLAME) or c:IsSetCard(SET_HOLYGRAIL)
end

-- (1)
function s.atcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_WARFLAME),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.atlimit(e,c)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_WARFLAME),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetMaxGroup(Card.GetAttack):IsContains(c)
end

-- (2)
function s.actcon(e)
	local bc=Duel.GetBattleMonster(e:GetHandlerPlayer())
	return bc and bc:IsFaceup() and bc:IsSetCard(SET_WARFLAME)
end