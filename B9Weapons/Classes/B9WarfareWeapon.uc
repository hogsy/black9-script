class B9WarfareWeapon extends Weapon
	abstract;

#exec TEXTURE IMPORT NAME=CHair1  FILE=..\HUD\Textures\green1.PCX GROUP="Icons" MIPS=OFF

var sound HolsterSound,ReloadSound;

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

state Reloading
{
	function ServerForceReload() 
	{
		ReloadCount = Default.ReloadCount;
		GotoState('Idle');
	}

	function ClientForceReload()
	{
		ReloadCount = Default.ReloadCount;
		GotoState('Idle');
	}
}

defaultproperties
{
	CrossHair=Texture'Icons.CHair1'
}