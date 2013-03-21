// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.events
{
	import flash.events.Event;
	
	import core.app.resources.IResource;

	public class ResourceManagerEvent extends Event
	{
		public static const RESOURCE_ADDED		:String = "resourceAdded"
		
		private var _resource	:IResource;
		
		public function ResourceManagerEvent(type:String, resource:IResource)
		{
			super(type);
			_resource = resource;
		}
		
		override public function clone():Event
		{
			return new ResourceManagerEvent( type, _resource );
		}
		
		public function get resource():IResource { return _resource; }
	}
}