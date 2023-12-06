--Shadowblade Witcher
local SET_SHADOWBLADE=0xB64A
local SET_HOLYGRAIL=0xAD9C
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),2,nil,s.lcheck)
	c:EnableReviveLimit()
	-- Set 1 "Shadowblade" Spell/Trap directly from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- (2) Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADOWBLADE}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_SHADOWBLADE,lc,sumtype,tp)
end

-- (1)
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_SHADOWBLADE) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.scfilter(c,ignore)
	return c:IsSetCard(SET_SHADOWBLADE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local sc=g:GetFirst()
			if sc:IsTrap() and Duel.SSet(tp,sc)>0 then
				--It can be activated this turn
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,1))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
		end
	end
end

-- (2)
function s.fufilter(c,g)
	return c:IsFaceup() and g:IsContains(c) and c:IsCanTurnSet()
end
function s.fdfilter(c,g)
	return c:IsFacedown() and g:IsContains(c) and c:IsCanChangePosition()
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and g:IsContains(chkc) end
	local b1=Duel.IsExistingTarget(s.fufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g)
	local b2=Duel.IsExistingTarget(s.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	if op==0 then
		e:SetOperation(s.fuop)
		Duel.SelectTarget(tp,s.fufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	else
		e:SetOperation(s.fdop)
		Duel.SelectTarget(tp,s.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
end
function s.fuop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
