class AssassinShadow extends Projector;

var transient vector	OldLocation;

function Tick(float Delta)
{
	if((Owner.Velocity Dot Owner.Velocity) > 0)
	{
		DetachProjector(true);
		AttachProjector();
		OldLocation = Location;
	}
}

defaultproperties
{
	ProjTexture=FinalBlend'Black9_Skins.Shadows.player_char_shadow'
	FOV=20
	MaxTraceDistance=500
	bProjectStaticMesh=false
	bProjectParticles=false
	bProjectActor=false
	bClipBSP=true
	bGradient=true
	bStatic=false
}