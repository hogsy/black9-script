class KeyStickPickup extends B9_PickUp;

var string fFinalKeyCode;

enum ePickupKeys
{
	PU_Key_UP,
	PU_Key_DOWN,
	PU_Key_LEFT,
	PU_Key_RIGHT
};

var(Lock) array<ePickupKeys> fKeyCode ;


function float BotDesireability(Pawn Bot)
{
	return 0.0;
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}
function ConvertLDCodeToString()
{
	local int index;
	log("PIcked Up Key and Decoding it");
	for(index = 0; index < fKeyCode.length; index++)
	{
		if(fKeyCode[index] == PU_Key_UP)
		{
			fFinalKeyCode = fFinalKeyCode $ "u";
		}else if(fKeyCode[index] == PU_Key_DOWN)
		{
			fFinalKeyCode = fFinalKeyCode $ "d";
		}else if(fKeyCode[index] == PU_Key_LEFT)
		{
			fFinalKeyCode = fFinalKeyCode $ "l";
		}else 	
		{
			fFinalKeyCode = fFinalKeyCode $ "r";
		}
	}
	log("Decoded Key is "$fFinalKeyCode);
}

function OuterTouch( actor Other )
{
	local B9_PlayerPawn P;
	P = B9_PlayerPawn( Other );
	if( P != None )
	{
		ConvertLDCodeToString();
		P.fKeyRing[P.fKeyRingIndex] = fFinalKeyCode;
		P.fKeyRingIndex = P.fKeyRingIndex + 1;
		if( P.fKeyRingIndex >= P.fKeyRingIndexMax)
		{
			P.fKeyRingIndex = 0;
		}
		AnnouncePickup(P);	
	}
}

auto state Pickup
{	
	function Touch( actor Other )
	{
		if ( ValidTouch(Other) ) 
		{	
			OuterTouch( Other );
		}
	}
}

defaultproperties
{
	MaxDesireability=0.5
	RespawnTime=20
	PickupMessage="You picked up a key"
	DrawType=8
	StaticMesh=StaticMesh'B9_items_mesh.data_stiks.data_stik_key'
	AmbientGlow=64
	CollisionHeight=8
	Mass=10
}