--Holy Grail - Mirage
local SET_HOLYGRAIL=0xAD9C
local SET_SHADOWBLADE=0xB64A
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- (1) extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SHADOWBLADE))
	c:RegisterEffect(e2)
	-- (2A) To Grave
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tg1)
	e3:SetOperation(s.op1)
	c:RegisterEffect(e3)
	-- (2B) special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.tg2)
	e4:SetOperation(s.op2)
	c:RegisterEffect(e4)
	-- (3) Can treat "Holy Grail" Spell cards as Link Material
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_FIELD)
	e5a:SetCode(EFFECT_EXTRA_MATERIAL)
	e5a:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e5a:SetRange(LOCATION_SZONE)
	e5a:SetTargetRange(1,0)
	e5a:SetCountLimit(1,{id,3})
	e5a:SetOperation(aux.TRUE)
	e5a:SetValue(s.extraval)
	c:RegisterEffect(e5a)
	local e5b=Effect.CreateEffect(c)
	e5b:SetType(EFFECT_TYPE_SINGLE)
	e5b:SetCode(EFFECT_ADD_TYPE)
	e5b:SetRange(LOCATION_SZONE)
	e5b:SetTargetRange(LOCATION_SZONE,0)
	e5b:SetCondition(s.addtypecon)
	e5b:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HOLYGRAIL))
	e5b:SetValue(TYPE_MONSTER+TYPE_EFFECT)
	c:RegisterEffect(e5b)
	local e5c=Effect.CreateEffect(c)
	e5c:SetType(EFFECT_TYPE_SINGLE)
	e5c:SetCode(EFFECT_ADD_ATTRIBUTE)
    e5c:SetRange(LOCATION_SZONE)
	e5c:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e5c)
	local e5d=Effect.CreateEffect(c)
	e5d:SetType(EFFECT_TYPE_SINGLE)
	e5d:SetCode(EFFECT_ADD_SETCODE)
	e5d:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5d:SetRange(LOCATION_SZONE)
	e5d:SetValue(SET_SHADOWBLADE)
	c:RegisterEffect(e5d)
end
s.listed_series={SET_HOLYGRAIL,SET_SHADOWBLADE}
s.counter_place_list={COUNTER_GRAIL}

-- (2A)
function s.filter1(c)
	return c:IsSetCard(SET_SHADOWBLADE) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- (2B)
function s.filter2(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_SHADOWBLADE) and not c:IsType(TYPE_LINK) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter2(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end

-- (3)
function s.matfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_SHADOWBLADE) or c:IsSetCard(SET_HOLYGRAIL)) and c:IsType(TYPE_CONTINUOUS) and c:IsCode(id)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and (sc:IsSetCard(SET_SHADOWBLADE) or sc:IsSetCard(SET_HOLYGRAIL))) then
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