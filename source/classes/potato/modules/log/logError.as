package potato.modules.log
{
	/**
	 * Issues an error log message.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Carlos Zanella
	 * @since  07.12.2010
	 */
	public function logError(...msg):void {
		Logger.defaultLogger ||= new TraceLogger();
		Logger.defaultLogger.logError.apply(Logger.defaultLogger, msg);
	}
}
