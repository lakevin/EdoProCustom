-- Souleater of the Revenant Bones
local s,id=GetID()
local SET_REVENTANTS=0x9616
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 3 Rank 4 "Revenant Bones" Xyz Monsters
	Xyz.AddProcedure(c,s.xyzfilter,nil,3,nil,nil,nil,nil,false)
	-- Alternative Xyz Summon: 1 Rank 8 Zombie Xyz + 1 Rank 4 Zombie Xyz
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.xyzcon)
	e3:SetOperation(s.xyzop)
	e3:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e3)
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
	-- (2) Prevent the activation of effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(0,LOCATION_ALL)
	e2:SetValue(1)
	e2:SetTarget(s.aclimit)
	c:RegisterEffect(e2)
	-- (3) Attach 1 face-up monster card to this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_REVENTANTS}

-- Xyz Summon Procedure
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(4) and c:IsRace(RACE_ZOMBIE,xyz,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se
end

-- Alternative Xyz Summon
function s.matfilter1(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
		and c:IsRank(8) and c:IsControler(tp)
end
function s.matfilter2(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
		and c:IsRank(4) and c:IsControler(tp)
end
function s.xyzcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,c)
	if ft<=0 then return false end
	local g1=Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_MZONE,0,nil,tp) -- Rank 8 Zombie Xyz
	local g2=Duel.GetMatchingGroup(s.matfilter2,tp,LOCATION_MZONE,0,nil,tp) -- Rank 4 Zombie Xyz
	return #g1>0 and #g2>0
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local sc1=g1:GetFirst()
	local sc2=g2:GetFirst()
	-- Detach (send to GY) materials of the used Xyz Monsters
    if sc1 then
        local og1=sc1:GetOverlayGroup()
        if #og1>0 then
            Duel.SendtoGrave(og1,REASON_RULE)
        end
    end
    if sc2 then
        local og2=sc2:GetOverlayGroup()
        if #og2>0 then
            Duel.SendtoGrave(og2,REASON_RULE)
        end
    end
	-- Now use only the two Xyz Monsters themselves as material
	local mg=Group.FromCards(sc1,sc2)
	c:SetMaterial(mg)
	Duel.Overlay(c, mg)
end

-- (1)
function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount()*1200
end

-- (2)
function s.matfilter(c,ty)
    return c:IsOriginalType(TYPE_MONSTER) and c:IsOriginalType(ty)
end
function s.aclimit(e,rc)
    local ty=rc:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
    if ty==0 then return false end
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(s.matfilter,1,nil,ty)
end

-- (3)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_ZOMBIE) and c:IsRankBelow(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
			Duel.Overlay(tc,c)
		end
	end
	Duel.SpecialSummonComplete()
end