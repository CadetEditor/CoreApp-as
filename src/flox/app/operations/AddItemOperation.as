// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.operations
{
	import flox.core.data.ArrayCollection;
	
	import flox.app.core.operations.IUndoableOperation;
	
	/**
	 * This Operation wraps up a call to an IList's addItem() method. You can optionally specify an index for the item to be added at,
	 * if not specified it defaults to -1, which symbolises simply adding it to the end of the array.
	 * @author Jonathan
	 * 
	 */	
	public class AddItemOperation implements IUndoableOperation
	{
		protected var item			:*;
		protected var list			:ArrayCollection;
		protected var index			:int;
		
		public function AddItemOperation( item:*, list:ArrayCollection, index:int = -1 )
		{
			this.item = item;
			this.list = list;
			this.index = index;
		}

		public function execute():void
		{
			if ( index == -1 || index >= list.length )
			{
				list.addItem( item );
			}
			else
			{
				list.addItemAt( item, index );
			}
		}
		
		public function undo():void
		{
			list.removeItemAt( list.getItemIndex( item ) );
		}
		
		public function get label():String
		{
			return "Add item";
		}
	}
}