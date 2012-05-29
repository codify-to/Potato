package potato.modules.media.video
{
	import flash.events.Event;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.MediaState;

	/**
	 * VideoPlayback is an extension of VideoDisplay, with a VideoStream instance. 
	 * 
	 * <p>It gets together all the main funcionalities that a videoPlayer needs.</p>
	 * 
	 * @see potato.modules.media.VideoDisplay
	 * @see potato.modules.media.VideoStream
	 */  
	public class VideoPlayback extends VideoDisplay
	{
		/**
		 * Holds the instance of VideoStream.
		 */
		protected var _stream:VideoStream; 
		private var watchingPlayback:Boolean;
		
		public function VideoPlayback()
		{
			super();
			_stream = new VideoStream();
			_stream.addEventListener(MediaEvent.METADATA_LOADED, metaDataLoadHandler);
			_stream.bufferTime = 1
			netStream = stream;
			watchingPlayback = false;
		}
		
		/**
		 * Clears the current video and stream and starts the load of a new file.
		 * 
		 * @param url The url of the video that will be loaded.
		*/
		public function load(url:String):void
		{
			_video.clear();
			_stream.load(url);
			_state = MediaState.STOPPED;
		}
		
		/**
		 * The instance of VideoStream utilized.
		*/
		public function get stream():VideoStream
		{
			return _stream;
		}
		
		/**
		 * Destroy the instance and clears memory.
		 */
		override public function dispose():void
		{
			_stream.close();
			_stream.removeEventListener(MediaEvent.METADATA_LOADED, metaDataLoadHandler);
			_stream = null;
			super.dispose();
		}
		
		/**
		 * Handles the metaData load by videoStream instance. Configure the video dimensions and total time automatically.
		 * 
		 * <p>Sometimes the property <code>duration</code> of the metaData is not available. In this case, the timeTotal must be setted manually.</p>
		 */
		protected function metaDataLoadHandler(e:Event):void
		{
			_video.width = _stream.metaData.width;
			_video.height = _stream.metaData.height;
			timeTotal = _stream.metaData.duration;
		}
	}
}