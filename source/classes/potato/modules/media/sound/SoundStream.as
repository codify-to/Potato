package potato.modules.media.sound
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.interfaces.IStream;

	/**
	* Dispatched when the load operation starts.
	*
	* <p>This dispatch doesn't matter if the url is valid or not, so after this event can ocurrs an error event.</p>  
	*
	* @eventType potato.modules.media.MediaEvent.LOAD_START
	*/
	[Event(name="load_start" , type="flash.events.Event")]
	
	/**
	* Dispatched when the bytesLoaded changes. 
	*
	* @eventType potato.modules.media.MediaEvent.LOAD_PROGRESS
	*/
	[Event(name="load_progress" , type="flash.events.Event")]
	
	/**
	* Dispatched when the load operation finishes.
	* 
	* @eventType potato.modules.media.MediaEvent.LOAD_COMPLETE
	*/
	[Event(name="load_complete" , type="flash.events.Event")]
	
	/**
	* Dispatched when the ID3 is available.
	* 
	* @eventType potato.modules.media.MediaEvent.METADATA_LOADED
	*/
	[Event(name="metadata_loaded" , type="flash.events.Event")]
	
	/**
	* Dispatched when an error occurs. 
	* 
	* @eventType flash.events.ErrorEvent.ERROR
	*/
	[Event(name="error" , type="flash.events.ErrorEvent")]

	/**
	 * SoundStream is a composite of Sound that provide some more useful features and event handlers. 
	 */
	public class SoundStream extends EventDispatcher implements IStream
	{
		/**
		 * The Sound instance used for load. 
		 */
		protected var _sound:Sound;
		/**
		 * The url loaded. 
		 */
		protected var _url:String;
		
		/**
		 * Construtor. 
		 */
		public function SoundStream()
		{
			super();
		}
		
		/**
		 * Starts the file load operation.
		 * 
		 * @param url The url of file that will be loaded. 
		 * @param bufferTime The number of milliseconds to preload a streaming sound into a buffer before the sound starts to stream.
     * @param checkPolicyFile Specifies whether Flash Player should try to download a URL policy file from the loaded sound's server before beginning to load the sound.
		 */
		public function load(url:String, bufferTime:Number = 1000, checkPolicyFile:Boolean = false):void
		{
			reset();
			_url = url;
			_sound.load(new URLRequest(url), new SoundLoaderContext(bufferTime, checkPolicyFile));
		}

		/**
		 * Current bytes already loaded.
		 */
		public function get bytesLoaded():uint
		{
			return _sound.bytesLoaded;
		}
		
		/**
		 * Total bytes of the file.
		 */
		public function get bytesTotal():uint
		{
			return _sound.bytesTotal;
		}
		
		/**
		 * The relative progress of load, from 0 to 1.
		 */
		public function get loadRatio():Number
		{
			return _sound.bytesLoaded/_sound.bytesTotal;
		}
		
		/**
		 * The Sound instance currently used for load.
		 */
		public function get sound():Sound
		{
			return _sound;
		}
		
		/**
		 * The current url loaded. 
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * Finishes the current load and clears the sound.
		 */
		public function close():void
		{
			if (_sound == null) return;
			try {_sound.close()} catch (e:*){};
			_sound.removeEventListener(Event.ID3, id3LoadHandler);
			_sound.removeEventListener(Event.OPEN, loadStartHandler);
			_sound.removeEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			_sound.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_sound = null;
		}
		
		/**
		 * Reset all properties and makes it ready for a new load.
		 */
		protected function reset():void
		{
			close();
			_sound = new Sound();
			_sound.addEventListener(Event.ID3, id3LoadHandler);
			_sound.addEventListener(Event.OPEN, loadStartHandler);
			_sound.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			_sound.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		/**
		 * Handles the load operation start. 
		 */
		protected function loadStartHandler(e:Event):void
		{
			dispatchEvent(new Event(MediaEvent.LOAD_START));
		}
		
		/**
		 * Handles the load development.
		 */
		protected function loadProgressHandler(e:ProgressEvent):void
		{
			dispatchEvent(new Event(MediaEvent.LOAD_PROGRESS));
		}
		
		/**
		 * Handles the load finish. 
		 */
		protected function loadCompleteHandler(e:Event):void
		{
			dispatchEvent(new Event(MediaEvent.LOAD_COMPLETE));
		}
		
		/**
		 * Handles any error that can occurs during loading.
		 */
		protected function errorHandler(e:Event):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Load failed. Stream not found."));
		}
		
		/**
		 * Handles the ID3 load, and dispatches the MediaEvent.METADATA_LOADED event. 
		 */
		protected function id3LoadHandler(e:Event):void
		{
			dispatchEvent(new Event(MediaEvent.METADATA_LOADED));
		}
		
	}
}