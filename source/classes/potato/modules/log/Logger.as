package potato.modules.log
{

	/**
	 * Base class to perform log in Potato.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class Logger {

		/**
		 *	The flags indicating the types of log messages.
		 */
		public static const LOG:uint		= 1<<0;
		public static const WARNING:uint	= 1<<1;
		public static const ERROR:uint		= 1<<2;

		/**
		 *	The logger object that is invoked by the log() function. By default, it's a TraceLogger. In other words,
		 *	calls to log() send the message to Flash's trace output, unless the user defines another logger.
		 */
		public static var defaultLogger:Logger;

		/**
		 *	The flags indicating which types of log messages should be issued. By default, all three kinds of
		 *	log messages are issued.
		 */
		public static var filterFlags:uint = LOG | WARNING | ERROR;

		/**
		 *	Indicates if each type of log message should show the call stack with it. By default, only error messages
		 *	show the stack trace.
		 */
		public static var callStackFlags:uint = ERROR;
		
		/**
		* List of all messages
		*/
		public var history:Array=[];

		/**
		 *	@constructor
		 */
		public function Logger() {
			super();
		}

		/**
		 *	Send a normal message to the log.
		 */
		public function log(...msg):void {
			// If no log messages should be issued, nothing is made
			if (!(filterFlags & LOG)) {
				return;
			}

			// If the call stack should be added, adds it
			if (callStackFlags & LOG) {
				msg.push(callStack);
			}
			
			//History
			history.push(msg);

			// Sends the message to the output
			output.apply(this, msg);
		}

		/**
		 *	Send a warning message to the log.
		 */
		public function logWarning(...msg):void {
			// If no warning messages should be issued, nothing is made
			if (!(filterFlags & WARNING)) {
				return;
			}

			// If the call stack should be added, adds it
			if (callStackFlags & WARNING) {
				msg.push(callStack);
			}

			// Adds a [WARNING] message at the beginning
			msg.splice(0, 0, "[WARNING]");
			
			//History
			history.push(msg);

			// Sends the message to the output
			output.apply(this, msg);
		}

		/**
		 *	Send an error message to the log.
		 */
		public function logError(...msg):void {
			// If no error messages should be issued, nothing is made
			if (!(filterFlags & ERROR)) {
				return;
			}

			// If the call stack should be added, adds it
			if (callStackFlags & ERROR) {
				msg.push(callStack);
			}

			// Adds a [ERROR] message at the beginning
			msg.splice(0, 0, "[ERROR]");
			
			//History
			history.push(msg);

			// Sends the message to the output
			output.apply(this, msg);
		}

		/**
		 *	After formatting, sends a message to the logger's output. Since each logger has a different output, this
		 *	method must be overriden.
		 */
		public function output(...msg):void {
			
		}

		/**
		 *	Returns the call stack.
		 *	@protected
		 */
		protected static function get callStack():String {
			var stack:String;

			stack = new Error().getStackTrace();
			if (stack) {
				// Removes the lines of the stack that doesn't concern the user
				stack = stack.replace(/^(.*?[\n\r]{1,2}){5}/, "");
			}
			else {
				stack = "[CALL STACK ONLY AVAILABLE IN DEBUG PLAYER]";
			}

			return stack;
		}
	}
}

