// ====================================================================
//  Class:  WarClassLight.TripMines
//  Parent: WarfareGame.StationaryWeapons
//
//  <Enter a description here>
// ====================================================================

class TripMines extends WarfareStationaryWeapon;

#EXEC OBJ LOAD FILE=..\StaticMeshes\jm_cog_tripmine.usx PACKAGE=jm_cog_tripmine
#EXEC OBJ LOAD FILE=..\StaticMeshes\gst_trip_mine.usx PACKAGE=gst_trip_mine

var() float MaxDistance;

var   PclTripMineBeam Beam;

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
	local rotator R;

	R = Rotation;
	Beam = spawn(class 'PclTripMineBeam',self,,Location,R);

	if (Beam!=None)
		Beam.Activate(TeamIndex,MaxDistance);
}

simulated event Deactivated()
{

	if (Beam!=None)
		Beam.Destroy();
}


function Explode(vector HitLocation, vector HitNormal)
{
	HurtRadius(75, MaxDistance, class 'WarDamageExplosionRadius',100000.0, HitLocation);
	Spawn(class 'PclCOGRocketReallyBigExplosion',,,HitLocation, rotator(HitNormal));

	Super.Explode(HitLocation, HitNormal);
}


state Online
{
	event Timer()
	{
		GotoState('Broken');
	}		

	event Tick(float Delta)
	{
	
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local actor Other;
		local pawn p;
		
		GetAxes(Rotation,X,Y,Z);
		StartTrace = Location + X + Y +Z; 
		EndTrace = StartTrace + (MaxDistance * X); 
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
		
		P = Pawn(Other);
		
		if ( (P != None) && (P.PlayerReplicationInfo!=None) && (Pawn(Other).PlayerReplicationInfo.Team.TeamIndex != TeamIndex) )
			Explode(P.Location,normal(P.Location-Location));
	}
	
	
	function BeginState()
	{
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
		local actor Other;

		Disable('Timer');
		
		GetAxes(Rotation,X,Y,Z);
		StartTrace = Location + X + Y +Z; 
		EndTrace = StartTrace + (MaxDistance * X); 
		Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);

		if ( (Other==None) || (!Other.bWorldGeometry) )
		{
			Disable('tick');
			Enable('Timer');
			SetTimer(0.5,false);
			return;
		}
		
		Super.BeginState();
	}	
}

defaultproperties
{
	MaxDistance=786
	Health=50
	cost=10
	Meshes[0]=StaticMesh'jm_cog_tripmine.trip_mine.C_tripmine_M02_JM'
	Meshes[1]=StaticMesh'gst_trip_mine.trip_mines.G_tripmine_M02_JM'
	StaticMesh=StaticMesh'jm_cog_tripmine.trip_mine.C_tripmine_M02_JM'
	bCollideWorld=false
}