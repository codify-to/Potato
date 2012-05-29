package potato.utils
{
	/**
	 * Utility method for constructing a class instance dynamically.
	 * This method is a work-around for the absence of <code>Function.apply()</code> for class constructors.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  05.08.2010
	 * 
	 * @param	aClass The class you want to instantiate.
	 * @param	args [optional] Up to ten more arguments to be applied to the class constructor. <b>Warning:</b> this method is not type safe at compile time!
	 * @return A new instance of the specified class.
	 */
	public function construct(aClass:Class, ...args):*
	{
		if (args.length > 10)
		{
			throw new Error("[construct] Too many arguments ("+ aClass +","+ args.length +").");
		}
		
		// Behold, the ugliest code the world has ever seen!
		switch (args.length) {
			case 0 :
				return new aClass();
			case 1 :
				return new aClass(args[0]);
			case 2 :
				return new aClass(args[0], args[1]);
			case 3 :
				return new aClass(args[0], args[1], args[2]);
			case 4 :
				return new aClass(args[0], args[1], args[2], args[3]);
			case 5 :
				return new aClass(args[0], args[1], args[2], args[3], args[4]);
			case 6 :
				return new aClass(args[0], args[1], args[2], args[3], args[4], args[5]);
			case 7 :
				return new aClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
			case 8 :
				return new aClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
			case 9 :
				return new aClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
			case 10 :
				return new aClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
		}
	}
}

