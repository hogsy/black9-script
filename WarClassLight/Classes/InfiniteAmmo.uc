class InfiniteAmmo extends WarfareAmmo;

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
	MaxAmmo=1000
	AmmoAmount=1000
}