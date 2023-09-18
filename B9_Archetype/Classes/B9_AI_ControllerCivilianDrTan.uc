//////////////////////////////////////////////////////////////////////////
//
// Black 9 Dr Tan
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCivilianDrTan extends B9_AI_ControllerBase;

auto state Idle
{
Begin:
	Pawn.Acceleration = vect( 0, 0, 0 );
	
//	log( "ALEX: Dr. Tan is Searching" );	
	Pawn.PlayAnim( 'search',, 0.35 );
	FinishAnim();
	
	while( Frand() < 0.3 )
	{
//		log( "ALEX: Dr. Tan is Idling" );	
		Pawn.PlayAnim( 'idle' );
	};
	FinishAnim();
	
	Goto 'Begin';
}
