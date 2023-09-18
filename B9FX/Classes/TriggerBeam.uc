class TriggerBeam extends Emitter;

enum BEAM_MODE
{
	BEAM_IDLE,
	BEAM_SAFE,
	BEAM_ARMED,
};

var BEAM_MODE	Mode;
var int			MaxDistance;
var float		CurrentRange;
var bool		Triggered;

function Safe( int distance )
{
	if ( Mode == BEAM_IDLE )
	{
		Mode		= BEAM_SAFE;
		MaxDistance	= distance;
		Emitters[ 0 ].Disabled	= false;
	}
}

function Armed()
{
	if ( Mode == BEAM_SAFE )
	{
		Mode		= BEAM_ARMED;
		Emitters[ 0 ].Disabled	= true;
		Emitters[ 1 ].Disabled	= false;
	}
}

event Tick( float Delta )
{
	local vector	HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor		other;
	local float		newRange;


	if ( Mode != BEAM_IDLE )
	{
		GetAxes( owner.Rotation, X, Y, Z );
		StartTrace		= Location + X + Y + Z;
		EndTrace		= StartTrace + ( MaxDistance * X ); 
		other			= Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );

		newRange		= VSize( HitLocation - Location );
		if ( ( Mode == BEAM_ARMED ) && ( newRange != CurrentRange ) )
		{
			Triggered	= true;
		}
		CurrentRange	= newRange;

		if ( other == None )
		{
			return;
		}
		
		BeamEmitter( Emitters[ 0 ] ).BeamEndPoints[ 0 ].Offset.X.Min	= vSize( HitLocation - Owner.Location );
		BeamEmitter( Emitters[ 0 ] ).BeamEndPoints[ 0 ].Offset.X.Max	= vSize( HitLocation - Owner.Location );
		BeamEmitter( Emitters[ 1 ] ).BeamEndPoints[ 0 ].Offset.X.Min	= vSize( HitLocation - Owner.Location );
		BeamEmitter( Emitters[ 1 ] ).BeamEndPoints[ 0 ].Offset.X.Max	= vSize( HitLocation - Owner.Location );
	}
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=1
}