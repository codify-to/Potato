package potato.modules.services
{
	/**
	 * Simple interface for service call encoders.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  28.10.2010
	 */
	public interface ICallEncoder
	{
		function get id():String;
		function encode(value:*):String;
	}

}

