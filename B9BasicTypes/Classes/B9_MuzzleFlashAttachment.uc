
class B9_MuzzleFlashAttachment extends Emitter;



simulated function Flash()
{
	if( Emitters[0] != None )
	{
		if( Emitters[0].Disabled )
		{
			Emitters[0].Disabled = false;
		}

		Emitters[0].SpawnParticle( 1 );
	}
}

