--Holy Grail - Adoration
local SET_HOLYGRAIL=0xAD9C
local COUNTER_GRAIL=0x4041
local SET_KNIGUARD=0xB1F3
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GRAIL)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- (1) add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- (2A) Add 1 "Kniguard" monster from your GY or banishment to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetCost(s.cost1)
	e4:SetTarget(s.tg1)
	e4:SetOperation(s.op1)
	c:RegisterEffect(e4)
	-- (2B) Special Summon 1 "Kniguard" monster from your hand.
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCost(s.cost2)
	e5:SetTarget(s.tg2)
	e5:SetOperation(s.op2)
	c:RegisterEffect(e5)
	-- (3) Can treat "Holy Grail" Spell cards as Link Material
	local e7a=Effect.CreateEffect(c)
	e7a:SetType(EFFECT_TYPE_FIELD)
	e7a:SetCode(EFFECT_EXTRA_MATERIAL)
	e7a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e7a:SetRange(LOCATION_SZONE)
	e7a:SetTargetRange(1,0)
	e7a:SetCountLimit(1,{id,3})
	e7a:SetOperation(aux.TRUE)
	e7a:SetValue(s.extraval)
	c:RegisterEffect(e7a)
	local e7b=Effect.CreateEffect(c)
	e7b:SetType(EFFECT_TYPE_SINGLE)
	e7b:SetCode(EFFECT_ADD_TYPE)
	e7b:SetRange(LOCATION_SZONE)
	e7b:SetTargetRange(LOCATION_SZONE,0)
	e7b:SetCondition(s.addtypecon)
	e7b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e7b:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e7b)
	local e7c=Effect.CreateEffect(c)
	e7c:SetType(EFFECT_TYPE_SINGLE)
	e7c:SetCode(EFFECT_ADD_ATTRIBUTE)
    e7c:SetRange(LOCATION_SZONE)
	e7c:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e7c)
	local e7d=Effect.CreateEffect(c)
	e7d:SetType(EFFECT_TYPE_SINGLE)
	e7d:SetCode(EFFECT_ADD_SETCODE)
	e7d:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7d:SetRange(LOCATION_SZONE)
	e7d:SetValue(SET_KNIGUARD)
	c:RegisterEffect(e7d)
end
s.listed_series={SET_HOLYGRAIL,SET_KNIGUARD}
s.counter_place_list={COUNTER_GRAIL}

-- (1)
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(SET_KNIGUARD)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(COUNTER_GRAIL,1)
	end
end

-- (2A)
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_GRAIL,3,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.RemoveCounter(tp,1,0,COUNTER_GRAIL,3,REASON_COST)
end
function s.filter1(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_KNIGUARD) and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- (2B)
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_GRAIL,6,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.RemoveCounter(tp,1,0,COUNTER_GRAIL,6,REASON_COST)
end
function s.filter2(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_KNIGUARD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- (3)
function s.matfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_KNIGUARD) or c:IsSetCard(SET_HOLYGRAIL)) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and (sc:IsSetCard(SET_KNIGUARD) or sc:IsSetCard(SET_HOLYGRAIL))) then
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