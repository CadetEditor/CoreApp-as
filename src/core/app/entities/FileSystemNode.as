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
	public class FileSystemNode extends TreeNode
	{
		private var _path			:String;
		private var _isPopulated	:Boolean;
		
		public function FileSystemNode()
		{
			
		}
	
		override public function set data( value:* ):void
		{
			path = value as String;
		}
		override public function get data():* { return path; }
		
		
		
		public function set path( value:String ):void
		{
			_path = value;
		}
		public function get path():String { return _path; }
		
		public function get filename():String
		{
			return uri.getFilename();
		}
		
		public function get extension():String
		{
			return uri.getExtension(true);
		}
		
		public function get uri():URI { return new URI(_path); }		
				
		public function set isPopulated(value:Boolean):void
		{
			_isPopulated = value;
		}
		public function get isPopulated():Boolean { return _isPopulated; }
		
		public function getChildWithPath( value:String, recursive:Boolean = false ):FileSystemNode
		{
			return getChildWithData( value, recursive ) as FileSystemNode;
		}
		
		
	}
}