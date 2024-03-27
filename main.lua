local share_debt_enabled = true
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
    if share_debt_enabled and not currently_paying then
        local s_type = args[1].value
        local cost = args[2].value
        local actor = args[3].value
        
        if cost == 0 or s_type ~= 0 then return end

        if actor.object_index == gm.constants.oP then
            for i = 1, #gm.CInstance.instances_active do
                local inst = gm.CInstance.instances_active[i]
                if inst.object_index == gm.constants.oP and inst.id ~= actor.id then                 
                    currently_paying = true
                    add_chat_message(actor.user_name .. " just spent <y>$" .. math.floor(cost) .. "<w>.")
                    gm.interactable_pay_cost(s_type, cost, inst.id)
                    currently_paying = false
                end
            end
        end
    end
end)