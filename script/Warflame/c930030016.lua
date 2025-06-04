--Warflame Qilin
local SET_HOLYGRAIL=0xAD9C
local SET_WARFLAME=0xBAA1
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- (1) Negate the opponent's effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e1)
	-- (2) Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- (3) destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WARFLAME}

-- (1)
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=ev-1
	if ch==0 or not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch_player,ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	local ch_c=ch_eff:GetHandler()
	return ch_player==tp and ch_c:IsSetCard(SET_WARFLAME) and ch_eff:IsMonsterEffect()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

-- (2)
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WARFLAME) and c:IsLinkMonster() and c:GetLink()<=2 
		and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c,0x60)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,0x60) then
		--Cannot attack
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

-- (3)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk1=c:GetAttack()
	local tc=Duel.GetFirstTarget()
	local atk2=tc:GetAttack()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and s.desfilter(tc,atk1) then
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.Damage(1-tp,atk1-atk2,REASON_EFFECT)
	end
end