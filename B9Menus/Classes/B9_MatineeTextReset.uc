// B9_MatineeTextReset

class B9_MatineeTextReset extends Actor
	placeable;

var(MatineeTextReset) name TextHolderEvent;
var(MatineeTextReset) int TextHolderIndex;

event Trigger( Actor Other, Pawn Instigator )
{
	TriggerEvent(TextHolderEvent, self, Instigator);
}

defaultproperties
{
	bHidden=true
}