scriptname _WL_LanternOil_v3 extends ReferenceAlias

; Main script. Controls all light functions for the player and assigning Reference Aliases for followers.

import debug
import utility

Actor property PlayerRef auto
_WL_Compatibility property Compatibility auto
FormList property _WL_InteriorWorldspaces auto

;Settings
GlobalVariable property _WL_SettingOil auto
GlobalVariable property _WL_SettingFeeding auto
GlobalVariable property _WL_SettingPosition auto
GlobalVariable property _WL_SettingAutomatic auto
GlobalVariable property _WL_SettingDropLit auto
GlobalVariable property _WL_Debug auto
GlobalVariable property GameHour auto

Formlist property _WL_AllLanterns auto
Formlist property _WL_GlowingBugList auto

MiscObject property _WL_LanternOil4 auto

Light property Torch01 auto

FormList property _WL_InvBugLanterns auto

Armor property _WL_WearableLanternInvDisplay auto
Armor property _WL_WearableLanternApparel auto 							;Travel Lantern Worn - Back Right
Armor property _WL_WearableLanternApparelFront auto 					;Travel Lantern Worn - Front Right
Light property _WL_LanternHeld auto 									;Travel Lantern Carried - Left Hand
Light property _WL_LanternDroppedLit auto 								;Travel Lantern Lit World Object

Armor property _WL_WearableTorchbugApparel_EmptyInvDisplay auto
Armor property _WL_WearableTorchbugApparel_Empty auto 					;Empty Bug Lantern Worn - Back Right
Armor property _WL_WearableTorchbugApparelFront_Empty auto 				;Empty Bug Lantern Worn - Front Right
Light property _WL_TorchbugHeld_Empty auto 								;Empty Bug Lantern Carried - Left Hand

Armor property _WL_WearableTorchbugInvDisplay auto
Armor property _WL_WearableTorchbugApparel auto 						;Torchbug Lantern Worn - Back Right
Armor property _WL_WearableTorchbugApparelFront auto 					;Torchbug Lantern Worn - Front Right
Light property _WL_TorchbugHeld auto 									;Torchbug Lantern Carried - Left Hand
Light property _WL_TorchbugDroppedLit auto 								;Torchbug Lantern Lit World Object

Armor property _WL_WearableTorchbugInvDisplayRED auto
Armor property _WL_WearableTorchbugApparelRED auto 						;Firefly Lantern Worn - Back Right
Armor property _WL_WearableTorchbugApparelFrontRED auto 				;Firefly Lantern Worn - Front Right
Light property _WL_TorchbugHeldRED auto 								;Firefly Lantern Carried - Left Hand
Light property _WL_TorchbugREDDroppedLit auto 							;Firefly Lantern Lit World Object

Armor property _WL_WearablePaperInvDisplay auto
Armor property _WL_WearablePaperApparel auto 							;Paper Lantern Worn - Back Right
Armor property _WL_WearablePaperApparelFront auto 						;Paper Lantern Worn - Front Right
Light property _WL_PaperHeld auto 										;Paper Lantern Carried - Left Hand
Light property _WL_PaperHeldDroppedLit auto 							;Paper Lantern Lit World Object

activator property CritterFirefly auto

Ingredient property Lavender auto
Ingredient property MountainFlower01Blue auto
Ingredient property MountainFlower01Purple auto
Ingredient property MountainFlower01Red auto
Ingredient property Thistle01 auto

Message property _WL_TorchbugDropRelease auto

Message property _WL_TorchbugEmptyEquip auto
Message property _WL_TorchbugCatch auto
Message property _WL_TorchbugNoPollen auto
Message property _WL_TorchbugRemainingFlowers auto
Message property _WL_TorchbugFlowersUsed auto
Message property _WL_LanternOilRemainingHalfFull auto
Message property _WL_LanternOilRemainingMostlyEmpty auto
Message property _WL_LanternOilRemainingEmptyRanOut auto
Message property _WL_LanternPollenRemainingEmptyRanOut auto
Message property _WL_LanternOilUsed auto

; enum
int property current_lantern = 0 auto hidden

int property LANTERN_NONE = 0 auto hidden
int property LANTERN_OIL = 1 auto hidden
int property LANTERN_TORCHBUG = 2 auto hidden
int property LANTERN_TORCHBUGEMPTY = 3 auto hidden

GlobalVariable property _WL_OilLevel auto
GlobalVariable property _WL_PollenLevel auto
GlobalVariable property _WL_gToggle auto
{ 0 = Off. 1 = On. }
GlobalVariable property _WL_HasFuel auto
{ 0 = Not using oil burning mechanic. 1 = Player has oil. 2 = Oil is depleted. }
GlobalVariable property _WL_AutoModeLightOn auto
{ 0 = Not using automatic lighting mechanic. 1 = Auto-on conditions exist. 2 = Auto-off conditions exist. }

int oil_update_counter = 0
float last_oil_level = 0.0
int pollen_update_counter = 0
int iLastPollenLevel = 0
int last_pollen_level = 0
bool is_sneaking = false

;Timer variables (for debug purposes)
float pfThreadLastUpdateTime = 0.0

Keyword property _WL_Lantern auto
Keyword property _WL_InventoryLantern auto
Keyword property ArmorShield auto
Keyword property LocTypeDwelling auto
Keyword property LocTypeInn auto
Keyword property LocTypeHouse auto
Keyword property LocTypeCastle auto
Keyword property LocTypeGuild auto
Keyword property LocTypePlayerHouse auto
Keyword property LocTypeStore auto

Form fCandleLanternHeld
Form fCandleLanternHeldDroppedLit

;--------------
;	States		\
;------------------------------------------------------------------------------------

State BlockEvents

	Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	endEvent
	
endState

;--------------
;	Events		\
;------------------------------------------------------------------------------------
Event OnInit()
	
endEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	SetShouldLightLanternAutomatically(akNewLoc)
endEvent

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if (asEventName == "tailSneakIdle" || asEventName == "tailSneakLocomotion")
		if is_sneaking == false
			is_sneaking = true
			SetShouldLightLanternAutomatically(PlayerRef.GetCurrentLocation())
		endif
	else
		if is_sneaking == true
			is_sneaking = false
			SetShouldLightLanternAutomatically(PlayerRef.GetCurrentLocation())
		endif
	endif
EndEvent

Event OnUpdateGameTime()
	SetShouldLightLanternAutomatically(PlayerRef.GetCurrentLocation())

	; Register for dawn / dusk
	float current_hour = GameHour.GetValue()
	if current_hour < 7.0
		RegisterForSingleUpdateGameTime(7.0 - current_hour)
	elseif current_hour >= 7.0 && current_hour < 19.0
		RegisterForSingleUpdateGameTime(19.0 - current_hour)
	elseif current_hour >= 19.0
		RegisterForSingleUpdateGameTime(7.0 + (24.0 - current_hour))
	endif
endEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if akBaseObject == Torch01
		WLDebug(1, "OnObjectEquipped Event, Torch")
		LanternMutex(akBaseObject)
	elseif (akBaseObject as Armor && akBaseObject.HasKeyword(ArmorShield)) || (akBaseObject as Weapon && PlayerRef.GetEquippedItemType(0) <= 4)	;I equipped a shield or off-hand weapon
		WLDebug(1, "OnObjectEquipped Event, Weapon or Shield")
		DropLantern()
    elseif akBaseObject == _WL_WearableLanternInvDisplay
    	SetLantern(akBaseObject, 0, LANTERN_OIL, "Lantern")
	elseif akBaseObject == _WL_WearableTorchbugInvDisplay
		SetLantern(akBaseObject, 1, LANTERN_TORCHBUG, "Torchbug")
	elseif akBaseObject == _WL_WearableTorchbugInvDisplayRED
		SetLantern(akBaseObject, 2, LANTERN_TORCHBUG, "Torchbug")
	elseif akBaseObject == _WL_WearablePaperInvDisplay
		if Compatibility.bIsDLC2Loaded
			SetLantern(akBaseObject, 3, LANTERN_OIL, "Paper")
		else
			debug.notification("Dragonborn not installed.")
			while PlayerRef.GetItemCount(_WL_WearablePaperInvDisplay) > 0
				PlayerRef.Removeitem(_WL_WearablePaperInvDisplay)
			endwhile
		endif
	elseif akBaseObject == _WL_WearableTorchbugApparel_EmptyInvDisplay
		SetLantern(akBaseObject, 5, LANTERN_TORCHBUGEMPTY, "Empty Torchbug")
		_WL_TorchbugEmptyEquip.Show()
	elseif akBaseObject == fCandleLanternHeld
		WLDebug(1, "OnObjectEquipped Event, Candle Lantern")
		LanternMutex(akBaseObject)
	endif
endEvent

bool unequip_lock = false
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	WLDebug(1, "OnObjectUnequipped " + akBaseObject)
	if akBaseObject as Armor && akBaseObject.HasKeyword(_WL_Lantern)
		unequip_lock = true
	    ToggleLanternOff()
		DestroyNonDisplayLantern(akBaseObject)
		if !akBaseObject.HasKeyword(_WL_InventoryLantern)
			UnequipDisplayLantern(akBaseObject)
		endif
		unequip_lock = false
    endif
endEvent

function SetLantern(Form akBaseObject, int aiLanternIndex, int aiLanternState, string asTorchTypeDebug)
	; Allow unequip events to process first
	int i = 20
    while unequip_lock == true && i > 0
        Utility.WaitMenuMode(0.2)
        i -= 1
    endWhile

	WLDebug(1, "Setting lantern: " + asTorchTypeDebug)
	LanternMutex(akBaseObject)						;Prevent using more than one light source
	DestroyNonDisplayLantern(akBaseObject)
	EquipNonPlayableLantern(aiLanternIndex)			;Equip the "real" lantern
	;The player has a lantern
	current_lantern = aiLanternState
	ToggleLanternOn()
endFunction

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	if _WL_InvBugLanterns.HasForm(akBaseItem) && akDestContainer == none && PlayerRef.IsSneaking()
		ReleaseTorchbugMenu(akBaseItem)
	endif
endEvent

Event OnUpdate()	
	if current_lantern == LANTERN_OIL
		UpdateOil()
		SetOilLevel()
	elseif current_lantern == LANTERN_TORCHBUG
		UpdatePollen()
		SetPollenLevel()
	endif
	
	if SettingIsEnabled(_WL_SettingOil) && _WL_gToggle.GetValueInt() == 1 && current_lantern == LANTERN_OIL
		RegisterForSingleUpdate(5)
	elseif SettingIsEnabled(_WL_SettingFeeding) && _WL_gToggle.GetValueInt() == 1 && current_lantern == LANTERN_TORCHBUG
		RegisterForSingleUpdate(5)
	endif
endEvent

function ToggleLanternOn()
	if current_lantern == LANTERN_OIL
		SetOilLevel()
	elseif current_lantern == LANTERN_TORCHBUG
		SetPollenLevel()
	endif
	_WL_gToggle.SetValueInt(1)
	RegisterForSingleUpdate(5)
endFunction

function ToggleLanternOff()
	_WL_gToggle.SetValueInt(0)
	UnregisterForUpdate()
endFunction

function CatchTorchbug(ObjectReference akTorchbug)
	if Compatibility.bIsBUGSLoaded && akTorchbug.GetBaseObject() == Compatibility.FireflyBUG
		;Firefly (101BUGS)
		PlayerRef.UnequipItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, abSilent = true)
		PlayerRef.RemoveItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, abSilent = true)
		PlayerRef.AddItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
		PlayerRef.EquipItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
		_WL_TorchbugCatch.Show()
		akTorchbug.Disable()
		akTorchbug.Delete()
	else
		;Default to torchbug
		PlayerRef.UnequipItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, abSilent = true)
		PlayerRef.RemoveItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, abSilent = true)
		PlayerRef.AddItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
		PlayerRef.EquipItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
		_WL_TorchbugCatch.Show()
		akTorchbug.Disable()
		akTorchbug.Delete()
	endif
endFunction

;-----------------------
;	Menu Functions		\
;------------------------------------------------------------------------------------
function ReleaseTorchbugMenu(Form akBaseObject)
	int ibutton = _WL_TorchbugDropRelease.Show()
	if ibutton == 0						;Release
		if akBaseObject == _WL_WearableTorchbugInvDisplay
			ObjectReference myEmptyLantern = FindAndDropEmptyBugLantern(_WL_WearableTorchbugInvDisplay)
			objectreference myTorchbug = myEmptyLantern.PlaceAtMe(CritterFirefly)
			myTorchbug.MoveTo(myEmptyLantern, 50.0, 0.0, 75.0)
		elseif akBaseObject == _WL_WearableTorchbugInvDisplayRED
			ObjectReference myEmptyLantern = FindAndDropEmptyBugLantern(_WL_WearableTorchbugInvDisplayRED)
			if Compatibility.FireflyBUG != none
				objectreference myTorchbug = myEmptyLantern.PlaceAtMe(Compatibility.FireflyBUG)
				myTorchbug.MoveTo(myEmptyLantern, 50.0, 0.0, 75.0)
			endif
		endif
	elseif ibutton == 1
		;do nothing
	endif
endFunction

ObjectReference function FindAndDropEmptyBugLantern(Form akBaseObject)
	objectreference myDroppedLantern = Game.FindClosestReferenceOfTypeFromRef(akBaseObject, PlayerRef, 350.0)
	if myDroppedLantern != none
		myDroppedLantern.Delete()
	endif
	objectreference myEmptyLantern = PlayerRef.PlaceAtMe(_WL_WearableTorchbugApparel_EmptyInvDisplay)
	myEmptyLantern.MoveTo(PlayerRef, 100.0, 0.0, 50.0)
	wait(0.2)
	myEmptyLantern.ApplyHavokImpulse(0.0, 0.0, -1.0, 1.0)		;Force to fall to the ground, like an item drop
	return myEmptyLantern
endFunction

;-------------------------------
;	Generic Light Functions		\
;------------------------------------------------------------------------------------
function EquipNonPlayableLantern(int iLanternIndex)
	int iPosition = _WL_SettingPosition.GetValueInt()
	if iLanternIndex == 0 					;Travel
		if iPosition == 0
			PlayerRef.EquipItem(_WL_WearableLanternApparel, abSilent = true)
		elseif iPosition == 1
			PlayerRef.EquipItem(_WL_WearableLanternApparelFront, abSilent = true)
		elseif iPosition == 2
			PlayerRef.EquipItem(_WL_LanternHeld, abSilent = true)
		endif
	elseif iLanternIndex == 1 				;Torchbug
		if iPosition == 0
			PlayerRef.EquipItem(_WL_WearableTorchbugApparel, abSilent = true)
		elseif iPosition == 1
			PlayerRef.EquipItem(_WL_WearableTorchbugApparelFront, abSilent = true)
		elseif iPosition == 2
			PlayerRef.EquipItem(_WL_TorchbugHeld, abSilent = true)
		endif
	elseif iLanternIndex == 2 				;Torchbug (red, abSilent = true)
		if iPosition == 0
			PlayerRef.EquipItem(_WL_WearableTorchbugApparelRED, abSilent = true)
		elseif iPosition == 1
			PlayerRef.EquipItem(_WL_WearableTorchbugApparelFrontRED, abSilent = true)
		elseif iPosition == 2
			PlayerRef.EquipItem(_WL_TorchbugHeldRED, abSilent = true)
		endif
	elseif iLanternIndex == 3 				;Paper
		if iPosition == 0
			PlayerRef.EquipItem(_WL_WearablePaperApparel, abSilent = true)
		elseif iPosition == 1
			PlayerRef.EquipItem(_WL_WearablePaperApparelFront, abSilent = true)
		elseif iPosition == 2
			PlayerRef.EquipItem(_WL_PaperHeld, abSilent = true)
		endif
	elseif iLanternIndex == 4 				;Candle
		; pass
	elseif iLanternIndex == 5 				;Empty Torchbug
		if iPosition == 0
			PlayerRef.EquipItem(_WL_WearableTorchbugApparel_Empty, abSilent = true)
		elseif iPosition == 1
			PlayerRef.EquipItem(_WL_WearableTorchbugApparelFront_Empty, abSilent = true)
		elseif iPosition == 2
			PlayerRef.EquipItem(_WL_TorchbugHeld_Empty, abSilent = true)
		endif
	endif
endFunction

;-----------------------
;	Misc Functions		\
;------------------------------------------------------------------------------------
function DropLantern()
	if SettingIsEnabled(_WL_SettingDropLit) && !IsInMenuMode()
		int iPosition = _WL_SettingPosition.GetValueInt()
		if PlayerRef.IsEquipped(_WL_WearableLanternInvDisplay) && iPosition == 2
			if SettingIsEnabled(_WL_SettingOil)
				if _WL_Oillevel.GetValue() > 0.0
					PlayerRef.UnequipItem(_WL_WearableLanternInvDisplay, abSilent = true)
					PlayerRef.RemoveItem(_WL_WearableLanternInvDisplay, abSilent = true)
					PlayerRef.PlaceAtMe(_WL_LanternDroppedLit)
				else
					return
				endif
			else
				PlayerRef.UnequipItem(_WL_WearableLanternInvDisplay, abSilent = true)
				PlayerRef.RemoveItem(_WL_WearableLanternInvDisplay, abSilent = true)
				PlayerRef.PlaceAtMe(_WL_LanternDroppedLit)
			endif
		elseif PlayerRef.IsEquipped(_WL_WearableTorchbugInvDisplay) && iPosition == 2
			if SettingIsEnabled(_WL_SettingFeeding)
				if _WL_PollenLevel.GetValueInt() > 0
					PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
					if PlayerRef.IsSneaking()
						GoToState("BlockEvents")
					endif
					PlayerRef.RemoveItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
					PlayerRef.PlaceAtMe(_WL_TorchbugDroppedLit)
					GoToState("")
				else
					return
				endif
			else
				PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
				if PlayerRef.IsSneaking()
					GoToState("BlockEvents")
				endif
				PlayerRef.RemoveItem(_WL_WearableTorchbugInvDisplay, abSilent = true)
				PlayerRef.PlaceAtMe(_WL_TorchbugDroppedLit)
				GoToState("")
			endif
		elseif PlayerRef.IsEquipped(_WL_WearableTorchbugInvDisplayRED) && iPosition == 2
			if SettingIsEnabled(_WL_SettingFeeding)
				if _WL_PollenLevel.GetValueInt() > 0
					PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
					if PlayerRef.IsSneaking()
						GoToState("BlockEvents")
					endif
					PlayerRef.RemoveItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
					PlayerRef.PlaceAtMe(_WL_TorchbugREDDroppedLit)
					GoToState("")
				else
					return
				endif
			else
				PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
				If PlayerRef.IsSneaking()
					GoToState("BlockEvents")
				endif
				PlayerRef.RemoveItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)
				PlayerRef.PlaceAtMe(_WL_TorchbugREDDroppedLit)
				GoToState("")

			endif
		elseif PlayerRef.IsEquipped(_WL_WearablePaperInvDisplay) && iPosition == 2
			if SettingIsEnabled(_WL_SettingOil)
				if _WL_Oillevel.GetValue() > 0.0
					PlayerRef.UnequipItem(_WL_WearablePaperInvDisplay, abSilent = true)
					PlayerRef.RemoveItem(_WL_WearablePaperInvDisplay, abSilent = true)
					PlayerRef.PlaceAtMe(_WL_PaperHeldDroppedLit)
				else
					return
				endif
			else
				PlayerRef.UnequipItem(_WL_WearablePaperInvDisplay, abSilent = true)
				PlayerRef.RemoveItem(_WL_WearablePaperInvDisplay, abSilent = true)
				PlayerRef.PlaceAtMe(_WL_PaperHeldDroppedLit)
			endif
		endif
	endif
endFunction

function RefillTorchbug()
	int pollen_level = _WL_PollenLevel.GetValueInt()
	
	bool has_flowers = true
	while pollen_level < 32 && has_flowers
		;Convert flowers to pollen
		if PlayerRef.GetItemCount(Thistle01) > 0
			PlayerRef.RemoveItem(Thistle01, 1, true)
			pollen_level += 8
		elseif PlayerRef.GetItemCount(Lavender) > 0
			PlayerRef.RemoveItem(Lavender, 1, true)
			pollen_level += 8
		elseif PlayerRef.GetItemCount(MountainFlower01Blue) > 0
			PlayerRef.RemoveItem(MountainFlower01Blue, 1, true)
			pollen_level += 8
		elseif PlayerRef.GetItemCount(MountainFlower01Purple) > 0
			PlayerRef.RemoveItem(MountainFlower01Purple, 1, true)
			pollen_level += 8
		elseif PlayerRef.GetItemCount(MountainFlower01Red) > 0
			PlayerRef.RemoveItem(MountainFlower01Red, 1, true)
			pollen_level += 8
		elseif Compatibility.bIsDLC1Loaded && PlayerRef.GetItemCount(Compatibility.MountainFlowerYellow) > 0
			PlayerRef.RemoveItem(Compatibility.MountainFlowerYellow, 1, true)
			pollen_level += 8
		else
			has_flowers = false
		endif
	endWhile
	_WL_PollenLevel.SetValueInt(pollen_level)
endFunction

function RefillLantern()
	int bottle_count = PlayerRef.GetItemCount(_WL_LanternOil4)
	if bottle_count >= 1
		_WL_OilLevel.SetValue(16.0)
		PlayerRef.RemoveItem(_WL_LanternOil4, 1, true)
	endif
endFunction

function LanternMutex(Form akBaseObject)
	;Ensure that the player can only equip one lantern at a time.
	if akBaseObject != Torch01
		PlayerRef.UnequipItem(Torch01, false, true)
	endif
	
	;Travel Lanterns
	PlayerRef.UnequipItem(_WL_WearableLanternApparel, false, true)
	PlayerRef.UnequipItem(_WL_WearableLanternApparelFront, false, true)
	PlayerRef.UnequipItem(_WL_LanternHeld, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparel_Empty, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparelFront_Empty, false, true)
	PlayerRef.UnequipItem(_WL_TorchbugHeld_Empty, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparel, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparelFront, false, true)
	PlayerRef.UnequipItem(_WL_TorchbugHeld, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparelRED, false, true)
	PlayerRef.UnequipItem(_WL_WearableTorchbugApparelFrontRED, false, true)
	PlayerRef.UnequipItem(_WL_TorchbugHeldRED, false, true)
	PlayerRef.UnequipItem(_WL_WearablePaperApparel, false, true)
	PlayerRef.UnequipItem(_WL_WearablePaperApparelFront, false, true)
	PlayerRef.UnequipItem(_WL_PaperHeld, false, true)

	if akBaseObject != _WL_WearableLanternInvDisplay
		PlayerRef.UnequipItem(_WL_WearableLanternInvDisplay, false, true)
	endif
	if akBaseObject != _WL_WearablePaperInvDisplay
		PlayerRef.UnequipItem(_WL_WearablePaperInvDisplay, false, true)
	endif
	if akBaseObject != _WL_WearableTorchbugInvDisplay
		PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplay, false, true)
	endif
	if akBaseObject != _WL_WearableTorchbugInvDisplayRED
		PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplayRED, false, true)
	endif
	if akBaseObject != _WL_WearableTorchbugApparel_EmptyInvDisplay
		PlayerRef.UnequipItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, false, true)
	endif
endFunction

function DestroyNonDisplayLantern(Form akBaseObject)
	while PlayerRef.GetItemCount(_WL_AllLanterns) > 0
		PlayerRef.RemoveItem(_WL_AllLanterns, 1, abSilent = true)
	endWhile
endFunction

function UnequipDisplayLantern(Form akNonDisplayLantern)
	if akNonDisplayLantern == _WL_WearableLanternApparel || 					\
			akNonDisplayLantern == _WL_WearableLanternApparelFront || 			\
			akNonDisplayLantern == _WL_LanternHeld

		PlayerRef.UnequipItem(_WL_WearableLanternInvDisplay, abSilent = true)

	elseif akNonDisplayLantern == _WL_WearableTorchbugApparel_Empty ||			\
			akNonDisplayLantern == _WL_WearableTorchbugApparelFront_Empty ||	\
			akNonDisplayLantern == _WL_TorchbugHeld_Empty

		PlayerRef.UnequipItem(_WL_WearableTorchbugApparel_EmptyInvDisplay, abSilent = true)

	elseif akNonDisplayLantern == _WL_WearableTorchbugApparel ||				\
			akNonDisplayLantern == _WL_WearableTorchbugApparelFront ||			\
			akNonDisplayLantern == _WL_TorchbugHeld

		PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplay, abSilent = true)

	elseif akNonDisplayLantern == _WL_WearableTorchbugApparelRED ||				\
			akNonDisplayLantern == _WL_WearableTorchbugApparelFrontRED ||		\
			akNonDisplayLantern == _WL_TorchbugHeldRED

		PlayerRef.UnequipItem(_WL_WearableTorchbugInvDisplayRED, abSilent = true)

	elseif akNonDisplayLantern == _WL_WearablePaperApparel ||					\
			akNonDisplayLantern == _WL_WearablePaperApparelFront ||				\
			akNonDisplayLantern == _WL_PaperHeld

		PlayerRef.UnequipItem(_WL_WearablePaperInvDisplay, abSilent = true)
	endif
endFunction

function SetShouldLightLanternAutomatically(Location akLocation)
	if !SettingIsEnabled(_WL_SettingAutomatic)
		; The auto-on setting is off.
		_WL_AutoModeLightOn.SetValueInt(0)
	else
		if PlayerRef.IsSneaking()
			_WL_AutoModeLightOn.SetValueInt(2)
			ToggleLanternOff()
		else
			if IsRefInInterior(PlayerRef)
				if akLocation.HasKeyword(LocTypeCastle) || akLocation.HasKeyword(LocTypeGuild) || 	\
					akLocation.HasKeyword(LocTypeInn) || akLocation.HasKeyword(LocTypeHouse) || 	\
					akLocation.HasKeyword(LocTypePlayerHouse) || akLocation.HasKeyword(LocTypeStore)
					_WL_AutoModeLightOn.SetValueInt(2)
					ToggleLanternOff()
				else
					; Inside in non-restricted location type
					_WL_AutoModeLightOn.SetValueInt(1)
					ToggleLanternOn()
				endif
			else
				if GameHour.GetValue() >= 19.0 || GameHour.GetValue() <= 7.0
					; Outside at night
					_WL_AutoModeLightOn.SetValueInt(1)
					ToggleLanternOn()
				else
					_WL_AutoModeLightOn.SetValueInt(2)
					ToggleLanternOff()
				endif
			endif
		endif
	endif
endFunction

function SetOilLevel()
	if SettingIsEnabled(_WL_SettingOil)
		float oil_level = _WL_OilLevel.GetValue()
		WLDebug(0, "last_oil_level = " + last_oil_level + ", oil_level = " + oil_level)

		; Attempt to refill the player's lantern
		if oil_level == 0
			RefillLantern()
			oil_level = _WL_OilLevel.GetValue()
		endif

		; Set fuel state global and show messages as necessary
		if last_oil_level < oil_level 							; Oil added
			_WL_LanternOilUsed.Show() 
			_WL_HasFuel.SetValueInt(1)
		elseif last_oil_level > oil_level && oil_level > 0 		; Oil burned
			ShowRemainingOilMessage(oil_level)
			_WL_HasFuel.SetValueInt(1)
		elseif last_oil_level == oil_level && oil_level > 0 	; The player has oil
			_WL_HasFuel.SetValueInt(1)
		elseif last_oil_level > 0 && oil_level == 0 			; Oil depleted
			_WL_LanternOilRemainingEmptyRanOut.Show()
			_WL_HasFuel.SetValueInt(2)
		elseif oil_level == 0
			_WL_HasFuel.SetValueInt(2)
		endif
		last_oil_level = oil_level
	else
		;Player is not using the oil-burning mechanic
		_WL_HasFuel.SetValueInt(0)
	endif
endFunction

function UpdateOil()
	if SettingIsEnabled(_WL_SettingOil)
		float oil_level = _WL_OilLevel.GetValue()
		if oil_update_counter >= 6             	  ;30 seconds have passed, reduce oil in player's lantern
			if oil_level >= 0.5
				oil_level -= 0.5
				_WL_OilLevel.SetValue(oil_level)
				oil_update_counter = 0
			endif
			WLDebug(1, "Oil Level: " + oil_level)
		else
			oil_update_counter += 1
		endif
	endif
endFunction

function SetPollenLevel()
	if SettingIsEnabled(_WL_SettingFeeding)
		int pollen_level = _WL_PollenLevel.GetValueInt()
		WLDebug(0, "last_pollen_level = " + last_pollen_level + ", pollen_level = " + pollen_level)

		; Attempt to refill the player's lantern
		if pollen_level == 0
			RefillTorchbug()
			pollen_level = _WL_PollenLevel.GetValueInt()
		endif

		; Set fuel state global and show messages as necessary
		if last_pollen_level < pollen_level 							; Pollen added
			_WL_TorchbugFlowersUsed.Show()
			_WL_HasFuel.SetValueInt(1)
		elseif last_pollen_level > pollen_level && pollen_level > 0 	; Pollen used
			ShowRemainingPollenMessage(pollen_level)
			_WL_HasFuel.SetValueInt(1)
		elseif last_pollen_level == pollen_level && pollen_level > 0 	; The player has pollen
			_WL_HasFuel.SetValueInt(1)
		elseif last_pollen_level > 0 && pollen_level == 0 				; Pollen depleted
			_WL_LanternPollenRemainingEmptyRanOut.Show()
			_WL_HasFuel.SetValueInt(2)
		elseif pollen_level == 0
			_WL_HasFuel.SetValueInt(2)
		endif
		last_pollen_level = pollen_level
	else
		; The player is not using the feeding mechanic
		_WL_HasFuel.SetValueInt(0)	
	endif
endFunction

function UpdatePollen()
	if SettingIsEnabled(_WL_SettingFeeding)
		int pollen_level = _WL_PollenLevel.GetValueInt()
		if pollen_update_counter >= 6
			if pollen_level >= 1
				pollen_level -= 1
				_WL_PollenLevel.SetValueInt(pollen_level)
				pollen_update_counter = 0
			endif
			WLDebug(1, "Pollen Level: " + pollen_level)
		else
			pollen_update_counter += 1
		endif
	endif
endFunction

function ShowRemainingOilMessage(float oil_level)
	if oil_level == 8.0
		_WL_LanternOilRemainingHalfFull.Show()
	elseif oil_level == 4.0
		_WL_LanternOilRemainingMostlyEmpty.Show()
	endif
endFunction

function ShowRemainingPollenMessage(int pollen_level)
	if pollen_level == 16
		_WL_LanternOilRemainingHalfFull.Show()
	elseif pollen_level == 8
		_WL_LanternOilRemainingMostlyEmpty.Show()
	endif
endFunction

bool function IsRefInInterior(ObjectReference akReference)
	if akReference.IsInInterior()
		return true
	else
		if _WL_InteriorWorldspaces.HasForm(akReference.GetWorldSpace())
			return true
		else
			return false
		endif
	endif
endFunction

function WLDebug(int aiSeverity, string asLogMessage)
	int LOG_LEVEL = _WL_Debug.GetValueInt()
	if LOG_LEVEL <= aiSeverity
		if aiSeverity == 0
			debug.trace("[Wearable Lanterns][Debug] " + asLogMessage)
		elseif aiSeverity == 1
			debug.trace("[Wearable Lanterns][Info] " + asLogMessage)
		elseif aiSeverity == 2
			debug.trace("[Wearable Lanterns][Warning] " + asLogMessage)
		elseif aiSeverity == 3
			debug.trace("[Wearable Lanterns][ERROR] " + asLogMessage)
		endif
	endif
endFunction

bool function SettingIsEnabled(GlobalVariable akSettingGlobal)
	if akSettingGlobal.GetValueInt() == 2
		return true
	else
		return false
	endif
endFunction