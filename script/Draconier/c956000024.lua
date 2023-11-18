--Draconier Avatnir
local s,id=GetID()
local SET_DRACONIER=0x9992
function s.initial_effect(c)
	--Synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x9992),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_DRAGON),1,99)
	c:EnableReviveLimit()
	--Pendulum attributes
	Pendulum.AddProcedure(c,false)
	--Cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efindes)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.btindes)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(s.efindes)
	c:RegisterEffect(e3)
	-- (2) Change attribute
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.attcon)
	e4:SetTarget(s.atttg)
	e4:SetOperation(s.attop)
	c:RegisterEffect(e4)
	-- (3) Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	-- (4) Place itself in the pendulum zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
	-- (5) [ PENDULUM EFFECT ]
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
end

-- cannot be targeted + destroyed
function s.btindes(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
function s.efindes(e,re,rp)
	local c=e:GetHandler()
	return re:GetHandler():IsAttribute(c:GetAttribute()) and re:IsActivated() and rp==1-c:GetControler()
end

-- (2)
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local aat=e:GetHandler():AnnounceAnotherAttribute(tp)
	e:SetLabel(aat)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end

-- (3)
function s.cfilter(c,tp)
	return c:IsMonster() and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c:GetAttribute())
end
function s.desfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil,tp)
	e:SetLabel(g:GetFirst():GetAttribute())
	Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local attr=e:GetLabel()
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,attr)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,LOCATION_ONFIELD,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- (4)
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_EFFECT+REASON_BATTLE~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- (5) Pendulum Effect
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9992) and c:IsRace(RACE_DRAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) and chkc:IsDifferentAttribute(e:GetLabel()) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.AND(s.filter,Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,0,nil,e)
	local att=Duel.AnnounceAnotherAttribute(g,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sel=g:FilterSelect(tp,Card.IsDifferentAttribute,1,1,nil,att)
	Duel.SetTargetCard(sel)
	e:SetLabel(att)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end