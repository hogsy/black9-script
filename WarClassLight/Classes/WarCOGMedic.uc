class WarCOGMedic extends CogLightInfantry;

#exec OBJ LOAD FILE=..\Sounds\WarPickupSounds.uax
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// Add this player's Influence
	
	//AddInfluence("WarfareGame.MedicInfluence");
}

// Medic's Special skill heals someone

function SpecialSkill()
{
	local Actor Other;
	local UnrealPawn Injured;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	
	StartTrace = Location;
	StartTrace.Z += BaseEyeHeight;
	EndTrace = StartTrace + vector(Controller.Rotation) * 128.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	Injured = UnrealPawn(Other);
	if ( (Injured!=None) && (Injured.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		Injured.Health=Injured.Default.Health;
		if ( Injured.Controller.bIsPlayer )
			PlayerController(Injured.Controller).ClientFlash(0.5,vect(0,0,255));

		Injured.PlayOwnedSound(sound 'MedicSuperHeal');

	}	
}

simulated function DrawBeacon(Beacons B, Canvas C, WarfareHud H, float X, float Y)
{
	if (RepairBeacon(B)!=None)
		return;
	
	B.DrawBeacon(Self,C,H,X,Y);
}		


defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.cog_helmets.CogGruntHelmet2a'
	LandGrunt=Sound'MaleSounds.(All).land10'
	ClassIcon=Texture'SG_Hud.COG.sg_classicons_medic'
	LoadOut=0
	RequiredEquipment[0]="WarClassLight.WeapCOGMedic"
	RequiredEquipment[1]="WarClassLight.WeapCOGAssaultRifle"
	GroundSpeed=400
	AirSpeed=400
	MenuName="COG Medic"
}