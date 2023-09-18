// ====================================================================
//  Class:  WarClassLight.Decapitator
//  Parent: WarfareGame.WarfareStationaryWeapon
//
//  <Enter a description here>
// ====================================================================

class Decapitator extends WarfareStationaryWeapon;

#EXEC OBJ LOAD FILE=..\StaticMeshes\jm_cog_tripmine.usx PACKAGE=jm_cog_tripmine
#EXEC OBJ LOAD FILE=..\StaticMeshes\gst_trip_mine.usx PACKAGE=gst_trip_mine
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

var   PclDecapBeam Beam;
var   float WallDist;

replication
{
	reliable if (ROLE==ROLE_Authority)
		WallDist;
}

simulated event Destroyed()
{
	if (Beam!=None)
		Beam.Destroy();

	if (MyBeacon!=None)
		MyBeacon.Destroy();
	
	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	if ( (bActive!=0) && (Beam==None) )
		Activated();

	Super.PostNetBeginPlay();
} 

simulated event Activated()
{
	Beam = spawn(class 'PclDecapBeam',self,,Location,Rotation);
	if (Beam!=None)
		Beam.Activate(TeamIndex,WallDist);
}

simulated event Deactivated()
{

	if (Beam!=None)
		Beam.Destroy();
}



auto state Warmup
{

	function Timer()
	{
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local actor Other;
		
		GetAxes(Rotation,X,Y,Z);
		StartTrace = Location + X + Y +Z; 
		EndTrace = StartTrace + (204800 * X); 
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
		
		if (Other.bWorldGeometry)
		{
			WallDist = vsize(Other.Location-Location);
			GotoState('Online');
		}
		else
			SetTimer(1.0,false);
	}
	
	function BeginState()
	{
		SetTimer(WarmupTime,false);
		PlaySound(PlaceSound,,1.0);
	}
}

state Online
{
	event Tick(float Delta)
	{
	
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local actor Other;
		local pawn p;
		
		GetAxes(Rotation,X,Y,Z);
		StartTrace = Location + X + Y +Z; 
		EndTrace = StartTrace + (WallDist * X); 
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
		
		P = Pawn(Other);
		
		
		if ( (P != None) && (P.PlayerReplicationInfo!=None) && (Pawn(Other).PlayerReplicationInfo.Team.TeamIndex != TeamIndex) )
			GotoState('Armed');
	}

	function BeginState()
	{
		AmbientSound = sound 'WeaponSounds.Decapitator.decapScan';
		SoundRadius = 16;		
	}	
}

state Armed
{
	function BeginState()
	{
	
		Activate();
		
		AmbientSound = sound'WeaponSounds.Decapitator.decapFire';
		SoundRadius = 64;		
		SetTimer(5.0,false);
	}
	
	event Tick(float Delta)
	{
	
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local actor Other;
		
		GetAxes(Rotation,X,Y,Z);
		StartTrace = Location + X + Y +Z; 
		EndTrace = StartTrace + (2048 * X); 
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
		
		if (Pawn(Other) != None) 
		{
			// Gib them
			
			Other.TakeDamage(10000,Instigator, Other.Location,HitNormal * 20000, class 'WarDamageExplosion');
		}
	}
	
	event Timer()
	{
		GotoState('Online');
	}
	
	function EndState()
	{
		DeActivate();
		AmbientSound = none;
	}
}
		

defaultproperties
{
	Health=50
	cost=40
	WarmUpTime=2
	Meshes[0]=StaticMesh'jm_cog_tripmine.trip_mine.C_tripmine_M02_JM'
	Meshes[1]=StaticMesh'gst_trip_mine.trip_mines.G_tripmine_M02_JM'
	StaticMesh=StaticMesh'jm_cog_tripmine.trip_mine.C_tripmine_M02_JM'
	bCollideWorld=false
}