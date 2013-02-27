// ActionScript file
package com.adobe.flex.extras.controls.myEvent
{
	import flash.events.Event;


    public class EnableChangeEvent extends Event
    {

        // Public constructor.
        public function EnableChangeEvent(type:String, 
            isEnabled:Boolean=false,param:String="",param1:Array=null,param2:String = "") {
                // Call the constructor of the superclass.
                super(type);
    
                // Set the new property.
                this.isEnabled = isEnabled;
                this.param=param;
                this.param1=param1;
                this.param2 = param2 ;
               
        }

        // Define static constant.
        public static const ENABLE_CHANGED:String = "enableChanged";

        // Define a public variable to hold the state of the enable property.
    
        public var isEnabled:Boolean;
		public var param:String;
		public var param1:Array;
		public var param2:String; 
	
	 // Override the inherited clone() method.
        override public function clone():Event {
            return new EnableChangeEvent(type, isEnabled);
        }
    }

}