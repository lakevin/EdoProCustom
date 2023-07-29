--Cosmoverse Planet Conqueror
local s,id=GetID()
local CARD_COSMO_QUEEN=38999506
local SET_COSMOVERSE=0x9995
function s.initial_effect(c)
	--Must be properly summoned before reviving
	Xyz.AddProcedure(c,s.mfilter,9,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	-- (1) attack all
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- (2) atk down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- (3) boost attack of "cosmoverse" monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetHintTiming(TIMING_DAMAGE_STEP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.atkcon)
	e4:SetCost(s.atkcost)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_COSMOVERSE}
s.listed_names={id,CARD_COSMO_QUEEN}

-- xyz
function s.mfilter(c,xyz,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,xyz,sumtype,tp)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsCode(CARD_COSMO_QUEEN) and c:IsType(TYPE_XYZ) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

-- (2)
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_COSMOVERSE),e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)*-500
end

-- (3)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local tc=Duel.GetAttacker()
	return tc:IsControler(tp) and tc:IsRelateToBattle() and tc:IsSetCard(SET_COSMOVERSE) and Duel.GetAttackTarget()~=nil
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
	end
end