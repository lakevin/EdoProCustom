--V-EYE-RUS - Spoofing
local s,id=GetID()
local SET_VEYERUS=0x9DD0
function s.initial_effect(c)
	-- (1) Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_HANDES)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DRAW)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
	-- (2) draw & discard
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VEYERUS}

-- (1)
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.cfilter,1,nil,1-tp)
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r&REASON_EFFECT~=0 and rp==ep
end

function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VEYERUS) and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,30459350) end
	Duel.SetTargetCard(eg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g and #g>0 then
		Duel.ConfirmCards(tp,g)
		local sc=g:Select(tp,1,1,nil)
		if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil):Filter(aux.NOT(Card.IsStatus),nil,STATUS_BATTLE_DESTROYED)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			Duel.Overlay(tc,sc)
		else
			Duel.SendtoHand(sc,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
		end
		Duel.ShuffleHand(1-tp)
	end
end

-- (2)
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    -- 0x4040 => REASON_EFFECT+REASON_DISCARD
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&0x4040)==0x4040
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		if Duel.SSet(tp,c)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end