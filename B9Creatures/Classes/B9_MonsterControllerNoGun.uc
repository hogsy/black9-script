class B9_MonsterControllerNoGun extends B9_MonsterController;

state Firing

{
begin:
	gotostate ('hunting');
}
