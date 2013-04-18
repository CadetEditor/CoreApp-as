// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.util
{
	import flash.utils.Dictionary;
	
	public class ArrayUtil
	{
		static public function shuffle( array:Array, iterations:int ):void
		{
			for ( var i:int = 0; i < iterations; i++ )
			{
				array = array.sort(shuffleFunc);
			}
		}
		static private function shuffleFunc( itemA:*, itemB:* ):Boolean
		{
			return Math.random()<0.5;
		}
		
		
		static public function filterByType( array:Array, type:Class ):Array
		{
			var obj:Object = { type:type };
			return array.filter( 
			function( item:*, index:int, arr:Array ):Boolean 
			{ 
				return item is type; 
			}
			, obj );
		}
		
		static public function filterByTypes( array:Array, types:Array ):Array
		{
			var obj:Object = { types:types };
			return array.filter( 
			function( item:*, index:int, arr:Array):Boolean 
			{ 
				for each ( var type:Class in types ) 
				{ 
					if ( item is type == false ) return false;
				}
				return true;
			}
			, obj );
		}
		
		static public function removeDuplicates( array:Array ):void
		{
			var table:Dictionary = new Dictionary();
			for ( var i:int = 0; i < array.length; i++ )
			{
				var item:* = array[i];
				if ( table[item] )
				{
					array.splice( i, 1 );
					i--;
				}
				else
				{
					table[item] = true;
				}
			}
		}
		
		static public function containsInstanceOf( array:Array, type:Class ):Boolean
		{
			for each ( var item:* in array )
			{
				if ( item is type ) return true;
			}
			return false;
		}
		
		static public function getInstanceOf( array:Array, type:Class ):Object
		{
			for each ( var item:* in array )
			{
				if ( item is type ) return item;
			}
			return null;
		}
		
		/**
		 * Compares the 2 input arrays for likeness and returns true if they match, false if they don't. 
		 * @param arrayA
		 * @param arrayB
		 * @param matchOrder Set this flag to true to check if both arrays not only contain the same items, but they are in the same order too.
		 * @return 
		 */		
		static public function compare( arrayA:Array, arrayB:Array, matchOrder:Boolean = false ):Boolean
		{
			if ( arrayA.length != arrayB.length ) return false;
			
			const L:int = arrayA.length;
			for ( var i:int = 0; i < L; i++ )
			{
				var item:Object = arrayA[i];
				
				if ( arrayB.indexOf( item ) == -1 ) return false;
				
				if ( matchOrder )
				{
					if ( item != arrayB[i] ) return false;
				}
			}
			return true;
		}
	}
}