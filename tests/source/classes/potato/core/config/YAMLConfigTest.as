package potato.core.config
{	
    import potato.core.config.YAMLConfig;
	import potato.core.config.Config;
	import flash.events.*;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class YAMLConfigTest 
	{
        private const YAML_PATH:String = "data/config.yaml";

        [Test(async)]
        public function boolParsing():void{

            var asyncHandler:Function = Async.asyncHandler(this, function(e:Event, o:*):void{
                trace(config._config);
                config.removeEventListener(Event.INIT, asyncHandler);
                Assert.assertEquals(config.getProperty("bool"), true);
            }, 5000, null, handleTimeout);

            var config:YAMLConfig = new YAMLConfig(YAML_PATH);
            config.addEventListener(Event.INIT, asyncHandler)
            config.init();
        }
        
        [Test(async)]
        public function stringParsing():void{

            var asyncHandler:Function = Async.asyncHandler(this, function(e:Event, o:*):void{
                config.removeEventListener(Event.INIT, asyncHandler);
                Assert.assertEquals(config.getProperty("str"), "my fançy and complex StRiNg!");
            }, 5000, null, handleTimeout);

            var config:YAMLConfig = new YAMLConfig(YAML_PATH);
            config.addEventListener(Event.INIT, asyncHandler)
            config.init();
        }
        
        [Test(async)]
        public function numberParsing():void{

            var asyncHandler:Function = Async.asyncHandler(this, function(e:Event, o:*):void{
                config.removeEventListener(Event.INIT, asyncHandler);
                Assert.assertEquals(config.getProperty("float"), 1.23456);
            }, 5000, null, handleTimeout);

            var config:YAMLConfig = new YAMLConfig(YAML_PATH);
            config.addEventListener(Event.INIT, asyncHandler)
            config.init();
        }


        //Failed
        public function handleTimeout(e:Event):void{
            Assert.fail("timeout");
        }
	}
}
