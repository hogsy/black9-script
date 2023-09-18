
class B9_Ammo extends Ammo
	native;



var string	fIniLookupName;



native(2023) final function		InitIniStats();



simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	InitIniStats();
}

