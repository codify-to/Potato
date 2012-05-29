package potato.modules.media.video
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.MediaState;
	import potato.modules.media.interfaces.IAudio;
	import potato.modules.media.interfaces.IMedia;
	import potato.modules.media.interfaces.ITimeline;

	/**
	 * Dispatched when the playback starts, only if the playback was in time 0
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_START
	*/
	[Event(name="playback_start" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the playback progress, in an enterFrame.
	 *
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_PROGRESS
	*/
	[Event(name="playback_progress" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the playback finishes.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_COMPLETE
	*/
	[Event(name="playback_complete" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the video plays.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAY
	*/
	[Event(name="play" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the video pauses.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PAUSE
	*/
	[Event(name="pause" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the video stops.
	 * 
	 * @eventType potato.modules.media.MediaEvent.STOP
	*/
	[Event(name="stop" , type="flash.events.Event")]

	/**
	 * VideoDisplay is a Video holder, and has important missing features for video control in Flash.
	 * 
	 * <p>It receives a NetStream object previously started and give all the expected controls that the video must have, like play, stop, pause, sets the playback
	 * position by time, by ratio and dispatches all the events aways needed (see MediaEvent).</p>
	 * 
	 * <p>VideoDisplay also implements known interfaces in the potato.modules.media universe. So you can control the video playback the same way that you control the sound playback.</p>
	 */ 
	public class VideoDisplay extends Sprite implements IMedia, IAudio, ITimeline
	{
		protected var _netStream:NetStream;
		protected var _state:String;
		protected var _video:Video;
		protected var _timeTotal:Number;
		protected var _renderAsBitmap:Boolean;
		protected var _netStatus:String;
		
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;
		private var watchingPlayback:Boolean;
		
		/**
		* Construtor.
		*/   
		public function VideoDisplay()
		{
			super();
			_state = MediaState.STOPPED;
			_video = new Video();
			_renderAsBitmap = false;
			addChild(_video);
			_timeTotal = 1;
		}
		
		/**
		 * Starts the playback in the last position registered.
		 *
		 * <p>Only works if the playback was paused or stopped.</p>
		 * 
		 * @see pause
		 * @see stop 
		*/   
		public function play():void
		{
			if (_state == MediaState.PLAYING) return;
			_state = MediaState.PLAYING;
			_netStream.resume();
			startPlaybackCheck();
			dispatchEvent(new Event(MediaEvent.PLAY));
			if (_netStream.time < .1) dispatchEvent(new Event(MediaEvent.PLAYBACK_START));
		}
		
		/**
		 * Pauses the playback and allow play by the same point.
		 *
		 * <p>Works only if the playback is playing.</p>
		 * 
		 * @see play
		 * @see stop 
		*/   
		public function pause():void
		{
			if (_state != MediaState.PLAYING) return;
			_state = MediaState.PAUSED;
			_netStream.pause();
			stopPlaybacksCheck();
			dispatchEvent(new Event(MediaEvent.PAUSE));
		}
		
		/**
		 * Stops the playback and reset the time position to 0.
		 *
		 * <p>Works only if the playback is playing or paused.</p>
		 * 
		 * @see play
		 * @see stop 
		*/   
		public function stop():void
		{
			if (_state == MediaState.STOPPED) return;
			_state = MediaState.STOPPED;
			_netStream.pause();
			time = 0;  
			stopPlaybacksCheck();
			dispatchEvent(new Event(MediaEvent.STOP));
		}

		/**
		 * Destroy the instance and clear memory.
		*/   		
		public function dispose():void
		{
			_netStream.close();
			_netStream = null;
			renderAsBitmap = false;
			_video.clear();
			removeChild(_video);
			_video = null;
		}
		
		public function set volume(value:Number):void
		{
			var st:SoundTransform = _netStream.soundTransform;
			st.volume = value;
			_netStream.soundTransform = st; 
		}
		/**
		 * Sets the volume of video, ranging from 0 to 1.
		 * 
		 * @default 1
		*/   
		public function get volume():Number
		{
			return _netStream.soundTransform.volume;
		}
		
		public function set timeRatio(value:Number):void
		{
			time = _timeTotal*value;
		}
		/**
		 * The relative time position (0 to 1).
		 * 
		 * @see time 
		*/ 
		public function get timeRatio():Number
		{
			return _netStream.time/_timeTotal;
		}
		
		public function set time(value:Number):void
		{
			_netStream.seek(value);
		}
		/**
		 * The absolute time position, in seconds.
		 * 
		 * <p>It replaces the netSTream.seek method.</p>
		 * 
		 * @see totalTime
		 * @see timeRatio 
		*/ 
		public function get time():Number
		{
			return _netStream.time;	
		}	
		
		public function set timeTotal(value:Number):void
		{
			_timeTotal = value;
		}
		/**
		 * The total time of video, in seconds.
		 * 
		 * <p>Must be setted manually, because the value has provided by the current netStream.</p>
		 * 
		 * @see time 
		*/ 
		public function get timeTotal():Number
		{
			return _timeTotal;
		}
		
		public function set netStream(value:NetStream):void
		{
			if (_netStream != null) {
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			}
			
			_state = MediaState.STOPPED;
			_netStream = value;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_netStream.pause();
			_netStream.seek(0); 
			_video.clear();
			_video.attachNetStream(_netStream);
		}
		/**
		 * Instace of NetStream attached to this object that will be reproduced.
		 * 
		 * <p>Automatically stops the netStream and the playback when setted. Also clears the video instance and listen the NET_STATUS event.</p>
		 * 
		 * @see video 
		*/ 
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		/**
		 * The current state of this object.
		 * 
		 * <p>Indicates if it is playing, paused or stopped.</p>
		 * 
		 * @see potato.modules.media.MediaState 
		*/ 
		public function get state():String
		{
			return _state;
		}
		
		/**
		 * The instance of Video used by this object,
		 * 
		 * @see flash.media.Video 
		*/ 
		public function get video():Video
		{
			return _video;
		}
		
		public function set renderAsBitmap(value:Boolean):void
		{
			if (value == _renderAsBitmap) return;
			_renderAsBitmap = value;
			if (_renderAsBitmap) {
				bitmap = new Bitmap();
				addChild(bitmap);
				removeChild(video);
				updateBitmap();
				addEventListener(Event.ENTER_FRAME, updateBitmap);
			} else {
				addChild(video);
				removeEventListener(Event.ENTER_FRAME, updateBitmap);
				bitmapData.dispose();
				bitmapData = null;
				removeChild(bitmap);
				bitmap = null;
			}
		}
		/**
		 * Replaces the video by a bitmap that will be renderized as a video copy each frame.
		 * 
		 * <p>Works only if the bitmapdata of the video is accessible.</p>
		*/ 
		public function get renderAsBitmap():Boolean
		{
			return _renderAsBitmap;
		}
		
		/**
		 * The last netStatus occurrency.
		*/
		public function get netStatus():String
		{
			return _netStatus;
		}
		
		/**
		 * Updates the bitmap with the video current bitmap.
		 * 
		 * @see renderAsBitmap
		*/ 
		protected function updateBitmap(e:Event = null):void
		{
			bitmapData = new BitmapData(video.width, video.height, true, BitmapDataChannel.ALPHA);
			bitmapData.draw(video, video.transform.matrix);
			bitmap.bitmapData = bitmapData;     
		}  
		
		/**
		 * Handles the NET_STATUS event, and holds the last ocurrency.
		 * 
		 * @see netStatus
		*/ 
		protected function netStatusHandler(e:NetStatusEvent):void
		{
			_netStatus = e.info.code;
			switch (_netStatus)
		    {
		        case "NetStream.Play.Start" :
		        	
		        break;
		        
		        case "NetStream.Play.Stop" :
		        	stop();
		            dispatchEvent(new Event(MediaEvent.PLAYBACK_COMPLETE));
		        break;
		          
		        case "NetStream.Buffer.Empty" :
					dispatchEvent(new Event(MediaEvent.BUFFER_EMPTY));
		        break;
		        
		        case "NetStream.Buffer.Full" :
		        	dispatchEvent(new Event(MediaEvent.BUFFER_FULL));
		        break;
		        
		        case "NetStream.Buffer.Flush" :
		        break;
		    }
		}  
		
		/**
		 * Starts the playback check, that will dispatch the MediaEvent.PLAYBACK_PROGRESS.
		 * 
		 * @see playbackCheck
		 * @see stopPlaybacksCheck
		*/ 
		protected function startPlaybackCheck():void
		{
			if (watchingPlayback) return;
			watchingPlayback = true;
			addEventListener(Event.ENTER_FRAME, playbackCheck);
		}
		
		/**
		 * Stops the playback check.
		 * 
		 * @see playbackCheck
		 * @see startPlaybackCheck
		*/ 
		protected function stopPlaybacksCheck():void
		{
			if (!watchingPlayback) return;
			watchingPlayback = false;
			removeEventListener(Event.ENTER_FRAME, playbackCheck);
		}
		
		/**
		 * The playback check, that will dispatch the MediaEvent.PLAYBACK_PROGRESS if the buffer is full.
		 * 
		 * @see stopPlaybacksCheck
		 * @see startPlaybackCheck
		*/ 
		protected function playbackCheck(e:Event):void
		{
			if (_netStatus == "NetStream.Buffer.Flush" || _netStatus == "NetStream.Buffer.Full") dispatchEvent(new Event(MediaEvent.PLAYBACK_PROGRESS));
		}
		
	}
}