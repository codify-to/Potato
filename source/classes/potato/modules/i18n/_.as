package potato.modules.i18n
{
  import br.com.stimuli.string.printf;

	/**
	* Localization helper method.
	* 
	* @param stringID The ID of the localization String.
	* @param args [optional] Arguments to be substituted by the <code>printf</code> method. Can be either a single property Object on a sequence of values.
	* 
	* @return The localized String with the substitutions applied to it.
	*
	**/
	
	public function _(stringID:String, ...args):String
	{
	  return printf.apply(this, [I18n.instance.textFor(stringID)].concat(args));
	}

}

