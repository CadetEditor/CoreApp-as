// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.managers
{
	public class DependencyNode
	{
		[Serializable]
		public var object	:Object
		
		// List of objects that depend on this object
		[Serializable]
		public var dependants	:Array
		
		// List of objects that this object depends on
		[Serializable]
		public var dependencies	:Array
		
		public function DependencyNode( object:Object = null )
		{
			this.object = object;
			dependants = new Array();
			dependencies = new Array();
		}
	}
}