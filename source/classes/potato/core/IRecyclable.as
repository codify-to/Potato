package potato.core
{
	/**
	 * Interface for recyclable / reusable objects, methods: <code>recycle()</code>.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  26.07.2010
	 */
	public interface IRecyclable extends IDisposable
	{
		function recycle():void;
	}

}

