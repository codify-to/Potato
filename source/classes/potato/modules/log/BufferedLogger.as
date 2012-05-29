package potato.modules.log
{
import flash.net.FileReference;

	/**
	 * A logger that stores all the logged messages and allows the user to save them as a text file.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class BufferedLogger extends Logger {

		/**
		 *	The buffer that olds all the logged messages.
		 *	@protected
		 */
		protected static var _buffer:Array = [];

		/**
		 *	Indicates if a time stamp should be added to each logged message.
		 *	@protected
		 */
		protected var _timeStamp:Boolean;

		/**
		 *	Builds a buffered logger.
		 *	@param	timeStamp	 Indicates if a time stamp should be added to each logged message.
		 *	@constructor
		 */
		public function BufferedLogger(timeStamp:Boolean=true) {
			super();

			_timeStamp = timeStamp;
		}

		/**
		 * @inheritDoc
		 */
		override public function output(...msg):void {
			// If a timestamp must be added, do it now
			if (_timeStamp) {
				_buffer.push(new Date());
			}

			// Adds the logged message
			var i:int;

			for (i=0; i<msg.length; i++) {
				_buffer.push(msg[i]);
			}

			// Adds a blank line
			_buffer.push("");
		}

		/**
		 *	Returns all the logged messages as a string.
		 */
		public static function get logContent():String {
			return _buffer.join("\n");
		}

		/**
		 *	Prompts the user to save the logged content in a text file.
		 */
		public static function save():void {
			new FileReference().save(logContent, "log.txt");
		}

		/**
		 *	Clears all the buffered messages.
		 */
		public static function clear():void {
			_buffer = [];
		}
	}
}