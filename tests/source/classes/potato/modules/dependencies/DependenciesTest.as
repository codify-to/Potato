package potato.modules.dependencies
{	
    import potato.modules.dependencies.Dependencies;
	import potato.core.config.Config;
	import flash.events.*;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class DependenciesTest
	{

        private var dep:Dependencies;

        public function get asyncHandler():Function{
            var handleComplete:Function = function(e:Event, x:*):void{
                trace("done");
            };
            return Async.asyncHandler( this, handleComplete, 5000, null, handleTimeout );
        }
        public function errorHandler(e:ErrorEvent):void{
            Assert.fail(e.toString());
        }
        public function handleTimeout(e:Event):void{
            Assert.fail("timeout");
        }

		[Test(async)]
		public function dependenciesFromConfig():void
		{
			var cfg:Config = new Config([
				{
					"id":"main",
					"url":"%(basePath)s/dummy.swf",
					"domain":"current"
				}
			]);
			cfg.interpolationValues = {basePath: "."};
			
			var dep:Dependencies = new Dependencies(cfg);
            dep.addEventListener(Event.COMPLETE, asyncHandler);
            Async.failOnEvent(this, dep, ErrorEvent.ERROR);
			dep.load();
			
			
		}

		[Test(async)]
		public function dependenciesFromManuallyAdding():void
		{
			var dep:Dependencies = new Dependencies();
            dep.addEventListener(Event.COMPLETE, asyncHandler, false, 0, true);
            Async.failOnEvent(this, dep, ErrorEvent.ERROR);
			dep.addItem("./dummy.swf");
			dep.addItem("./dummy.swf", {id: "dummy2"});
			dep.load();
		}
		
		[Test(async)]
		public function dependenciesFailed():void
		{
			var dep:Dependencies = new Dependencies();
            dep.addEventListener(ErrorEvent.ERROR, asyncHandler, false, 0, true);
            Async.failOnEvent(this, dep, Event.COMPLETE);
			dep.addItem("./dummye.swf");
			dep.load();
		}
		
		[Test(async)]
		public function dependenciesFromConfigAndAdd():void
		{
			var cfg:Config = new Config([
				{
					"id":"main",
					"url":"%(basePath)s/dummy.swf",
					"domain":"current"
				}
			]);
			cfg.interpolationValues = {basePath: "."};
			
			var dep:Dependencies = new Dependencies(cfg);;
            dep.addEventListener(Event.COMPLETE, asyncHandler, false, 0, true);
            Async.failOnEvent(this, dep, ErrorEvent.ERROR);
			dep.addItem("./dummy.swf");
			dep.addItem("./dummy.swf", {id: "dummy2"});
			dep.load();
		}
		
		[Test(async)]
		public function dependenciesEmpty():void
		{
			var dep:Dependencies = new Dependencies();
            dep.addEventListener(Event.COMPLETE, asyncHandler, false, 0, true);
            Async.failOnEvent(this, dep, ErrorEvent.ERROR);
			dep.load();
		}

	}
}
