//=============================================================================
// B9_BotHatch.uc
//
// A "nest" type object that spawns the specified actor class when triggered
// An anim notifier determines when the spawn actually happens
//
//=============================================================================


class B9_BotHatch extends B9_Pawn
		placeable;



var(B9_BotHatch) int			MaxBotsToSpawn;
var(B9_BotHatch) class<Actor>	BotClass;
var(B9_BotHatch ) name			fEnemyTag;
var private int					fSpidersAlive;
var array<Pawn>					fSpiders;
var private int					fTickCount;


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );

	if( Health <= 0 )
	{
		Explode(HitLocation, Normal(HitLocation-instigatedBy.Location));
	}
}

function MaintainSpiders()
{
	local Actor A;
	local int i;

	// Maintain spiders
	//
	fTickCount++;

	if( fTickCount % 8 == 0 )
	{
		fTickCount = 0;

		for( i = 0; i < fSpiders.Length; i++ )
		{
			if( fSpiders[ i ] != None && fSpiders[ i ].Health <= 0 )
			{
				fSpiders.Remove( i, 1 );
			}
		}

		fSpidersAlive = fSpiders.Length;

		if (!bBlockActors)
		{
			i = 0;
			foreach TouchingActors(BotClass, A)
			{
				i = 1;
				break;
			}
			if (i == 0)
				SetCollision(true, true, true);
		}
	}
}

function Tick( float DeltaTime )
{
	MaintainSpiders();
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	if( fSpidersAlive >= MaxBotsToSpawn )
	{
		return;
	}

	GotoState( 'Spawning' );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	spawn(class<Effects>(DynamicLoadObject("B9FX.ExplosionFX_One",class'Class')),,,HitLocation,rot(16384,0,0));

	HurtRadius( 20, 500, class'Impact', 0, Location );
	Destroy();
}

simulated function SpawnBot()
{}

simulated state Spawning
{
	function Trigger( Actor Other, Pawn EventInstigator ) {}
	
	simulated function BeginState()
	{
		PlayAnim( 'SpawnBot', 1.0, 0.0 );
	}
	
	simulated function AnimEnd( int Channel )
	{
		GotoState( '' );
	}

	simulated function SpawnBot()
	{
		local Pawn			bot;
		local Controller	botController;
		local Pawn			enemyPawn;

		if( BotClass == None )
		{
			return;
		}

		SetCollision(true, false, true);
		bot = Pawn( Spawn( BotClass, , , Location, Rotation ) );

		
		if( bot == None )
		{
			SetCollision(true, true, true);
			return;
		}
		else
		{
			// Add the spider to the list
			//
			fSpiders.Length = fSpiders.Length + 1;
			fSpiders[fSpiders.Length - 1] = bot;
			
		}
	}
}












defaultproperties
{
	MaxBotsToSpawn=1
	Health=50
	ControllerClass=none
}