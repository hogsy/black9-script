class WarfareWeapon extends Weapon
	abstract;

#exec TEXTURE IMPORT NAME=CHair1  FILE=..\HUD\Textures\green1.PCX GROUP="Icons" MIPS=OFF

var sound HolsterSound,ReloadSound;

var float AdjustStep;	// Used for aligning effects
var int AdjustPerson;	// Used for aligning effects

replication
{
	reliable if( Role<ROLE_Authority )
		ServerNextWeaponFunction, ServerPrevWeaponFunction;
		
	reliable if( ROLE==ROLE_Authority)
		NextWeaponFunction, PrevWeaponFunction;
}

simulated exec function SetMuzzleX(float NewX)
{
    FlashOffsetX=NewX;
}
simulated exec function SetMuzzleY(float NewY)
{
    FlashOffsetY=NewY;
}
simulated exec function ShowMuzzle()
{
	log("#### Muzzle X/Y: "$FlashOffsetX$"/"$FlashOffsetY);
}
simulated function SetAdjustStep(float NewStep)
{
	AdjustStep = NewStep;
	Log("#### Setting Adjustment Step to "$NewStep);
}

simulated function IncAdjustStep()
{
	AdjustStep += 0.25;
	Log("#### Setting Adjustment Step to "$AdjustStep);
}

simulated function DecAdjustStep()
{
	AdjustStep -= 0.25;
	Log("#### Setting Adjustment Step to "$AdjustStep);
}

simulated function SetAdjustPerson(int NewPerson)
{
	AdjustPerson = NewPErson;
	if (AdjustPerson==0)
		Log("#### Adjusting 3rd Person offsets");
	else
		Log("#### Adjusting 1st Person offsets");
}

simulated function AdjustX(int dir)
{

	local WarfareWeaponAttachment W;
	local vector v;

	W = WarfareWeaponAttachment(ThirdPersonActor);
	if (w==none)
		return;

	v.X = AdjustStep *Dir;
	W.Adjust(AdjustPerson,V);		
}		 
	
simulated function AdjustY(int dir)
{

	local WarfareWeaponAttachment W;
	local vector v;
	
	W = WarfareWeaponAttachment(ThirdPersonActor);
	if (w==none)
		return;

	v.Y = AdjustStep *Dir;
	W.Adjust(AdjustPerson,V);		

}		 

simulated function AdjustZ(int dir)
{

	local WarfareWeaponAttachment W;
	local vector v;
	
	W = WarfareWeaponAttachment(ThirdPersonActor);
	if (w==none)
		return;

	v.z = AdjustStep *Dir;
	W.Adjust(AdjustPerson,V);		
		
}		 


simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local WarfareWeaponAttachment W;

	Super.DisplayDebug(Canvas, YL, YPos);

	
	W = WarfareWeaponAttachment(ThirdPersonActor);

	Canvas.SetDrawColor(255,255,0);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if (AdjustPerson==0)
		Canvas.DrawText("Adjusting 3rd Person View with a step of "$AdjustStep);
	else
		Canvas.DrawText("Adjusting 1st Person View with a step of "$AdjustStep);
	
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("     3rd Person Offset: "$W.EffectLocationOffset[0]);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("     1st Person Offset: "$W.EffectLocationOffset[1]);

}


simulated exec function SetWeapFOV(float newfov)
{
	if ( Pawn(Owner).Weapon != self)
		return;

	DisplayFOV = newFOV;
}

simulated exec function ShowWeapFOV()
{
	if ( Pawn(Owner).Weapon != self)
		return;

	log("#### DisplayFOV = "$DisplayFOV);
}	

simulated exec function SetWeapScale(float ns)
{
	if ( Pawn(Owner).Weapon != self)
		return;

	SetDrawScale(ns);
}

simulated exec function ShowWeapScale()
{
	if ( Pawn(Owner).Weapon != self)
		return;

	log("#### DrawScale= "$DrawScale);
}

simulated exec function SetWeapX(float x)
{
	if ( Pawn(Owner).Weapon != self)
		return;

	PlayerViewOffset.X = x;
}

simulated exec function SetWeapY(float Y)
{
	if ( Pawn(Owner).Weapon != self)
		return;

	PlayerViewOffset.Y = Y;

}
simulated exec function SetWeapZ(float Z)
{
	if ( Pawn(Owner).Weapon != self)
		return;

	PlayerViewOffset.Z = Z;

}

simulated exec function ShowWeapXYZ()
{
	if ( Pawn(Owner).Weapon != self)
		return;

	log("#### ViewOffset: "$PlayerViewOffset);
}

// TrackPlayer - This function is linked to the hud and used to display any special
// player tracking or targetting info.  X/Y is the screen coordinates of the player.  
// returns FALSE if it doesn't process the player.

simulated function bool TrackPlayer(canvas Canvas, float X, float Y, pawn P);

simulated function DrawHud(canvas Canvas, WarfareHud Hud, FontInfo Fonts, float Scale)
{
	local float tScale;
	local int team;
	
	if ( Instigator == None )
		return;

	tScale = Scale;
	if (Scale<1)
		Scale=1;
		
	// Draw the Clip Ammo Display
	
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,255,255);
	Team = Instigator.PlayerReplicationInfo.Team.TeamIndex; 
	Canvas.SetPos(0,0);
	Canvas.DrawTile(Hud.LeftHud[Team],191*Scale,98*Scale,0,0,191,98);

	Canvas.SetDrawColor(255,255,0);
	
	Canvas.Font = Fonts.GetHugeFont(Canvas.ClipX);
	Canvas.SetPos(73*Scale,10*Scale);
	Canvas.DrawText(AmmoType.AmmoAmount, false);
	
	Canvas.SetDrawColor(255,255,255);
	
	Canvas.SetPos(15*Scale, 54*Scale);
	Canvas.Font = Fonts.GetSmallestFont(Canvas.ClipX);
	Canvas.DrawText(AmmoType.ItemName,false);	

	Scale=tScale;

}

simulated function TweenDown()
{
	local name Anim;
	local float frame,rate;

	if ( IsAnimating() && AnimIsInGroup(0,'Select') )
	{
		GetAnimParams(0,Anim,frame,rate);
		TweenAnim( Anim, frame * 0.4 );
	}
	else
	{
		PlayAnim('Holster', 1.0, 0.05);
		PlayOwnedSound(HolsterSound);
	}
}

simulated function PlayReloading()
{
	PlayAnim('Reload', 1.0, 0.05);
	PlayOwnedSound(ReloadSound);
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	if ( !IsAnimating() || !AnimIsInGroup(0,'Select') )
		PlayAnim('Load',1.0,0.0);
		
	Owner.PlaySound(SelectSound, SLOT_Misc, 1.0);	
}

// Next/PrevWeaponFunctions are used to scroll though alternate functions on the weapon.

simulated function NextWeaponFunction()
{
	ServerNextWeaponFunction();
}

function ServerNextWeaponFunction();

simulated function PrevWeaponFunction()
{
	ServerPrevWeaponFunction();
}

function ServerPrevWeaponFunction();

// FakeTrace - Performs the same logic as a TraceHit, but doesn't actually pass it
// to the ammo.  It's used for spawning beam effects and such in first/person
simulated function FakeTrace()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	EndTrace = StartTrace + TraceDist * X; 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	if (Other==None)
		HitLocation = EndTrace;

	if (ThirdPersonActor!=None)
	{
		WarfareWeaponAttachment(ThirdPersonActor).HitLoc=HitLocation;
		WarfareWeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
	}
}

defaultproperties
{
	AdjustStep=1
	AdjustPerson=1
	CrossHair=Texture'Icons.CHair1'
}