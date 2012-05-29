package potato.modules.navigation.events
{

	import flash.events.Event;
	import potato.modules.navigation.View;

	/**
	 * Internal navigation event
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin
	 * @since  26.07.2010
	 */
	public class NavigationEvent extends Event
	{
	
		/**
		 * @private
		 */
		public static const ADD_VIEW:String = "addView";
		/**
		 * @private
		 */
		public static const REMOVE_VIEW:String = "removeView";
		
		public static const VIEW_SHOWN:String = "viewShown";
		public static const VIEW_HIDDEN:String = "viewHidden";
		
		public static const TRANSITION_START:String = "transitionStart";
		public static const TRANSITION_COMPLETE:String = "transitionComplete";
	
		public var view:View;
	
		public function NavigationEvent(type:String, view:View=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.view = view;
		}
	
		override public function clone():Event
		{
			return new NavigationEvent(type, view, bubbles, cancelable);
		}
	
	}

}
