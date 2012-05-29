package potato.modules.navigation
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import potato.core.config.Config;
	import flash.utils.Proxy;
	import potato.modules.dependencies.IDependencies;
	import potato.core.IDisposable;
	import potato.core.IVisible;
	import potato.core.config.Config;
	import potato.modules.navigation.ViewLoader;
	import potato.modules.navigation.ViewMessenger;
	import potato.modules.navigation.NavigationController;
	import potato.modules.navigation.events.NavigationEvent;
	import flash.utils.getQualifiedClassName;
	import potato.display.DisposableSprite;
	import potato.utils.getInstanceByName;
	
	// Potato Navigation module namespace
	import potato.modules.navigation.potato_navigation;
	use namespace potato_navigation;

	/**
	 * Main piece of the navigation
	 * Can be initialized with a configuration
	 * 
	 * A default format is assumed for the config where parameters and dependencies
	 * can be present
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin, Fernando França
	 * @since  17.06.2010
	 */
	public class View extends DisposableSprite implements IView
	{
		/**
		 * id used for sending messages and doing navigation operations
		 */
		protected var _id:String;
		
		/**
		 * Default order on stage
		 * TODO managed by the navigation controller
		 */
		protected var _zIndex:int = 0;
		
		/**
		 * Navigation controller.
		 * Used to change, remove, add or load views.
		 */
		public var nav:NavigationController;
		
		// The following variables use a decoupled behavior
		// (dependencies and parameters modules are not included by default)
		protected var _parameters:Object;
		protected var _dependencies:IDependencies;
		protected var _config:Config;
		
		/**
		 * @constructor
		 * Nothing is done here, logic was moved to <code>startup</code> to prevent synchronization issues.
		 * 
		 * @see	startup
		 */
		public function View() {}
		
		/**
		 * @param value Config View configuration
		 * 
		 * Prepares the view to receive interaction.
		 */
		potato_navigation final function startup(value:Config=null):void
		{
			_config = value || new Config();
			
			// Config initialization
			_config.interpolationValues = parameters;
			_config.addEventListener(Event.INIT, onConfigInit, false, 0, true);
			_config.init();
		}
		
		/**
		 * @param e Event 
		 * Runs after configuration is loaded.
		 * Responsible for setting default view behaviours: init, resize, transitions
		 */
		protected function onConfigInit(e:Event):void
		{
			_config.removeEventListener(Event.INIT, onConfigInit);
			
			// Initialize the id (set it to class name if not defined)
			if(_config.hasProperty("id"))
				_id = _config.getProperty("id");
			else if (!_id)
				_id = getQualifiedClassName(this);
				
			//zIndex
			if(_config.hasProperty("zIndex"))
				_zIndex = _config.getProperty("zIndex");
			
			// Configure parameters if they have been defined
			if(_config.hasProperty("parameters"))
				parameters.inject(_config.configForKey("parameters"));
			
			// Creating the navigation controller to add, remove or change views
			nav = new NavigationController(_config.hasProperty("views") ? _config.getProperty("views") : null, this, parameters);
			nav.addEventListener(NavigationEvent.ADD_VIEW, onViewReadyToAdd);
			nav.addEventListener(NavigationEvent.REMOVE_VIEW, onViewReadyToRemove);
			
			// Default view behaviour
			addEventListener(Event.ADDED_TO_STAGE, potato_navigation::_init, false, 0, true);
			
			//If this is the first view, it's already on stage
			if(stage)
				potato_navigation::_init();
			
		}

        /**
         * @param view String
         * Returns a proxy to a View
         */
        public function msg(view:String):ViewMessenger{
            return nav.getViewMessenger(view);
        }

        public function addView(id:String):ViewLoader
		{
            return nav.root.nav.addView(id);
        }
        
		public function removeView(id:String):void
		{
            nav.root.nav.removeView(id);
        }
        
		public function changeView(id:String):ViewLoader
		{
            return nav.changeView(id);
        }
        
		public function loaderFor(view:String):ViewLoader
		{
            return nav.loaderFor(view);
        }


		/**
		 * @private
		 * Internal initialization (fired after view is added to the stage).
		 */
	 	potato_navigation function _init(e:Event=null):void
		{
			//Init only once
			removeEventListener(Event.ADDED_TO_STAGE, potato_navigation::_init);
			
			//Enable resize
			stage.addEventListener(Event.RESIZE, _resize, false, 0, true);
			
			//User implementation
			init();
			
			//Position all stuff
			resize();
		}
		
		/**
		 * @private
		 * Internal resize, calls user implementation.
		 */
		potato_navigation function _resize(e:Event):void
		{
			if(stage)
				resize();
		}
		
		/**
		 * @private
		 * Internal dispose
		 */
		potato_navigation function _dispose():void
		{
			//Call user dispose implementation
			dispose();
			
			if(nav){
				nav.dispose();
				nav = null;
			}
			
			if(_dependencies){
				_dependencies.dispose();
				_dependencies = null;
			}
			
			//Cleanup
			for (var p:String in this){
				this[p] = null;
			}
			
			_parameters = null;
		}
		
		/**
		 * @private
		 */
		protected function onViewReadyToAdd(e:NavigationEvent):void
		{
			addChild(e.view);
			sortViews();
		}
		/**
		 * @private
		 */
		protected function onViewReadyToRemove(e:NavigationEvent):void
		{
			if(e.view.parent == this)
				removeChild(e.view);
		}
		
		/**
		 * @private
		 * Cocktail sorting algorithm
		 * Put every child view in its correct zIndex.
		 * (not adding them again to keep other stuff order)
		 */
		potato_navigation function sortViews():void
		{
			if(nav.children.length < 2) return;
			
			var swapped:Boolean, i:int, i2:int;
			do
			{
				swapped = false;
				for(i=0; i< nav.children.length; i++){
				  i2 = i+1 == nav.children.length ? 0 : i+1;
          if ((nav.children[i].zIndex > nav.children[i2].zIndex && getChildIndex(nav.children[i]) < getChildIndex(nav.children[i2])) ||
            (nav.children[i].zIndex < nav.children[i2].zIndex && getChildIndex(nav.children[i]) > getChildIndex(nav.children[i2]))) { // test whether the two elements are in the wrong order
            swapChildren(nav.children[i], nav.children[i2]); // let the two elements change places
            swapped = true;
          }
        }
        
				if(!swapped)
					break;
					
				swapped = false;
				for(i=nav.children.length-1; i<0; i--){
					if ((nav.children[i].zIndex > nav.children[i2].zIndex && getChildIndex(nav.children[i]) < getChildIndex(nav.children[i2])) ||
            (nav.children[i].zIndex < nav.children[i2].zIndex && getChildIndex(nav.children[i]) > getChildIndex(nav.children[i2]))){
						swapChildren(nav.children[i], nav.children[i2]); // let the two elements change places
				        swapped = true;
				    }
				 }
			} while (swapped);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get zIndex():int
		{
			return _zIndex;
		}
		public function get config():Config
		{
			return _config;
		}
		
		/**
		 * Potato parameters.
		 * Returns null when the module is not included
		 * Otherwise, a <code>potato.modules.parameters.Parameters</code> instance is returned
		 * (automatically created if needed)
		 */
		public function get parameters():Object
		{
			if(!_parameters)
				_parameters = getInstanceByName("potato.modules.parameters.Parameters");
			
			return _parameters;
		}
		/**
		 * Used by parent view to override the parameters
		 */
		public function set parameters(value:Object):void
		{
			_parameters = value;
		}
		
		/**
		 * Potato dependencies.
		 * 
		 * Returns null when the module is not included
		 * Otherwise, a <code>potato.modules.dependencies.Dependencies</code> instance is returned
		 * 
		 * Dependencies are usually added in the main configuration file, but nothing prevents you
		 * from adding them manually using your own code.
		 * 
		 * (automatically created if needed)
		 */
		public function get dependencies():IDependencies
		{
			return _dependencies;
		}
		public function set dependencies(value:IDependencies):void
		{
			_dependencies = value;
		}

		/**
		 * [override] Transition implementation.
		 * 
		 * <b>Call super.show() if you override this method.</b>
		 */
		public function show():void {
			nav.addEventListener(NavigationEvent.TRANSITION_COMPLETE, _showComplete, false, 0, true);
			nav.doTransition();
		}
		potato_navigation function _showComplete(e:Event):void
		{
			nav.removeEventListener(NavigationEvent.TRANSITION_COMPLETE, _showComplete);
			dispatchEvent(new NavigationEvent(NavigationEvent.VIEW_SHOWN, this));
		}
	
		/**
		 * [override] Transition implementation.
		 * 
		 * <b>Call super.hide() if you override this method</b>
		 */
		public function hide():void {
			nav.addEventListener(NavigationEvent.TRANSITION_COMPLETE, _hideComplete, false, 0, true);
			nav.hideAll();
		}
		potato_navigation function _hideComplete(e:Event):void
		{	
			nav.removeEventListener(NavigationEvent.TRANSITION_COMPLETE, _hideComplete);
			dispatchEvent(new NavigationEvent(NavigationEvent.VIEW_HIDDEN, this));
		}
	
		/**
		 * [override] Stage resize callback.
		 * The stage is available to the view at this point.
		 */
		public function resize():void {}

		/**
		 * [override] Called after the view has been initialized and added to the stage.
		 * At this point dependencies, parameters and stage are available to you.
		 */
		public function init():void {}
		
		/**
		 * Dispose view and children.
		 * <b>Don't forget to call super if you override this method.</b>
		 */
		override public function dispose():void {
			super.dispose();
		}
		
		/**
		 * @inheritDoc
		 */
        override public function toString():String{
            return "[View: " + id + "]"
        }
	}

}
