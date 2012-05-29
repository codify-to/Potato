package potato.modules.log
{

	/**
	 * A logger that holds several logger objects, sending the same message to all of them.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public class MultiLogger extends Logger {

		/**
		 *	The list of loggers in this Multi Loggers.
		 *	@protected
		 */
		protected var _loggers:Vector.<Logger>;

		/**
		 *	Builds a new Multi Logger.
		 *	@param	loggers	 An optional list of loggers that are added upon creation.
		 *	@constructor
		 */
		public function MultiLogger(...loggers) {
			super();

			// Builds the list of loggers
			_loggers = new Vector.<Logger>();

			// Adds the passed loggers, if any
			var i:int;

			for (i=0; i<loggers.length; i++) {
				addLogger(loggers[i] as Logger);
			}
		}

		/**
		 *	Adds a logger to this Multi Logger.
		 */
		public function addLogger(logger:Logger):void {
			_loggers.push(logger);
		}

		/**
		 *	Removes a logger from this Multi Logger.
		 *	@param logger The logger to be removed. If the passed logger wasn't added to this Multi Logger, nothing happens
		 */
		public function removeLogger(logger:Logger):void {
			var position:int;

			if ((position=_loggers.indexOf(logger))>=0) {
				_loggers.splice(position, 1);
			}
		}

		/**
		 *	Removes all loggers from this Multi Logger.
		 */
		public function removeAllLoggers():void {
			_loggers = new Vector.<Logger>();
		}

		/**
		 * @inheritDoc
		 */
		override public function output(...msg):void {
			var i:int;

			for (i=0; i<_loggers.length; i++) {
				_loggers[i].output.apply(_loggers[i], msg);
			}
		}
	}
}

