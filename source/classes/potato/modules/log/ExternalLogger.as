package potato.modules.log
{
import flash.external.ExternalInterface;

	/**
	 * A logger that send the message to a JavaScript function.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class ExternalLogger extends Logger {

		/**
		 *	The name of the JS function to be called.
		 *	@protected
		 */
		protected var _functionName:String;

		/**
		 *	Builds a new JavaScript logger.
		 *	@param	functionName	 the name of the JS function to be called
		 *	@constructor
		 */
		public function ExternalLogger(functionName:String) {
			_functionName = functionName;
		}

		/**
		 * @inheritDoc
		 */
		override public function output(...msg):void {
			var newMsg:Array
			var i:int;

			newMsg = [ _functionName ];
			for (i=0; i<msg.length; i++) {
				newMsg.push(msg[i]);
			}

			ExternalInterface.call.apply(null, newMsg);
		}
	}
}