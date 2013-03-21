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
	import core.app.core.operations.IUndoableOperation;
	
	/**
	 * This Operation sets the value of a single property on a single object. It remembers the value
	 * it is replacing, allowing the operation to be undone.
	 * @author Jonathan
	 * 
	 */	
	public class ChangePropertyOperation implements IUndoableOperation
	{
		protected var object		:Object
		protected var propertyName	:String
		protected var newValue		:*
		protected var oldValue		:*
		
		private var _label			:String = "Change Property";
		
		public function ChangePropertyOperation(object:Object, propertyName:String, newValue:*, oldValue:* = null)
		{
			this.object = object
			this.propertyName = propertyName
			this.newValue = newValue;
			if ( oldValue )
			{
				this.oldValue = oldValue;
			}
			else
			{
				this.oldValue = object[propertyName]
			}
		}

		public function execute():void
		{
			object[propertyName] = newValue
		}
		
		public function undo():void
		{
			object[propertyName] = oldValue
		}
		
		public function set label( value:String ):void
		{
			_label = value;
		}
		public function get label():String { return _label; }
	}
}