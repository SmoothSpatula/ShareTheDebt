local share_debt_enabled = true

log.info("Successfully loaded ".._ENV["!guid"]..".")

gui.add_to_menu_bar(function()
    local new_value, clicked = ImGui.Checkbox("Enable Share Debt", share_debt_enabled)
    if clicked then
        share_debt_enabled = new_value
    end
end)

local function add_chat_message(text)
    gm.chat_add_message(gm["@@NewGMLObject@@"](gm.constants.ChatMessage, text))
end

local currently_paying = false
gm.post_script_hook(gm.constants.interactable_pay_cost, function(self, other, result, args)
    if not share_debt_enabled or currently_paying then return end

    local s_type, cost, actor = args[1].value, args[2].value, args[3].value

    if s_type ~= 0 or cost == 0 then return end --if its spending gold and more than 0
    if actor.object_index ~= gm.constants.oP then return end

    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oP then 
            if inst.id == actor.id then 
                add_chat_message(actor.user_name .. " just spent <y>$" .. math.floor(cost) .. "<w>.")
            else
                currently_paying = true
                gm.interactable_pay_cost(s_type, cost, inst.id)
                currently_paying = false
            end
        end
    end
end)
