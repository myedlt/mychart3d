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
	import mx.controls.listClasses.BaseListData;
	import mx.core.mx_internal;
	import mx.olap.OLAPMember;
	use namespace mx_internal;
	
	[Event(name="uncheckAll" , type="flash.events.Event")] 
	public class MyCheckBox extends CheckBox 
	{
		private var selectedTrue :Boolean=false;
	
		public function MyCheckBox():void
		{
			this.addEventListener("change",storeChange);
			super();
		}
		
		private var pivotComponent:PivotComponent ; 
		private var parentButton:PivotPopUpButton ;
		private var _data:Object;
		override public function set data(value:Object):void
		{
			if(!value) return;
			this.label=OLAPMember(value).displayName;
			var dimName:String=OLAPMember(value).dimension.displayName;
			getPopUpButton();
			/* if(allChecked()) 
			{
				this.selected = true ;
				return ;
			} */
			  
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
		
		private var _listData:BaseListData ;
		override public function set listData(value:BaseListData):void
		{
			_listData = value ;
			
				
		}	
		override public function get listData():BaseListData
		{
			return _listData;
		}
		/**
		 * Push the chopped off screen
		 */ 
		private function populateTemp():void
		{
			iFlag = true ;
			getPopUpButton();
			getPivotComponent();
			if(parentButton.tempSelection.length > 0 ) return ;	
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
		/** 
		 * Get popUpButton
		 */ 
		private function getPopUpButton():void
		{
			
			if(!parentButton)
	    	{
				var p:Object = this.owner;
				while(p)
	    		{
	    			if(p is PivotPopUpButton)
	    			{
	    				parentButton = p as PivotPopUpButton;
	    				return;
	    			}
	    		else
	    			p = p.owner;
	    			
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
		
		private var iFlag:Boolean=false;
		/**
	 * @private 
	 */
	 	private function memberPresent(memberName:String):Boolean
	 	{
	 		getPopUpButton();
	 		if(!iFlag )
	 		populateTemp();
	 		for(var i:int=0;i<parentButton.tempSelection.length;i++)
	 		{
	 			if(parentButton.tempSelection[i]== memberName) return true;
	 		}
	 		
	 		return false;		
	 		
	 				
	 	}
	  
	  
	  private function storeChange(event:Event):void
	  {
	  	var tlist:List;
	  	var i:int;
	  	var j:int;
	  	// since set data is called only when recycling happens 
	    if(this.label != "(All)" && this.selected == false)
	  	{
	  			tlist = List(this.owner) ;
	  			for(i=0;i<tlist.rendererArray.length;i++)
				{
					for(j=0; j<tlist.rendererArray[i].length; j++)
					{
						if(tlist.rendererArray[i][j] is MyCheckBox)
						{
								var cname:String=MyCheckBox(tlist.rendererArray[i][j]).label;
								if(cname == "(All)")
								{
									parentButton.tempSelection.push("(All)");
									MyCheckBox(tlist.rendererArray[i][j]).selected = false ;
								}
							}		
						}
					}
	  	}
	
		if(this.label == "(All)"	&& this.selected == true )
	  	{
	  		tlist= List(this.owner) ;
	  		parentButton.tempSelection=[];
	  	//	parentButton.push("reset$$");
	  		for(i=0;i<tlist.rendererArray.length;i++)
			{
				for( j = 0; j<tlist.rendererArray[i].length; j++)
				{
					if(tlist.rendererArray[i][j] is MyCheckBox)
					{
						removeFromSelection(MyCheckBox(tlist.rendererArray[i][j]).label)
						MyCheckBox(tlist.rendererArray[i][j]).selected = true ;
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
	  	var index:int = parentButton.tempSelection.indexOf(name);
	  	parentButton.tempSelection.splice(index,1);
		
	  }
	  
	  private function allChecked():Boolean
	  {
	  		getPopUpButton();
	  		var index:int = parentButton.tempSelection.indexOf("(All)");
	  		if( index == -1) return true ;
	  		else return false ;
	  }
					  	
		
	private function any_one_Checked():Boolean
	{	
		getPopUpButton();
		var index:int = parentButton.tempSelection.indexOf("(All)");
		if(index == -1) 
		{
			if(parentButton.tempSelection.length >0) return true;
			else return false;
		}
		return false;
	}					  	
					  	
}
	
}		