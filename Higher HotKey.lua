--[[

	This small addon raises the hotkey text above cooldowns, flashing
	borders and other stuff like OmniCC.

	The upshot is your hotkeys always appear topmost on action buttons.

	From this thread: http://us.battle.net/wow/en/forum/topic/12673197448
	It's Fenril-Whisperwind's idea, I just supplied the minor code.

	After testing it for a bit, it's a nice subtle effect and maybe others
	will find it useful too.

	Action bars supported:
	- Default
	- Dominos
	- Bartender4
	- ElvUI

	It should have no problems with addons that modify hotkey text.

	10/06/2018 1.0.9 added ElvUI support
	08/29/2017 1.0.8 toc update for 7.3 patch
	03/28/2017 1.0.7 toc update for 7.2 patch
	10/24/2016 1.0.6 toc update for 7.1 patch
	07/16/2016 1.0.5 toc update for 7.0 patch
	06/22/2015 1.0.4 toc update for 6.2 patch
	02/24/2015 1.0.3 toc update for 6.1 patch
	10/14/2014 1.0.2 6.0 patch
	04/29/2014 1.0.1 added BT4 support
	04/28/2014 1.0.0 posted on official forums

]]

-- Default and Dominos button stubs and their number of buttons
local defaultStubs = {
	ActionButton=12, DominosActionButton=60, MultiBarRightButton=12,
	MultiBarLeftButton=12, MultiBarBottomRightButton=12,
	MultiBarBottomLeftButton=12, StanceButton=10, PetActionButton=10,
}
-- Bartender4 button stubs
local bt4Stubs = { BT4Button=120, BT4StanceButton=10, BT4PetButton=10 }

-- ElvUI_Bar button stubs
local ElvUIStubs = { ElvUI_Bar1Button=12, ElvUI_Bar2Button=12, 
	ElvUI_Bar3Button=12, ElvUI_Bar4Button=12, ElvUI_Bar5Button=12, 
	ElvUI_Bar6Button=12, PetActionButton=10, ElvUI_StanceBarButton=10 }


local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate",function(self,event)
	self:Hide() -- runs this only once per login
	local stubs = IsAddOnLoaded("Bartender4") and bt4Stubs or IsAddOnLoaded("ElvUI") and ElvUIStubs or defaultStubs
	for stub,numButtons in pairs(stubs) do
    local parent, hotkey
		for i=1,numButtons do
      parent = _G[stub..i] -- ie ActionButton1
      hotkey = _G[stub..i.."HotKey"] -- ie ActionButton1HotKey
      if parent and hotkey and not parent.higherHotKey then
        -- if a "higherHotKey" hasn't been made yet, create one for this button
        parent.higherHotKey = CreateFrame("Frame",nil,parent)
        -- stretch new blank frame to cover parent button
        parent.higherHotKey:SetAllPoints(true)
        -- move new blank frame to 12 frameLevels above parent button
        parent.higherHotKey:SetFrameLevel(parent:GetFrameLevel()+12)
        -- move/re-parent the hotkey FontString to the higher frame
        hotkey:SetParent(parent.higherHotKey)
				-- move/re-parent the name and count FontString to the higher frame
				_G[stub..i.."Name"]:SetParent(parent.higherHotKey)
				_G[stub..i.."Count"]:SetParent(parent.higherHotKey)
      end
		end
  end
end)

-- BT4 creates its buttons on demand, some during login, others when bars enabled.
-- When a BT4Button is created, come back the next frame to add any new higherHotKeys.
if IsAddOnLoaded("Bartender4") then
	hooksecurefunc("CreateFrame",function(frameType,frameName)
		if frameType=="CheckButton" and frameName and frameName:match("^BT4Button") then
			frame:Show() -- come back next frame and create any new higher hotkeys
		end
	end)
end
