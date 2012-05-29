package potato.modules.parameters
{	
    import org.flexunit.Assert;
	import flash.display.Sprite;
	import potato.modules.parameters.Parameters;
	import potato.core.config.Config;
	public class ParametersTest
	{

		private var p:Parameters;
		public function get parameter():Parameters
		{
			if(!p)
				p = new Parameters();
			
			//Loaded values
			p.inject(new Config({
				"name": "value",
				"name2": "value2",
				"name3": "value3",
				"name4": null,
				"name5": "%(name)s"
			}))
			
			//Defaults
			p.defaults.name2 = "otherValue"
			p.defaults.defaultName = "default"
			p.defaults.interpolated = "%(name2)s"
			
			//Overriding values
			p.name3 = "changed value";
			
			return p;
		}
		
        [Test]
		public function undefinedParamter():void
		{
			Assert.assertEquals(parameter.sbrubles, undefined);
		}

        [Test]
		public function nullParameter():void
		{
			Assert.assertEquals(parameter.name4, null);
		}

        [Test]
		public function parameterInjecting():void
		{
			Assert.assertEquals(parameter.name, "value");
		}

        [Test]
		public function parameterSetting():void
		{
			Assert.assertEquals(parameter.name3, "changed value");
		}

        [Test]
		public function parameterDefaults():void
		{
			Assert.assertEquals(parameter.defaultName, "default");
		}

        [Test]
		public function parametersOverrideOrder():void
		{
			Assert.assertEquals(parameter.name2, "value2");
		}

        [Test]
		public function parameterInterpolation():void
		{
			Assert.assertEquals(parameter.name5, parameter.name)
		}

        [Test]
		public function defaultsInterpolation():void
		{
			Assert.assertEquals(parameter.interpolated, parameter.name2);
		}

        [Test]
		public function inheritance():void
		{
			var inh:Parameters = new Parameters(new Config({
				inheritedProp: "yep"
			}));
			parameter.inherit = inh;
			
			Assert.assertEquals(parameter.inheritedProp, "yep");
			
		}

	}
}
