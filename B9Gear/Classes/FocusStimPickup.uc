class FocusStimPickup extends B9_PickUp;


var() int FocusAmount;


function float BotDesireability(Pawn Bot)
{
/*
	local float desire;
	local int FocusMax;

	FocusMax = Bot.Default.Focusth;
	if (bSuperFocus) FocusMax = Min(199, FocusMax * 2.0);
	desire = Min(FocusingAmount, FocusMax - Bot.Focusth);

	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( Bot.Focusth < 45 )
		return ( FMin(0.03 * desire, 2.2) );
	else
	{
		if ( desire > 6 )
			desire = FMax(desire,25);
		return ( FMin(0.017 * desire, 2.0) ); 
	}
	*/
	return 0.0;
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage$Default.FocusAmount;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}


auto state Pickup
{	
	function Touch( actor Other )
	{
		local int FocusMax;
		local B9_AdvancedPawn P;
			
		if ( ValidTouch(Other) ) 
		{	
			log("Touched Focus");
			P = B9_AdvancedPawn(Other);
			if( P != None) 
			{
				FocusMax = P.fCharacterMaxFocus;
				if (P.fCharacterFocus < FocusMax) 
				{
					
					P.fCharacterFocus = Min(FocusMax, P.fCharacterFocus + FocusAmount);
					AnnouncePickup(P);
				}else
				{
					log("Focus too high");	
				}
			}else
			{
				log("Not an Advanced Pawn");	
			}
		}
	}
}

defaultproperties
{
	FocusAmount=20
	MaxDesireability=0.5
	RespawnTime=20
	PickupMessage="You picked up a Focus Pack +"
	DrawType=8
	StaticMesh=StaticMesh'B9_items_mesh.data_stiks.data_stik_chi'
	AmbientGlow=64
	CollisionHeight=8
	Mass=10
}