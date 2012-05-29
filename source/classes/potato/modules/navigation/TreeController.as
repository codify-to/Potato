package potato.modules.navigation {

    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
	import potato.core.config.*;
    import potato.modules.navigation.View;
    
	/**
	 * Class responsible for the NavigationController's tree management.
	 * 
	 * @see	potato.modules.navigation.NavigationController
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin, Fernando França
	 * @since  17.06.2010
	 */
    public class TreeController extends EventDispatcher
	{
		protected var _childrenConfig:Vector.<Config> = new Vector.<Config>();
		
		/**
		 * List of visible children
		 */
		public var children:Vector.<View> = new Vector.<View>();
        
        /**
		 * The view which this nav belongs
		 */
		public var currentView:View;
		
		/**
		 * Parent View (null if there is none)
		 */
		public var parent:View;

        //Parameters glue
		protected var _interpolationValues:Object;
		
		//Transition control
		internal var _viewsToShow:Vector.<View> = new Vector.<View>();
		internal var _viewsToHide:Vector.<View> = new Vector.<View>();
		internal var _viewsLoaded:Vector.<View> = new Vector.<View>();


        public function TreeController(viewsConfig:Object, currentView:View, interpolationValues:Object)
		{
            //Node's view
            this.currentView = currentView;

            //Parameters glue
			_interpolationValues = interpolationValues || {};
			
			//Creating a config object
			for each(var raw:Object in viewsConfig)
			{
				//Creating a config from the raw data
				var config:Config = new Config(raw);
				config.interpolationValues = _interpolationValues;
				//No need to wait for the INIT event in Configs
				config.init();
				
				//Checking if this is the config we want
				_childrenConfig.push(config);
			}

        }

        /**
		 * @param id String 
		 * @return Boolean 
		 * Checks if this view has a VISIBLE view (children list) with the name of the id
		 */
		protected function findChild(id:String):View
		{
            //Check if we have already searched for this view
            //if(_cachedSearchResults[id]) return _cachedSearchResults[id];

			for each (var child:View in children)
			{
				if(child.id == id)
					return child;
				
                //Looking up
				var c:View = child.nav.findChild(id);
                //Found
				if(c) {
                    //Return the view
                    return c;
                }
			}
			return null;
		}

         /**
		 * @param id String 
		 * @return Boolean 
		 * Checks if this view has a referente to <code>id</code> in the CONFIGs (_childrenConfig list)
		 */
		protected function findUnloadedChild(id:String):Config
		{
			var miner:Function = function(search:String, haystack:Vector.<Config>):Config {
				for each (var c:Config in haystack)
				{
					//Did we find our view?
					if(c.getProperty("id") == search) return c;

					//No... look in the child
					if(c.hasProperty("views"))
					{
						//List of children views
						var views:Config = c.configForKey("views");
						
						//Generate a new haystack
						var newHaystack:Vector.<Config> = new Vector.<Config>();
						var keys:Array = views.keys;
						for (var i:int = 0; i < keys.length; i++)
						{
							newHaystack.push(views.configForKey(keys[i]));
						}

						//Search in the children
						var searchResult:Config;

						searchResult = miner(search, newHaystack);
						if (searchResult) {
							return searchResult;
						}
					}
				}
				return null;
			}
			return miner(id, _childrenConfig);
		}

        /**
		 * Searches the view and go up untill it finds a common ancestor
		 * 
		 * @param startFrom View a point in the haystack
		 * @param needle String The view we're looking for
		 * @return View Common ancestor
		 */
		public function findCommonAncestor(startFrom:View, needle:String):View
		{
			//No more places to search
			if(!startFrom) return null;

			//Search in loaded views and unloaded views
			if(startFrom.nav.findChild(needle) || startFrom.nav.findUnloadedChild(needle))
				return startFrom;
			else
			//Could not find, go up in the tree
				return findCommonAncestor(startFrom.nav.parent, needle);
		}
		
        public function get root():View
		{
			//Go to the root of the tree
			var topView:View = currentView;
			while (topView.nav.parent){
				topView = topView.nav.parent;
            }
			return topView;
		}

        public function get viewsLoaded():Vector.<View>{
            return root.nav._viewsLoaded;
        }

        /**
		 * @private
		 */
		public function dispose():void
		{
			if (children)
			{
				for each (var v:View in children)
					v.dispose();
				children = null;
			}
			_childrenConfig = null;
			_viewsToHide = null;
			_viewsToShow = null;
			_viewsLoaded = null;	
		}
    }
}
