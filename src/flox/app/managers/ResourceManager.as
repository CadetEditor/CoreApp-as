// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import flox.app.FloxApp;
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.serialization.ResourceSerializerPlugin;
	import flox.app.entities.URI;
	import flox.app.events.ResourceManagerEvent;
	import flox.app.resources.IExternalResource;
	import flox.app.resources.IFactoryResource;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;

	[Event( type="flox.app.events.ResourceManagerEvent", name="resourceAdded" )]

	public class ResourceManager extends EventDispatcher
	{
		private var fileSystemProvider		:IFileSystemProvider;
		private var resourceTable			:Object;
		private var allResources			:Vector.<IResource>;
		private var factoryInstanceTable	:Dictionary;
		private var bindingsByResourceID	:Object;
		private var bindingsByHost			:Dictionary;
		
		public function ResourceManager( fileSystemProvider:IFileSystemProvider = null )
		{
			this.fileSystemProvider = fileSystemProvider;
			resourceTable = {};
			allResources = new Vector.<IResource>();
			
			factoryInstanceTable = new Dictionary(true);
			
			bindingsByResourceID = {};
			bindingsByHost = new Dictionary(true);
		}
				
		public function dispose():void
		{
			fileSystemProvider = null;
			resourceTable = null;
			allResources = null;
			
			factoryInstanceTable = null;
			
			bindingsByResourceID = null;
			bindingsByHost = null;
		}
		
		public function addResource( resource:IResource ):void
		{
			resourceTable[resource.getID()] = resource;
			
			if( resource is IExternalResource )
			{
				IExternalResource( resource ).setFileSystemProvider(fileSystemProvider);
			}
			else if ( resource is IFactoryResource )
			{
				// TODO JP Do we really need to be able to get a factory back from a resource?
				//factoryInstanceTable[IFactoryResource(resource).getInstance()] = resource;
			}
			
			allResources.push(resource);
			
			var bindingsForThisResourceID:Vector.<ResourceBinding> = bindingsByResourceID[resource.getID()];
			if ( bindingsForThisResourceID )
			{
				for each ( var binding:ResourceBinding in bindingsForThisResourceID )
				{
					if ( resource is IExternalResource )
					{
						var externalResource:IExternalResource = IExternalResource(resource);
						if ( externalResource.getIsLoaded() )
						{
							binding.host[binding.property] = externalResource.getInstance();
							return;
						}
						
						if ( externalResource.getIsLoading() == false )
						{
							externalResource.addEventListener(Event.COMPLETE, loadResourceCompleteHandler);
							externalResource.load();
						}
					}
					else if ( resource is IFactoryResource )
					{
						binding.host[binding.property] = IFactoryResource(resource).getInstance();
					}
				}
			}
			
			
			
			dispatchEvent( new ResourceManagerEvent( ResourceManagerEvent.RESOURCE_ADDED, resource ) );
		}
		
		public function removeResource( resource:IResource, removeBindings:Boolean = true ):void
		{
			var index:int = allResources.indexOf(resource);
			if ( index == -1 )
			{
				throw( new Error( "Resource has not been added" ) );
				return;
			}
			
			if ( resource is IFactoryResource )
			{
				delete factoryInstanceTable[IFactoryResource(resource).getInstance()];
			}
			
			resourceTable[resource.getID()] = null;
			allResources.splice(index,1);
			
			var bindingsForThisResourceID:Vector.<ResourceBinding> = bindingsByResourceID[resource.getID()];
			var binding:ResourceBinding;
			if ( removeBindings )
			{
				while ( bindingsForThisResourceID.length > 0 )
				{
					binding = bindingsForThisResourceID[0];
					unbindResource( binding.host, binding.property );
				}
			}
			else
			{
				// Simply null any properties bound to this resource. Binding remains.
				for each ( binding in bindingsForThisResourceID )
				{
					binding.host[binding.property] = null;
				}
			}
			
			if ( resource is IExternalResource )
			{
				IExternalResource(resource).unload();
			}
		}
		
		public function getResourcesByURI(uri:URI):Vector.<IResource>
		{
			var output:Vector.<IResource> = new Vector.<IResource>();
			for each ( var resource:IResource in allResources )
			{
				if ( resource is IExternalResource ) {
					var resourceURI:URI = IExternalResource(resource).getUri();
					var projectAssetsPath:String = uri.path;
					//TODO: currently only works for nesting one level deep //WHY GET PARENT..?
					//var resourceAssetsPath:String = resourceURI.getParentURI().path;
					var resourceAssetsPath:String = resourceURI.path;
					if ( projectAssetsPath == resourceAssetsPath ) {
						output.push( resource );
					}
					//trace("projectAssetsPath "+projectAssetsPath+" resourceAssetsPath "+resourceAssetsPath);
				}
				
			}
			return output;
		}
		
		public function getAllResources():Vector.<IResource>
		{
			return allResources;
		}
		
		public function getResourceByID( id:String ):IResource
		{
			return resourceTable[id];
		}
		
		public function getResourcesOfType( type:Class ):Vector.<IResource>
		{
			var output:Vector.<IResource> = new Vector.<IResource>();
			for each ( var resource:IResource in allResources )
			{
				if ( IntrospectionUtil.isRelatedTo(resource, type) )
				{
					output.push( resource );
				}
			}
			return output;
		}
		
		public function getFactoriesForType( type:Class ):Vector.<IFactoryResource>
		{
			var output:Vector.<IFactoryResource> = new Vector.<IFactoryResource>();
			for each ( var resource:IResource in allResources )
			{
				var resourceFactory:IFactoryResource = resource as IFactoryResource;
				if ( resourceFactory == null ) continue;
				if ( IntrospectionUtil.isRelatedTo(resourceFactory.getInstanceType(), type) )
				{
					output.push( resourceFactory );
				}
			}
			return output;
		}
		
		/////////////////////////////////////////
		// Binding functions
		/////////////////////////////////////////
		
		public function bindResource( resourceID:String, host:Object, property:String ):void
		{
			var resource:IResource = getResourceByID(resourceID);
			
			if ( resource != null && resource is IFactoryResource == false )
			{
				throw( new Error( "Resource with this ID is not an IFactoryResource" ) );
				return;
			}
			
			unbindResource( host, property );
			
			var resourceBinding:ResourceBinding = new ResourceBinding( resourceID, host, property );
			
			var bindingsForThisResourceID:Vector.<ResourceBinding> = bindingsByResourceID[resourceID];
			if ( bindingsForThisResourceID == null )
			{
				bindingsForThisResourceID = bindingsByResourceID[resourceID] = new Vector.<ResourceBinding>();
			}
			bindingsForThisResourceID.push( resourceBinding );
			
			var bindingsForThisHost:Vector.<ResourceBinding> = bindingsByHost[host];
			if ( bindingsForThisHost == null )
			{
				bindingsForThisHost = bindingsByHost[host] = new Vector.<ResourceBinding>();
			}
			bindingsForThisHost.push( resourceBinding );
			
			resourceBinding.bindingsForThisHost = bindingsForThisHost;
			resourceBinding.bindingsForThisResourceID = bindingsForThisResourceID;
			
			if ( resource == null )
			{
				host[property] = null;
				return;
			}
			
			if ( resource is IExternalResource )
			{
				var externalResource:IExternalResource = IExternalResource(resource);
				if ( externalResource.getIsLoaded() )
				{
					host[property] = externalResource.getInstance();
					return;
				}
				
				if ( externalResource.getIsLoading() == false )
				{
					externalResource.addEventListener(Event.COMPLETE, loadResourceCompleteHandler);
					externalResource.load();
				}
			}
			else if ( resource is IFactoryResource )
			{
				host[property] = IFactoryResource(resource).getInstance();
			}
		}
		
		public function unbindResource( host:Object, property:String ):void
		{
			var bindingsForThisHost:Vector.<ResourceBinding> = bindingsByHost[host];
			if ( bindingsForThisHost == null ) return;
			
			var binding:ResourceBinding;
			for ( var i:int = 0; i < bindingsForThisHost.length; i++ )
			{
				var currentBinding:ResourceBinding = bindingsForThisHost[i];
				if ( currentBinding.property == property )
				{
					binding = currentBinding;
					break;
				}
			}
			
			if ( binding == null ) return;
			
			binding.bindingsForThisHost.splice( binding.bindingsForThisHost.indexOf( binding ), 1 );
			if ( binding.bindingsForThisHost.length == 0 )
			{
				delete bindingsByHost[host];
			}
			
			binding.bindingsForThisResourceID.splice( binding.bindingsForThisResourceID.indexOf( binding ), 1 );
			if ( binding.bindingsForThisResourceID.length == 0 )
			{
				bindingsByResourceID[binding.resourceID] = null;
			}
			
			host[property] = null;
		}
		
		public function getResourceIDForBinding( host:Object, property:String ):String
		{
			var bindingsForThisHost:Vector.<ResourceBinding> = bindingsByHost[host];
			if ( bindingsForThisHost == null ) return null;
			
			for each ( var binding:ResourceBinding in bindingsForThisHost )
			{
				if ( binding.property == property )
				{
					return binding.resourceID;
				}
			}
			return null;
		}
		
		public function getFactoryForInstance( instance:Object ):IFactoryResource
		{
			return factoryInstanceTable[instance];
		}
		
		///////////////////////////////////////////////////
		// Private
		///////////////////////////////////////////////////
		
		private function loadResourceCompleteHandler( event:Event ):void
		{
			var externalResource:IExternalResource = IExternalResource(event.target);
			
			factoryInstanceTable[externalResource.getInstance()] = externalResource;
			
			var resourceBindings:Vector.<ResourceBinding> = bindingsByResourceID[externalResource.getID()];
			for each ( var resourceBinding:ResourceBinding in resourceBindings )
			{
				resourceBinding.host[resourceBinding.property] = externalResource.getInstance();
			}
		}
	}
}

internal class ResourceBinding
{
	public var resourceID	:String;
	public var host			:Object;
	public var property		:String;
	
	public var bindingsForThisResourceID	:Vector.<ResourceBinding>;
	public var bindingsForThisHost			:Vector.<ResourceBinding>;
	
	public function ResourceBinding( resourceID:String, host:Object, property:String )
	{
		this.resourceID = resourceID;
		this.host = host;
		this.property = property;
	}
}