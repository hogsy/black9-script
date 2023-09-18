class WarfarePlayer extends UnrealPlayer;

const MAX_FIRE_PITCH=1536;	// Maximum amount of additive pitch you can give

var StaticView AimControl;
var Vector AlternateAim;
var float YawAdjust, FirePitchAdjust, FirePitchSpeed;
var rotator ViewChange;

replication
{
	reliable if ( Role==ROLE_Authority )	// Client Side functions
		ChangeAim, ClientPawnDied;

	reliable if ( Role<ROLE_Authority)
		ServerAdjustLoadOut, ServerAltAim, ServerEditSpeed, ServerAdjustSpeed, ServerSetWalkingPerc,ServerSloMo;

	reliable if ( Role<ROLE_Authority)
		ServerCallForHelp, ServerUnStick;		
	 
} 

//////// ============= These are just for debugging

simulated exec function SetAdjustStep(float NewStep)
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).SetAdjustStep(newstep);
}

simulated exec function IncAdjustStep()
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).IncAdjustStep();
}

simulated exec function DecAdjustStep()
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).DecAdjustStep();
}

simulated exec function SetAdjustPerson(int NewPerson)
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).SetAdjustPerson(newPerson);
}

simulated exec function AdjustX(int dir)
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).AdjustX(dir);
}
	
simulated exec function AdjustY(int dir)
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).AdjustY(dir);
}

simulated exec function AdjustZ(int dir)
{
	if ( (Pawn!=None) && (WarfareWeapon(Pawn.Weapon)!=None) )
		WarfareWeapon(Pawn.Weapon).AdjustZ(dir);
}


/////// ======================================

exec function ShowBeacons()
{
	local Beacons B;
	
	foreach DynamicActors(class'Beacons',b)
	{
	
		if ( ( (B.bOptional) && (!b.bEnabled) ) && (b.Team == PlayerReplicationInfo.Team.TeamIndex) )
			B.MakeVisible();
	}
}

exec function UnStick()
{
	ServerUnStick();
}

function ServerUnStick()
{
	local PlayerStart P;
	
	
	foreach AllActors(class'PlayerStart',P)
	{
		if (P.TeamNumber == PlayerReplicationInfo.Team.TeamIndex)
		{
			Pawn.Setlocation(P.Location);
			Pawn.SetRotation(P.Rotation);
		}
	}
}

exec function SetServerSloMo(float t)
{
	ServerSloMo(t);
}

exec function CallForHelp()
{
	ServerCallForHelp();
}

function ServerCallForHelp()
{
	local MedicBeacon B;

	if (PAwn==None)
		return;


	// See if a beacon exists for this controller

	foreach AllActors(class 'MedicBeacon',B)
	{
		if (B.Owner == Self)
			return;
	}	
	
	b = Spawn(class 'MedicBeacon',self,,Pawn.Location);
	if (B!=None)
	{
		B.Team = PlayerReplicationInfo.Team.TeamIndex;
		B.SetBase(Pawn);
	}
	
	// Add code to send "HELP" chat
	
}

function ServerSloMo( float T )
{
	Level.Game.SetGameSpeed(T);
	Level.Game.SaveConfig(); 
	Level.Game.GameReplicationInfo.SaveConfig();
	log("#### Adjusting GameSpeed to :"$T);
}


function PlayWinMessage(bool bWinner)
{
	local sound Announcement;

	if ( bWinner )
		Announcement = Sound(DynamicLoadObject("Announcer.Winner", class'Sound'));
	else
		Announcement = Sound(DynamicLoadObject("Announcer.LostMatch", class'Sound'));

	ClientPlaySound(Announcement, true);
}

exec function lognote(string x)
{
	log(x);
}

event PlayerTick(float Delta)
{
	local WarfarePawn P;

	// If the Pawn is a player Pawn... Adjust the controller's Rotation
	
	P = WarfarePawn(Pawn); 
	if (P!=None)
		P.RestoreViews(Delta);
	
	Super.PlayerTick(Delta);
	
}

exec function SetWalkingPerc(float newperc)
{
	ServerSetWalkingPerc(newPerc);
}

exec function AdjustSpeed(float Adjustment)
{
	ServerAdjustSpeed(Adjustment);
}

exec function EditSpeed(class <UnrealPawn> WP, float NewSpeed)
{
	ServerEditSpeed(WP,NewSpeed);
}  

exec function ShowSpeeds()
{
	log("#### GroundSpeed: "$Pawn.GroundSpeed);
	log("#### WalkingPct : "$Pawn.WalkingPCT);
}

exec function ListPlayer()
{
	local UnrealPawn p;
	
	foreach DynamicActors(class 'UnrealPawn',p)
	{
		log("#### Found "$P);
	}
}

function ServerSetWalkingPerc(float newPerc)
{
	local UnrealPawn P;
	foreach DynamicActors(class 'UnrealPawn',P)
	{
		Log("#### Setting Walking % for "$P$" ("$P.PlayerReplicationInfo.PlayerName$") from: "$P.WalkingPct$" to "$NewPerc);
		P.WalkingPCT = newPerc;
	}
}	

function ServerAdjustSpeed(float Adjustment)
{
	local UnrealPawn P;
	foreach DynamicActors(class 'UnrealPawn',P)
	{
		Log("#### Adjusting "$P$" ("$P.PlayerReplicationInfo.PlayerName$") speed from: "$P.GroundSpeed$" to "$P.GroundSpeed+Adjustment);
		P.GroundSpeed += Adjustment;
		P.AirSPeed += Adjustment;
		
	}
}
	

function ServerEditSpeed(class <UnrealPawn> WP, float NewSpeed)
{
	local Actor P;
	
	foreach DynamicActors(WP,P)
	{
		UnrealPawn(P).GroundSpeed = NewSpeed;
		UnrealPawn(P).AirSPeed = NewSpeed;
		Log("#### Adjusting "$P$" ("$UnrealPawn(P).PlayerReplicationInfo.PlayerName$") speed to: "$UnrealPawn(P).GroundSpeed);
	}

}

event Destroyed()
{
	// Remove the aim control when this controller is destroyed
	
	if (AimControl!=None)
	{
		Aimcontrol.bActive = false;
		AimControl.Controller = None;
		AimControl.PointingAt = none;
		AimControl.Master.RemoveInteraction(AimControl);
	}
		
	Super.Destroyed();		
}

// Turns on/off the interaction for dealing with the new aiming system

function ServerAltAim(vector NewAim)
{
	AlternateAim = NewAim;
}


function ClientPawnDied()
{
	if (AimControl!=None)
	{
		AimControl.DeActivate();		// Reset the pawn on death
	}
}

function ChangeAim(bool On)
{
	local Interaction Intr;		
	
	if (AimControl==None)
	{
		intr = Player.InteractionMaster.AddInteraction("WarfareGame.StaticView",Player);
		AimControl = StaticView(intr);
		AimControl.Controller = self;
	}

	if (!On)
	{
		log("#### Changing State to Player Walking");
	
		GotoState('PlayerWalking');
		AimControl.DeActivate();
		ViewChange = rotator(vect(0,0,0));
	}
	else
	{
		AimControl.Activate();
	}
}


function Deploy()
{
	GotoState('Deployed');
}

// ====================================================================
// When Deployed, the player is locked in a given location.  The Crosshair is unlocked
// and can be used to target anything on the screen.
// ====================================================================
	
state Deployed
{
	function Deploy();

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local UnrealPawn WP;
	
		Pawn.Acceleration = Vect(0,0,0);
		WP = UnrealPawn(Pawn);
		if (WP!=None)
		{
			if (bDuck==1)
			{
				WP.ShouldUnCrouch();
			}
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local eDoubleClickDir DoubleClickMove;
		local rotator OldRotation;

		GetAxes(Pawn.Rotation,X,Y,Z);
		
		// Update acceleration.
		
		NewAccel = vect(0,0,0);
		OldRotation = Rotation;

		if (AimControl!=None)
		{
			ServerAltAim(AimControl.AimTarget);
		}
		
 		if ( Role < ROLE_Authority ) // then save this move and replicate it
 			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
 		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);

	}

	function BeginState()
	{
		YawAdjust = 0;
	}
	
	function EndState()
	{
		YawAdjust = 0;
	}

	function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
	{
		Super.CalcFirstPersonView(CameraLocation, CameraRotation);
		CameraRotation += ViewChange;
	}
}			

// Player is controlling orientation of a gun turret.
state PlayerGunning
{
	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {

    }

	function PlayerMove( float DeltaTime )
	{

	}

	function BeginState()
	{

	}
	
	function EndState()
	{

	}
}
exec function AdjustLoadOut(int newloadout)
{
	ServerAdjustLoadOut(newLoadOut);
}

function ServerAdjustLoadOut(int newLoadOut)
{
	if (UnrealPawn(Pawn)!=None)
	{
		UnrealPawn(Pawn).LoadOut = newLoadOut;
		if (Pawn.Weapon!=None)
		{
			PAwn.Weapon.OwnerEvent('LoadOut');
		}
	}
}

exec function NextSkill()
{
	if (WarfarePawn(Pawn) != None)
		WarfarePawn(Pawn).NextSkill();
}

exec function PrevSkill()
{
	if (WarfarePawn(Pawn) != None)
		WarfarePawn(Pawn).PrevSkill();
}


// Use the special skill

function ServerUse()
{
	Super.ServerUse();
	
	if (WarfarePawn(Pawn) != None)
		WarfarePawn(Pawn).SpecialSkill();
}

