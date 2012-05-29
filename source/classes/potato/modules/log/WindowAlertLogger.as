package potato.modules.log
{

	/**
	 * A logger that shows the message in a window alert. It sucks. Just for kicks.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class WindowAlertLogger extends ExternalLogger {

		/**
		 *	@constructor
		 */
		public function WindowAlertLogger() {
			super("window.alert");
		}

		/**
		 * @inheritDoc
		 */
		override public function output(...msg):void {
			super.output.apply(this, [ msg.join(" ") ]);
		}
	}
}

