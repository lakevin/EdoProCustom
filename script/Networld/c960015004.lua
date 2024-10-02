--Networld Anomaly - Darkweb Overlay
local s,id=GetID()
local SET_NETWORLD=0x9DD2
function s.initial_effect(c)
	-- (1) Xyz summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) Attach material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NETWORLD}

-- (1)
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and not c:IsType(TYPE_TOKEN)
end
function s.xyzfilter(c,mg,sc,set)
	local reset={}
	if not set then
		for tc in aux.Next(mg) do
			local e1=Effect.CreateEffect(sc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_XYZ_MATERIAL)
			tc:RegisterEffect(e1)
			table.insert(reset,e1)
		end
	end
	local res=c:IsXyzSummonable(nil,mg,#mg,#mg) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE)
	for _,te in ipairs(reset) do
		te:Reset()
	end
	return res 
end
function s.rescon(set)
	return function(sg,e,tp,mg)
				return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg,e:GetHandler(),set)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,nil,nil,s.rescon(false),0) end
	local reset={}
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		tc:RegisterEffect(e1)
		table.insert(reset,e1)
	end
	local tg=aux.SelectUnselectGroup(mg,e,tp,nil,nil,s.rescon(true),1,tp,HINTMSG_XMATERIAL,s.rescon(true))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	for _,te in ipairs(reset) do
		te:Reset()
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local reset={}
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		table.insert(reset,e1)
	end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,c,true)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,g)
	else
		for _,te in ipairs(reset) do
			te:Reset()
		end
	end
end

-- (2)
function s.atchfilter(c,atk)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsAttackBelow(atk)
end
function s.xyzfilter2(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsType(TYPE_XYZ) and
	       Duel.IsExistingTarget(s.atchfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local xyzc=Duel.SelectTarget(tp,s.xyzfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,s.atchfilter,tp,0,LOCATION_MZONE,1,1,nil,xyzc:GetAttack())
	e:SetLabelObject(xyzc)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=1 then return end
	local xyzc,tgc=(function()
		local c1=g:GetFirst()
		local c2=g:GetNext()
		if c1==e:GetLabelObject() then return c1,c2 else return c2,c1 end
	end)()
	if xyzc:IsRelateToEffect(e) and xyzc:IsControler(tp) and tgc:IsRelateToEffect(e) and tgc:IsControler(1-tp)
		and not xyzc:IsImmuneToEffect(e) and not tgc:IsImmuneToEffect(e) then
		Duel.Overlay(xyzc,tgc,true)
	end
end