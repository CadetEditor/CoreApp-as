package flox.app.resources
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import flox.app.entities.URI;
	
	public class ExternalXMLResource extends AbstractExternalResource
	{
		private var xml				:XML;
		
		public function ExternalXMLResource(id:String, uri:URI)
		{
			super(id, uri);
			type = XML;
		}
		
		override public function unload():void
		{
			if ( isLoaded )
			{
				xml = null;
				//loader.unload();
				//bitmapData.dispose();
			}
			super.unload();
		}
		
		override protected function parseBytes(bytes:ByteArray):void
		{
			xml = XML( bytes.readUTFBytes( bytes.length ) );
			isLoading = false;
			isLoaded = true;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		override public function getInstance():Object
		{
			return xml;
		}
	}
}