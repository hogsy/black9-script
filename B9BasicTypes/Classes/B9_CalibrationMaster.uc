////////////////
//
// B9_CalibrationMaster

class B9_CalibrationMaster extends Actor;

var transient B9_Calibration Calibration;
var class<B9_Calibration> CalClass;

simulated function AddCalibration(B9_Calibration cal)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
	if (Calibration == None)
		Calibration = new(None) CalClass;

	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

			if (Item == cal)
				return;
		}

		cal.Calibration = Calibration.Calibration;
		Calibration.Calibration = cal;

		//Log("Added calibration: " $ cal.Name $ "/" $ cal.PawnName);
	}
}

simulated function RemoveCalibration(B9_Calibration cal)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

			if( Item == cal )
			{
				Link.Calibration = Item.Calibration;
				Item.Calibration = None;
				return;
			}
		}
	}
}

function MakePermanent(B9_AdvancedPawn pawn)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

//			Log("Checking calibration: " $ Item.Name $ "/" $ item.PawnName);

			if( Item.PawnName == pawn.Name )
				Item.Permanent = true;
		}
	}
}

function ApplyCalibrations(B9_AdvancedPawn pawn)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
//	Log("Checking calibration for: " $ pawn.Name);

	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

//			Log("Checking calibration: " $ Item.Name $ "/" $ item.PawnName);

			if( Item.PawnName == pawn.Name )
			{
				Item.Perform(pawn);
				if (Item.Permanent)
				{
					Link.Calibration = Item.Calibration;
					Item.Calibration = None;
					Item = Link;
				}
			}
		}
	}
}

function UndoCalibrations(B9_AdvancedPawn pawn)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
//	Log("Checking calibration for: " $ pawn.Name);

	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

//			Log("Checking calibration: " $ Item.Name $ "/" $ item.PawnName);

			if( Item.PawnName == pawn.Name )
			{
				Item.Undo(pawn);
			}
		}
	}
}

simulated function DeleteCalibrations(B9_AdvancedPawn pawn)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	
	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

			if( Item.PawnName == pawn.Name )
			{
				Link.Calibration = Item.Calibration;
				Item.Calibration = None;
				Item = Link;
			}
		}
	}
}

simulated function ListCalibrations(B9_AdvancedPawn pawn, out array<string> list)
{
	local B9_Calibration Link;
	local B9_Calibration Item;
	local int n, k;

	n = 0;

	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

			if( Item.PawnName == pawn.Name )
				n++;
		}

		if (n == 0) return;

		k = list.Length;
		list.Length = k + n;
		n = 0;

		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;

			if( Item.PawnName == pawn.Name )
			{
				list[k+n] = Item.Description(Pawn);
				n++;
			}
		}
	}
}

simulated function B9_Calibration FindCalibrationKind(B9_AdvancedPawn pawn, B9_Calibration match)
{
	local B9_Calibration Link;
	local B9_Calibration Item;

	if (Calibration != None)
	{
		for( Link=Calibration; Link.Calibration!=None; Link=Item )
		{
			Item = Link.Calibration;
			if( Item.PawnName == pawn.Name && Item.IsSameKind(match) )
				return Item;
		}
	}

	return None;
}

// Kiosk helper functions

function bool ShouldDirectPurchase();
function bool GameInHeadquarters();
function bool ConfirmBuyItem(string InvName, int Price);
function bool ConfirmSellItem(string InvName, out int Price);
function bool ConfirmBuyMod(string InvName, int Price);
function AddBodyModCalibration(name PawnName, string InvName, int Price);
function AddAttrCalibration(Pawn P, byte type, int points, int adjustment);
function AddNanoCalibration(Pawn P, B9_Skill skill, int points, int adjustment);
simulated function QueryResultWithLocation(Pawn P, vector L, bool Result);

defaultproperties
{
	CalClass=Class'B9_Calibration'
}