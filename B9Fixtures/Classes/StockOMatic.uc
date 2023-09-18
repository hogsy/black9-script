// StockOMatic.uc

class StockOMatic extends Actor
	placeable;

var() globalconfig bool Accessible;
var() class<Inventory> StockClasses[16];
var() class<Pawn> PawnKind;

function StockMe(Pawn Pawn)
{
	local class<Inventory> StockClass;
	local int i;
	local Inventory Inv;

	if ( Accessible && ClassIsChildOf( Pawn.Class, PawnKind ) )
	{
		for (i=0;i<16;i++)
		{
			StockClass = StockClasses[i];
			if ( StockClass != None && Pawn.FindInventoryType( StockClass ) == None )
			{
				Inv = Spawn(StockClass);
				Inv.GiveTo(Pawn);

				Log("StockOMatic gives " $ Inv.Name $ " to " $ Pawn.Name); 
			}
		}
	}
}

event Trigger( Actor Other, Pawn Instigator )
{
	StockMe( Instigator );
}

defaultproperties
{
	bHidden=true
	Tag=StockOMatic
}