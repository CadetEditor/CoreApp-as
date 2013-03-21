// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.util.swfClassExplorer.data
{
	public class RecordHeader {
		public var tagCode:int;
		public var tagLength:int;
		
		public function RecordHeader(tag:int, length:int) {
			tagCode = tag;
			tagLength = length;
		}
		
	}
	
}