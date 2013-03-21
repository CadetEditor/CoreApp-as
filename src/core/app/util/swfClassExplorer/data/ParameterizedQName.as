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
	public class ParameterizedQName extends AbcQName {
		private var parameters:Array;
		
		public function ParameterizedQName(name:AbcQName, parameters:Array) {
			super(name.localName);
			this.parameters = parameters;
		}
		
		override public function toString():String {
			if (parameters.length == 0) return super.toString() + " []";
			var s:String = super.toString() + " [";
			for each(var name:QName in parameters) s += name.toString() + ", ";
			return s.substr(0, s.length - 2) + "]";
		}
	}
}