package potato.modules.i18n
{	
  import flash.display.DisplayObjectContainer;
	
	/**
	* Searches for TextFields in a DisplayObjectContainer using a custom miner function.
	* 
	* <p>The miner function always receives the <code>TextField</code> as a parameter and should return a <code>String</code> 
	* which is the id of the localized string in the I18n locale file, other miner function parameters
	* can be passed using the rest parameters.</p>
	* 
	* <p>Here is an example, matching by instance name:</p>
	* 
	* <listing>
	* 
	* function(s:TextField):String {
	* 	return s.name;
	* }
	* </listing>
	* 
	* @param haystack The container that will be searched.
	* @param miner Specifies how to search the container.
	* @param ... minerParams [optional] Miner function parameters.
	* 
	* @example <listing>
	* 
	* // Default mining function (MATCH_BY_TEXT):
	* fillWithLocale(this);
	* 
	* // Function with no parameters:
	* fillWithLocale(this, I18nMatch.MATCH_BY_TEXT);
	* 
	* // Functions with parameters:
	* fillWithLocale(this, I18nMatch.MATCH_BY_INSTANCE_WITH_PREFIX, "prefix_");
	* fillWithLocale(this, I18nMatch.MATCH_BY_INSTANCE_WITH_SUFFIX, "_suf");
	* </listing>
	* 
	* <p><b>Important note:</b> MATCH_BY_TEXT searches for {my_text}, between braces.</p>
	* 
	* @see potato.modules.i18n.I18nMatch
	**/
	
	public function fillWithLocale(haystack:DisplayObjectContainer, miner:Function = null, ...minerParams):void
	{
		if(minerParams.length > 0){	
			I18nMatch.fillWithLocale(haystack, miner, minerParams);
		}
		else
		{
			I18nMatch.fillWithLocale(haystack, miner);
		}
	}	
	
}
