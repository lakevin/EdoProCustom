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

-- Majestal: Place in S/T Zone
function Reflexxion.AddMajestalSpellActivation(s,id,c)
    local function settg(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then return c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    end
    local function setop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_HAND) then return end
        if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            -- Treat as Continuous Spell
            local e1=Effect.CreateEffect(c)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            c:RegisterEffect(e1)
        end
    end
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetTarget(settg)
	e1:SetOperation(setop)
	c:RegisterEffect(e1)
end