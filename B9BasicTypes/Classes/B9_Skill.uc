//=============================================================================
// B9_Skill
//
// Nanotech Skill
//
// 
//=============================================================================

Class B9_Skill extends B9_CharMod
	abstract;
//    Native
//    NativeReplication;
 

//////////////////////////////////
// Variables
//


enum eSkillID
{
	skillID_None,
	skillID_Fireball,
	skillID_Hacking,
	skillID_Healing,
	skillID_FireFist,
	skillID_IceFist,
	skillID_RockFist,
	skillID_IceShards,
	skillID_RockShards,
	skillID_RockGrenade,
	skillID_LiquidFire,
	skillID_FireBlaze,
	skillID_FireShield,
	skillID_HydroCloak,
	skillID_HydroShock,
	skillID_WindShock,
	skillID_WindBurst,
	skillID_WindFist,
	skillID_HeavenBlast,
	skillID_NightVision,
	skillID_Defocus,
	skillID_CamJam,

};



// Determines how this skill uses fActive and how it uses up Focus points
//
enum eSkillType
{
	skillType_InstantUse,
	skillType_ConstantDrain,
	skillType_DrainOnCommand,
	skillType_VisionMode,
};

enum eSkillMode
{
	skillMode_RequestingHackRank,  // The reciever of this mode has been asked what the hacking rank is.
	skillMode_Hacking, // The reciever of this mode has been asked for their hack rank for the hacking process to begin. 
	skillMode_StoppedHacking, // The recieve should go back to the pre-being hacked behavior (if different from hacking )
	skillMode_Hacked, // The reciever of this mode has been hacked.
};

enum eSkillResponseCodes
{
	skillResponse_ThisIsMyRank,
	skillResponse_BeingHacked,
	skillResponse_StoppedHacking,
	skillResponse_GetCamJamStrength,
};
var bool				fActivatable;		// Must be used to become active
var bool				fActive;

var class<Projectile>   fProjectileClass;

var class<DamageType>   fMyDamageType;
var float               fWarnTargetPct;
var float               fRefireRate;
var sound               fSound;
var float               fRechargeTimeNeeded;	// (seconds)
var float               fRechargeTime;          // (seconds)
//var class<RenderFX>     fRenderFx;              // Used for X-Ray and Heat Vision type stuff 

var localized string	fSkillName;			// displayed in kiosks, etc.

var eSkillID			fUniqueID;
var material			fIcon;

var eSkillType			fSkillType;
var int					fFocusUsePerActivation;	// points used per activation
var float				fTimeBetweenFocusUses;	// for constant-on types, how often do we deduct fFocusUsePerActivation from Focus
var float				fFocusUseTimer;			// tracks tick time for use with fTimeBetweenFocusUses

var eSkillMode			fSkillMode;
var string fLocksKeyCode;


replication
{
	// Things the server should send to the client.
	reliable if( Role <ROLE_Authority )
		ServerActivate;		//,fLocksKeyCode;

	reliable if( Role == ROLE_Authority )
		fLocksKeyCode;
}

//////////////////////////////////
// Functions
//


function ServerActivate();
simulated function Activate(); // pure virtual, very class-specific
function AIActivate( Rotator aimRotation );
function Deactivate();

function FireNano(); // called by notify in animation 

function int SkillFeedBack( Actor interactingActor,eSkillResponseCodes ResponseCode, int numericData,optional string LocksKeyCode ); // Also pure Virtual Used to interact with the skill if needed.  See Hacking skill for example of use.

simulated event RenderOverlays( canvas Canvas ); // Also pure Virtual 

function int GetFocusRequired()
{
	return fFocusUsePerActivation;
}

// Should only be needed for cached Nanoskills
function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	// We may want to remove this when we think all of inits are finihsed 
	// No need to call this from within the specific skills routine
	// Non activatable skills are considered by default to require caching (Not a law just a rule of thumb)
	if( fActivatable == false )
	{
		log( "!"$Class.Name$"::Has no Initializing specific code" );
	}
}

// Called when Pawn::ApplyModifications() fires
//
simulated function UpdateSkillForStrength()
{}

// Return the amount of Focus points used per activation
//
function bool CheckFocus()
{
	local B9_AdvancedPawn P;

	P = B9_AdvancedPawn( Owner );
	if( P == None || P.fCharacterFocus < GetFocusRequired() )
	{
		return false;
	}

	return true;
}

simulated function bool CanActivate()
{
	local B9_AdvancedPawn		P;
	local B9_BasicPlayerPawn	PP;

	P = B9_AdvancedPawn( Owner );
	if( P == None || !CheckFocus() )
	{
		return false;
	}

	if( P.IsHumanControlled() )
	{
		PP = B9_BasicPlayerPawn( Owner );
		if( PP == None || PP.IsPerformingExclusiveAction() )
		{
			return false;
		}
	}
	
	return true;
}

simulated function SetActionExclusivity( bool exclusive )
{
	local B9_BasicPlayerPawn	P;

	P = B9_BasicPlayerPawn( Owner );
	
	if( P == None )
	{
		return;
	}

	P.ActExclusively( exclusive );
}

// Use up Focus points
//
function UseFocus()
{
	local B9_AdvancedPawn P;

	P = B9_AdvancedPawn( Owner );
	if( P != None )
	{
		P.fCharacterFocus -= GetFocusRequired();
		if( P.fCharacterFocus < 0 )
		{
			P.fCharacterFocus = 0;
		}
	}
}

function bool IsVisionMode()
{
	return ( fSkillType == skillType_VisionMode );
}

function int FinalSkillStrength()
{
	return fStrength;
}

// These will be used to replace existing Unreal Pawn functions

function DoDamage( Pawn pawn, Pawn against, class<DamageType> DamageType, vector HitLoc );
function RecieveDamage(Pawn pawn, Pawn instigator, class<DamageType> DamageType, vector HitLoc );


// Functions for melee skills
//
function int GetDamage();
function bool IsMeleeEnhancer()
{
	// Don't change this to <= && >= because designers
	// are free to change the enum order
	//
	return (	fUniqueID == skillID_FireFist
			||	fUniqueID == skillID_IceFist
			||	fUniqueID == skillID_RockFist
		);
}


//////////////////////////////////
// Initialization
//


          
defaultproperties
{
	fSkillName="Unknown"
}