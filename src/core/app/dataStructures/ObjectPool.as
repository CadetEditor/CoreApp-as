// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.dataStructures
{
	import flash.utils.Dictionary;
	
	import core.app.util.IntrospectionUtil;
	
	public class ObjectPool
	{
		static private var maxSize		:int = 100;
		static private var table		:Dictionary = new Dictionary();
		static private const nodes		:Array = [];
		static private var numNodes		:int = 0;
		
		public static function clear():void
		{
			table = new Dictionary();
		}
		
		/**
		 * Grabs a instance of the supplied type from the pool and returns it.
		 * If an existing instance cannot be found, then it simply returns a new instance.
		 * 
		 * IMPORTANT: Bear in mind that instances returned from this method aren't 'fresh'. For example,
		 * if a flasg.geom.Point instance was returned to the pool via returnInstance() - it's x and y
		 * properties are probably not their default zero, unlike they would be if created from scratch.
		 * @param type
		 * @return
		 */		
		static public function getInstance( type:Class ):*
		{
			var node:ObjNode = table[type];
			if ( !node )
			{
				return new type();
			}
			
			var L:int = node.length;
			var temp:ObjNode = table[type] = node.next;
			node.next = null;
			if ( temp )
			{
				temp.length = L-1;
			}
			
			var instance:Object = node.data;
			node.data = null;
			
			nodes[numNodes++] = node;
			
			return instance;
		}
		
		static public function getInstances( type:Class, count:int ):Array
		{
			const instances:Array = [];
			for ( var i:int = 0; i < count; i++ )
			{
				instances[i] = getInstance(type);
			}
			return instances;
		}
		
		/**
		 * Returns and instance to the pool, ready to be returned via getInstance() in the future.
		 * IMPORTANT: Make sure any instances returned via this method are completely disposed of.
		 * ie, don't leave any of their properties pointing to other instances.
		 * @param instance
		 * 
		 */		
		static public function returnInstance( instance:Object, type:Class = null ):void
		{
			if ( !type ) type = IntrospectionUtil.getType(instance);
			var node:ObjNode = table[type];
			if ( !node )
			{
				table[type] = node = getNode();
				node.length = 1;
				node.data = instance;
			}
			else
			{
				if ( node.length > maxSize ) return;
				var newNode:ObjNode = getNode();
				newNode.data = instance;
				newNode.next = node;
				newNode.length = node.length+1;
				table[type] = newNode;
			}
		}
		
		static public function returnInstances( instances:Array, allSameType:Boolean = false ):void
		{
			if ( instances.length == 0 ) return;
			if ( allSameType )
			{
				var type:Class = IntrospectionUtil.getType(instances[0]);
			}
			for each ( var instance:Object in instances )
			{
				returnInstance(instance, type);
			}
		}
		
		static private function getNode():ObjNode
		{
			if ( numNodes == 0 )
			{
				return new ObjNode();
			}
			return nodes[--numNodes];
		}
	}
}

internal class ObjNode
{
	public var next:ObjNode;
	
	public var data:*;
	public var length:int = 0;
}