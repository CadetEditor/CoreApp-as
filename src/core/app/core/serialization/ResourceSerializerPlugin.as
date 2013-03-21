// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.core.serialization
{
	import core.app.managers.ResourceManager;

	public class ResourceSerializerPlugin implements ISerializationPlugin
	{
		private var resourceManager	:ResourceManager;
		
		public function ResourceSerializerPlugin( resourceManager:ResourceManager )
		{
			this.resourceManager = resourceManager;
		}
		
		public function get id():String
		{
			return "resource";
		}
		
		public function serialize( task:SerializerTask ):XML
		{
			var value:* = task.value;
			
			var resourceID:String = resourceManager.getResourceIDForBinding( task.obj, task.propertyName );
			if ( resourceID == null )
			{
				trace("Warning : Cannot find resourceID for object - " + task.obj + ", with property - " + task.propertyName + ". Check that this property is only set via the ResourceManager.bindResource() method" );
				return null;
			}
			
			task.parentXML.@[task.propertyAlias] = resourceID;
			return null;
		}
		
		public function deserialize( task:DeserializeTask ):void
		{
			var resourceID:String = String(task.xml);
			resourceManager.bindResource( resourceID, task.parentTask.instance, task.name );
		}
		
		public function get allowNullValue():Boolean
		{
			return true;
		}
	}
}