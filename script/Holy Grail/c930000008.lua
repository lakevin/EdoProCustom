--Holy Grail - Battleground
local SET_HOLYGRAIL=0xAD9C
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- (1) "Warflame" monsters become DARK monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_WARFLAME))
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	-- (2) to deck / Special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.cond)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
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

-- (2)
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
	-- (2A)
function s.filter1(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_WARFLAME) and c:IsAbleToDeck()
end
	-- (2B)
function s.filter2(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_WARFLAME) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter1(chkc) end
	local c=e:GetHandler()
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local b2=Duel.GetMZoneCount(tp,e:GetHandler())>0 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- Target 1 "Warflame" card that is banished or in your GY, shuffle it into your Deck, then draw 1 card.
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=1 then return end
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==1 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif op==2 then
		--Special Summon 1 "Warflame" monster from your Deck in face-up Attack Position.
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
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