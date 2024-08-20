--V-EYE-RUS - Denial of Service
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- (1) atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- (2) cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_VEYERUS))
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- (3) --Attach 1 card from the GY to a "V-EYE-RUS" Xyz Monster you control
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.mattg)
	e5:SetOperation(s.matop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_VEYERUS}

-- (1)
function s.atktg(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_VEYERUS)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*200
end

-- (2)


-- (3)
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_VEYERUS)
end
function s.atchfilter(c,tp)
	return c:IsControler(tp) or c:IsAbleToChangeControler()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.atchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local xyzc=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	e:SetLabelObject(xyzc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local tc=Duel.SelectTarget(tp,s.atchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local tc=g:GetFirst()
	local xyzc=g:GetNext()
	if tc==e:GetLabelObject() then tc,xyzc=xyzc,tc end
	Duel.Overlay(xyzc,tc)
end