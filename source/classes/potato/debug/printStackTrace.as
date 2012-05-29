package potato.debug
{
  import potato.modules.log.log;
  
	/**
	 * Prints the stack trace anywhere in your code.
	 * 
	 * <p><b>Warning:</b> This method is really slow and extensive use is not recommended.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin, Fernando França
	 * @since  16.08.2010
	 */
	public function printStackTrace():void
	{
		try
		{
			throw new Error();
		} 
		catch (e:Error)
		{
			var str:String = e.getStackTrace();
			str = str.split("\n").slice(2).join("\n");
			str = str.replace(/\[.*\//g,"\n\twarning:[");
			log("Error:\n" + str);
		}
	}
}
