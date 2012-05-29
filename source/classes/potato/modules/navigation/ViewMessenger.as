package potato.modules.navigation
{	
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import potato.modules.navigation.View;
	import potato.modules.log.log;
	use namespace flash_proxy;

	/**
	 * View proxy
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin
	 * @since  26.07.2010
	 */
	public dynamic class ViewMessenger extends Proxy
	{
		private var view:View;
		
		public function ViewMessenger(view:View)
		{
			this.view = view;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			if (view.hasOwnProperty(name))
				return view[name];

			return undefined
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (view.hasOwnProperty(name))
				view[name] = value;
            else
                log("[ViewMessenger]", view.id, "does not respond to", name);
		}
		
        override flash_proxy function callProperty(name:*, ... rest):*
		{
			if (view.hasOwnProperty(name))
				return view[name].apply(view, rest);
            else
                log("[ViewMessenger]", view.id, "does not respond to", name);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return view.hasOwnProperty(name);
		}

	}
}
