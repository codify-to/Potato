package potato.modules.dependencies
{
  import flash.events.IEventDispatcher;
  import flash.display.Bitmap;
  import flash.display.MovieClip;
  import flash.display.BitmapData;
  import flash.display.DisplayObject;
  import flash.display.Loader;
  import flash.display.Loader;
  import flash.media.Sound;
  import flash.utils.ByteArray;
  import flash.utils.ByteArray;
  
	import potato.core.IDisposable;
	import potato.core.config.Config;
  
	public interface IDependencies extends IEventDispatcher, IDisposable
	{
		
		function inject(config:Config):void;
		
		function addItem(url:*, props:Object = null):void;
		
		/**
		 * Start loading the dependencies.
		 * Dispatches <code>Event.COMPLETE</code> when done.
		 */
		function load() : void;
		
		function getBitmap(key:String):Bitmap;
		function getBitmapData(key:String):BitmapData;
    function getByteArray(key:String):ByteArray;
		function getContent(key:String):*;
		function getDisplayObject(key:String):DisplayObject;
    function getLoader(key:String):Loader;
		function getSound(key:String):Sound;
		function getString(key:String):String;
    function getXML(key:String):XML;
    function getVideo(key:String):*;
    function getMovieClip(key:String):MovieClip;
	}

}

