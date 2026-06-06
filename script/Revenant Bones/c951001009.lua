-- Souleater of the Revenant Bones
local s,id=GetID()
local SET_REVENTANTS=0x9616
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 Rank 4 "Revenant Bones" Xyz Monsters
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)
	-- Must be Xyz Summoned using the correct materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- (1) atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- (2) Immune to monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- (3) Attach 1 face-up monster card to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.atcost)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_REVENTANTS}

-- Xyz Summon Procedure
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(4) and c:IsRace(RACE_ZOMBIE,xyz,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se
end

-- (1)
function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*1000
end

-- (2)
function s.efilter(e,te)
	local c=e:GetHandler()
	local tc=te:GetHandler()
	if not te:IsActiveType(TYPE_EFFECT) then return false end
	if not tc or tc==c or not tc:IsMonster() then return false end
	local ty=tc:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	return ty~=0 and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,ty)
end

-- (3)
function s.xyzmatfilter(c)
	return c:IsType(TYPE_XYZ)
end

function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup()
	local b1=c:CheckRemoveOverlayCard(tp,2,REASON_COST)
	local b2=og:IsExists(s.xyzmatfilter,1,nil)
	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,2)}, -- detach 2
			{true,aux.Stringid(id,3)}  -- detach 1 Xyz
		)
	elseif b1 then
		op=1
	else
		op=2
	end
	if op==1 then
		c:RemoveOverlayCard(tp,2,2,REASON_COST)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=og:FilterSelect(tp,s.xyzmatfilter,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.atfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsAbleToChangeControler()
		and not c:IsType(TYPE_TOKEN) 
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.atfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end

