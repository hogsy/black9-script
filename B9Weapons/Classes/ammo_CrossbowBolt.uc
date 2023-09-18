//=============================================================================
// ammo_CrossbowBolt
//
// 
//=============================================================================

class ammo_CrossbowBolt extends B9Ammunition;

defaultproperties
{
	fIniLookupName="Crossbow"
	MaxAmmo=8
	AmmoAmount=8
	PickupAmmo=8
	bLeadTarget=true
	ProjectileClass=Class'proj_CrossbowBolt'
	MyDamageType=Class'B9BasicTypes.damage_CrossbowBolt'
	PickupClass=Class'ammo_CrossbowBolt_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
	ItemName="Crossbow Bolt"
}