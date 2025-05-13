-- Majestal Orthodra
local s,id=GetID()
local SET_MAJESTAL=0x9615
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	Reflexxion.AddMajestalRuling(c)
	-- (SPELL) Fusion Summon (from S/T Zone)
	local params2 = {aux.FilterBoolFunction(Card.IsSetCard,SET_MAJESTAL),nil,s.fextra,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params2)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params2)))
	c:RegisterEffect(e1)
    -- (2) Move 1 "Majestal" to another S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MAJESTAL}

local function get_szone_seq_id(bit)
	local field_id=nil
	if bit==256 then
		field_id=0
	elseif bit==512 then
		field_id=1
	elseif bit==1024 then
		field_id=2
	elseif bit==2048 then
		field_id=3
	elseif bit==4096 then
		field_id=4
	end
	return field_id
end

-- (1)
function s.mfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsCode(id)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_SZONE,0,nil)
end

-- (2)
function s.mvfilter1(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
end
function s.mvfilter2(c,tp)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.mvfilter3,tp,LOCATION_SZONE,0,1,c)
end
function s.mvfilter3(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.mvfilter1,tp,LOCATION_SZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0
	local b2=Duel.IsExistingMatchingCard(s.mvfilter2,tp,LOCATION_SZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 end
	e:SetLabel(op)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local g=Duel.SelectMatchingCard(tp,s.mvfilter1,tp,LOCATION_SZONE,0,1,1,nil)
		if #g>0 and not g:GetFirst():IsImmuneToEffect(e) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local s=Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
			local nseq=get_szone_seq_id(s)
			Duel.MoveSequence(g:GetFirst(),nseq)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g1=Duel.SelectMatchingCard(tp,s.mvfilter2,tp,LOCATION_SZONE,0,1,1,nil,tp)
		local tc1=g1:GetFirst()
		if not tc1 then return end
		Duel.HintSelection(g1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g2=Duel.SelectMatchingCard(tp,s.mvfilter3,tp,LOCATION_SZONE,0,1,1,tc1)
		Duel.HintSelection(g2)
		local tc2=g2:GetFirst()
		Duel.SwapSequence(tc1,tc2)
	end
end

--[[ function s.seqfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.seqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_SZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
	if Duel.MoveSequence(tc,calc_seq_id(seq)) then
		-- Treat as Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end ]]
