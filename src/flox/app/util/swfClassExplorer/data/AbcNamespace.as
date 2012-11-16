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
	public class AbcNamespace {
		public var prefix:String;
		public var uri:String;
		
		public function AbcNamespace(uri:String, prefix:String = "") {
			this.uri = uri;
			this.prefix = prefix;
		}
		
	}
	
}