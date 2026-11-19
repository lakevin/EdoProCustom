-- Headhunter, Grimm Chain of the Abyss
local s,id=GetID()
local SET_CONTRACTOR=0x9998
local SET_GRIMM_CHAIN=0x9999
local CARD_INTENTION=960000023
local CARD_ALLIANCE=960000006
local CARD_PACT=960000009
local TRIBUTE_FLAGS=EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY
function s.initial_effect(c)
	--Synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_DARK),2,99,s.matfilter)
	c:EnableReviveLimit()
	-- (1) destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- (2) Search or recover when Tributed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(TRIBUTE_FLAGS)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CONTRACTOR,SET_GRIMM_CHAIN}
s.listed_names={CARD_INTENTION,CARD_ALLIANCE,CARD_PACT}

-- synchro material
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_CONTRACTOR,scard,sumtype,tp)
end

-- (1) Destroy the battling monster and revive a banished Grimm Chain
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GRIMM_CHAIN) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
			if tg and Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tg:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tg:RegisterEffect(e2)
				if not tg:IsLevel(9) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_CHANGE_LEVEL)
					e3:SetValue(9)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tg:RegisterEffect(e3)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end

-- (2)
function s.searchfilter(c)
	return c:IsCode(CARD_INTENTION) and c:IsAbleToHand()
end
function s.recoverfilter(c)
	return c:IsCode(CARD_ALLIANCE,CARD_PACT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local recoverfilter=aux.NecroValleyFilter(s.recoverfilter)
	if chkc then
		return e:GetLabel()==2 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and recoverfilter(chkc)
	end
	local can_search=Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil)
	local can_recover=Duel.IsExistingTarget(recoverfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return can_search or can_recover end
	local choice=Duel.SelectEffect(tp,{can_search,aux.Stringid(id,3)},{can_recover,aux.Stringid(id,4)})
	e:SetLabel(choice)
	if choice==1 then
		e:SetProperty(TRIBUTE_FLAGS)
		e:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetProperty(TRIBUTE_FLAGS|EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,recoverfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and aux.NecroValleyFilter(s.recoverfilter)(tc) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

-- don't delete, cuz useful for alter
--[[function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--cannot trigger
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetTargetRange(0,LOCATION_ALL)
	e1:SetValue(1)
	e1:SetTarget(s.attg)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.attg(e,c)
	local ty=c:GetType() & (TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	if ty==0 then return false end
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,ty)
end]]--
