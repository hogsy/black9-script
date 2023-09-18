// B9_HQListener

class B9_HQListener extends B9_CalibrationMaster
	placeable;

var transient B9_Intermission intermission;
var name IntermissionName;

var string fStrInfirmaryBooth;
var name fStrInfirmaryBoothTrigger;
var string fStrNanoCalKiosk;
var string fStrIntrinsicSkillDisplay;
var string fStrHQZoneInfo;
var string fStrStationInUse;
var string fStrBoothInUse;

var class<B9_MenuInteraction> YesNoInteractionClass;

var class<B9_MenuInteraction> KioskClassArray[32];
var class<B9_Calibration> CalClassArray[4];

var int fComPanelUseCount;

var(HQListener) float KioskHoloWidth;		// width of rotating holographic display
var(HQListener) float KioskHoloHeight;		// height of same
var(HQListener) float KioskHoloOffset;		// offset of center of display from trigger
var(HQListener) float KioskHoloShift;		// shift left/right of center of display

var globalconfig int ConcludedMissionAdjustment[15];

replication
{
	// Replicated variables from server.
	reliable if( bNetDirty && Role==ROLE_Authority )
		IntermissionName;
}

function Tick(float Delta)
{
	local B9_PlayerPawn Pawn;
	local B9_PlayerController Controller;

	Super.Tick( Delta );

	foreach AllActors(class'B9_PlayerPawn', Pawn)
	{
		Controller = B9_PlayerController(Pawn.Controller);
		if (Controller != None && Controller.fKioskTrigger != None &&
			InStr(""$Controller.fKioskTrigger.Tag, fStrInfirmaryBooth) == 0)
		{
			if (Controller.fKioskOffDelay > 0.0f)
			{
				Controller.fKioskOffDelay -= Delta;
				if (Controller.fKioskOffDelay <= 0.0f)
				{
					//Log("Deactivating infirmary booth after delay");
					if (Controller.fKioskOpTicks != 0.0f)
						TriggerSideEffects(fStrInfirmaryBoothTrigger, Controller.fKioskTrigger, Pawn);
					Controller.fKioskTrigger = None;
					Controller.fKioskOffDelay = 0.0f;
				}
			}
			else if (Controller.fKioskOnDelay > 0.0f)
			{
				Controller.fKioskOnDelay -= Delta;
				if (Controller.fKioskOnDelay <= 0.0f)
				{
					//Log("Activating infirmary booth after delay & healing");
					TriggerSideEffects(fStrInfirmaryBoothTrigger, Controller.fKioskTrigger, Pawn);
					Controller.fKioskOnDelay = 0.0f;
					Heal(Pawn, Controller.fKioskOpTicks);
				}
			}
			else if (Controller.fKioskOpTicks > 0.0f)
			{
				Controller.fKioskOpTicks -= Delta;
				if (Controller.fKioskOpTicks <= 0.0f)
				{
					//Log("Infirmary booth is healing:"$string(Pawn.Health));
					Heal(Pawn, Controller.fKioskOpTicks);
				}
			}
		}
	}
}

function Heal(B9_PlayerPawn Patient, out float ticks)
{
	if (Patient.Health < Patient.fCharacterMaxHealth)
	{
		ticks = 0.5f;
		if (Patient.Health >= Patient.fCharacterMaxHealth / 4)
			Patient.fCharacterCash -= intermission.HealingPrice;
		Patient.Health += 1;
	}
}

function TriggerSideEffects(name TriggerTagName, Actor Other, Pawn Instigator)
{
	local Triggers T;

	ForEach AllActors(class'Triggers', T)
	{
		if (T.Tag == TriggerTagName)
			T.Trigger(Other, Instigator);
	}
}

function ActivateZone( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn pp;
	local B9_PlayerController pc;
	local B9_HQZoneInfo zone;
	local B9_AttributeReadout readout;
	local bool bSkipMessage;

	pp = B9_PlayerPawn(Instigator);
	zone = B9_HQZoneInfo(Other);
	if (pp == None || zone == None)
		return;

/*
	if (zone.CheckMultipleOccupants)
	{
		// debugging: no one can come in
		pp.SetLocation(Normal(pp.Location - zone.Location) * 100 + pp.Location);
	}
*/
	if (zone.CheckMultipleOccupants && zone.CurrentOccupant != None)
	{
		if (zone.CurrentOccupant != pp)
		{
			// can't come in
			pp.SetLocation(Normal(pp.Location - zone.Location) * 100 + pp.Location);
			bSkipMessage = true;
		}
	}

	ForEach zone.ZoneActors(class'B9_AttributeReadout', readout)
	{
		pp.ReadoutSubject(readout.Tag, true);
		break;
	}

	pc = B9_PlayerController(pp.Controller);
	//Log("AZ: PZ="$pc.fPrevZoneInfo.Name$" CZ="$pc.fCurrentZoneInfo.Name$" Z="$zone.Name);
	if (!bSkipMessage && pc != None && zone != pc.fCurrentZoneInfo)
	{
		zone.CurrentOccupant = pp;
		pc.ShowLocationMessage(zone.EntryMessage);
	}
}

function DeactivateZone( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn pp;
	local B9_PlayerController pc;
	local B9_HQZoneInfo zone;
	local B9_AttributeReadout readout;
	local Interaction mm;
	local B9_MenuInteraction mi;
	local B9_Calibration cal;
	local Pickup A;
	local bool hasPending;

	pp = B9_PlayerPawn(Instigator);
	zone = B9_HQZoneInfo(Other);
	if (pp == None || zone == None)
		return;

	Log("B9_HQListener asked to deactivate zone" );

	if (zone.CheckOnExit)
	{
		// three cases: purchased things on ground, mods in Calibration list, or cals in Calibration list

		/* check physical item purchases (not needed in current design)
		ForEach AllActors(class'Pickup', A, pp.fServerName)
		{
			hasPending = true;
			break;
		}

		if (!hasPending)
		{
		*/
			cal = Calibration;
			if (cal != None)
			{
				while (cal.Calibration != None)
				{
					cal = cal.Calibration;
	
					if( cal.PawnName == pp.Name )
					{
						hasPending = true;
						break;
					}
				}
			}
		/*
		}
		*/

		if (hasPending)
		{
			Instigator.ClientMessage( "Did you forget something?" );

			pc = B9_PlayerController(pp.Controller);
			pc.ShowInteraction(YesNoInteractionClass, zone.Location, zone.CancelMessage);
			pp.SetPhysics(PHYS_None);

			return;
		}
	}

	if (zone.CheckMultipleOccupants && zone.CurrentOccupant == pp)
	{
		zone.CurrentOccupant = None;
	}

	ForEach zone.ZoneActors(class'B9_AttributeReadout', readout)
	{
		pp.ReadoutSubject(readout.Tag, false);
		break;
	}
}

function DeferredDeactivateZone( ZoneInfo Z, Pawn P )
{
	local B9_PlayerPawn pp;
	local B9_HQZoneInfo zone;
	local B9_AttributeReadout readout;

	pp = B9_PlayerPawn(P);
	zone = B9_HQZoneInfo(Z);
	if (pp == None || zone == None)
		return;

	if (zone.CheckMultipleOccupants && zone.CurrentOccupant == pp)
	{
		zone.CurrentOccupant = None;
	}

	ForEach zone.ZoneActors(class'B9_AttributeReadout', readout)
	{
		pp.ReadoutSubject(readout.Tag, false);
		break;
	}
}

function ActivateInfirmaryBooth( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn Pawn;
	local B9_PlayerController Controller;
	local int showError;
	local Triggers TriggerSource;

	Pawn = B9_PlayerPawn(Instigator);
	if (Pawn == None)
		return;
	Controller = B9_PlayerController(Pawn.Controller);
	if (Controller == None)
		return;

	//Log("Entering infirmary booth");

	TriggerSource = Triggers(Other);

	if (Controller.fKioskTrigger != None && InStr(""$Controller.fKioskTrigger.Tag, fStrInfirmaryBooth) != 0)
	{
		Log("In kiosk!! name="$Controller.fKioskTrigger);
		return;
	}

	if (Controller.fKioskTrigger != TriggerSource && !Controller.CanEnterKiosk(TriggerSource, showError))
	{
		if (showError != 0)
			Controller.ShowLocationMessage(fStrBoothInUse);
		return;
	}

	Pawn.Health = (Pawn.Health * 3) / 4; // debugging code

	Controller.fKioskTrigger = TriggerSource;
	Controller.fKioskOffDelay = 0.0f;
	Controller.fKioskOnDelay = 0.5f;
	Controller.fKioskOpTicks = 0.0f;

	// !!!! Show current cash in HUD
}

function DeactivateInfirmaryBooth( Actor Other, Pawn Instigator )
{
	local B9_PlayerPawn Pawn;
	local B9_PlayerController Controller;

	Pawn = B9_PlayerPawn(Instigator);
	if (Pawn == None)
		return;
	Controller = B9_PlayerController(Pawn.Controller);
	if (Controller == None)
		return;
	if (Controller.fKioskTrigger != Triggers(Other))
		return;

	//Log("Leaving infirmary booth");

	Controller.fKioskOffDelay = 0.5f;
	Controller.fKioskOnDelay = 0.0f;

	// !!!! Hide current cash in HUD
}

function ActivateKiosk( Actor Other, Pawn Instigator )
{
	local string MenuName;
	local B9_PlayerController pc;
	local B9_PlayerPawn pp;
	local B9_AttrCalibration cal; // debugging
	local Inventory mod;
	local B9_Skill skill;
	local string skillName;
	local int i, n;
	local int showError;
	local bool isNanoCal;
	local bool isSkillDisplay;
	local bool isMissionKit;
	local bool result;
	local B9_BaseKiosk kiosk;
	local class<B9_BaseKiosk> kioskClass;
	local Triggers TriggerSource;
	local bool found;

	pp = B9_PlayerPawn(Instigator);
	pc = B9_PlayerController(Instigator.Controller);
	if (pc == None || pp == None)
		return;

	TriggerSource = Triggers(Other);

	MenuName = string(Other.Tag);
log("pp.fCharacterConcludedMission=" $ pp.fCharacterConcludedMission);
	if (MenuName == "ConferenceComPanel" && pp.fCharacterConcludedMission != 0)
	{
		if (intermission.ConcludedMission == 1)
		{
			switch (fComPanelUseCount)
			{

			case 2:
				// goto mission briefing
				MissionBriefing(pc);
				fComPanelUseCount++;
				return;

			case 0:
				// comment #1
				break;
			case 1:
				// comment #2
				break;
			default:
				// ask if user wants to repeat mission briefing
				break;
			}
		}
		else
		{
			switch (fComPanelUseCount)
			{
			case 0:
				MissionBriefing(pc);
				//fComPanelUseCount++;
				return;

			default:
				// ask if user wants to repeat mission briefing
				break;
			}
		}

		//fComPanelUseCount++;
		found = true;
	}

	if (!found)
	{
		i = InStr(MenuName, fStrNanoCalKiosk);
		if (i == 0)
		{
			// nanotech skill calibration
			isNanoCal = true;
			n = int(Mid(MenuName, Len(fStrNanoCalKiosk)));
			MenuName = fStrNanoCalKiosk;

			for (mod=pp.Inventory;mod!=None;mod=mod.Inventory)
			{
				skill = B9_Skill(mod);
				if (skill != None && n-- == 0)
					break;
			}

			if (skill == None) // not that many skills
				return;

			found = true;
		}
	}

	if (!found)
	{
		i = InStr(MenuName, fStrIntrinsicSkillDisplay);
		if (i == 0)
		{
			// intrinsic skill view
			isSkillDisplay = true;
			skillName = Mid(MenuName, Len(fStrIntrinsicSkillDisplay));
			MenuName = fStrIntrinsicSkillDisplay;
			found = true;
		}
	}

	if (!found)
	{
		for (i=0;i<Intermission.MissionKits.Length;i++)
		{
			if (Intermission.MissionKits[i].Tag == MenuName)
			{
				MenuName = "MissionKitKiosk";
				isMissionKit = true;
				found = true;
				break;
			}
		}
	}

	MenuName = "B9Headquarters.B9_" $ MenuName;

	kioskClass = class<B9_BaseKiosk>(DynamicLoadObject(MenuName, class'Class'));
	kiosk = new(None) kioskClass;
	if (kiosk != None)
	{
		showError = 0;
		if (pc.EnterKioskMode(self, TriggerSource, kiosk.ServerTriggerTagName(TriggerSource.Tag),
			kiosk.fBackOffPawn, kiosk.fFOV, showError))
		{
			if (isNanoCal)
				pc.ShowNanoCalKiosk(kioskClass, TriggerSource.Rotation, skill);
			else if (isSkillDisplay)
				pc.ShowIntrinsicSkillDisplay(kioskClass, TriggerSource.Rotation, skillName);
			else if (isMissionKit)
				pc.ShowMissionKitKiosk(kioskClass, TriggerSource.Rotation, string(Other.Tag));
			else
				pc.ShowStandardKiosk(kioskClass, TriggerSource.Rotation);
		}
		else if (showError != 0)
		{
			pc.ShowLocationMessage(fStrStationInUse);
		}
	}
}

/*
function ActivateExclusionArea( Actor Other, Pawn Instigator )
{
	local B9_OccupantUseTrigger trigger;

	Log("B9_HQListener asked to activate exclusion area" );

	trigger = B9_OccupantUseTrigger(Other);

	if (trigger.Occupant != None && trigger.Occupant != Instigator)
	{
		// can't come in
		Instigator.SetLocation(Normal(Instigator.Location - trigger.Location) * 100 + Instigator.Location);
	}
}

function DeactivateExclusionArea( Actor Other, Pawn Instigator )
{
	local B9_OccupantUseTrigger trigger;

	Log("B9_HQListener asked to dectivate exclusion area" );

	trigger = B9_OccupantUseTrigger(Other);

	if (trigger.Occupant != None && trigger.Occupant == Instigator)
	{
		trigger.Occupant = None;
	}
}
*/

event Trigger( Actor Other, Pawn Instigator )
{
	local string otag;

	if (intermission == None)
		FindIntermission(Instigator);

	// Other is the UseTrigger
	// Instigator is the player

	otag = "" $ Other.Tag;

	Log(otag);
//	if (B9_OccupantUseTrigger(Other) != None)
//		ActivateExclusionArea( Other, Instigator );
//	else
	if (InStr(otag, fStrInfirmaryBooth) == 0)
		ActivateInfirmaryBooth( Other, Instigator );
	else if (B9_HQZoneInfo(Other) != None)
		ActivateZone( Other, Instigator );
	else
		ActivateKiosk( Other, Instigator );
}

event Untrigger( Actor Other, Pawn Instigator )
{
	local string otag;

	if (intermission == None)
		FindIntermission(Instigator);
	
	// Other is the UseTrigger
	// Instigator is the player

	otag = "" $ Other.Tag;
//	if (B9_OccupantUseTrigger(Other) != None)
//		DeactivateExclusionArea( Other, Instigator );
//	else
	if (InStr(otag, fStrInfirmaryBooth) == 0)
		DeactivateInfirmaryBooth( Other, Instigator );
	else if (B9_HQZoneInfo(Other) != None)
		DeactivateZone( Other, Instigator );
}

function int FindPrice(string className, array<string> stock)
{
	local int i, j;
	local string s;

	className = className $ ",";

	for (i=0;i<stock.Length;i++)
	{
		s = stock[i];

		Log ("Check " $ s $ " vs " $ className);

		j = InStr(s, className);
		if (j == 0 || (j > 0 && Mid(s, j - 1, 1) == "."))
		{
			s = Mid(s, j + Len(className));
			j = InStr(s, ",");
			if (j == -1)
				return int(s);
			return int(Left(s, j));
		}
	}

	return 0;
}

simulated function QueryResultWithLocation(Pawn Pawn, vector L, bool Result)
{
	local vector Loc;
	local Pickup A;
	local string className;
	local int price;
	local B9_BodyModCalibration mod;
	local B9_NanoCalibration nano;
	local B9_AttrCalibration attr;
	local B9_Calibration cal;
	local B9_PlayerPawn P;
	local B9_PlayerController PC;

	P = B9_PlayerPawn(Pawn);

	if (P.Role < ROLE_Authority)
	{
		P.HQQueryResultWithLocation(L, Result);
		DeleteCalibrations(P);
		return;
	}

	P.SetPhysics(PHYS_Walking);
	PC = B9_PlayerController(P.Controller);

	if (Result)
	{
		/*
		// cancel physical item purchases (not needed in current design)
		ForEach AllActors(class'Pickup', A, P.fServerName)
		{
			className = string(A.Class.Name);
			className = Left(className, InStr(className, "_Pickup"));

			// figure out price
			price = FindPrice(className, intermission.FirearmsKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.HeavyWeaponsKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.ExplosivesKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.MeleeWeaponsKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.SpecialWeaponsKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.ArmorKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.ReconGearKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.BiomedGearKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.AddonGearKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.EnvironmentGearKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.MiscGearKioskStock);
			if (price == 0)
				price = FindPrice(className, intermission.AmmoPrices);

			P.fCharacterCash += price;
			A.Destroy();
		}
		*/

		// cancel body mod & calibration purchases
		cal = Calibration;
		if (cal != None)
		{
			while (cal.Calibration != None)
			{
				cal = cal.Calibration;
				if( cal.PawnName == P.Name )
				{
					mod = B9_BodyModCalibration(cal);
					if (mod != None)
					{
						P.fCharacterCash += mod.HoloMod.Price;
						continue;
					}

					nano = B9_NanoCalibration(cal);
					if (nano != None)
					{
						P.fCharacterSkillPoints += nano.Points;
						continue;
					}

					attr = B9_AttrCalibration(cal);
					if (attr != None)
					{
						P.fCharacterSkillPoints += attr.Points;
						continue;
					}
				}
			}
		}

		DeleteCalibrations(P);
		DeferredDeactivateZone( PC.fPrevZoneInfo, P );
	}
	else
	{
		// move player to zone info
		//Log("QRWL: PZ="$PC.fPrevZoneInfo.Name$" CZ="$PC.fCurrentZoneInfo.Name);
		Loc = L;
		Loc.Z = P.Location.Z;
		P.SetLocation(loc);
	}
}

function MissionBriefing(B9_PlayerController pc)
{
	local SceneManager A;
	local B9_PlayerPawn playerPawn;
	local B9_Conversation_Actor_Player convActor;

	ForEach AllActors(class'B9_PlayerPawn', playerPawn )
	{
		ForEach AllActors(class'B9_Conversation_Actor_Player', convActor)
		{
log("playerPawn.fCharacterConcludedMission=" $ playerPawn.fCharacterConcludedMission $ "& convActor.fConversationClass=" $ convActor.fConversationClass);

			if ( playerPawn.fCharacterConcludedMission == 1 && convActor.fConversationClass==class'M02_Briefing_Sahara' )
			{
				break;
			}
			else if ( playerPawn.fCharacterConcludedMission == 5 && convActor.fConversationClass==class'M06_Sahara_Briefing' )
			{
				break;
			}
			else if ( playerPawn.fCharacterConcludedMission == 7 && convActor.fConversationClass==class'M08_Sahara_Briefing' )
			{
				break;
			}
			else if ( playerPawn.fCharacterConcludedMission == 8 && convActor.fConversationClass==class'M09_Sahara_Briefing' )
			{
				break;
			}
			else if ( playerPawn.fCharacterConcludedMission == 12 && convActor.fConversationClass==class'M13_Sahara_Briefing' )
			{
				break;
			}

		}
		convActor.Trigger(playerPawn, playerPawn);
	}

/*
	ForEach AllActors(class'SceneManager', A, intermission.BriefingName)
	{
		A.AffectedActor = pc.Pawn;
		A.Trigger(pc, None);
		return;
	}
*/
}

function FindIntermission(Pawn pawn)
{
	local B9_Intermission A;
	local int ConcludedMission;

	//Log("FindIntermission");

	ConcludedMission = B9_PlayerPawn(pawn).fCharacterConcludedMission;
	if (ConcludedMission >= 0 && ConcludedMissionAdjustment[ConcludedMission] != 0)
	{
		ConcludedMission = ConcludedMissionAdjustment[ConcludedMission];
		B9_PlayerPawn(pawn).fCharacterConcludedMission = ConcludedMission;
	}

	ForEach AllActors(class'B9_Intermission', A)
	{
		//Log("FindIntermission:"$A.Name);
		Log("Concluded Mission of Player"$ConcludedMission);
		Log("Concluded Mission of Level"$A.ConcludedMission);
		if ( A.ConcludedMission == ConcludedMission )
		{
			intermission = A;
			IntermissionName = A.ServerName;
			return;
		}
	}

	// !!!! debugging
	ForEach AllActors(class'B9_Intermission', A)
	{
		//Log("FindIntermission:"$A.Name);
		intermission = A;
		IntermissionName = A.ServerName;
		return;
	}
}

// helper functions

function bool ShouldDirectPurchase()
{
	return (B9_GameInfo(Level.Game) != None && B9_GameInfo(Level.Game).IsDirectPurchase);
}

function bool GameInHeadquarters()
{
	return (B9_GameInfo(Level.Game) != None && B9_GameInfo(Level.Game).IsHeadquarters);
}

function bool ConfirmBuyItem(string InvName, int Price)
{
	return intermission.ConfirmBuyItem(InvName, Price);
}

function bool ConfirmSellItem(string InvName, out int Price)
{
	return intermission.ConfirmSellItem(InvName, Price);
}

function bool ConfirmBuyMod(string InvName, int Price)
{
	return intermission.ConfirmBuyMod(InvName, Price);
}

function AddBodyModCalibration(name PawnName, string InvName, int Price)
{
	local B9_BodyModCalibration cal;

	cal = new(None) class'B9_BodyModCalibration';
	cal.SetCalibration( PawnName, Spawn(class<B9_HoloItem>(DynamicLoadObject(InvName $ "_Holo", class'Class'))) );
	cal.HoloMod.Price = Price;
	AddCalibration(cal);
}

function AddAttrCalibration(Pawn P, byte type, int points, int adjustment)
{
	local B9_PlayerPawn Pawn;
	local B9_AttrCalibration cal, oldCal;

	Pawn = B9_PlayerPawn(P);

	if (Pawn.fCharacterSkillPoints - adjustment < 0)
		return;

	cal = new(None) class'B9_AttrCalibration';
	cal.SetCalibration(P.Name, points);
	cal.SetType(type);

	oldCal = B9_AttrCalibration(FindCalibrationKind(Pawn, cal));
	if (oldCal != None)
	{
		if (adjustment > oldCal.points)
			return;

		if (points == 0) 
			RemoveCalibration(oldCal);
		else
			oldCal.Points = points;
	}
	else
	{
		AddCalibration(cal);
	}

	Pawn.fCharacterSkillPoints -= adjustment;
}

function AddNanoCalibration(Pawn P, B9_Skill skill, int points, int adjustment)
{
	local B9_PlayerPawn Pawn;
	local B9_NanoCalibration cal, oldCal;

	Pawn = B9_PlayerPawn(P);

	if (Pawn.fCharacterSkillPoints - adjustment < 0)
		return;

	cal = new(None) class'B9_NanoCalibration';
	cal.SetCalibration(P.Name, points);
	cal.SetSkill(skill);

	oldCal = B9_NanoCalibration(FindCalibrationKind(Pawn, cal));
	if (oldCal != None)
	{
		if (adjustment > oldCal.points)
			return;

		if (points == 0) 
			RemoveCalibration(oldCal);
		else
			oldCal.Points = points;
	}
	else
	{
		AddCalibration(cal);
	}

	Pawn.fCharacterSkillPoints -= adjustment;
}

defaultproperties
{
	fStrInfirmaryBooth="InfirmaryBooth"
	fStrInfirmaryBoothTrigger=InfirmaryBoothTrigger
	fStrNanoCalKiosk="NanoCalKiosk"
	fStrIntrinsicSkillDisplay="IntrinsicSkillDisplay"
	fStrHQZoneInfo="B9_HQZoneInfo"
	fStrStationInUse="Sorry, that station is already in use!"
	fStrBoothInUse="Sorry, that booth is already in use!"
	YesNoInteractionClass=Class'B9_YesNoInteraction'
	KioskClassArray[0]=Class'B9_ArmorKiosk'
	KioskClassArray[1]=Class'B9_AttrAgilityKiosk'
	KioskClassArray[2]=Class'B9_AttrConstitutionKiosk'
	KioskClassArray[3]=Class'B9_AttrDexterityKiosk'
	KioskClassArray[4]=Class'B9_AttrStrengthKiosk'
	KioskClassArray[5]=Class'B9_BioCalibrationChamber'
	KioskClassArray[6]=Class'B9_ConferenceComPanel'
	KioskClassArray[7]=Class'B9_GearAddonKiosk'
	KioskClassArray[8]=Class'B9_GearBiomedKiosk'
	KioskClassArray[9]=Class'B9_GearEnvironmentKiosk'
	KioskClassArray[10]=Class'B9_GearMiscKiosk'
	KioskClassArray[11]=Class'B9_GearReconKiosk'
	KioskClassArray[13]=Class'B9_GearSellKiosk'
	KioskClassArray[15]=Class'B9_MediaCenterSystem'
	KioskClassArray[16]=Class'B9_ModBiomedKiosk'
	KioskClassArray[17]=Class'B9_ModDefensiveKiosk'
	KioskClassArray[18]=Class'B9_ModEnvironmentKiosk'
	KioskClassArray[19]=Class'B9_ModMiscKiosk'
	KioskClassArray[20]=Class'B9_ModReconKiosk'
	KioskClassArray[21]=Class'B9_NanoCalKiosk'
	KioskClassArray[23]=Class'B9_WeaponFirearmsKiosk'
	KioskClassArray[24]=Class'B9_WeaponHeavyKiosk'
	KioskClassArray[25]=Class'B9_WeaponMeleeKiosk'
	KioskClassArray[26]=Class'B9_WeaponSellKiosk'
	KioskClassArray[27]=Class'B9_WeaponSpecialKiosk'
	KioskClassArray[28]=Class'B9_NanoCalKiosk'
	KioskClassArray[29]=Class'B9_MissionKitKiosk'
	CalClassArray[0]=Class'B9_AttrCalibration'
	CalClassArray[1]=Class'B9_BodyModCalibration'
	CalClassArray[2]=Class'B9_NanoCalibration'
	KioskHoloWidth=50
	KioskHoloHeight=160
	KioskHoloOffset=80
	KioskHoloShift=30
	ConcludedMissionAdjustment[0]=1
	ConcludedMissionAdjustment[1]=1
	ConcludedMissionAdjustment[2]=5
	ConcludedMissionAdjustment[3]=5
	ConcludedMissionAdjustment[4]=5
	ConcludedMissionAdjustment[5]=5
	ConcludedMissionAdjustment[6]=7
	ConcludedMissionAdjustment[7]=7
	ConcludedMissionAdjustment[8]=8
	ConcludedMissionAdjustment[9]=12
	ConcludedMissionAdjustment[10]=12
	ConcludedMissionAdjustment[11]=12
	ConcludedMissionAdjustment[12]=12
	ConcludedMissionAdjustment[13]=12
	ConcludedMissionAdjustment[14]=12
	bHidden=true
	bAlwaysRelevant=true
	Tag=HQListener
}