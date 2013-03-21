// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.data 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import core.events.ArrayCollectionChangeKind;
	import core.events.ArrayCollectionEvent;
	
	[Event( type="core.events.ArrayCollectionEvent", name="change" )]
	public class ArrayCollection extends Proxy implements IEventDispatcher
	{
		private var array		:Array;
		private var dispatcher	:EventDispatcher;
		
		public function ArrayCollection( source:Array = null ) 
		{
			array = source == null ? [] : source;
			dispatcher = new EventDispatcher(this);
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		public function addItemAt( item:*, index:int ):void
		{
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			array.splice( index, 0, item );
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.ADD, index, item ) );
		}
		
		public function removeItemAt( index:int ):void
		{
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			var item:* = array[index];
			array.splice( index, 1 );
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.REMOVE, index, item ) );
		}
		
		public function getItemIndex( item:* ):int
		{
			return array.indexOf(item);
		}
		
		public function getItemAt( index:int ):*
		{
			return array[index];
		}
		
		public function removeItem( item:* ):void
		{
			var index:int = array.indexOf(item);
			if ( index == -1 )
			{
				throw( new Error( "Item does not exist." ) );
				return;
			}
			removeItemAt(index);
		}
		
		public function addItem( value:* ):void
		{
			this[array.length] = value;
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.ADD, array.length, value ) );
		}
		
		public function contains( item:* ):Boolean
		{
			return source.indexOf(item) != -1;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set source( value:Array ):void
		{
			var oldValue:Array = array;
			array = value;
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, ArrayCollectionChangeKind.RESET, 0, oldValue ) );
		}
		
		public function get source():Array
		{
			return array.slice();
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return array[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			var index:int = int(name);
			if ( isNaN(index) ) throw( new Error( "Invalid index : " + name) );
			if ( index < 0 || index > array.length ) throw( new Error( "Index out of bounds : " + index) );
			
			var changeKind:int;
			if ( index == array.length )
			{
				if ( value == null )
				{
					array.length--;
					changeKind = ArrayCollectionChangeKind.REMOVE;
				}
				else
				{
					changeKind = ArrayCollectionChangeKind.ADD;
					array[array.length] = value;
				}
			}
			else
			{
				changeKind = ArrayCollectionChangeKind.REPLACE;
				array[index] = value;
			}
			
			dispatcher.dispatchEvent( new ArrayCollectionEvent( ArrayCollectionEvent.CHANGE, changeKind, index, value ) );
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			return index < length ? index + 1 : 0;
		}
		
		override flash_proxy function nextName(index:int):String
		{
			return (index - 1).toString();
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return getItemAt(index - 1);
		}

		public function get length():int
		{
			return array.length;
		}
		
		public function toString():String
		{
			return String(array);
		}
		
		////////////////////////////////////////////////
		// Implement IEventDispatcher
		////////////////////////////////////////////////
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
	}
}