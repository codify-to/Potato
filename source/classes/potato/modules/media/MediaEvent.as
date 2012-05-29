package potato.modules.media
{
	/**
	 * The ids of the events dipatched by the media objects.
	 * 
	 * <p>MediaEvent cannot be instantiated. Only holds the ids that can be used with flash.events.Event.</p>
	 */
	public class MediaEvent
	{
		/**
		 * Dispatch when the playback starts from the position 0.
		 */
		public static const PLAYBACK_START:String = "playback_start";
		/**
		 * Dispatch while the playback progress.
		 */
		public static const PLAYBACK_PROGRESS:String = "playback_progress";
		/**
		 * Dispatch when the playback time equalizes the timeTotal.
		 */
		public static const PLAYBACK_COMPLETE:String = "playback_complete";
		
		
		/**
		 * Dispatch when the load operation is requested.
		 */
		public static const LOAD_START:String = "load_start";
		/**
		 * Dispatch when the bytesLoaded changes.
		 */
		public static const LOAD_PROGRESS:String = "load_progress";
		/**
		 * Dispatch when the bytesLoaded equalizes the bytesTotal.
		 */
		public static const LOAD_COMPLETE:String = "load_complete";
		/**
		 * Dispatch when the metaData (or ID3 in case of sounds) is available.
		 */
		public static const METADATA_LOADED:String = "metadata_loaded";
		
		/**
		 * Dispatch when the stream don't have the bytes needed by the playback.
		 */
		public static const BUFFER_EMPTY:String = "buffer_empty";
		/**
		 * Dispatch when the stream obtains the bytes needed by the playback.
		 */
		public static const BUFFER_FULL:String = "buffer_full";
		
		
		/**
		 * Dispatch when the media play.
		 */
		public static const PLAY:String = "play";
		/**
		 * Dispatch when the media pause.
		 */
		public static const PAUSE:String = "pause";
		/**
		 * Dispatch when the media stop.
		 */
		public static const STOP:String = "stop";
	}
}