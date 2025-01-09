-- WoW Classic 1.12 Addon: Party Plus
local PartyPlus = CreateFrame("Frame", "PartyPlusFrame", UIParent)
PartyPlus:SetWidth(260)
PartyPlus:SetHeight(230)
PartyPlus:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- Make the frame movable and enable mouse interaction
PartyPlus:SetMovable(true)
PartyPlus:EnableMouse(true)

-- Register for dragging
PartyPlus:RegisterForDrag("LeftButton")

-- Set the behavior for dragging (starting and stopping the movement)
PartyPlus:SetScript("OnDragStart", function()
    PartyPlus:StartMoving()  -- Directly reference PartyPlus
end)

PartyPlus:SetScript("OnDragStop", function()
    PartyPlus:StopMovingOrSizing()  -- Directly reference PartyPlus
end)

-- Add background and border manually
PartyPlus:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
PartyPlus:SetBackdropColor(0, 0, 0, 0.8)

-- Title
local title = PartyPlus:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", PartyPlus, "TOP", 0, -6)
title:SetText("Party Plus")

-- Close Button
local closeButton = CreateFrame("Button", nil, PartyPlus, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", PartyPlus, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function() PartyPlus:Hide() end)

-- Function to create a numeric input box aligned to the right edge of the frame
local function CreateInputBox(parent, label, x, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(260)  -- Set the width to fill the parent frame
    frame:SetHeight(20)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    -- Label aligned to the left
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", frame, "LEFT", 0, 0)
    text:SetText(label)

    -- Create a sub-frame for the input box and buttons, aligned to the right
    local rightFrame = CreateFrame("Frame", nil, frame)
    rightFrame:SetWidth(80)  -- Adjust width to make sure it fits inside the parent frame (combined width of input box and buttons)
    rightFrame:SetHeight(20)
    rightFrame:SetPoint("RIGHT", frame, "RIGHT", 0, 0)  -- Right-align this frame

    -- Numeric input box
    local editbox = CreateFrame("EditBox", nil, rightFrame, "InputBoxTemplate")
    editbox:SetWidth(40)  -- Make sure input box is narrow enough
    editbox:SetHeight(20)
    editbox:SetPoint("RIGHT", rightFrame, "RIGHT", -23, 0)
    editbox:SetAutoFocus(false)
    editbox:SetNumeric(true)
    editbox:SetNumber(0)
    
    -- Function to adjust the value of the numeric box
    local function AdjustValue(delta)
        local value = editbox:GetNumber() + delta
        if value < 0 then value = 0 end
        editbox:SetNumber(value)
    end

    -- + Button
    local plusButton = CreateFrame("Button", nil, rightFrame, "UIPanelButtonTemplate")
    plusButton:SetWidth(20)
    plusButton:SetHeight(20)
    plusButton:SetText("+")
    plusButton:SetPoint("RIGHT", editbox, "LEFT", -8, 0)
    plusButton:SetScript("OnClick", function() AdjustValue(1) end)

    -- - Button
    local minusButton = CreateFrame("Button", nil, rightFrame, "UIPanelButtonTemplate")
    minusButton:SetWidth(20)
    minusButton:SetHeight(20)
    minusButton:SetText("-")
    minusButton:SetPoint("RIGHT", plusButton, "LEFT", -4, 0)
    minusButton:SetScript("OnClick", function() AdjustValue(-1) end)

    return editbox
end




-- Create input fields
local tankBox = CreateInputBox(PartyPlus, "Tanks:", 10, -35)
local healerBox = CreateInputBox(PartyPlus, "Healers:", 10, -65)
local dpsBox = CreateInputBox(PartyPlus, "DPS:", 10, -95)
local requiredBox = CreateInputBox(PartyPlus, "Required Party Size:", 10, -125)

-- Free text field for dungeon
local dungeonLabel = PartyPlus:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dungeonLabel:SetPoint("TOPLEFT", PartyPlus, "TOPLEFT", 10, -155)
dungeonLabel:SetText("Dungeon Name")

local dungeonBox = CreateFrame("EditBox", nil, PartyPlus, "InputBoxTemplate")
dungeonBox:SetWidth(232)
dungeonBox:SetHeight(20)
dungeonBox:SetPoint("TOPLEFT", PartyPlus, "TOPLEFT", 16, -170)
dungeonBox:SetAutoFocus(false)

-- Post Button
local postButton = CreateFrame("Button", nil, PartyPlus, "UIPanelButtonTemplate")
postButton:SetWidth(100)
postButton:SetHeight(25)
postButton:SetPoint("BOTTOM", PartyPlus, "BOTTOM", 0, 10)
postButton:SetText("Post")

-- Function to generate and send the chat message
local function PostToChat()
    local tanks = tankBox:GetNumber()
    local healers = healerBox:GetNumber()
    local dps = dpsBox:GetNumber()
    local required = requiredBox:GetNumber()
    local dungeon = dungeonBox:GetText()

    -- Check if "Required Party Size" is empty or zero
    if required == 0 or required == "" then
        -- Show an error message in the chat window
        print("Required Party Size is required!")
        return
    end

    -- Check if the dungeon name is empty
    if dungeon == "" then
        print("Dungeon Name is required!")  -- Display a message in the chat window if the dungeon is empty
        return
    end
    

    -- Add the party size (including the player)
    local partySize = GetNumPartyMembers() + 1

    -- Construct the message
    local messageParts = {}

    -- Add tanks if greater than 0
    if tanks > 0 then
        table.insert(messageParts, string.format("%d TANKS", tanks))
    end

    -- Add healers if greater than 0
    if healers > 0 then
        table.insert(messageParts, string.format("%d HEALERS", healers))
    end

    -- Add DPS if greater than 0
    if dps > 0 then
        table.insert(messageParts, string.format("%d DPS", dps))
    end

    -- Add dungeon name if entered
    if dungeon ~= "" then
        table.insert(messageParts, dungeon)
    end

    -- Add current party size and required party size
    table.insert(messageParts, string.format("%d/%d", partySize, required))

    -- Join the parts into a single string and send the chat message
    local message = table.concat(messageParts, ", ")
    SendChatMessage(message)
end




postButton:SetScript("OnClick", PostToChat)

-- Slash commands to open the PartyPlus frame
SLASH_PARTYPLUS1 = "/partyplus"
SLASH_PARTYPLUS2 = "/pp"

function SlashCmdList.PARTYPLUS(msg, editBox)
    if PartyPlus:IsShown() then
        PartyPlus:Hide()  -- If the frame is already shown, hide it
    else
        PartyPlus:Show()  -- If the frame is hidden, show it
    end
end

-- Function to detect clicks outside and clear focus
local function ClearFocus(self, button)
    tankBox:ClearFocus()
    healerBox:ClearFocus()
    dpsBox:ClearFocus()
    requiredBox:ClearFocus()
    dungeonBox:ClearFocus()
end

-- Attach the click event to the PartyPlus frame itself
PartyPlus:SetScript("OnMouseDown", ClearFocus)
WorldFrame:SetScript("OnMouseDown", ClearFocus)