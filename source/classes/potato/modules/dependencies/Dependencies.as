package potato.modules.dependencies
{
  
  import flash.display.BitmapData;	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.core.LoaderCore;
	
	import potato.core.config.Config;
	import potato.modules.log.log;
	import flash.net.NetStream;
	import flash.display.MovieClip;

	/**
	 * Implements IDependencies with GreenSock's LoaderMax.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França, Lucas Dupin
	 * @since  10.08.2010
	 */
	public class Dependencies extends EventDispatcher implements IDependencies
	{
	  /** @private */
		protected var _queue:LoaderMax;
		
		/** @private flag */
		protected var _error:Boolean;
		
		/**
		 * @param config An optional configuration object describing items to load.
		 * @constructor
		 */
		public function Dependencies(config:Config = null)
		{
			LoaderMax.activate([ImageLoader, DataLoader, SWFLoader, XMLLoader]);
			
			// Create a new LoaderMax instance (an unique name is automatically assigned)
			_queue = new LoaderMax({onProgress:onLoaderProgress, onComplete:onLoaderComplete, onError:onLoaderError});
			
			// Populate the loader
			if (config)
				inject(config);
		}
		
		public function onLoaderProgress(e:LoaderEvent):void
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, e.target.bytesLoaded, e.target.bytesTotal));
		}
		
		public function onLoaderComplete(e:LoaderEvent):void
		{
		  if(!_error)
			  dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function onLoaderError(e:LoaderEvent):void
		{
			log("Dependencies::onLoaderError()");
			_error = true;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR))
		}
		
		/**
		 * Merges new items into the loading queue.
		 * 
		 * @param config A configuration object containing items to be merged.
		 */
		public function inject(config:Config):void
		{
			var keys:Array = config.keys;
			
			for each (var key:String in keys)
			{
				// Dependency item parameters (e.g. id, type, domain, etc)
				var params:Object = {};
				
				// Get the id
				if (config.hasProperty(key, "id"))
					params.name = config.getProperty(key, "id");
				
				// Get the type
				if (config.hasProperty(key, "type"))
					params.type = config.getProperty(key, "type");
				
				// Add additional keys from config
				mergeProperties(params, config.configForKey(key), ["id", "type", "domain", "url"]);
				
				// All a loader item really needs is an URL
				if (!config.hasProperty(key, "url"))
					throw new Error("[Dependencies] " + key + " has no 'url'");
				 
				var url:String = config.getProperty(key, "url")
				
				// Add item to queue
				this.addItem(url, params);
			}
		}
		
		/**
		 * Merges properties of an object and a configuration. Ignores some keys if necessary.
		 * 
		 * @param obj Object 
		 * @param config Config 
		 * @param ignoreKeys Array An Array containing keys to be ignored from the merge.
		 * 
		 * @private
		 */
		protected function mergeProperties(obj:Object, config:Config, ignoreKeys:Array):void
		{			
			var keys:Array = config.keys;
			
			for each(var ignoredKey:String in ignoreKeys)
			{
				var pos:int = keys.indexOf(ignoredKey);
				if(pos != -1){
					keys.splice(pos, 1);
				}
				
			}
			
			for each(var key:String in keys)
			{
				if(!obj.hasOwnProperty(key))
				{
					obj[key] = config.getProperty(key);
				}
			}
		}
		
		/**
		 * Adds a new item to the loading queue.
		 * 
		 * @param url * The item's URL.
		 * @param props [optional] Properties object for LoaderMax's item loader (useful!).
		 */
		public function addItem(url : *, props : Object= null ):void
		{
			var itemLoader:LoaderCore;
			var ext:String = url.substr(url.lastIndexOf(".") + 1);
			props ||= {};
			
			// Set default LoaderContext for SWFs in the same domain.
			if(ext == "swf" && !props.hasOwnProperty("context"))
			{
				props.context = new LoaderContext(false, ApplicationDomain.currentDomain);
			}
			
			// Create correct type of loader from the given URL.
			var dataExtensions:Array = ["yaml", "json"];
			if (props.type == 'data' || dataExtensions.indexOf(ext) != -1) {
				itemLoader = new DataLoader(url, props);
			}
			else if (props.type == 'xml') {
			  itemLoader = new XMLLoader(url, props);
			}	else {
				itemLoader = LoaderMax.parse(url, props);
			}
			_queue.append(itemLoader);
		}
		
		/**
		 * Starts loading the queued items.
		 */
		public function load():void
		{
		  _error = false;
			if(_queue.numChildren > 0){
				_queue.load();
			}
			else{
				dispatchEvent(new Event(Event.COMPLETE));
			}		
		}
		
		//---------------------------------------
		// IDEPENDENCIES IMPLEMENTATION
		//---------------------------------------
		
		public function getBitmap(key:String):Bitmap
		{
			return _queue.getContent(key).rawContent as Bitmap;
		}
		
		public function getBitmapData(key:String):BitmapData
		{
			return _queue.getContent(key).rawContent.bitmapData;
		}
		
		public function getByteArray(key:String):ByteArray
		{
		  return _queue.getContent(key).rawContent as ByteArray;
		}
		
		public function getContent(key:String):*
		{
			return _queue.getContent(key);
		}
		
		public function getDisplayObject(key:String):DisplayObject
		{
		  return _queue.getContent(key).content;
		}
		
		public function getLoader(key:String):Loader
		{
		  return _queue.getContent(key).rawContent as Loader;
		}
		
		public function getMovieClip(key:String):MovieClip
		{
		  return _queue.getContent(key).rawContent as MovieClip;
		}
		
		public function getSound(key:String):Sound
		{
		  return _queue.getContent(key).content;
		}
		
		public function getString(key:String):String
		{
		  return _queue.getContent(key).rawContent as String;
		}
		
		public function getXML(key:String):XML
		{
			return _queue.getContent(key);
		}
		
		public function getVideo(key:String):*
		{
			return _queue.getLoader(key);
		}
		
		/**
		 * IDisposable implementation
		 * @private
		 */
		public function dispose():void
		{
			// TODO verify if flushContent == true is interfering with projects (removing DisplayObjects or not) 
			_queue.dispose(true);
			_queue = null;
		}
	}

}