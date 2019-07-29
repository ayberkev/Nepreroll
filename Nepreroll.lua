
local macroDeleted = false;

local frameBaseWidth = 255;
local frameBaseHeight = 220;

local globalXOffset = 110;

function createNeprerollMacro()
	CreateMacro("Neprerollmacro", 1, "#showtooltip Draft Mode Deck\n/cast Draft Mode Deck;\n/click StaticPopup1Button1;", 1)
	macroDeleted = false;
end

function deleteNeprerollMacro()
	DeleteMacro("Neprerollmacro")
	macroDeleted = true;
end

local macroFrame = CreateFrame("frame")
macroFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
macroFrame:SetScript("OnEvent", function()
	deleteNeprerollMacro();
	createNeprerollMacro();
end)

function MyAddonCommands(arg1)
	local command = string.upper(arg1);
	print("Executing command: '"..command.."'")
	if command == "HIDE" then
		myframe:Hide();
	end
	if command == "SHOW" then
		myframe:Show();
	end
	if command == "" then
		if myframe:IsShown() then
			myframe:Hide();
		else
			myframe:Show()
		end
	end
	if command == "CREATE" then
		createNeprerollMacro()
	end
	if command == "DELETE" then
		deleteNeprerollMacro()
	end
	if command == "RESIZE" then
		myframe:SetWidth(frameBaseWidth);
		myframe:SetHeight(frameBaseHeight);
	end
end

SLASH_TEST1 = "/nep";
SlashCmdList["TEST"] = MyAddonCommands;

------------------------------------------------------------------------------------
myframe = CreateFrame("Frame", "myframe",UIParent,"OptionsFrameListTemplate")
myframe:SetPoint("BOTTOMLEFT", 500, 500)
myframe:SetWidth(frameBaseWidth);
myframe:SetHeight(frameBaseHeight);
myframe:SetMovable(true);
myframe:EnableMouse(true);
myframe:SetResizable(true);
myframe:RegisterForDrag("LeftButton")
myframe:SetScript("OnDragStart", myframe.StartMoving)
myframe:SetScript("OnDragStop", myframe.StopMovingOrSizing)

myframe.title = myframe:CreateFontString(nil, "OVERLAY");
myframe.title:SetFontObject("GameFontHighlight");
myframe.title:SetPoint("TOPLEFT", myframe, "TOPLEFT", -15+globalXOffset, -9);
myframe.title:SetText("Spell ID");

myframe:Hide()

local clickButton = CreateFrame("Button", "clickButton", myframe, "SecureActionButtonTemplate")
clickButton:SetSize(120, 120);
clickButton:SetPoint("TOPLEFT", -15+globalXOffset, -200);
clickButton:EnableMouse(true)
clickButton:SetMovable(true)
clickButton:RegisterForClicks("LeftButtonUp")
clickButton:RegisterForDrag("LeftButton")
clickButton:SetScript("OnDragStart", clickButton.StartMoving)
clickButton:SetScript("OnDragStop", clickButton.StopMovingOrSizing)
clickButton:SetScript("OnEnter", function(self) self:SetAlpha(1);end);
clickButton:SetScript("OnLeave", function(self) self:SetAlpha(0.5);end);
clickButton.isEnabled = false;
clickButton:SetScript("OnMouseUp", function(self) 
	self:SetAlpha(0.2);
	if self.isEnabled == false then 
		nepreroll_wait(2.1, function() 
			if clickButton:IsShown() then
				self:SetAlpha(1);
				self.isEnabled = false;
			end
		end); 
	end
	self.isEnabled = true
end);
clickButton.texture = clickButton:CreateTexture("ARTWORK");
clickButton.texture:SetPoint("TOPRIGHT" , clickButton, 0, 0);
clickButton.texture:SetPoint('BOTTOMLEFT', clickButton, 0, 0)
clickButton.texture:SetTexture("Interface/Icons/misc_draftmode")
clickButton:SetAttribute("type", "macro");
clickButton:SetAttribute("macro", "Neprerollmacro");
clickButton:SetAlpha(0.5);
clickButton:Hide()

local createClickButton = CreateFrame("Button", "createClickButton", myframe, "GameMenuButtonTemplate")
createClickButton:SetSize(100, 20);
createClickButton:SetPoint("TOPLEFT", -50+globalXOffset, -170);
createClickButton:SetText("Toggle button");
createClickButton:SetScript("OnClick", function()
	if createClickButton:GetText() == "Toggle button" then
		if clickButton:IsShown() then
			clickButton:Hide()
			changeSizeAndAdjustPosition(myframe, 0, (frameBaseHeight-myframe:GetHeight()));
			--myframe:SetHeight(frameBaseHeight);
		else
			clickButton:SetPoint("TOPLEFT", -55+globalXOffset, -200);
			clickButton:SetAlpha(0.5);
			clickButton:Show()
			changeSizeAndAdjustPosition(myframe, 0, 120);
			--myframe:SetHeight(frameBaseHeight+120);
		end;
	else
		deleteNeprerollMacro();
		createNeprerollMacro();
		clickButton:SetAttribute("macro", "Neprerollmacro");
		createClickButton:SetText("Toggle button");
	end
end);

function configureEditBox(textBox, sizeX, sizeY, pointLocation, pointOffsetX, pointOffsetY, iconFrame)
	textBox:SetSize(sizeX, sizeY);
	textBox:SetPoint(pointLocation, pointOffsetX, pointOffsetY);
	textBox:SetAutoFocus(false);
	textBox:SetFontObject("GameFontNormal");
	iconFrame:SetSize(30, 30);
	iconFrame:SetPoint(pointLocation, pointOffsetX+130, pointOffsetY);
	iconFrame.texture:SetPoint("TOPRIGHT", iconFrame, 0, 0);
	iconFrame.texture:SetPoint("BOTTOMLEFT", iconFrame, 0, 0);
	iconFrame:SetScript("OnEnter", function(self)
		tooltipFrame:SetOwner(self,"ANCHOR_CURSOR");
		tooltipFrame:SetHyperlink("spell:"..getSpellID(textBox:GetText()));
		tooltipFrame:Show();
	end);
	iconFrame:SetScript("OnClick", function(self)
		local name, rank, icon, castTime, minRange, maxRange, spellCooldown = GetSpellInfo(getSpellID(textBox:GetText()));
		DEFAULT_CHAT_FRAME:AddMessage("\124cff71d5ff\124Hspell:"..getSpellID(textBox:GetText()).."\124h["..name.."]\124h\124r");
	end);
	iconFrame:SetScript("OnLeave", function(self)
		tooltipFrame:Hide()
	end);
	textBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus();
	end);
	textBox:SetScript("OnTextChanged", function(self)
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBox:GetText()));
		iconFrame.texture:SetTexture(icon);
		updateSettings();
	end);
end

function getSpellID(text)
	if text ~= nil then
		local spellNames =
		{"raptor strike","mongoose bite","wrath","moonfire","thorns","demoralizing roar","maul","growl","bear form","swipe",
         "healing touch","mark of the wild","rejuvenation","aspect of the monkey","tame beast","call pet","dismiss pet","feed pet",
         "revive pet","aspect of the hawk","auto shot","serpent sting","arcane shot","hunter's mark","concussive shot","track beasts",
         "arcane intellect","conjure water","conjure food","arcane missiles","fireball","fire blast","frost armor","frostbolt",
         "holy light","seal of righteousness","blessing of wisdom","devotion aura","divine protection","hammer of justice",
         "righteous fury","blessing of might","judgement of light","judgement of wisdom","power word: fortitude","power word: shield",
         "lesser heal","smite","renew","shadow word: pain","fade","eviscerate","slice and dice","sinister strike","backstab","gouge",
         "evasion","sprint","stealth","pick pocket","lightning bolt","earth shock","earthbind totem","stoneclaw totem","searing totem",
         "stoneskin totem","lightning shield","healing wave","curse of weakness","corruption","life tap","curse of agony","fear",
         "drain soul","demon skin","summon imp","summon voidwalker","shadow bolt","immolate","heroic strike","battle stance","charge",
         "rend","thunder clap","hamstring","overpower","battle shout","victory rush","bloodrage","defensive stance","shield bash",
         "shield block", "taunt"};
		local spellID = 
		{"2973","1495","5176","8921","467","99","6807","6795","5487","779","5185","1126","774","13163","1515","883","2641","1539",
		 "982","13165","75","1978","3044","1130","5116","1494","1459","5504","587","5143","133","2136","168","116","635","21084",
		 "19742","465","498","853","25780","19740","20271","53408","1243","17","2050","585","139","589","586","2098","5171","1752",
		 "53","1776","5277","2983","1784","921","403","8042","2484","5730","3599","8071","324","331","702","172","1454","980","5782",
		 "1120","687","688","697","686","348","78","2457","100","772","6343","1715","7384","6673","34428","2687","71","72","2565","355"};
		local id = nil
		for i=1,table.getn(spellNames),1 do
				if string.lower(text) == spellNames[i] then
					id = spellID[i]
					break
				end
		end
		if id ~= nil then
			return id
		else
			return text
		end
	end
end

local tooltipFrame = CreateFrame("GameTooltip", "tooltipFrame", UIParent, "GameTooltipTemplate");
	
local textBoxa = CreateFrame("EditBox", "MyMultiLineEditBoxa", myframe, "InputBoxTemplate");
local iconFramea = CreateFrame("Button", "iconFramea", myframe);
iconFramea.texture = iconFramea:CreateTexture("ARTWORK");
configureEditBox(textBoxa, 120, 30, "TOPLEFT", -55+globalXOffset, -20, iconFramea);

local textBoxb = CreateFrame("EditBox", "MyMultiLineEditBoxb", myframe, "InputBoxTemplate")
local iconFrameb = CreateFrame("Button", "iconFrameb", myframe);
iconFrameb.texture = iconFrameb:CreateTexture("ARTWORK");
configureEditBox(textBoxb, 120, 30, "TOPLEFT", -55+globalXOffset, -50, iconFrameb);

local textBoxc = CreateFrame("EditBox", "MyMultiLineEditBoxc", myframe, "InputBoxTemplate")
local iconFramec = CreateFrame("Button", "iconFramec", myframe);
iconFramec.texture = iconFramec:CreateTexture("ARTWORK");
configureEditBox(textBoxc, 120, 30, "TOPLEFT", -55+globalXOffset, -80, iconFramec);

local textBoxd = CreateFrame("EditBox", "MyMultiLineEditBoxd", myframe, "InputBoxTemplate")
local iconFramed = CreateFrame("Button", "iconFramed", myframe);
iconFramed.texture = iconFramed:CreateTexture("ARTWORK");
configureEditBox(textBoxd, 120, 30, "TOPLEFT", -55+globalXOffset, -110, iconFramed);

local textBoxe = CreateFrame("EditBox", "MyMultiLineEditBoxe", myframe, "InputBoxTemplate")
local iconFramee = CreateFrame("Button", "iconFramee", myframe);
iconFramee.texture = iconFramee:CreateTexture("ARTWORK");
configureEditBox(textBoxe, 120, 30, "TOPLEFT", -55+globalXOffset, -140, iconFramee);



local orTextBoxa = CreateFrame("EditBox", "orTextBoxa", myframe, "InputBoxTemplate");
local orIconFramea = CreateFrame("Button", "orIconFramea", myframe);
orIconFramea.texture = orIconFramea:CreateTexture("ARTWORK");
configureEditBox(orTextBoxa, 120, 30, "TOPLEFT", 160+globalXOffset, -20, orIconFramea);
orTextBoxa:Hide();

local orTextBoxb = CreateFrame("EditBox", "orTextBoxb", myframe, "InputBoxTemplate")
local orIconFrameb = CreateFrame("Button", "orIconFrameb", myframe);
orIconFrameb.texture = orIconFrameb:CreateTexture("ARTWORK");
configureEditBox(orTextBoxb, 120, 30, "TOPLEFT", 160+globalXOffset, -50, orIconFrameb);
orTextBoxb:Hide();

local orTextBoxc = CreateFrame("EditBox", "orTextBoxc", myframe, "InputBoxTemplate")
local orIconFramec = CreateFrame("Button", "orIconFramec", myframe);
orIconFramec.texture = orIconFramec:CreateTexture("ARTWORK");
configureEditBox(orTextBoxc, 120, 30, "TOPLEFT", 160+globalXOffset, -80, orIconFramec);
orTextBoxc:Hide();

local orTextBoxd = CreateFrame("EditBox", "orTextBoxd", myframe, "InputBoxTemplate")
local orIconFramed = CreateFrame("Button", "orIconFramed", myframe);
orIconFramed.texture = orIconFramed:CreateTexture("ARTWORK");
configureEditBox(orTextBoxd, 120, 30, "TOPLEFT", 160+globalXOffset, -110, orIconFramed);
orTextBoxd:Hide();

local orTextBoxe = CreateFrame("EditBox", "orTextBoxe", myframe, "InputBoxTemplate")
local orIconFramee = CreateFrame("Button", "orIconFramee", myframe);
orIconFramee.texture = orIconFramee:CreateTexture("ARTWORK");
configureEditBox(orTextBoxe, 120, 30, "TOPLEFT", 160+globalXOffset, -140, orIconFramee);
orTextBoxe:Hide();

function configureOrButton(buttonFrame, pointLocation, pointOffsetX, pointOffsetY, orTextbox, orIconFrame)
	buttonFrame:SetSize(20, 20);
	buttonFrame:SetPoint(pointLocation, pointOffsetX, pointOffsetY);
	buttonFrame:SetText("or");
	buttonFrame.enabled = false;
	buttonFrame:SetScript("OnClick", function(self)
		if self.enabled then 
			self:SetSize(20,20);
			self:SetText("or");
			self.enabled = false;
			orTextbox:Hide();
			orIconFrame.texture:Hide();
			if isOrButtonPressed() == false and math.ceil(myframe:GetWidth()) ~= frameBaseWidth then
				changeSizeAndAdjustPosition(myframe, (frameBaseWidth-myframe:GetWidth()), 0)
				--myframe:SetWidth(frameBaseWidth);
			end
		else
			self:SetSize(30,20);
			self:SetText("or >");
			self.enabled = true;
			orTextbox:Show();
			orIconFrame.texture:Show();
			if math.ceil(myframe:GetWidth()) ~= (frameBaseWidth+200) then
				changeSizeAndAdjustPosition(myframe, (frameBaseWidth+200-myframe:GetWidth()), 0)
				--myframe:SetWidth(frameBaseWidth+200);
			end
		end
	end);
end;


local orButtona = CreateFrame("Button", "orButtona", myframe, "GameMenuButtonTemplate");
configureOrButton(orButtona, "TOPLEFT", 115+globalXOffset, -25, orTextBoxa, orIconFramea);
local orButtonb = CreateFrame("Button", "orButtona", myframe, "GameMenuButtonTemplate");
configureOrButton(orButtonb, "TOPLEFT", 115+globalXOffset, -55, orTextBoxb, orIconFrameb);
local orButtonc = CreateFrame("Button", "orButtona", myframe, "GameMenuButtonTemplate");
configureOrButton(orButtonc, "TOPLEFT", 115+globalXOffset, -85, orTextBoxc, orIconFramec);
local orButtond = CreateFrame("Button", "orButtona", myframe, "GameMenuButtonTemplate");
configureOrButton(orButtond, "TOPLEFT", 115+globalXOffset, -115, orTextBoxd, orIconFramed);
local orButtone = CreateFrame("Button", "orButtona", myframe, "GameMenuButtonTemplate");
configureOrButton(orButtone, "TOPLEFT", 115+globalXOffset, -145, orTextBoxe, orIconFramee);

function isOrButtonPressed()
	return orButtona.enabled or orButtonb.enabled or orButtonc.enabled  or orButtond.enabled  or orButtone.enabled;
end;

function configureCheckBox(checkBox, pointLocation, pointOffsetX, pointOffsetY)
	checkBox:SetPoint(pointLocation, pointOffsetX, pointOffsetY)
	checkBox:SetScript("OnClick", function(self)
		updateSettings();
	end);
	--checkBox.text = _G[checkBox:GetName().."Text"]
	--checkBox.text:SetText(checkBox:GetName())
end


local waitTable = {};
local waitFrame = nil;

function nepreroll_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function changeSizeAndAdjustPosition(frame, widthIncrease, heightIncrease)
	local framePoint, frameRelativeTo, frameRelativePoint, frameXOffset, frameYOffset = frame:GetPoint();
	frame:SetWidth(frame:GetWidth()+widthIncrease);
	frame:SetHeight(frame:GetHeight()+heightIncrease);
	if framePoint == "TOPLEFT" then
		frame:SetPoint(framePoint, frameXOffset, frameYOffset);
	end
	if framePoint == "TOP" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease/2), frameYOffset);
	end
	if framePoint == "TOPRIGHT" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease), frameYOffset);
	end
	if framePoint == "LEFT" then
		frame:SetPoint(framePoint, frameXOffset, frameYOffset-(heightIncrease/2));
	end
	if framePoint == "CENTER" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease/2), frameYOffset-(heightIncrease/2));
	end
	if framePoint == "RIGHT" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease), frameYOffset-(heightIncrease/2));
	end
	if framePoint == "BOTTOMLEFT" then
		frame:SetPoint(framePoint, frameXOffset, frameYOffset+(heightIncrease));
	end
	if framePoint == "BOTTOM" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease/2), frameYOffset-(heightIncrease));
	end
	if framePoint == "BOTTOMRIGHT" then
		frame:SetPoint(framePoint, frameXOffset+(widthIncrease), frameYOffset-(heightIncrease));
	end
end

--[[function DoWeKnowSpellOrIgnore(textBox, orButton, orTextBox)
	if textBox:GetText() ~= "" then
		if getSpellID(textBox:GetText()) == "" then
			return false;
		end
		if IsSpellKnown(getSpellID(textBox:GetText())) then
			return true;
		end
		if orButton.enabled == false then
			return false;
		end
		if getSpellID(orTextBox:GetText()) == "" then
			return false;
		end
		if IsSpellKnown(getSpellID(orTextBox:GetText())) then
			return true;
		end
	else
		return true;
	end
	return false;
end]]--


function checkText()
	local textboxes = {textBoxa:GetText(), textBoxb:GetText(), textBoxc:GetText(), textBoxd:GetText(), textBoxe:GetText()};
	local ortextboxes = {orTextBoxa:GetText(), orTextBoxb:GetText(), orTextBoxc:GetText(), orTextBoxd:GetText(), orTextBoxe:GetText()};
	local orbuttons = {orButtona.enabled, orButtonb.enabled, orButtonc.enabled, orButtond.enabled, orButtone.enabled};
	local cards = {Card1SpellFrame.Icon.Spell,Card2SpellFrame.Icon.Spell,Card3SpellFrame.Icon.Spell}
	local timer = 0;
	for i = 1,10 do
		local spell = getSpellID(textboxes[i]);
		local orspell = getSpellID(ortextboxes[i-5]);
		for r=1,3 do
		local cardid = tostring(cards[r]);
--		print(_G["card"..r])
			if spell == cardid and i <= 5 then
				learnSpell(r);
				break
			elseif orbuttons[i-5] and i >= 6 and orspell == cardid then
				learnSpell(r);
				break
			else
				if timer == 29 then
					learnSpell(math.random(3));
				else
					timer = timer + 1;
				end
			end
		end
	end
end

local doPrint = true;
function checkSpells()
	local textboxes = {textBoxa:GetText(), textBoxb:GetText(), textBoxc:GetText(), textBoxd:GetText(), textBoxe:GetText()};
	local ortextboxes = {orTextBoxa:GetText(), orTextBoxb:GetText(), orTextBoxc:GetText(), orTextBoxd:GetText(), orTextBoxe:GetText()};
	local orbuttons = {orButtona.enabled, orButtonb.enabled, orButtonc.enabled, orButtond.enabled, orButtone.enabled};
	
	local failcount = 0;
	
	checkText();
	
	for i=1,5 do
		if textboxes[i] ~= "" then
			if not IsSpellKnown(getSpellID(textboxes[i])) then
				if not orbuttons[i] then
					failcount = failcount + 1;
				elseif not ortextboxes[i] ~= "" and not IsSpellKnown(getSpellID(ortextboxes[i])) then
					failcount = failcount + 1;
				end
			end
		end
	end
	if failcount ~= 0 then
		return;
	end
	
--[[	if DoWeKnowSpellOrIgnore(textBoxa, orButtona, orTextBoxa) == false then
		return;
	end
	if DoWeKnowSpellOrIgnore(textBoxb, orButtonb, orTextBoxb) == false then
		return;
	end
	if DoWeKnowSpellOrIgnore(textBoxc, orButtonc, orTextBoxc) == false then
		return;
	end
	if DoWeKnowSpellOrIgnore(textBoxd, orButtond, orTextBoxd) == false then
		return;
	end
	if DoWeKnowSpellOrIgnore(textBoxe, orButtone, orTextBoxe) == false then
		return;
	end]]--
	--[[
	if checkButtona:GetChecked() then
		if textBoxa:GetText() ~= "" then
			if IsSpellKnown(textBoxa:GetText()) == false then
				if orButtona.enabled then
					if orTextBoxa:GetText() ~= "" then
						if IsSpellKnown(orTextBoxa:GetText()) == false then
							return;
						end
					end;
				else 
					return;
				end;
			end
		else
			return
		end
	end
	if checkButtonb:GetChecked() then
		if IsSpellKnown(textBoxb:GetText()) == false then
			--print("We do not have the 2nd spell in the list. Time to reroll!");
			return;
		end
	end
	if checkButtonc:GetChecked() then
		if IsSpellKnown(textBoxc:GetText()) == false then
			--print("We do not have the 3rd spell in the list. Time to reroll!");
			return;
		end
	end
	if checkButtond:GetChecked() then
		if IsSpellKnown(textBoxd:GetText()) == false then
			--print("We do not have the 4th spell in the list. Time to reroll!");
			return;
		end
	end
	if checkButtone:GetChecked() then
		if IsSpellKnown(textBoxe:GetText()) == false then
			--print("We do not have the 5th spell in the list. Time to reroll!");
			return;
		end
	end
	]]--
	
	if doPrint then
		doPrint = false
		print("WE HAVE ALL SPELLS!")
		nepreroll_wait(0.5, function() 
			doPrint = true;
		end); 
	end
	StaticPopup1Button2:Click()
	deleteNeprerollMacro();
	myframe:SetHeight(frameBaseHeight);
	if clickButton:IsShown() then
		clickButton:Hide();
	end
	createClickButton:SetText("Reset");
end

function learnSpell(n)
	if n == 1 then
		print(n)
		Card1LearnSpellButton:Enable()
		Card1LearnSpellButton:Click()
	elseif n == 2 then
		print(n)
		Card2LearnSpellButton:Enable()
		Card2LearnSpellButton:Click()
	elseif n == 3 then
		print(n)
		Card3LearnSpellButton:Enable()
		Card3LearnSpellButton:Click()
	end
end
local spellLearned1=CreateFrame("frame")
spellLearned1:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
spellLearned1:RegisterEvent("SPELL_CAST_SUCCESS")
spellLearned1:SetScript("OnEvent", function(self, event, ...)
	local timestamp,event,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,spellId = ...
	if sourceName == UnitName("player") and UnitLevel("player") == 1 and spellId == 18285 then
		checkSpells();
	end
end);


local spellLearned=CreateFrame("frame")
spellLearned:RegisterEvent("LEARNED_SPELL_IN_TAB")
spellLearned:SetScript("OnEvent", function()
	if UnitLevel("player") == 1 then
		checkSpells();
	end
end);

function updateSettings()
	firstSpellID = textBoxa:GetText();
	secondSpellID = textBoxb:GetText();
	thirdSpellID = textBoxc:GetText();
	fourthSpellID = textBoxd:GetText();
	fifthSpellID = textBoxe:GetText();
end

local addonLoadedFrame = CreateFrame("FRAME");
addonLoadedFrame:RegisterEvent("ADDON_LOADED");
addonLoadedFrame:SetScript("OnEvent", function()
	myframe:SetWidth(frameBaseWidth);
	myframe:SetHeight(frameBaseHeight);
	if firstSpellID == nil then
		firstSpellID = textBoxa:GetText();
	else
		textBoxa:SetText(firstSpellID);
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBoxa:GetText()));
		iconFramea.texture:SetTexture(icon);
	end
	
	if secondSpellID == nil then
		secondSpellID = "";
	else
		textBoxb:SetText(secondSpellID);
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBoxb:GetText()));
		iconFrameb.texture:SetTexture(icon);
	end
	
	if thirdSpellID == nil then
		thirdSpellID = "";
	else
		textBoxc:SetText(thirdSpellID);
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBoxc:GetText()));
		iconFramec.texture:SetTexture(icon);
	end
	
	if fourthSpellID == nil then
		fourthSpellID = "";
	else
		textBoxd:SetText(fourthSpellID);
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBoxd:GetText()));
		iconFramed.texture:SetTexture(icon);
	end
	
	if fifthSpellID == nil then
		fifthSpellID = "";
	else
		textBoxe:SetText(fifthSpellID);
		local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(getSpellID(textBoxe:GetText()));
		iconFramee.texture:SetTexture(icon);
	end
end);