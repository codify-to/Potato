package potato.display
{
	import flash.display.DisplayObject;
	
	/**
	 * Yet another DisplayObject safe removal implementation.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Vitor Calejuri, Lucas Dupin, Fernando França
	 * @since  29.07.2010
	 */
	public function safeRemoveChild(displayObject:DisplayObject):void
	{
		if(displayObject != null && displayObject.parent) {
			displayObject.parent.removeChild(displayObject);
		}
	}
}
