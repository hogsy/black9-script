class DynamicProjector extends Projector;

function Tick(float DeltaTime)
{
	DetachProjector();
	AttachProjector();
}

defaultproperties
{
	bDynamicAttach=true
	bStatic=false
}