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
	
	import mx.collections.IList;
	import mx.controls.CheckBox;
	import mx.controls.List;
	import mx.olap.OLAPMember;
	import mx.core.mx_internal;
	use namespace mx_internal;

	public class ChartCheckbox extends CheckBox
	{
		public function ChartCheckbox()
		{
			this.addEventListener("change",storeChange);
			super();
		}
		private var pivotComponent:PivotComponent ; 
		private var parentButton:ChartPopUpButton;
		private var _data:Object;
		override public function set data(value:Object):void
		{
			this.label=OLAPMember(value).displayName;
			var dimName:String=OLAPMember(value).dimension.displayName;
			getPopUpButton();
			 if( this.label == "(All)" ) 
			{
					if(parentButton.tempSelection.length == 0) 
						this.selected = true;
					else 
						this.selected = false	
				
			}
			else
			{
				if(memberPresent(this.label) )
					this.selected=false;
				else
				    this.selected=true;	
			}
			
				
		}		
		
		override public function get data():Object
		{
			return _data;
		}
			
		
		/** 
		 * Get pivotComponent
		 */ 
		private function getPopUpButton():void
		{
			
			if(!parentButton)
	    	{
				var p:Object = this.owner;
				while(p)
	    		{
	    			if(p is ChartPopUpButton)
	    			{
	    				parentButton = p as ChartPopUpButton;
	    				return;
	    			}
	    		else
	    			p = p.owner;
	    			
	    		}
	    	}	    	
		} 
		
		
		/**
	 * @private 
	 */
	 	private var iFlag:Boolean=false;
	 	private function memberPresent(memberName:String):Boolean
	 	{
	 		getPopUpButton();
	 		if(!iFlag)
	 		populateTemp();
	 		for(var i:int=0;i<parentButton.tempSelection.length;i++)
	 		{
	 			if(parentButton.tempSelection[i]==memberName) return true;
	 		}
	 		
	 		return false;		
	 		
	 				
	 	}
	  
	  private function populateTemp():void
		{
			iFlag = true ;
			getPopUpButton();
			getPivotComponent();	
			var bname:String = parentButton.label;
			if(pivotComponent.filterMembers.hasOwnProperty(bname))
			{
				var found:Boolean = false ;
				var memb:IList = pivotComponent.cube.findDimension(bname).findAttribute(bname).members;
				for(var i :int = 0 ; i < memb.length ; i++)
				{	
					found = false ; 
					for(var j:int=0 ; j < pivotComponent.filterMembers[bname].length ; j++ )
					{
						if( OLAPMember( memb[i] ).displayName == OLAPMember(pivotComponent.filterMembers[bname][j]).displayName )
							{
								found = true;
								break;
							}	
					}	
					
					if( found == false ) parentButton.tempSelection.push( OLAPMember(memb[i]).displayName) ;
					
				}
			}
				
		}	
		
		
		private function getPivotComponent():void
	    {
	    	if(!pivotComponent)
	    	{
				var p:Object = this.owner;
	    		while(p)
	    		{
	    			if(p is PivotComponent)
	    			{
	    				pivotComponent = p as PivotComponent;
	    				return;
	    			}
	    			else
	    				p = p.owner;
	    		}
	    	}	    	
	    } 
		
	  
	  private function storeChange(event:Event):void
	  {
	  	var tlist:List;
	  	var i:int;
	  	var j:int;
	  	if(this.label != "(All)" && this.selected == false)
	  	{
	  		 tlist = List(this.owner) ;
	  			for(i = 0;i<tlist.rendererArray.length;i++)
				{
					for( j=0; j<tlist.rendererArray[i].length; j++)
					{
						if(tlist.rendererArray[i][j] is ChartCheckbox)
						{
								var cname:String=ChartCheckbox(tlist.rendererArray[i][j]).label;
								if(cname == "(All)")
								{
									parentButton.tempSelection.push("(All)");
									ChartCheckbox(tlist.rendererArray[i][j]).selected = false ;
								}
							}		
						}
					}
	  	}
	
		if(this.label == "(All)"	&& this.selected == true )
	  	{
	  		tlist = List(this.owner) ;
	  		parentButton.tempSelection=[];
	  	//	parentButton.push("reset$$");
	  		for(i = 0;i<tlist.rendererArray.length;i++)
			{
				for(j=0; j<tlist.rendererArray[i].length; j++)
				{
					if(tlist.rendererArray[i][j] is ChartCheckbox)
					{
						removeFromSelection(ChartCheckbox(tlist.rendererArray[i][j]).label)
						ChartCheckbox(tlist.rendererArray[i][j]).selected = true ;
					}		
				}
			}
	  		
	  	}

	
	  	if(!this.selected && this.label != "(All)" ) 
	  	{
	  	 	parentButton.tempSelection.push(this.label);
	  	 	
	  	}	
	  	 
	  	else
	  	 removeFromSelection(this.label); 
	  }	
	  
	  private function removeFromSelection(name:String):void
	  {
		for(var i:int=0;i<parentButton.tempSelection.length;i++)
		{
			if(parentButton.tempSelection[i]==name) parentButton.tempSelection.pop();
		}
	  }
					  	
	}
}