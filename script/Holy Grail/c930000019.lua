--The Shadowblade of the Holy Grail
local SET_HOLYGRAIL=0xAD9C
local SET_SHADOWBLADE=0xB64A
local SET_KINGDOM_SHADOWS=930020009
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- Add 1 "Kingdom of Shadow" or "Holy Grail" Continous Spell to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADOWBLADE}

function s.matfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(SET_SHADOWBLADE,xyz,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end

-- (1)
function s.thfilter(c,tp)
	return c:IsCode(SET_KINGDOM_SHADOWS) or (c:IsSetCard(SET_HOLYGRAIL) and c:IsSpell() and c:IsType(TYPE_CONTINUOUS))
		and c:IsAbleToHand()
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end

-- (2)
function s.filter1(c,e,tp,lnk)
	local clnk=c:GetLink()
	return clnk>0 and c:IsLinkMonster() and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lnk+clnk)
end
function s.filter2(c,e,tp,lnk)
	return c:GetLink()==lnk and c:IsSetCard(SET_SHADOWBLADE) and c:IsType(TYPE_LINK)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter1(chkc,e,tp,e:GetHandler():GetLink()) end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
		and e:GetHandler():IsAbleToRemove()
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,e:GetHandler():GetLink()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp,e:GetHandler():GetLink())
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lnk=c:GetLink()+tc:GetLink()
	local g=Group.FromCards(c,tc)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lnk)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end