
class B9EjectedCartridgeFX extends Emitter;


function EjectOneRound()
{
	Emitters[0].RotationOffset = Owner.Rotation;
	Emitters[0].SpawnParticle(1);
}



