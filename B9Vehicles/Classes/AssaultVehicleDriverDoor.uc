class AssaultVehicleDriverDoor extends Actor;

#exec OBJ LOAD FILE=..\animations\B9Vehicles_models.ukx PACKAGE=B9Vehicles_models




function Toggle()
{
}

auto state Closed
{
	function BeginState()
	{
		PlayAnim( 'door_close_hold' );
		FreezeAnimAt( 0 );
	}

	function Toggle()
	{
		PlayAnim( 'door_open' );
	}

	simulated event AnimEnd( int channel )
	{
		GotoState( 'Opened' );
	}
}

state Opened
{
	function BeginState()
	{
		LoopAnim( 'door_open_hold' );
		FreezeAnimAt( 0 );
	}

	function Toggle()
	{
		PlayAnim( 'door_close' );
	}

	simulated event AnimEnd( int channel )
	{
		GotoState( 'Closed' );
	}
}




defaultproperties
{
	DrawType=2
	Mesh=SkeletalMesh'B9Vehicles_models.AV_driver_door_mesh'
}