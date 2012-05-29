package potato.modules.log
{
	/**
	 * Issues a warning log message.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public function logWarning(...msg):void {
		Logger.defaultLogger ||= new TraceLogger();
		Logger.defaultLogger.logWarning.apply(Logger.defaultLogger, msg);
	}
}
