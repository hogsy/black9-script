class biomed_MedKit extends B9_AccumulativeItem;

#exec TEXTURE IMPORT NAME=MedKitIcon FILE=Textures\MedKitIcon.bmp

function Activate()
{
	if( bActivatable )
	{
		Log("Activate "$self);

/*		if (Level.Game.StatLog != None)
			Level.Game.StatLog.LogItemActivate(Self, Pawn(Owner));*/

		B9_AdvancedPawn(Owner).PlayUseItem();
	}
}

function Use( float value )
{
	local B9_AdvancedPawn Pawn;

	Pawn = B9_AdvancedPawn(Owner);
	if (Pawn != None)
	{
		Pawn.Health += 25;
		if (Pawn.Health > Pawn.fCharacterMaxHealth)
			Pawn.Health = Pawn.fCharacterMaxHealth;

		Super.Use( value );
	}
}

defaultproperties
{
	MaxAmount=10
	Amount=1
	fUniqueID=11
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'biomed_MedKit_pickup'
	Icon=Texture'B9HUD_textures.Browser_items.MedKit_bricon'
	ItemName="MedKit"
	RemoteRole=1
	MessageClass=Class'WarfareGame.ItemMessagePlus'
}