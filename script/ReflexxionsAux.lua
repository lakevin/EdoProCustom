if not aux.ReflexxionsAux then
    aux.ReflexxionsAux = {}
    Reflexxion = aux.ReflexxionsAux
end

if not Reflexxion then
    Reflexxion = aux.ReflexxionsAux
end


-- [[ COSMOVERSE DEFAULTS ]]

--Parameters
-- c: the card that will receive the effect
-- atk: Increase the equipped monsters ATK by this value
-- def: Increase the equipped monsters DEF by this value
-- effect: Effect Code of the effect the equipped monsters gains
function Reflexxion.CosmoverseEquipHandler(c,atk,def,effcode,effval)
    --Increase ATK
    if atk==nil then atk=0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	c:RegisterEffect(e1)
    --Increase DEF
    if def==nil then def=0 end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(def)
	c:RegisterEffect(e2)
    --Gain Effect
    if effcode then
        if effval==nil then effval=1 end
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_EQUIP)
        e3:SetCode(effcode)
        e3:SetValue(effval)
        c:RegisterEffect(e3)
    end
end


-- [[ MAJESTAL DEFAULTS ]]

--Parameters
-- c: the card that will receive the effect
-- Majestal: Place in S/T Zone
function Reflexxion.AddMajestalRuling(c)
    local function activate(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        -- Treat as Continuous Spell
        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        c:RegisterEffect(e1)
    end
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetOperation(activate)
	c:RegisterEffect(e1)
end


-- [[ SHIMMERBANE DEFAULTS ]]

local SET_SHIMMERBANE=0x9617

--Parameters:
-- c: the card that will receive the effect
-- extracat: optional, eventual extra categories for the effect. Adding CATEGORY_TODECK is not necessary
-- extrainfo: optional, eventual OperationInfo to be set in the target (see Nebula Neos)
-- extraop: optional, eventual operation to be performed if the card is returned to the ED (see Nebula Neos, NOT Magma Neos)
function Reflexxion.AddShimmerbaneSetReturn(c,extracat,extrainfo,extraop,returneff)
	if not extracat then extracat=0 end
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(extracat)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Reflexxion.ShimmerbaneSetTarget(c,extrainfo))
	e1:SetOperation(Reflexxion.ShimmerbaneSetOperation(c,extraop))
	c:RegisterEffect(e1)
	if returneff then
		e1:SetLabelObject(returneff)
	end
end
function Reflexxion.ShimmerbaneSetTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
        CATEGORY_NONE=0
		Duel.SetOperationInfo(0,CATEGORY_NONE,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Reflexxion.ShimmerbaneSetOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		if Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEDOWN,true) and c:IsLocation(LOCATION_SZONE) then
            -- Treat as Continuous Trap
            local e1=Effect.CreateEffect(c)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
            c:RegisterEffect(e1)
            -- Extra operation
            if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end

--Parameters:
-- c: the card that will receive the effect
function Reflexxion.AddShimmerbaneRuling(c)
    -- Special Summon condition
    local function spconlimit(e,se,sp,st)
        return se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsSetCard(SET_SHIMMERBANE)
    end
    local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(spconlimit)
	c:RegisterEffect(e1)
	-- Set as a Continuous Trap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MONSTER_SSET)
	e2:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	c:RegisterEffect(e2)
end

--Parameters:
-- c: the card that will receive the effect
-- tc: the card that is related to the effect (it's basically the targeted card)
function Reflexxion.ShimmerbaneForceActivation(c,e,tp,eg,ep,ev,re,r,rp,tc)
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	if tc:IsTrap() and tc:IsSetCard(SET_SHIMMERBANE) then
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		local condition
		local cost
		local target
		local operation
		if te then
			condition=te:GetCondition()
			cost=te:GetCost()
			target=te:GetTarget()
			operation=te:GetOperation()
		end
		local chk=te and te:GetCode()==EVENT_BECOME_TARGET and te:IsActivatable(tep)
        --local chk=te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
			and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
			and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
			and (not target or target(te,tep,eg,ep,ev,re,r,rp,0))
		Duel.ChangePosition(tc,POS_FACEUP)
		Duel.ConfirmCards(tp,tc)
		if chk then
			Duel.ClearTargetCard()
			e:SetProperty(te:GetProperty())
			Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
			if tc:GetType()==TYPE_TRAP then
				tc:CancelToGrave(false)
			end
			tc:CreateEffectRelation(te)
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if target~=te:GetTarget() then
				target=te:GetTarget()
			end
			if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			for tg in aux.Next(g) do
				tg:CreateEffectRelation(te)
			end
			tc:SetStatus(STATUS_ACTIVATED,true)
			if tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
				tc:SetStatus(STATUS_LEAVE_CONFIRMED,false)
			end
			if operation~=te:GetOperation() then
				operation=te:GetOperation()
			end
			if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
			tc:ReleaseEffectRelation(te)
			for tg in aux.Next(g) do
				tg:ReleaseEffectRelation(te)
			end
        else
            Duel.SendtoGrave(tc,REASON_RULE)
		end
        return chk
	else
		Duel.ConfirmCards(tp,tc)
        return chk
	end
end