--Dodo, the Black Winged Chain
local s,id=GetID()
Duel.LoadScript("GrimmChainAux.lua")
local SET_GRIMM_CHAIN=0x9999
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	GrimmChain.AddContractorSearch(c,id,960000003,1)
	--Create an illusion during either Main Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--The illusion protects all of your Grimm Chain Ritual Monsters.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.protcon)
	e2:SetTarget(s.prottg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e3)
end
s.listed_names={960000003,960000014}
s.listed_series={SET_GRIMM_CHAIN}
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_GRIMM_CHAIN,TYPES_TOKEN,1000,1000,3,RACE_WINGEDBEAST,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_GRIMM_CHAIN,TYPES_TOKEN,1000,1000,3,RACE_WINGEDBEAST,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	local token=Duel.CreateToken(tp,id+1)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.protcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id+1),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.prottg(e,c)
	return c:IsSetCard(SET_GRIMM_CHAIN) and c:IsRitualMonster()
end
