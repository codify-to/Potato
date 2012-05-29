package potato.utils
{
	import potato.utils.construct;
	import flash.utils.getDefinitionByName;
	import potato.modules.log.log;
	
	/** 
	 * Utility method for <code>flash.utils.getDefinitionByName</code>.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  05.08.2010
	 * 
	 * @param	className	The qualified class name for this instance.
	 * @return The instance of the given class, or <code>null</code> if the class definition can't be found.
	 */
	
	public function getInstanceByName(className:String, ...args):*
	{
		try {
			//Check if the module was included and create an instance
			var classDefinition:Class = getDefinitionByName(className) as Class;
		}
		catch (e:ReferenceError) {
			log("[getInstanceByName] Error, "+ className +" was not found.");
			return null;
		}
		
		var classInstance:* = construct.apply(null, [classDefinition].concat(args));
		return classInstance;
	}
	
}
