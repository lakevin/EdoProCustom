--Shared procedures for Grimm Chain cards.
GrimmChain=GrimmChain or {}
local SET_GRIMM_CHAIN=0x9999

--Banish a Ritual Monster from the hand to find its named Contractor.
function GrimmChain.AddContractorSearch(c,id,contractor,description)
	local e=Effect.CreateEffect(c)
	e:SetDescription(aux.Stringid(id,description))
	e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e:SetType(EFFECT_TYPE_IGNITION)
	e:SetRange(LOCATION_HAND)
	e:SetCountLimit(1,{id,2})
	e:SetCost(Cost.SelfBanish)
	local function filter(tc)
		return tc:IsCode(contractor) and tc:IsAbleToHand()
	end
	e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end)
	e:SetOperation(function(e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end)
	c:RegisterEffect(e)
	return e
end

--Add a mutually exclusive, targeted return-from-banishment option to an
--existing Contractor's Summon trigger. Its original option remains intact.
function GrimmChain.AddContractReturnOption(e,id)
	local target=e:GetTarget()
	local operation=e:GetOperation()
	local category=e:GetCategory()
	local property=e:GetProperty()|EFFECT_FLAG_DELAY
	local function filter(c,e,tp)
		return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_GRIMM_CHAIN)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	e:SetDescription(aux.Stringid(id,2))
	e:SetCountLimit(1,id)
	e:SetProperty(property)
	e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then
			if e:GetLabel()==1 then return target(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and filter(chkc,e,tp)
		end
		local b1=target(e,tp,eg,ep,ev,re,r,rp,0)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		if chk==0 then return b1 or b2 end
		local choice=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		e:SetLabel(choice)
		if choice==1 then
			e:SetCategory(category)
			e:SetProperty(property)
			target(e,tp,eg,ep,ev,re,r,rp,1)
		else
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(property|EFFECT_FLAG_CARD_TARGET)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_REMOVED)
		end
	end)
	e:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetLabel()==1 then
			operation(e,tp,eg,ep,ev,re,r,rp)
		else
			local tc=Duel.GetFirstTarget()
			if tc and tc:IsRelateToEffect(e) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end)
end
