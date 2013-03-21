// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.resources
{
	public class ExternalResourceParserFactory extends FactoryResource
	{
		private var _supportedExtensions	:Array;
		
		public function ExternalResourceParserFactory(type:Class, label:String, supportedExtensions:Array)
		{
			super(type, label);
			_supportedExtensions = supportedExtensions;
			for ( var i:int = 0; i < _supportedExtensions.length; i++ )
			{
				_supportedExtensions[i] = _supportedExtensions[i].toLowerCase();
			}
		}
		
		public function get supportedExtensions():Array
		{
			return _supportedExtensions.slice();
		}
	}
}