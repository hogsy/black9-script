//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Pawn Combatant Class
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatant extends B9_ArchetypePawnBase placeable;

var(AIDeprecated) name	fCombatantIdleAnimationName;
var		name	fWalkAnim;//@PDS remove when full anim system is moved to B9_AdvancedPawn
var		name	fRunAnim;//@PDS remove when full anim system is moved to B9_AdvancedPawn
var		name	fFlyAnim;
var		name	fDodgeLeftAnim;
var		name	fDodgeRightAnim;
var			bool	bCanDodge;
var(AI)		bool	bHostile;
var(AIDeprecated) bool	bWanderAllowed;
var(AIWeapon) string	fWeaponIdentifierName;
var(AIWeapon)	int		fWeaponStartingAmmo;
var(AIWeapon) string	fWeaponIdentifierName1;
var(AIWeapon)	int		fWeaponStartingAmmo1;
var(AIWeapon) string	fWeaponIdentifierName2;
var(AIWeapon)	int		fWeaponStartingAmmo2;
var(AIWeapon) string	fWeaponIdentifierName3;
var(AIWeapon)	int		fWeaponStartingAmmo3;
var(AIDeprecated) float	fMinimumFiringDistance;
var(AIDeprecated) float	fFiringInterval;	// Must be less than the weapon's reload time.
var(AIDeprecated) int	fNumShotsInBurst;	// Number of shots in a burst.
var(AIWeapon) bool bWeaponHidden;
var(AIDeprecated) bool  fRetreatOnTakingFire;			// Whether this AI should do small retreats upon taking fire.  // NYI: Broken with Bot controller.
var(AIDeprecated) float fRetreatOnTakingFireRatio;	// The ratio of health at which point the AI will retreat some upon taking any fire.  // NYI: Broken with Bot controller.
var(AIMovement) float	fRetreatToCoverRatio;			// The ratio of health at which point the AI will retreat to cover.
var(AIMovement) bool	fJumpAtEnemy;
var(AIMovement) bool	fPsychicKnowPlayerPosition;
var(AIMovement) float	fCombatStyle;					// -1 to 1.  -1 = stay back more, 1 is charge more.

var(AI) bool	fWarnsAlliesAboutEnemies;
var(AI) float	fFrequencyOnGivingUpEnemyPosition;
var(AI) bool	fAggressiveInNumbers;				// Whether the AI will aggressively attack the enemy when there are more than one of them.
var(AI) bool	fIgnoreEnemyWarnings;				// Whether this AI will ignore cries of pain or warning about the enemy.

var(AIDeprecated) int		fNumShotsBeforeChangePosition;
var(AIDeprecated) float	fChangePositionAmount;

var		float		fMaxAttackTargetRange;
var		int		fNumCurrentLocationShots;
var		vector	fLastFireLocation;
var		bool	fShouldChangeFiringPosition;
var		bool	fTakingFire;
var		bool	fRetreatToCover;
var		int		fShotsFiredInBurst;		// The number of shots fired in the current burst.
var		bool	fFiredFromCover;		// Whether or not this pawn has fired since the last time it was in cover.

var		bool	fFireAndMoveSimultaneously;	// Whether the pawn can fire and move simultaneously.

var		Pawn	fLastGuyWhoShotMe;			// The last pawn who did damage to this AI.



function PostBeginPlay()
{
	local SquadAI S;

	Super.PostBeginPlay();

	if( (( Role == ROLE_Authority ) && (Controller == None)) )
	{
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);

			if ( UnrealMPGameInfo(Level.Game) == None )
			{
				if ( Bot(Controller) != None )
				{
					ForEach DynamicActors(class'SquadAI',S,SquadName)
						break;
					if ( S == None )
						S = spawn(class'SquadAI');
					S.Tag = SquadName;
					if ( bIsSquadLeader || (S.SquadLeader == None) )
						S.SetLeader(Controller);
					S.AddBot(Bot(Controller));

					B9_AI_ControllerCombatant(Controller).CombatStyle = fCombatStyle;
					B9_AI_ControllerCombatant(Controller).SetupWeapon();
				}
			}
		}
	}
	else
	{
		B9_AI_ControllerCombatant(Controller).CombatStyle = fCombatStyle;
		B9_AI_ControllerCombatant(Controller).SetupWeapon();
	}
}

// Global Functions
function HearPainMessageAbout( Pawn instigatedBy )
{
	//log( "MikeT: AI: " $self $"Heard pain message about: " $instigatedBy );
	
	if ( (Controller == None) || fIgnoreEnemyWarnings )
		return;
	
	if (Controller.Enemy == None)
	{
		if (B9_AI_OldControllerCombatant(Controller) != None)
		{
			//log( "MikeT: AI: " $self $"Heard pain message about: " $instigatedBy $"And is setting it to enemy"  );
			B9_AI_OldControllerCombatant( Controller ).SetAsEnemy( instigatedBy );
			// NYI: Check that the caller can see the instigator, or is this good enough?
			if (!fSentry)
			{
				B9_AI_OldControllerCombatant( Controller ).SetRouteGoalLocation(instigatedBy.Location);
				B9_AI_OldControllerCombatant( Controller ).GotoState( 'AttackAndHunting' );
			}	
		}
		else if (B9_AI_ControllerCombatant(Controller) != None)
		{
			B9_AI_ControllerCombatant(Controller).SetEnemy(instigatedBy);
			if ( !fSentry && !Controller.IsInState('Scripting') )
				B9_AI_ControllerCombatant(Controller).GotoState('GotoEnemyPosition');
		}
	}

	fLastTimeScreamed = Controller.Level.TimeSeconds;	// Don't go yelling for a while.
}


// Heard the enemy...
function HearEnemySpotted( Pawn seen )
{
	//log( "MikeT: AI: " $self $" Heard enemy spotted message about: " $seen );
	if (seen.Health > 0)
		HearPainMessageAbout(seen);
	//log( "MikeT: AI: out of HearEnemySpotted" );
}


// Notifier for when the camera has spotted the enemy.  The AI is responsible to figure out if it is supposed
// to react to the message.
function AlertAItoAlarm( Pawn	seen,int alarmNumber )
{
	local int AlarmIndex;
	local B9_AI_ControllerCombatant cnt;
	cnt = B9_AI_ControllerCombatant(Controller);
	if (cnt != None)
	{
		cnt.fOnAlert = cnt.fOnAlert + 1;
		for(AlarmIndex = 0; AlarmIndex < fAlarmList.length;AlarmIndex++)
		{
			if(fAlarmList[Alarmindex] == alarmNumber)
			{
				HearPainMessageAbout(seen);
				return;
			}
		}
	}
}

function AlertAItoAlarmSilenced( )
{
	local B9_AI_ControllerCombatant cnt;
	cnt = B9_AI_ControllerCombatant(Controller);
	if (cnt != None)
	{
		cnt.fOnAlert = cnt.fOnAlert - 1;
		if( cnt.fOnAlert < 0 )
		{
			cnt.fOnAlert = 0; //This should not happen
		}
	}
}


function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	fLastGuyWhoShotMe = instigatedBy;
	
	// Target is about to die.
	if( damage >= Health )
	{
		// Destroy weapon
		if (B9_AI_ControllerBase(Controller) != None)
			B9_AI_ControllerBase(Controller).AboutToDie();
		else if (B9_AI_ControllerCombatant(Controller) != None)
			B9_AI_ControllerCombatant(Controller).AboutToDie();
			
		// Prevent gibs (AFSNOTE: this does not seem to work)
		damage = Health;
	}
	
	Super.TakeDamage( damage, instigatedBy, hitlocation, momentum, damageType );

	if( damageType != fDamageImmunity1 &&
		damageType != fDamageImmunity2 &&
		damageType != fDamageImmunity3 &&
		damageType != fDamageImmunity4 &&
		damageType != fDamageImmunity5 )
	{
		// If taking damage, move a little, and retreat a little.
		if ( fRetreatOnTakingFire &&
			 ((Damage > fCharacterMaxHealth / 10) ||
			  (Health < (fCharacterMaxHealth*fRetreatOnTakingFireRatio))) )
		{
			fShouldChangeFiringPosition = true;
			
			if (fRetreatOnTakingFireRatio > 0)
				fTakingFire = true;
		}
		
		if (Health < (fCharacterMaxHealth*fRetreatToCoverRatio))
		{
			fShouldChangeFiringPosition = true;
			fRetreatToCover=true;
		}
	}
}

function bool GiveNanotech(string aClassName )
{
	local class<B9_Skill> SkillClass;
	local B9_Skill newNanoTech;

	SkillClass = class<B9_Skill>(DynamicLoadObject(aClassName, class'Class'));

	// Check to see if nanotech as already present in pawn's inventory
	if( FindInventoryType( SkillClass ) != None )
	{
		return false;
	}

	newNanoTech = Spawn( SkillClass );
	if( newNanoTech != None &&  newNanoTech.fActivatable )
	{
//		log( "MikeT: Nanotech weapon given" );
		// Take note of nano-skill now equiped.
		fSelectedSkill = newNanoTech;
		newNanoTech.GiveTo( self );
		return true;
	}
	else
	{
//		log( "MikeT: Nanotech weapon NOT given; newNanoTech: " $newNanoTech $"newNanoTech.fActivatable: " $newNanoTech.fActivatable );
		return false;
	}
}


simulated function PlayDodging( bool left )
{
	if( ! left )
	{
//		log( "MikeT: Dodging to right" );
		PlayAnim( 'Dodge_right' );
	}
	else
	{
//		log( "MikeT: Dodging to left" );
		PlayAnim( 'Dodge_left' );
	}
}

function bool IsInFiringState()
{
	return IsInState( 'Firing' );
}

function bool PopShouldChangeFiringPositionQue()
{
	if (fShouldChangeFiringPosition)
	{
		fShouldChangeFiringPosition = false;
		return true;
	}
	else
	{
		return false;
	}
}


function bool PopTakingDamageQue()
{
	if (fTakingFire)
	{
		fTakingFire = false;
		return true;
	}
	else
	{
		return false;
	}
}


// possible interactions
function int GetHUDActions( Pawn other )
{
	local int	HUDActions;

	if ( Controller != None )
	{
		if ( Bot(self.Controller).AttitudeToQuick( other ) < ATTITUDE_Ignore )
			HUDActions	= HUDActions | kHUDAction_Attack;
	}

	return HUDActions;
}

// This function is REQUIRED in the 927 build in order
// for the sleep function to operate properly.
function Tick(float DeltaSeconds)
{
	Super.Tick( DeltaSeconds );
	//log( "MikeT: Pawn ticking: " $DeltaSeconds );
}

state Firing
{
	function BeginState()
	{
		//log( "MikeT: Begginning firing state" );

		fShotsFiredInBurst = 0;
		// Count the number of shots taken at the current location
		if( fLastFireLocation == Location )
		{
			fNumCurrentLocationShots++;

			if( fNumCurrentLocationShots >= fNumShotsBeforeChangePosition )
			{
//				log( "MikeT: fShouldChangeFiringPosition set for: " $self );
				fShouldChangeFiringPosition = true;
			}
		}
		else
		{
			fNumCurrentLocationShots = 0;
			fLastFireLocation = Location;
		}
	}
	
	// Does the firing.  Returns true if we should wait Weapon.RefireRate() and shoot again.
	function bool Openfire( float value )
	{
		local vector	fireDirection;
		local rotator	fireDirectionRot;
		local B9_AI_ControllerCombatant	C;

		C = B9_AI_ControllerCombatant(Controller);
		if (C == None)
			return false;
		
		switch (C.HasCombatItem())
		{
			case kWeapon:
				C.FireWeaponAt( C.Enemy );
				fShotsFiredInBurst++;
				return (B9WeaponBase(Weapon).fROF < fFiringInterval) && (fShotsFiredInBurst < fNumShotsInBurst);
			break;

			case kNanoTech:
				// Generate a fire direction vector
				fireDirection = C.Enemy.Location - Location;

				// Generate a fire direction rotator
				fireDirectionRot = rotator( fireDirection );

				// AFSNOTE: This will 'fire' the nano-weaponry in the direction that the enity is facing.
				fSelectedSkill.AIActivate( fireDirectionRot );
			break;
		}
		
		return false;
	}

Begin:
	while (OpenFire(1))
	{
		fFiredFromCover = true;
		if (B9WeaponBase(Weapon).fROF > 0.1)
			Sleep(B9WeaponBase(Weapon).fROF);
		else
			Sleep(0.1);
	}
	
	//log("MikeT: Refire rate: " $B9WeaponBase(Weapon).fROF);
		
	//log( "MikeT: Firing state, going to sleep for: " $fFiringInterval );
	if (fFiringInterval > B9WeaponBase(Weapon).fROF)
		Sleep( fFiringInterval - B9WeaponBase(Weapon).fROF );

	if ( (Controller != None) && (Controller.bFire == 0) )
	{
		// Cease fire
		//log( "MikeT: Firing state, before StopFiring() "  );
		Controller.StopFiring();
	}
	
	// Start the cycle over
	//log( "MikeT: Firing state, going to idle state" );
	GotoState('Idle');
}

defaultproperties
{
	bHostile=true
	bWanderAllowed=true
	fWeaponIdentifierName="B9Weapons.pistol_9mm"
	fWeaponStartingAmmo=1200
	fFiringInterval=0.5
	fNumShotsInBurst=1
	fRetreatOnTakingFire=true
	fRetreatOnTakingFireRatio=0.75
	fRetreatToCoverRatio=0.25
	fCombatStyle=1
	fWarnsAlliesAboutEnemies=true
	fFrequencyOnGivingUpEnemyPosition=5
	fAggressiveInNumbers=true
	fNumShotsBeforeChangePosition=3
	fChangePositionAmount=120
	fMaxAttackTargetRange=1200
	fFireAndMoveSimultaneously=true
	fAlarmList=/* Array type was not detected. */
	bAvoidLedges=true
	bStopAtLedges=true
	ControllerClass=Class'B9_AI_ControllerCombatant'
}