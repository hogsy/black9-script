// ====================================================================
//  Class:  WarClassHeavy.WarCogHeavyCanopyAttachment
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarCogHeavyCanopyAttachment extends CanopyAttachment;

#exec OBJ LOAD FILE=..\StaticMeshes\character_canopymeshes.usx PACKAGE=character_canopymeshes

defaultproperties
{
	StaticMesh=StaticMesh'character_canopymeshes.COG.COG_HG_Canopy2'
	DrawScale=0.4
}