class GeistSoldiers extends WarfarePawn
	abstract;

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	bHidden=true;
}

simulated function PlayFiring(float Rate, name FiringMode)
{
}
