package potato.modules.tracking
{   
  /**
  * Pushes a new tracking request to the queue, with optional String substitution.
  * @param id The tracking call ID.
  * @param replace [optional] Arguments to be substituted by the <code>printf</code> method. Can be either a single property Object on a sequence of values.
  */ 
  public function track(id:String, ...replace):void
  {
    Tracker.instance.track.apply(null, [id].concat(replace));
  }
}

