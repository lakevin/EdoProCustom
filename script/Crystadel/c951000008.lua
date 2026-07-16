-- The Crystadel Origin - Dragon Vein
local s,id=GetID()
local SOLA_WIZARD=951000001
Duel.LoadScript("ReflexxionsAux.lua")

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={SOLA_WIZARD}

-- First effect
function s.sendfilter(c,tp)
	return c:IsAbleToGrave()
		and ((c:IsControler(tp) and c:IsOnField() and c:IsManifestMonster())
		or (c:IsLocation(LOCATION_SZONE) and c:IsOriginalType(TYPE_MONSTER)))
end
function s.solafilter(c,e,tp)
	return c:IsCode(SOLA_WIZARD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.solaplacefilter(c)
	return c:IsCode(SOLA_WIZARD) and not c:IsForbidden()
end

-- Second effect
function s.solacheck(c)
	return c:IsCode(SOLA_WIZARD)
end
function s.plfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsManifestMonster() and not c:IsForbidden()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hg=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_ONFIELD,LOCATION_SZONE,e:GetHandler(),tp)
	local b1=#hg>0
		and ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.solaplacefilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
		or (#hg>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.solafilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)))
	local b2=Duel.IsExistingMatchingCard(s.solacheck,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end

	local op
	if b1 and b2 then
		op=Duel.SelectEffect(tp,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})
	elseif b1 then
		op=1
	else
		op=2
	end
	e:SetLabel(op)

	if op==1 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	else
		e:SetCategory(0)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_ONFIELD,LOCATION_SZONE,e:GetHandler(),tp)
		if #g==0 then return end

		local max=1
		if #g>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.solafilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) then
			max=2
		end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g=g:Select(tp,1,max,nil)
		local ct=Duel.SendtoGrave(g,REASON_EFFECT)
		if ct==0 then return end

		if ct>=2 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.solafilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
		else
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=Duel.SelectMatchingCard(tp,s.solaplacefilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
			if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				s.makecontinuous(tc,e:GetHandler())
			end
		end
	else
		if not Duel.IsExistingMatchingCard(s.solacheck,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
			or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			s.makecontinuous(tc,e:GetHandler())
		end
	end
end

function s.makecontinuous(c,handler)
	local e1=Effect.CreateEffect(handler)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	c:RegisterEffect(e1)
end