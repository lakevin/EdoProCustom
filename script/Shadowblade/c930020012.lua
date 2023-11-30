--Shadowblade - Darkening Veil
local SET_SHADOWBLADE=0xB64A
local s,id=GetID()
function s.initial_effect(c)
	-- (1) Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- (2) Flip Facedown
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.fdtg)
	e2:SetOperation(s.fdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SHADOWBLADE}

-- (1)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.filter(c,e,sp)
	return c:IsMonster() and c:IsSetCard(SET_SHADOWBLADE) and not c:IsType(TYPE_LINK)
		and c:IsCanBeSpecialSummoned(e,0,sp,false,false) 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local cg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=cg:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end

-- (2)
function s.fdfilter(c,g)
	return g:IsContains(c) and c:IsCanTurnSet()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	if chk==0 then return eg and eg:IsExists(s.fdfilter,1,nil,cg) end
	local g=eg:Filter(s.fdfilter,nil,cg)
	Duel.SetTargetCard(g)
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end