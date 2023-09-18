//=============================================================================
// B9_DemoPlayerController
//
//
// 
//=============================================================================


class B9_DemoPlayerController extends PlayerController;


event PostBeginPlay()
{
	local B9_ArchetypePawnBase P;

	log( "B9_DemoPlayerController::PostBeginPlay" );

	Super.PostBeginPlay();

	ForEach DynamicActors( class'B9_ArchetypePawnBase', P )
	{
		if( P != None && P.IsDemoProtagPawn() )
		{
			log( "---------- Found a B9_DemoProtag_Pawn view target" );
			SetViewTarget( P );
            break;
		}
	}
}

defaultproperties
{
	bBehindView=true
}