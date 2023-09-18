// ====================================================================
//  Class:  WarClassLight.WarGeistEngineer
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarGeistEngineer extends GeistLightInfantry;

function PossessedBy(Controller C)
{
	local WarfareStationaryWeapon W;
	
	Super.PossessedBy(c);

	foreach AllActors(class 'WarfareStationaryWeapon', W)
	{
		if (W.Owner == C)
		{
			if (Energy>W.Cost)
			{
				Energy-=W.Cost;
			}
			else
				W.Explode(W.Location,vect(0,0,0));
		}
	}
}

simulated function DrawWarfareHud(canvas Canvas, WarfareHud Hud, FontInfo Fonts, float Scale)
{
	local WarfareStationaryWeapon W;
	local vector V;
	local float DScale,Perc;
	
	Super.DrawWarfareHud(Canvas,Hud,Fonts,Scale);
	
	W = WarfareStationaryWeapon(Hud.LastTraceActor);
	if ( (W!=None) && (Vsize(W.Location-Location)<=384) )
	{
		
		Canvas.SetDrawColor(0,255,0);
		Canvas.Style=1;

		DScale = (640 / VSize(W.Location-Location)) * 90 / Controller.FOVAngle;
		DScale = fmin(2.5,DScale);

		V = PlayerController(Controller).Player.Console.WorldToScreen(W.Location, Location + (EyeHeight * Vect(0,0,1)), Rotation);				
		Canvas.SetPos(V.X-16*DScale,V.Y-16*DScale);
		Canvas.DrawBracket(32*DScale,32*DScale,4*DScale);
	
		Perc = float(W.Health) / float(W.Default.Health);
		Hud.DrawPercBar(Canvas,25,V.X,V.Y+18*DScale, Perc);
	}
	
	
}

simulated function DrawBeacon(Beacons B, Canvas C, WarfareHud H, float X, float Y)
{
	if (MedicBeacon(B)!=None)
		return;

	B.DrawBeacon(Self,C,H,X,Y);
}		
		


defaultproperties
{
	LandGrunt=Sound'MaleSounds.(All).land10'
	LoadOut=0
	RequiredEquipment[0]="WarClassLight.WeapCOGAssaultRifle"
	RequiredEquipment[1]="WarClassLight.WeapCOGEngineerGun"
	RequiredEquipment[2]="WarClassLight.ConstructTripMine"
	RequiredEquipment[3]="WarClassLight.ConstructReloadAmmo"
	RequiredEquipment[4]="WarClassLight.ConstructAmmoDepot"
	RequiredEquipment[5]="WarClassLight.ConstructionDecapitator"
	GroundSpeed=400
	AirSpeed=400
	MenuName="Geist Engineer"
}