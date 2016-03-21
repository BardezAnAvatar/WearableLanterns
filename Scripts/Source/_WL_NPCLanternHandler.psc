scriptname _WL_NPCLanternHandler extends ObjectReference

Actor property PlayerRef auto
int property LanternIndex auto
Keyword property _WL_NPCLanternPositionDatastore auto
formlist property _WL_AllLanterns auto

; Spell property _WL_NPCLanternSpell auto

Armor property _WL_WearableLanternApparel auto
Armor property _WL_WearableTorchbugApparel auto
Armor property _WL_WearableTorchbugApparelRED auto
Armor property _WL_WearablePaperApparel auto

Armor property _WL_WearableLanternApparelFront auto
Armor property _WL_WearableTorchbugApparelFront auto
Armor property _WL_WearableTorchbugApparelFrontRED auto
Armor property _WL_WearablePaperApparelFront auto
	
Armor property _WL_WearableLanternInvDisplay auto
Armor property _WL_WearableTorchbugInvDisplay auto
Armor property _WL_WearableTorchbugInvDisplayRED auto
Armor property _WL_WearablePaperInvDisplay auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	if akNewContainer != PlayerRef && akNewContainer != none && (akNewContainer as Actor) != none
		EquipInventoryLantern(akNewContainer as Actor, LanternIndex)
	endif
endEvent

Event OnUnequipped(Actor akActor)
	if akActor != PlayerRef
		;if akActor.HasSpell(_WL_NPCLanternSpell)
			;akActor.RemoveSpell(_WL_NPCLanternSpell)
		;endif
		debug.trace("[Wearable Lanterns] " + self + " _WL_NPCLanternHandler OnUnequipped")
		
	endif
endEvent

function HandleLanternEquip(Actor akActor, int iIndex)
	EquipInventoryLantern(akActor, iIndex)
	int position = GetLanternPositionForActor(akActor)
	debug.trace("Last position: " + position)
	if position == 0
		EquipBackLantern(akActor, iIndex)
	elseif position == 1
		EquipFrontLantern(akActor, iIndex)
	endif
endFunction

function DestroyNonPlayableLanterns(Actor akActor)
	while akActor.GetItemCount(_WL_AllLanterns) > 0
		akActor.RemoveItem(_WL_AllLanterns, 1, abSilent = true)
	endWhile
endFunction

function EquipInventoryLantern(Actor akActor, int iIndex)
	debug.trace("[Wearable Lanterns] " + self + " _WL_NPCLanternHandler EquipInventoryLantern")
	if iIndex == 0 					;Travel
		akActor.EquipItem(_WL_WearableLanternInvDisplay, true, true)
	else
		akActor.UnequipItem(_WL_WearableLanternInvDisplay)
	endif
	if iIndex == 1 				;Torchbug
		akActor.EquipItem(_WL_WearableTorchbugInvDisplay, true, true)
	else
		akActor.UnequipItem(_WL_WearableTorchbugInvDisplay)
	endif
	if iIndex == 2 				;Torchbug (red)
		akActor.EquipItem(_WL_WearableTorchbugInvDisplayRED, true, true)
	else
		akActor.UnequipItem(_WL_WearableTorchbugInvDisplayRED)
	endif
	if iIndex == 3 				;Paper
		akActor.EquipItem(_WL_WearablePaperInvDisplay, true, true)
	else
		akActor.UnequipItem(_WL_WearablePaperInvDisplay)
	endif
endFunction

function EquipBackLantern(Actor akActor, int iIndex)
	if iIndex == 0 					;Travel
		akActor.EquipItem(_WL_WearableLanternApparel, true, true)
	elseif iIndex == 1 				;Torchbug
		akActor.EquipItem(_WL_WearableTorchbugApparel, true, true)
	elseif iIndex == 2 				;Torchbug (red)
		akActor.EquipItem(_WL_WearableTorchbugApparelRED, true, true)
	elseif iIndex == 3 				;Paper
		akActor.EquipItem(_WL_WearablePaperApparel, true, true)
	endif
endFunction

function EquipFrontLantern(Actor akActor, int iIndex)
	if iIndex == 0 					;Travel
		akActor.EquipItem(_WL_WearableLanternApparelFront, true, true)
	elseif iIndex == 1 				;Torchbug
		akActor.EquipItem(_WL_WearableTorchbugApparelFront, true, true)
	elseif iIndex == 2 				;Torchbug (red)
		akActor.EquipItem(_WL_WearableTorchbugApparelFrontRED, true, true)
	elseif iIndex == 3 				;Paper
		akActor.EquipItem(_WL_WearablePaperApparelFront, true, true)
	endif
endFunction

int function GetLanternPositionForActor(Actor akActor)
	debug.trace("Getting lantern position for actor " + akActor + "...")
	string dskey = GetDatastoreKeyFromForm(akActor)
	int pos = StorageUtil.GetIntValue(_WL_NPCLanternPositionDatastore, dskey, -1)
	if pos != -1
		return pos - 1
	else
		StorageUtil.SetIntValue(_WL_NPCLanternPositionDatastore, dskey, 2)
		return 1
	endif
endFunction

string function GetDatastoreKeyFromForm(Actor akActor)
	int form_id = akActor.GetFormID()
	int mod_index = form_id/16777216
	if mod_index < 0
		mod_index = 0
	endif

	return (form_id % 16777216) + "___" + Game.GetModName(mod_index)
endFunction