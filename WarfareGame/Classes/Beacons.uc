// ====================================================================
//  Class:  WarfareGame.Beacons
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class Beacons extends Keypoint
	Abstract;

#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud
	
var byte Team;				// Which team owns this beacon
var Material Icon;			// 32x32 material to display
var bool bEnabled;			// Is this beacon active
var bool bDrawDistance;		// Should we display the distance
var bool bOptional;			// Should this be displayed all the time
var float VisibleTime;		// If Optional, how long to display them for
var float Alpha;			// How transparent are they?
	
replication
{
	reliable if (role==ROLE_Authority)
		Team, bEnabled, bOptional;
}

simulated function DrawIcon(Canvas C, WarfareHud H, float Scale, float X, float Y);
simulated function DrawBeacon(pawn Who, Canvas C, WarfareHud H,  float X, float Y)
{
	local float xl,yl,dist, RangeToTarget, DistanceScale;
	local string s;
	
	RangeToTarget = VSize(Location - Who.Location);
	DistanceScale = (640 / RangeToTarget) * 85 / PlayerController(Who.Controller).FOVAngle;

	DistanceScale=fClamp(DistanceScale,0.25,1);
	DrawIcon(C,H,DistanceScale,X,Y);

	if (bDrawDistance)
	{
	
		Dist = (Vsize(Location - Who.Location) / 2) * 0.0254;
		C.Font = C.SmallFont;
		s = ""$int(Dist)$"m";
		C.Strlen(s,xl,yl);
		C.SetPos(x-(xl/2),y+20);
		C.SetDrawColor(255,255,0);
		C.DrawText(s,true);
	}
}
	

function Trigger(actor Other, pawn EventInstigator)
{
	bEnabled = !bEnabled;
	super.Trigger(Other,EventInstigator);
}

simulated function MakeVisible()	// Make it visible for a bit
{
	GotoState('VisibleForABit');
}

state VisibleForABit
{

	simulated event Tick(float Delta)
	{
		if (VisibleTime>0)
		Alpha -= (255*VisibleTime) * Delta;
	}

	simulated event Timer()
	{
		bEnabled = false;
		Gotostate('');
	}
	
	
	simulated function BeginState()
	{
		Alpha=1;
		bEnabled = true;
		SetTimer(VisibleTime,false);
	}
		
}
		
		

defaultproperties
{
	bEnabled=true
	Alpha=1
	bStatic=false
	bAlwaysRelevant=true
	RemoteRole=2
}