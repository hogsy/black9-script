//=============================================================================
// TournamentAmmo.
//=============================================================================
class TournamentAmmo extends Ammo
	abstract;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\AmmoPickup_4.WAV" NAME="AmmoPick" GROUP="Pickups"

defaultproperties
{
	PickupSound=Sound'Pickups.AmmoPick'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}