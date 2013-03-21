// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.entities
{
	import flash.events.EventDispatcher;
	
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionChangeKind;
	import core.events.ArrayCollectionEvent;
	
	[Event( type="core.events.ArrayCollectionEvent", name="change" )]
	public class TreeNode extends EventDispatcher
	{
		protected var _children		:ArrayCollection;
		protected var _data			:*;
		protected var _label		:String;
		public var parent			:TreeNode;
		
		public function TreeNode()
		{
			_children = new ArrayCollection();
			_children.addEventListener(ArrayCollectionEvent.CHANGE, collectionChangeHandler);
		}
		
		private function collectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			if ( event.kind == ArrayCollectionChangeKind.ADD )
			{
				event.item.parent = this;
				event.item.addEventListener( ArrayCollectionEvent.CHANGE, childCollectionChangedHandler );
			}
			else if ( event.kind == ArrayCollectionChangeKind.REMOVE )
			{
				event.item.parent = null;
				event.item.removeEventListener( ArrayCollectionEvent.CHANGE, childCollectionChangedHandler );
			}
			else if ( event.kind == ArrayCollectionChangeKind.RESET )
			{
				throw ( new Error( "TreeItem cannot handle the 'removeAll()' operation on it's children" ) );
				return;
			}
			dispatchEvent( event );
		}
		
		private function childCollectionChangedHandler( event:ArrayCollectionEvent ):void
		{
			dispatchEvent( event );
		}
		
		public function get children():ArrayCollection { return _children; }
		
		public function set data( value:* ):void
		{
			_data = value;
		}
		public function get data():* { return _data; }
		
		public function set label( value:String ):void
		{
			_label = value;
		}
		public function get label():String { return _label; }
		
		public function getChildren( recursive:Boolean = true ):Array
		{
			var array:Array = [];
			for ( var i:int = 0; i < _children.length; i++ )
			{
				var child:TreeNode = _children[i];
				array.push(child);
				
				if ( recursive )
				{
					array = array.concat(child.getChildren(true));
				}
			}
			return array;
		}
		
		public function getChildWithLabel( value:String, recursive:Boolean = false ):TreeNode 
		{
			for ( var i:int = 0; i < _children.length; i++ )
			{
				var child:TreeNode = _children[i];
				if ( child.label == value ) return child;
				
				if ( recursive )
				{
					var result:TreeNode = child.getChildWithLabel(value,true);
					if ( result ) return result;
				}
			}
			return null;
		}
		
		public function getChildWithData( value:*, recursive:Boolean = false ):TreeNode 
		{
			for ( var i:int = 0; i < _children.length; i++ )
			{
				var child:TreeNode = _children[i];
				if ( child.data == value ) return child;
				
				if ( recursive )
				{
					var result:TreeNode = child.getChildWithData(value,true);
					if ( result ) return result;
				}
			}
			return null;
		}
	}
}