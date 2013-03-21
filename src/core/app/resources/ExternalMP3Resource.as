package core.app.resources
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.tags.TagDefineSound;
	import com.codeazur.as3swf.tags.TagDoABC;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFileAttributes;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import core.app.entities.URI;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.IClassBuilder;
	import org.as3commons.bytecode.emit.IPackageBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.io.AbcSerializer;
	
	public class ExternalMP3Resource extends AbstractExternalResource
	{
		private static const PACKAGENAME:String = "tmp";
		private static const CLASSNAME:String = "SoundClass";
		private static const QNAME:String = PACKAGENAME + "." + CLASSNAME;
		
		private var sound				:Sound;
		
		public function ExternalMP3Resource(id:String, uri:URI)
		{
			super(id, uri);
			type = Sound;
		}
		
		override public function unload():void
		{
			if ( isLoaded )
			{
				sound = null;
				//loader.unload();
				//bitmapData.dispose();
			}
			super.unload();
		}
		
		override protected function parseBytes(bytes:ByteArray):void
		{
			// Wrap the MP3 with a SWF
			var swf:ByteArray = createSWFFromMP3(bytes);
			// Load the SWF with Loader::loadBytes()
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			loader.loadBytes(swf,context);
		}
		
		protected function initHandler(e:Event):void {
			// Get the sound class definition
			var SoundClass:Class = LoaderInfo(e.currentTarget).applicationDomain.getDefinition(QNAME) as Class;
			// Instantiate the sound class
			sound = new SoundClass() as Sound;
			// Play the sound
			//sound.play();
			
			isLoading = false;
			isLoaded = true;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		// https://gist.github.com/218226
		protected function createSWFFromMP3(mp3:ByteArray):ByteArray
		{
			// Create an empty SWF
			// Defaults to v10, 550x400px, 50fps, one frame (works fine for us)
			var swf:SWF = new SWF();
			
			// Add FileAttributes tag
			// Defaults: as3 true, all other flags false (works fine for us)
			swf.tags.push(new TagFileAttributes());
			
			// Add DefineSound tag
			// The ID is 1, all other parameters are automatically
			// determined from the mp3 itself.
			swf.tags.push(TagDefineSound.createWithMP3(1, mp3));
			
			// Create and add DoABC tag
			// Contains the AS3 byte code for the class definition for the embedded sound:
			// package tmp {
			//    public dynamic class SoundClass extends flash.media.Sound {
			//    }
			// }
			var abcBuilder:IAbcBuilder = new AbcBuilder();
			var packageBuilder:IPackageBuilder = abcBuilder.definePackage(PACKAGENAME);
			var classBuilder:IClassBuilder = packageBuilder.defineClass(CLASSNAME, "flash.media.Sound");
			var abcFile:AbcFile = abcBuilder.build();
			var abcSerializer:AbcSerializer = new AbcSerializer();
			var abcBytes:ByteArray = abcSerializer.serializeAbcFile(abcFile);
			swf.tags.push(TagDoABC.create(abcBytes));
			
			// Add SymbolClass tag
			// Binds the sound class definition to the embedded sound
			var symbolClass:TagSymbolClass = new TagSymbolClass();
			symbolClass.symbols.push(SWFSymbol.create(1, QNAME));
			swf.tags.push(symbolClass);
			
			// Add ShowFrame tag
			swf.tags.push(new TagShowFrame());
			
			// Add End tag
			swf.tags.push(new TagEnd());
			
			// Publish the SWF
			var swfData:SWFData = new SWFData();
			swf.publish(swfData);
			
			return swfData;
		}		
		
		override public function getInstance():Object
		{
			return sound;
		}
	}
}