class DummyGear extends Powerups;

//#exec TEXTURE IMPORT NAME=DuffelBagIcon FILE=Textures\DuffelBagIcon.bmp

defaultproperties
{
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'DummyGear_Pickup'
	Icon=Texture'B9HUD_textures.Browser.Duffel_Bag_BrIcon_tex'
	ItemName="Duffel Bag"
	RemoteRole=1
}