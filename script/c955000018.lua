-- Protectrix Zerastia
local s,id=GetID()
function c955000018.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),s.matfilter)
	--1) cannot disable spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c955000018.effcon)
	c:RegisterEffect(e1)
	--2) lvchange
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67136033,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c955000018.lvtg)
	e2:SetOperation(c955000018.lvop)
	c:RegisterEffect(e2)
	--3) xyz limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetValue(c955000018.xyzlimit)
	c:RegisterEffect(e3)
	--4) cannot target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--5) indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c955000018.indval)
	c:RegisterEffect(e5)
	--6) todeck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(12369277,1))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,12369278)
	e6:SetTarget(c955000018.tdtg)
	e6:SetOperation(c955000018.tdop)
	c:RegisterEffect(e6)
end

--fusion material
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x9990) and c:IsType(0x800000)
end

--1)
function c955000018.effcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION
end

--2)
function c955000018.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:GetLevel()==4
end
function c955000018.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c955000018.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function c955000018.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c955000018.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

--3)
function c955000018.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_PSYCHO)
end

--5)
function c955000018.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

--6)
function c955000018.tdfilter(c)
	return c:IsSetCard(0x9990) and c:IsType(TYPE_TRAP) and c:IsAbleToDeck()
end
function c955000018.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c955000018.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c955000018.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c955000018.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c955000018.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end