package potato.modules.media.video
{
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.interfaces.IStream;

	/**
	 * @eventType potato.modules.media.MediaEvent.LOAD_START
	 */
	[Event(name="load_start" , type="flash.events.Event")]
	
	/**
	* @eventType potato.modules.media.MediaEvent.LOAD_PROGRESS
	*/
	[Event(name="load_progress" , type="flash.events.Event")]
	
	/**
	* @eventType potato.modules.media.MediaEvent.LOAD_COMPLETE
	*/
	[Event(name="load_complete" , type="flash.events.Event")]
	
	/**
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
	 * VideoStream is an extension of NetStream, with some improves. 
	 * 
	 * <p></p>
	 * 
	 * @example The basic usage of a VideoStream object:
	 * 
	 * <listing version="3.0">
	 * var stream:VideoStream = new VideoStream();
	 * stream.addEventListener(MediaEvent.LOAD_START, loadStartHandler);
	 * stream.addEventListener(MediaEvent.LOAD_PROGRESS, loadProgressHandler);
	 * stream.addEventListener(MediaEvent.LOAD_COMPLETE, loadCompleteHandler);
	 * stream.addEventListener(MediaEvent.METADATA_LOADED, metadataLoadHandler);
	 * stream.load("someVideo.flv");
	 * </listing>
	 * 
	 */  
	public class VideoStream extends NetStream implements IStream
	{
		/**
		 * The current netStatus ocurrency.
		*/
		protected var _netStatus:String;
		
		/**
		 * The last metaData loaded.
		*/
		protected var _metaData:Object;
		
		/**
		 * The current url loaded.
		*/
		protected var _url:String;
		
		private var currentBytesLoaded:Number;
		private var interval:uint;
		private var listenerTarget:Sprite;
		
		/**
		* Construtor.
		*/        
		public function VideoStream()
		{
			var nc:NetConnection = new NetConnection();
			nc.connect(null);  
			super(nc);
			listenerTarget = new Sprite();
		}

		/**
		* Starts the video load, and don't play it automatically. If you need it, call <code>play</code> after that.
		*
		* @param url The url of video that will be loaded.
		* @see close
		*/ 
		public function load(url:String, bufferTime:Number = 1000, checkPolicyFile:Boolean = false):void
		{
			close();
			_url = url;
			client = {onMetaData:metaDataLoadHandler}; 
			play(url);
			pause();
			seek(0);
			dispatchEvent(new Event(MediaEvent.LOAD_START));
			addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			startProgressCheck();
		}
		
		/**
		* Stops the current load, and clear the netStream.
		*
		* @see load
		*/
		override public function close():void
		{
			stopProgressCheck();
			currentBytesLoaded = -1;
			_metaData = null;
			super.close();
			_url = null;
		}
		
		/**
		* The current url requested for load.
		*
		* @see load
		*/
		public function get url():String
		{
			return _url;
		}
		
		/**
		* The progress ratio (bytesLoaded/bytesTotal) of the load.
		*
		* @see load
		*/
		public function get loadRatio():Number
		{
			return bytesLoaded/bytesTotal;
		}
		
		/**
		* The metadata received in the load.
		*/
		public function get metaData():Object
		{
			return _metaData;
		}
		
		/**
		 * Holds the last netStatus ocurrency.
		*/
		public function get netStatus():String
		{
			return _netStatus;
		}
		
		/**
		 * Handles the metadata load, and make its awlays avaliable.
		 * 
		 * @see metaData  
		*/
		protected function metaDataLoadHandler(meta:*):void
		{
			_metaData = meta;
			dispatchEvent(new Event(MediaEvent.METADATA_LOADED));
		}
		
		/**
		 * Handles the netStatus and holds the last ocurrency.
		 * 
		 * @see netStatus
		*/
		protected function netStatusHandler(e:NetStatusEvent):void
		{
			_netStatus = e.info.code;
			switch (_netStatus) {
				case "NetStream.Play.StreamNotFound" :
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Load failed. Stream not found."));
				break;
			}
			removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
	
		/**
		 * Starts the ENTER_FRAME that will check the bytesLoaded, dispatch the progressHandler and check if the load has finished.
		 * 
		 * @see stopProgressCheck
		*/
		protected function startProgressCheck():void
		{
			if (listenerTarget.hasEventListener(Event.ENTER_FRAME)) return;
			listenerTarget.addEventListener(Event.ENTER_FRAME, progressCheck, false, 0, true);
		}
		
		/**
		 * Stops the timer that checks the load progress.
		 * 
		 * @see startProgressCheck
		*/
		protected function stopProgressCheck():void
		{
			listenerTarget.removeEventListener(Event.ENTER_FRAME, progressCheck);
		}
		
		/**
		 * The callback of the ENTER_FRAME initialized in startProgressCheck.
		 * 
		 * @see startProgressCheck
		 * @see stopProgressCheck
		*/
		protected function progressCheck(e:Event):void
		{
			if (currentBytesLoaded == bytesLoaded) return;
			
			currentBytesLoaded = bytesLoaded;
			dispatchEvent(new Event(MediaEvent.LOAD_PROGRESS));
			
			if (bytesLoaded == bytesTotal && _netStatus != "NetStream.Play.StreamNotFound") {
				stopProgressCheck();
				dispatchEvent(new Event(MediaEvent.LOAD_COMPLETE));
			}
		}
		
	}
}