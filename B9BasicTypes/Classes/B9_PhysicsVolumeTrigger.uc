class B9_PhysicsVolumeTrigger extends Trigger
	placeable;

event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local PhysicsVolume A;

	if ( EventName == '' )
		return;

	ForEach AllActors( class 'PhysicsVolume', A, EventName )
		A.Trigger(Other, EventInstigator);
}

