// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.util.swfClassExplorer.data
{
	public class Traits {
		public var name:AbcQName;
		public var baseName:AbcQName;
		public var flags:uint;
		public var interfaces:Array;
		
		public function toString():String
		{
            return name.toString();
        }
	}
}