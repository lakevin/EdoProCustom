-- Sola, Keeper of Crystal Dragons
local s,id=GetID()
local SET_CRYSTADEL=0x9614
local SET_MAJESTAL=0x9615
local CARD_SOLA_CRYSTADEL=951000001
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Materials
	Fusion.AddProcMix(c,true,true,CARD_SOLA_CRYSTADEL,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON))
	-- Fusion.AddContactProc(c,function(tp) return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil) end,function(g) Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL) end,nil,nil,nil,nil,false)
	-- Manifest marker / activation as Continuous Spell
	Reflexxion.AddManifestProcedure(c)
	-- [Manifest Effect] copy another Manifest Monster's Manifest Effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.copycost)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	-- (1) Special Summon Manifest Monster from S/T Zone + negate column
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- (2) If Fusion Summoned card would be sent to GY, place in S/T Zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_CRYSTADEL}
s.listed_names={CARD_SOLA_CRYSTADEL}
s.miracle_synchro_fusion=true

-- Manifest Effect
function s.copycostfilter(c,fc)
	return c:IsManifestMonster()
		and c~=fc
		and c:IsAbleToRemoveAsCost()
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.copycostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,c,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.copycostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,c,c)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalCode())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if code==0 or not c:IsRelateToEffect(e) then return end
	local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN
	-- Name becomes that monster's name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	e1:SetReset(reset)
	c:RegisterEffect(e1)
	-- Copy that monster's original effects
	c:CopyEffect(code,reset,1)
end

-- (1)
function s.spfilter2(c,e,tp)
	return c:IsManifestMonster() and c:IsOriginalType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.spfilter2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Unaffected by opponent's traps
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3113)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end

-- (2)
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	c:RegisterEffect(e1)
end