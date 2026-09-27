-- Obsidius, Shimmerbane Dragon of Crystadel
local s,id=GetID()
local SET_CRYSTADEL=0x9614
local SET_SHIMMERBANE=0x9617
local CARD_OBSIDIUS_WITCHER=951000002
Duel.LoadScript("ReflexxionsAux.lua")
function s.initial_effect(c)
	--Special Summon procedure
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.sprcon)
	e0:SetTarget(s.sprtg)
	e0:SetOperation(s.sprop)
	c:RegisterEffect(e0)
	--Set as a Continuous Trap
	Reflexxion.AddAmbushProcedure(c)
	--Ambush activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfChangePosition(POS_FACEUP))
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.ambushtg)
	e1:SetOperation(s.ambushop)
	Reflexxion.RegisterAmbushActivation(c,e1)
	--Shuffle up to 2 cards into the Deck, then draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Special Summon a Continuous Trap from the GY as a monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.traptg)
	e4:SetOperation(s.trapop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_OBSIDIUS_WITCHER}
s.listed_series={SET_CRYSTADEL,SET_SHIMMERBANE}

--Special Summon procedure
function s.matfilter(c,sc)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial(sc) and c:IsAbleToGrave()
end
function s.obsfilter(c,tp,sc)
	if not (c:IsCode(CARD_OBSIDIUS_WITCHER) and s.matfilter(c,sc)) then return false end
	return Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_MZONE,0,1,c,tp,sc,c)
end
function s.tunerfilter(c,tp,sc,oc)
	if not (c:IsType(TYPE_TUNER) and s.matfilter(c,sc)) then return false end
	local mg=Group.FromCards(oc,c)
	return Duel.GetLocationCountFromEx(tp,tp,mg,sc)>0
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.obsfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local oc=Duel.SelectMatchingCard(tp,s.obsfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c):GetFirst()
	if not oc then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_MZONE,0,1,1,oc,tp,c,oc):GetFirst()
	if not tc then return false end
	local mg=Group.FromCards(oc,tc)
	mg:KeepAlive()
	e:SetLabelObject(mg)
	return true
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	if not mg then return end
	Duel.SendtoGrave(mg,REASON_COST)
	mg:DeleteGroup()
end

--Ambush effect
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFacedown() and not c:IsStatus(STATUS_SET_TURN)
end
function s.exfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(10) and c:IsRace(RACE_FIEND|RACE_DRAGON)
		and c:IsAmbushMonster() and not c:IsCode(id)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.ambushtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra()
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ambushop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsAbleToExtra() then return end
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_EXTRA) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(function(e,te) return te:IsActivated() and te:GetOwnerPlayer()~=e:GetOwnerPlayer() end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		sc:RegisterEffect(e1)
	end
end

--Monster effect 1
function s.tdfilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--Monster effect 2
function s.trapfilter(c,e,tp)
	return c:IsContinuousTrap() and c:IsTrapMonster() and not c:IsForbidden()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_MONSTER|TYPE_EFFECT,
			c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
end
function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE)
		and aux.NecroValleyFilter(s.trapfilter)(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(aux.NecroValleyFilter(s.trapfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,aux.NecroValleyFilter(s.trapfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and s.trapfilter(tc,e,tp)) then return end
	tc:AddMonsterAttribute(TYPE_EFFECT)
	if tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		tc:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end
end
