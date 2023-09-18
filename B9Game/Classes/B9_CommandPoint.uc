//===============================================================================
//  [B9_CommandPoint] 
//===============================================================================

class B9_CommandPoint extends B9_Pawn;

enum eLockMode
{
	skillMode_OneTimeHackToggle,  // The door can only be hacked to Open
	skillMode_MultipleHackToggle,  // The door can only be hacked to Open
};
var (Hacking) bool fIsHackable;
var (Hacking) float fHackRank;
var (Hacking) bool fActive;
var (Hacking) eLockMode fLockMode;
var (Hacking) sound		fDoorLocked;
var (Hacking) sound		fDoorOpened;
var int	fTeamNum;
var TeamInfo	ControllingTeam;
var float fTimeAccumilator;
var string fLocksKeyCode;

// This bot has been hacked.
function Hacked(pawn EventInstigator)
{
	local B9_Pawn    B9Pawn;
	local Controller Cntrl;
	if( fLockMode == skillMode_OneTimeHackToggle )
	{
		fIsHackable = False;
	}

	fActive = true;
	Cntrl = EventInstigator.Controller;
	if( Cntrl != None )
	{
		if ( (Cntrl.PlayerReplicationInfo == None) || (Cntrl.PlayerReplicationInfo.Team == None) )
			fTeamNum = 255;
		else
			fTeamNum = Cntrl.PlayerReplicationInfo.Team.TeamIndex;
		ControllingTeam = Cntrl.PlayerReplicationInfo.Team;

		// let decorations know about change
		TriggerEvent(Event, self, EventInstigator);
	}
}

function Tick(float Delta)
{
	if( fActive )
	{
		fTimeAccumilator = fTimeAccumilator + Delta;
		if( fTimeAccumilator > 1.0 )
		{
			fTimeAccumilator = 0.0;
			B9_Command(Level.Game).AddCommandPoint(ControllingTeam);
		}
	}
}
// Hacking Example
function Trigger( actor Other, pawn EventInstigator )
{
	if( B9_Skill( Other ) != none )
	{
		// Check to see if the trigger is the Hacking Skill and we are hackable 
		if( B9_Skill( Other ).fUniqueID == skillID_Hacking && fIsHackable)
		{
			// First Querry from the Hacking Skill What is your hack rank?
			if( B9_Skill( Other ).fSkillMode == skillMode_RequestingHackRank )
			{
				// if we are hackable we must give the skill feedback.
				// The skill is expecting the responce to the skillMode_RequestingHackRank querry and this objects hack rank
				// The hack rank is the difficulty of the hack.  Zero means that it is near effortless.
				B9_Skill( Other ).SkillFeedBack( self,skillResponse_ThisIsMyRank, fHackRank,fLocksKeyCode);
			}else if( B9_Skill( Other ).fSkillMode == skillMode_Hacking )
			{
				// This trigger is fired when the skill begins to interogate the object which is the begining of the hacking process.

				B9_Skill( Other ).SkillFeedBack( self,skillResponse_BeingHacked, 0,fLocksKeyCode);
			}else if( B9_Skill( Other ).fSkillMode == skillMode_StoppedHacking )
			{
				// This is only triggered if the hack was interupted before completion
				// If the skill has successfully interogated this object we should drop most hackable ranks down to zero
				// The responce to StoppedHacking will return a 1 if the interogation was successful
				// To simulated that we know how to hack this one already.
				if( B9_Skill( Other ).SkillFeedBack( self,skillResponse_StoppedHacking, 0,fLocksKeyCode) == 1 && fHackRank >= 0)
				{
					fHackRank = -fHackRank; // This means that this object has been interogated correctly and now does not have to wait for a long interogation process if the object did not get hacked completely
				}

			}else
			{
				// We have been hacked, now do something fun!
				Hacked(EventInstigator);
			}
		}
	}else if( B9_TargetingReticule( Other ) != none )
	{
		// This is to let the target reticule know that we are hackable
		if( fIsHackable )
		{
			B9_TargetingReticule( Other ).SetHackableBit();
		}
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
}

function int GetHUDActions( Pawn other )
{
	local int HUDActions;
	
	HUDActions = kHUDAction_Hack;

	return HUDActions;
}

defaultproperties
{
	fIsHackable=true
	fHackRank=20
	fLocksKeyCode="ududlrlr"
	fNoTargetLock=true
	Health=9999
	DrawType=8
	StaticMesh=StaticMesh'Luna_hangar_Mesh_EC.hangar.SComputer'
}