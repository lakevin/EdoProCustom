-- The Crystadel Forest
local s,id=GetID()
local SET_CRYSTADEL=0x9614
local SET_SHIMMERBANE=0x9617
Duel.LoadScript("ReflexxionsAux.lua")
function s.initial_effect(c)
	--Activate and Set 1 Ambush Monster as a Continuous Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Opponent must Set Spell/Trap Cards before activating them
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--Inflict damage after an opponent's Set Spell/Trap Card resolves
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_REFLEXXION_MONSTER_EFFECT_IN_SZONE)
	e3b:SetCondition(s.mdamcon)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_CRYSTADEL,SET_SHIMMERBANE}

function s.setfilter(c)
	return c:IsAmbushMonster() and c:IsMonster() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or not Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local sc=g:GetFirst()
	if sc and Duel.SSet(tp,sc)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		sc:RegisterEffect(e1)
		sc:SetStatus(STATUS_SET_TURN,false)
	end
end

function s.emzfilter(c)
	return c:IsFaceup() and c:IsAmbushMonster()
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and not re:GetHandler():IsLocation(LOCATION_SZONE)
		and Duel.IsExistingMatchingCard(s.emzfilter,e:GetHandlerPlayer(),LOCATION_EMZONE,0,1,nil)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp then return false end
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_SZONE~=0
	end
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_SZONE==0 then return false end
	local ae={rc:IsHasEffect(EFFECT_REFLEXXION_AMBUSH_ACTIVATION)}
	for _,me in ipairs(ae) do
		if me:GetLabelObject()==re then return true end
	end
	return false
end
function s.mdamcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
