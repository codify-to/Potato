package potato.modules.log
{

	/**
	 * A logger that send the message to Flash's trace output.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class TraceLogger extends Logger {

		/**
		 *	@constructor
		 */
		public function TraceLogger() {
			super();
		}

		/**
		 * @inheritDoc
		 */
		override public function output(...msg):void {
			trace.apply(null, msg);
		}
	}
}

