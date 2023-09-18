//
// An Unreal Warfare Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the DamageType Class.
//

class WarfareDeathMessage extends LocalMessage;

var localized string KilledString, SomeoneString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local string KillerName, VictimName;

	if (Class<DamageType>(OptionalObject) == None)
		return "";

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.PlayerName;

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName, 
			VictimName,
			Class<DamageType>(OptionalObject).Static.SuicideMessage(RelatedPRI_2) );
	}

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.PlayerName;

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName, 
		VictimName,
		Class<DamageType>(OptionalObject).Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

	if (RelatedPRI_1 == P.PlayerReplicationInfo)
	{
		// Interdict and send the child message instead.
		P.myHUD.LocalizedMessage( Default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

		if ( Default.bIsConsoleMessage )
		{
			P.Player.InteractionMaster.Process_Message( Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ), 6.0, P.Player.LocalInteractions);
			
		}
	} 
	else if (RelatedPRI_2 == P.PlayerReplicationInfo) 
	{
		P.ReceiveLocalizedMessage( class'VictimMessage', 0, RelatedPRI_1 );
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	} 
	else
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	KilledString="was killed by"
	SomeoneString="someone"
	ChildMessage=Class'KillerMessagePlus'
	DrawColor=(B=0,G=0,R=255,A=255)
}