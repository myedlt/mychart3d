///////////////////////////////////////////////////////////////////////////////////////
//  
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//   
//  NOTICE:  Adobe permits you to use, modify, and distribute this file in 
//  accordance with the terms of the Adobe license agreement accompanying it.  
//  If you have received this file from a source other than Adobe, then your use,
//  modification, or distribution of it requires the prior written permission of Adobe.
////////////////////////////////////////////////////////////////////////////////////////
package com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses
{
	import com.adobe.flex.extras.controls.PivotComponent;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.listClasses.BaseListData;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	
	/**
	 *  @private
	 */
	public class MeasuresComboBox extends ComboBox
	{
		//------------------------------------------------------------
		// variables
		//-----------------------------------------------------------
		[Bindable]	
		private var aggregatorNames:ArrayCollection;
		public var agg:Array=[];
		private var pivotComponent:PivotComponent;
		private var displayName:String;
		//---------------------------------------------------------------
		// Constructor
		//--------------------------------------------------------------- 
		
		public function MeasuresComboBox():void
		{   aggregatorNames=new ArrayCollection;
			this.addEventListener(FlexEvent.DATA_CHANGE,fillAggregators);
			this.dataProvider=aggregatorNames;	
			this.addEventListener("change",modifyMeasures);	
			//this.itemRenderer=new ClassFactory(mx.controls.CheckBox);
		}
		
		//--------------------------------------------------------------
		//
		// Properties
		//
		//----------------------------------------------------------------
		/**
		 * @private
		 */ 
		
		private var _listData:BaseListData
		override public function set listData(value:BaseListData):void
		{
			_listData=value;
			if(value)
			{
		   		this.prompt=value.label
		   		displayName=value.label
			}
	
		}	
				
		override public function get listData():BaseListData
		{
			return _listData;				
		}
		//-------------------------------------------------------------
		//
		//   private Methods
		//
		//-------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		private function fillAggregators(event:Event):void
		{
			aggregatorNames.addItem({label:"Sum("+displayName+")"});
			aggregatorNames.addItem({label:"Avg("+displayName+")"});
			aggregatorNames.addItem({label:"Count("+displayName+")"});
			aggregatorNames.addItem({label:"Min("+displayName+")"});
			aggregatorNames.addItem({label:"Max("+displayName+")"});
			
			for(var i:int=0; agg.length;i++)
			{
				aggregatorNames.addItem({label:Object(agg[i]).toString()});
			}		
		}	
		
	    /**
	    * @private
	    */
	    private function modifyMeasures(event:Event):void
	    {	getPivotComponent();
	    	var s:String=this.selectedLabel;
	    	var splitArray:Array=s.split("(",2);
	    	s=splitArray[0];
	    	if(s=="SUM" || s=="Avg" || s=="Count" || s=="Min" || s=="Max")
	    	pivotComponent.modifyFacts(displayName,splitArray[0]);
	    	else
	    	{
	    		var index:int=agg.indexOf(s);
	    		if(index!=-1)
	    		{
	    			pivotComponent.modifyFacts(displayName,agg[index])
	    		}
	    	}
	    		
	    }
	    
	     private function getPivotComponent():void
	    {
	    	if(!pivotComponent)
	    	{
				var p:Object = this.parent;
	    		while(p)
	    		{
	    			if(p is PivotComponent)
	    			{
	    				pivotComponent = p as PivotComponent;
	    				return;
	    			}
	    			else
	    				p = p.parent;
	    		}
	    	}	    	
	    }  
		
	    
	     
	    	 	
		
	}
	
}		
		
			
			
		