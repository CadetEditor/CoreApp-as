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
	public class MultiName extends AbcQName {
		public var nsset:Array;
		
		public function MultiName(nsset:Array, localName:String) {
			super(localName);
			this.nsset = nsset;
		}
	}
}