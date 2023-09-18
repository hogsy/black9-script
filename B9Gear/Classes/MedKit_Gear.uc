class Medkit_Gear extends B9_Powerups;

//#exec TEXTURE IMPORT NAME=DuffelBagIcon FILE=Textures\DuffelBagIcon.bmp

defaultproperties
{
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'Medkit_Gear_Pickup'
	Icon=Texture'B9HUD_textures.Browser.MedKit_BrIcon_tex'
	ItemName="MedKit"
	RemoteRole=1
}