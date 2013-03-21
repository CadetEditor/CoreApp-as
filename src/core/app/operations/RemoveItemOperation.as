// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.operations
{
	import core.data.ArrayCollection;
	
	import core.app.core.operations.IUndoableOperation;
	
	public class RemoveItemOperation implements IUndoableOperation
	{
		protected var item		:*;
		protected var list		:ArrayCollection;
		
		protected var index:int
		
		public function RemoveItemOperation( item:*, list:ArrayCollection )
		{
			this.item = item;
			this.list = list;
		}

		public function execute():void
		{
			index = list.getItemIndex( item );
			list.removeItemAt( index );
		}
		
		public function undo():void
		{
			if ( index >= list.length )
			{
				list.addItem( item );
			}
			else
			{
				list.addItemAt(item, index);
			}
		}
		
		public function get label():String
		{
			return "Remove item";
		}
	}
}