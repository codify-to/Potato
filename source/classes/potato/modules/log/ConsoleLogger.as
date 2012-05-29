package potato.modules.log
{

	/**
	 * A logger that sends the message to the browser's console.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class ConsoleLogger extends ExternalLogger {

		/**
		 *	@constructor
		 */
		public function ConsoleLogger() {
			super("console.log");
		}
	}
}

