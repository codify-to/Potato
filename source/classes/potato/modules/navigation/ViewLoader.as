package potato.modules.navigation
{

	import flash.events.EventDispatcher;
	import potato.core.config.Config;
	import potato.modules.navigation.View;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import potato.modules.dependencies.IDependencies;
	import flash.utils.getDefinitionByName;
	import potato.core.config.Config;
	import ReferenceError;
	import potato.core.IDisposable;
	import potato.modules.navigation.events.NavigationEvent;
	import potato.utils.getInstanceByName;
	import potato.modules.log.log;

	// Potato Navigation module namespace
	import potato.modules.navigation.potato_navigation;
	use namespace potato_navigation;
	
	/**
	 * Loads the view and notifies progress or completion
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin
	 * @since  17.06.2010
	 */
	public class ViewLoader extends EventDispatcher implements IDisposable
	{
		//@private
		private var _viewConfig:Config;
		
		//Internal: view to be loaded
		protected var _viewId:String;
		
		protected var _loaded:Boolean;
		
		//View loaded
		public var view:View;
		
		//This parent
		public var parentView:View;
		
		//Dependency
		public var chain:ViewLoader;
		
		/**
		 * Receives a view to load or an Config.
		 * The second parameter is a chain we must load before
		 * @return  
		 */
		public function ViewLoader(config:Config, chain:ViewLoader=null){
			_viewConfig = config;
			this.chain = chain;
		}

		/**
		 * @param v View 
		 * Setup listeners, create dependencies and start to load
 		 */
		public function start():void
		{
			/*
			Checking the type, maybe it's a view, maybe not
			*/
			_viewId = _viewConfig.getProperty("id");
			log("[ViewLoader] ", _viewId, " load start");

			//Do we need to load localization stuff?
			if (_viewConfig.hasProperty("localeFile"))
			{
				//Check if the module was included
				with(getDefinitionByName("potato.modules.i18n.I18n")){
					inject(new parser(_viewConfig.getProperty("localeFile")));
					instance.addEventListener(Event.COMPLETE, continueConfigLoading);
				}
			} else {
				//Nothing to load
				continueConfigLoading();
			}
			
		}
		
		/**
		 * @param e Event 
		 * Runs after i18n verifications
		 * (Loading Config instance)
		 */
		public function continueConfigLoading(e:Event=null):void
		{
			if(e)
				e.target.removeEventListener(Event.COMPLETE, continueConfigLoading);
			
			//Do we have dependencies?
			if (_viewConfig.hasProperty("dependencies"))
			{
				//Getting a dependencies instance
				var dependencies:IDependencies = getDependenciesInstance(_viewConfig.configForKey("dependencies"));
				
				//Setup listeners
				dependencies.addEventListener(Event.COMPLETE, onViewReadyToCreate);
				dependencies.addEventListener(ProgressEvent.PROGRESS, onViewLoadProgress, false, 0, true);
				
				//Start loading
				dependencies.load();
			} else
			{
				onViewReadyToCreate();
			}
		}
		
		protected function getDependenciesInstance(config:Config):IDependencies
		{
			var dependencies:IDependencies = getInstanceByName("potato.modules.dependencies.Dependencies", config);
			
			if(!dependencies) throw new Error("[ViewLoader] potato.modules.dependencies.Dependencies was not found.");
			
			return dependencies;
		}
		
		/**
		 * @param e Event 
		 * passing events
		 */
		protected function onViewLoadProgress(e:Event):void
		{
			dispatchEvent(e.clone());
		}
		/**
		 * @param e Event 
		 * All depencendies are loaded.
		 * Creates the view instance
		 */
		protected function onViewReadyToCreate(e:Event=null):void
		{
		  var viewType:String = _viewConfig.getProperty("class") || "potato.modules.navigation.View";
			view = getInstanceByName(viewType);
			if(view == null) {
			  log("[ViewLoader] error: Could not create an instance for: ", viewType)
			}
			view.startup(_viewConfig);
			
			if(e)
			{
				e.target.removeEventListener(Event.COMPLETE, onViewReadyToCreate);
				view.dependencies = e.target as IDependencies;
			}
			
			onViewLoadComplete();
		}
		/**
		 * @param e Event 
		 * View loaded, check if there is something else to load
		 */
		protected function onViewLoadComplete(e:Event=null):void
		{
			if(e) e.target.removeEventListener(Event.COMPLETE, onViewLoadComplete);
			log("[ViewLoader] ", _viewId, " load complete:", view);
			
			if(chain) {
				chain.addEventListener(Event.COMPLETE, view.nav.onViewLoaded, false, 0, true);
				chain.addEventListener(ProgressEvent.PROGRESS, onChainProgress, false, 0, true);
				chain.addEventListener(Event.COMPLETE, onChainLoaded);
                chain.parentView = view;
				chain.start();
			} else {
				continueFromChain();
			}
		}
		
		public function onChainLoaded(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, onChainLoaded);			
			
			//TODO this is ugly
			//Telling the nav we should show this view (cascade)
			view.nav._viewsToShow.push(chain.view);
			
			continueFromChain();
		}
		
		public function continueFromChain():void
		{
            view.nav.parent = parentView;
			_loaded = true;
			dispatchEvent(new NavigationEvent(Event.COMPLETE, view));
		}
		
		/*
		Load finished
		*/
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function onChainProgress(e:Event):void
		{
			dispatchEvent(e.clone());
		}
		
		/**
		 * @private
		 */
		public function dispose():void
		{
			_viewId      = null;
			_viewConfig  = null;
			view         = null;

		}
	
	}

}