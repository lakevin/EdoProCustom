-- Crystal Beast Majestal
local s,id=GetID()
local SET_MAJESTAL=0x9615
local SET_CRYSTALBEAST=0x1034
Duel.LoadScript('ReflexxionsAux.lua')
function s.initial_effect(c)
	Reflexxion.AddManifestProcedure(c)
	-- (SPELL) To hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- (1) tribute summon with continuous spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    -- (2) send replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(s.repcon)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAJESTAL}

-- (SPELL)
function s.cfilter(c)
	return (c:IsSetCard(SET_MAJESTAL) or c:IsSetCard(SET_CRYSTALBEAST)) and c:IsFaceup() and not c:IsForbidden()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

-- (1)
function s.spfilter(c)
	return c:IsFaceup() and (c:IsMonster() or c:IsType(TYPE_SPELL+TYPE_CONTINUOUS))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_SZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and aux.SelectUnselectGroup(g,e,tp,2,2,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_SZONE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,nil,1,tp,HINTMSG_RELEASE)
	local has_spell=sg:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	local has_monster=sg:IsExists(Card.IsMonster,1,nil)
	local label=0
	if has_spell then label=label+1 end
	if has_monster then label=label+2 end
	e:GetHandler():RegisterFlagEffect(id,(RESET_EVENT|RESETS_STANDARD_DISABLE)&~RESET_TOFIELD,0,1,label)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if sg then
		Duel.Release(sg,REASON_COST)
		sg:DeleteGroup()
	end
end

-- (2)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local label=c:GetFlagEffectLabel(id)
	local b_spell=label and (label&1)~=0
	local b_monster=label and (label&2)~=0
	if chk==0 then
		return (b_spell and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_SZONE,1,nil))
			or (b_monster and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=c:GetFlagEffectLabel(id)
	if not label then return end
	local b_spell=(label&1)~=0
	local b_monster=(label&2)~=0
	-- Spell: Destroy 1 Spell/Trap your opponent controls.
	if b_spell and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_SZONE,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_SZONE,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	-- Monster: Destroy 1 monster your opponent controls.
	if b_monster and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

-- (3)
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end