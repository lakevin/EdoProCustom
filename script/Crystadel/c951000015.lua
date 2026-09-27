-- Realm of Prismatic Manifestation
local s,id=GetID()
local SET_MAJESTAL=0x9615
local CARD_MAJESTAL_AURORION=951002011
Duel.LoadScript("ReflexxionsAux.lua")
function s.initial_effect(c)
	-- Activate and add 1 Manifest Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Mandatory while the turn player controls no face-up Monster Card in their S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.forceplcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	-- Optional while the turn player controls a face-up Monster Card in their S/T Zone
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCondition(s.optplcon)
	c:RegisterEffect(e4)
	-- Allow opposing Monster Cards in the S/T Zone to be used for a later Fusion Summon this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
	e3:SetOperation(s.cmop)
	c:RegisterEffect(e3)
end

function s.thfilter(c)
	return c:IsManifestMonster() and c:IsOriginalType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.manifestfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
end
function s.gyfilter(c,e)
	return c:IsMonster() and c:GetTurnID()==Duel.GetTurnCount() and not c:IsForbidden()
		and c:IsCanBeEffectTarget(e)
end
function s.baseplcon(e,tp)
	local turnp=Duel.GetTurnPlayer()
	return Duel.GetLocationCount(turnp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.gyfilter,turnp,LOCATION_GRAVE,0,1,nil,e)
end
function s.forceplcon(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	return s.baseplcon(e,tp)
		and not Duel.IsExistingMatchingCard(s.manifestfilter,turnp,LOCATION_SZONE,0,1,nil)
end
function s.optplcon(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	return s.baseplcon(e,tp)
		and Duel.IsExistingMatchingCard(s.manifestfilter,turnp,LOCATION_SZONE,0,1,nil)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local turnp=Duel.GetTurnPlayer()
	if chkc then return chkc:IsControler(turnp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc,e) end
	if chk==0 then return Duel.GetLocationCount(turnp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.gyfilter,turnp,LOCATION_GRAVE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(turnp,s.gyfilter,turnp,LOCATION_GRAVE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,turnp,LOCATION_GRAVE)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(turnp,LOCATION_SZONE)<=0 then return end
	if Duel.MoveToField(tc,turnp,turnp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end

function s.cmfilter(c,e,banish)
	local able=banish and c:IsAbleToRemove() or (not banish and c:IsAbleToGrave())
	return c:IsCanBeFusionMaterial() and able
		and not c:IsImmuneToEffect(e) and (c:IsMonster()
			or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)))
end
function s.cmvalue(c,tp)
	return c:IsManifestMonster() or c:IsSetCard(SET_MAJESTAL)
end
function s.cmtarget(e,te,tp,value)
	if value and value&SUMMON_TYPE_FUSION==0 then return Group.CreateGroup() end
	local aurorion=te:GetHandler():IsCode(CARD_MAJESTAL_AURORION)
	local loc=LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE
	if aurorion then
		if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=loc|LOCATION_GRAVE end
	end
	return Duel.GetMatchingGroup(s.cmfilter,tp,loc,LOCATION_SZONE,nil,te,aurorion)
end
function s.cmoperation(e,te,tp,tc,mat,sumtype,sg,sumpos)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	if te:GetHandler():IsCode(CARD_MAJESTAL_AURORION) then
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	else
		Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	end
	Duel.BreakEffect()
	if sg then
		sg:AddCard(tc)
	else
		Duel.SpecialSummonStep(tc,sumtype,tp,tp,false,false,sumpos)
	end
	e:Reset()
end
function s.cmop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.cmtarget)
	e1:SetOperation(s.cmoperation)
	e1:SetValue(s.cmvalue)
	Duel.RegisterEffect(e1,tp)
end
