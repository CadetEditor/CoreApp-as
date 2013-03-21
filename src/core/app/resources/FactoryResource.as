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
	import core.app.resources.IFactoryResource;
	import core.app.util.IntrospectionUtil;

	public class FactoryResource implements IFactoryResource
	{
		protected var _type					:Class;
		protected var _icon					:Class;
		protected var _label				:String;
		protected var _constructorParams	:Array;
		
		public function FactoryResource( type:Class, label:String, icon:Class = null, constructorParams:Array = null )
		{
			_type = type;
			_label = label;
			_icon = icon;
			_constructorParams = constructorParams;
		}
		
		public function getLabel():String
		{
			return _label;
		}
		
		public function get icon():Class
		{
			return _icon;
		}
		
		// Implement IFactoryResource
		
		public function getID():String
		{
			return IntrospectionUtil.getClassName(_type);
		}
		
		public function getInstance():Object
		{
			if ( _constructorParams == null )
			{
				return new _type();
			}
			
			var p:Array = _constructorParams;
			// Eeeeeewwww! Yeah, I know. But no other way.
			switch (p.length)
			{
				case 0 : return new _type();
				case 1 : return new _type(p[0]);
				case 2 : return new _type(p[0], p[1]);
				case 3 : return new _type(p[0], p[1], p[2]);
				case 4 : return new _type(p[0], p[1], p[2], p[3]);
				case 5 : return new _type(p[0], p[1], p[2], p[3], p[4]);
				case 6 : return new _type(p[0], p[1], p[2], p[3], p[4], p[5]);
				case 7 : return new _type(p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
				case 8 : return new _type(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
				case 9 : return new _type(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
			}
			
			throw( new Error( "Urgh, too many constructor params" ) );
			return null;
		}
		
		public function getInstanceType():Class
		{
			return _type;
		}
	}
}