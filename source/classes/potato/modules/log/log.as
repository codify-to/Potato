package potato.modules.log
{
	/**
	 * Issues a normal log message.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public function log(...msg):void {
		Logger.defaultLogger ||= new TraceLogger();
		Logger.defaultLogger.log.apply(Logger.defaultLogger, msg);
	}
}
