class DuffelBag extends Powerups;

#exec TEXTURE IMPORT NAME=DuffelBagIcon FILE=Textures\DuffelBagIcon.bmp

defaultproperties
{
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'DuffelBagPickup'
	Icon=Texture'DuffelBagIcon'
	ItemName="Duffel Bag"
	RemoteRole=1
	MessageClass=Class'WarfareGame.ItemMessagePlus'
}