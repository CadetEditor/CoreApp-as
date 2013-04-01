// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.validators
{
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionEvent;
	import core.app.events.CollectionValidatorEvent;
	import core.app.util.ArrayUtil;
	
	[Event( type="core.app.events.CollectionValidatorEvent", name="validItemsChanged" )]
	
	public class CollectionValidator extends AbstractValidator
	{
		protected var _collection	:ArrayCollection;
		protected var _validType	:Class;
		protected var _min			:uint;
		protected var _max			:uint;
		protected var oldCollection	:Array
		
		public function CollectionValidator( collection:core.data.ArrayCollection = null, validType:Class = null, min:uint = 1, max:uint = uint.MAX_VALUE )
		{
			oldCollection = [];
			
			this.collection = collection;
			this.validType = validType;
			this.min = min;
			this.max = max;
		}
		
		override public function dispose():void
		{
			if ( _collection )
			{
				_collection.removeEventListener(ArrayCollectionEvent.CHANGE, collectionChangeHandler);
			}
			_collection = null;
			_validType = null;
			super.dispose();
		}
		
		public function set collection( value:ArrayCollection ):void
		{
			if ( value == _collection ) return;
			if ( value == null )
			{
				value = new ArrayCollection();
			}
			
			if ( _collection )
			{
				_collection.removeEventListener(ArrayCollectionEvent.CHANGE, collectionChangeHandler);
			}
			_collection = value;
			if ( _collection )
			{
				_collection.addEventListener(ArrayCollectionEvent.CHANGE, collectionChangeHandler);
			}
			updateState();
		}
		public function get collection():ArrayCollection { return _collection; }
		
		private function collectionChangeHandler( event:ArrayCollectionEvent ):void
		{
			updateState();
		}
		
		public function set validType( value:Class ):void
		{
			if ( value == null ) value = Object;
			_validType = value;
			updateState();
		}
		public function get validType():Class { return _validType; }
				
		public function set min( value:uint ):void
		{
			_min = value;
			updateState();
		}
		public function get min():uint { return _min; }
		
		public function set max( value:uint ):void
		{
			_max = value;
			updateState();
		}
		public function get max():uint { return _max; }
		
		
		public function getValidItems():Array
		{
			if ( !_collection ) return [];
			var validItems:Array = ArrayUtil.filterByType(_collection.source, _validType);
			
			if ( validItems.length < _min ) return [];
			if ( validItems.length > _max ) return [];
			
			return validItems;
		}
		
		protected function updateState():void
		{
			var validItems:Array = getValidItems();
			
			if ( validItems.length == 0 )
			{
				setState(false);
			}
			else
			{
				setState(true);
			}
			
			if( ArrayUtil.compare( oldCollection, validItems ) == false )
			{
				oldCollection = validItems;
				dispatchEvent( new CollectionValidatorEvent( CollectionValidatorEvent.VALID_ITEMS_CHANGED, validItems ) );
			}
		}
	}
}