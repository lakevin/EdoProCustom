--Shadowblade - Surprise Assault
local SET_SHADOWBLADE=0xB64A
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADOWBLADE}

-- (1)
function s.filter(c,e)
	return c:IsFacedown() and c:IsRelateToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,99,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter,nil,e)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,true)
	local ct=g:FilterCount(Card.IsSetCard,nil,SET_SHADOWBLADE)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

-- (2)
function s.spfilter1(c,e,tp)
	return c:IsSetCard(SET_SHADOWBLADE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter2(c,e,tp,code)
	return c:IsSetCard(SET_SHADOWBLADE) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
	local og=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp,sc:GetCode())
	local oc=og:GetFirst()
	local g=Group.FromCards(sc,oc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	e:SetLabelObject(sc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local oc=g:GetFirst()
	if oc==sc then oc=g:GetNext() end
	if sc then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if oc:IsRelateToEffect(e) then
		Duel.SpecialSummonStep(oc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end

--[[
	function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_HAND) and s.spfilter1(chkc,e,tp) end
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
			and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
		e:SetLabelObject(sg:GetFirst())
	end
	function s.spop(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sc=e:GetLabelObject()
		if sc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			-- Special Summon to opponent's side of field
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
			local og=Duel.SelectTarget(1-tp,s.spfilter2,1-tp,LOCATION_GRAVE,0,1,1,nil,e,tp,sc:GetCode())
			local oc=og:GetFirst()
			if oc:IsRelateToEffect(e) then
				Duel.SpecialSummonStep(oc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			end
		end
	end
]]