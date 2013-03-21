// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.events 
{
	import flash.events.Event;
	
	public class ArrayCollectionEvent extends Event 
	{
		public static var CHANGE		:String = "change";
		
		private var _kind	:int;
		private var _index		:int;
		private var _item		:*;
		
		public function ArrayCollectionEvent( type:String, changeKind:int, index:int = 0, item:* = null ) 
		{
			super(type, false, false);
			_kind = changeKind;
			_index = index;
			_item = item;
		}
		
		override public function clone():Event
		{
			return new ArrayCollectionEvent( type, _kind, _index, _item );
		}
		
		public function get kind():int
		{
			return _kind;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function get item():*
		{
			return _item;
		}
	}
}