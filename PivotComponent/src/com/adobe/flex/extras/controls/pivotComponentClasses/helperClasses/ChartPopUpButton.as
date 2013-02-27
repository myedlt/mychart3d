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
	import com.adobe.flex.extras.controls.myEvent.EnableChangeEvent;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.List;
	import mx.controls.PopUpButton;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.olap.OLAPMember;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	/**
 	 *  Dispatched when selection changes in the underlying
 	 *  list
 	 */
	[Event(name="selected" , type="myEvent.EnableChange")] 
	
	/**
	 *  @private
	 *  ChartPopUpButton control is used in
	 *  rowAxis, columnAxis and slicerAxis of
	 *  OLAPChartExtension as a renderer to show underlying 
	 *  members of an attribute. It also helps to filter out
	 *  certian members from the result 
	 */
	public class ChartPopUpButton extends PopUpButton
	{
		private var createdNow:Boolean = true;
		private var pivotComponent:PivotComponent;
		//-----------------------------------------------------------
		//
		//					Variables
		//
		//-----------------------------------------------------------
		
		private var memb:Boolean;
		private var  PBCanvas:Canvas
		private var PBList:List;
		private var filterMembers:Array;
		public var tempSelection:Array=[]; 
		
		//-----------------------------------------------------------
		//
		//					Constructor
		//
		//------------------------------------------------------------
		
		/**
		 *  @private
		 */
		public function ChartPopUpButton()
		{
			/* this.addEventListener(Event.ADDED_TO_STAGE, addEventHandler);
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, checkAll) */
			this.addEventListener("open",traceOpen);
		}
		
		//------------------------------------------------------------
		//
		//				Properties
		//
		//------------------------------------------------------------
		[Bindable]
		private var _members:ArrayCollection;
		
		/**
		 *  @private
		 *  Sets the members of the 
		 *  attribute represented by this renderer
		 */
		public function set members(value:ArrayCollection):void
		{
			_members = value;
		}	
		
		/**
		 *  @private
		 */
		public function get members():ArrayCollection
		{
			return _members;
		}
		
		//-------------------------------------------------------------
		//
		//					Methods
		//
		//-------------------------------------------------------------
		
		private function traceOpen(event:Event):void
		{
			checkAll();
			addMembers(members);
		}
		/**
		 *  @private
		 *  Selects all members when the renderer is
		 *  created for first time
		 */
		private function checkAll():void
		{
			getPivotComponent();
			try
			{
				if(pivotComponent.filterMembers.hasOwnProperty(this.label))
				{
					for(var i:int=0;i<PBList.rendererArray.length;i++)
					{
						for(var j:int=0; j<PBList.rendererArray[i].length; j++)
						{
							if(PBList.rendererArray[i][j] is ChartCheckbox)
							{
								var cname:String=ChartCheckbox(PBList.rendererArray[i][j]).label;
								if(memberPresent(pivotComponent.filterMembers[this.label],cname))
									ChartCheckbox(PBList.rendererArray[i][j]).selected = true;
								else
									ChartCheckbox(PBList.rendererArray[i][j]).selected = false;
							
							}		
						}
					}
				}
			}
				
			catch(e:Error)
			{
				;
			}
					
			
		}
		
	/**
	 * @private
	 */
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
		
	/**
	 * @private 
	 */
	 private function memberPresent(arr:ArrayCollection,memberName:String):Boolean
	 {
	 	for(var i:int=0;i<arr.length;i++)
	 		{
	 			
	 			if(OLAPMember(arr[i]).displayName==memberName)
	 				return true;
	 		}
	 		
	 	return false;				
	 }
	 
		/**
		 *  @private
		 *  Adds all members to the renderer
		 */
		private function addEventHandler(event:Event):void
		{
			addMembers(members);
		}	
		
		/**
		 *  @private
		 */
		public function addMembers(members:ArrayCollection):void
		{			
			if(!PBCanvas)
			{
				PBCanvas=new Canvas();			
				var VB:VBox=new VBox();
				var HB:HBox=new HBox;
		
				if(members==null) return;
				this.members = members
				var okButton:Button=new Button();
				okButton.label="OK";
				okButton.addEventListener("click",commit)
		
				var cancelButton:Button=new Button();
				cancelButton.label="Cancel";
				cancelButton.addEventListener("click",remove);
				
				HB.addChild(okButton);
				HB.addChild(cancelButton);
				//HB.percentHeight = 10;
				VB.addChild(HB);
			
		    	PBList=new List();
				PBList.itemRenderer=ListClassFactory();
				
				PBList.dataProvider=members;
				PBList.labelField="displayName";
				PBList.allowMultipleSelection=true;
				/* PBList.percentHeight = 90;*/
				PBList.percentWidth = 100;
				VB.addChild(PBList);
				
				PBCanvas.addChild(VB);			
				PBCanvas.setStyle("borderThickness",5);
				PBCanvas.setStyle("borderStyle","solid");
				PBCanvas.setStyle("backgroundColor","white");
				//PBCanvas.height = HB.measuredHeight + PBList.height;
				this.popUp=PBCanvas;
			}	
					
		}
		
		/**
		 *  @private
		 */
		private function ListClassFactory():ClassFactory
		{
			var temp:ClassFactory=new ClassFactory;
			temp.generator=ChartCheckbox;
			return temp;	
		}
		
		//-------------------------------------------------------------------
		//
		//						Event Handlers
		//
		//-------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function commit(event:Event):void
		{	
			
			var atleast_one:Boolean = true ;
			var index:int;
			getPivotComponent();
			if(members)
			{
				if(tempSelection.length == members.length) atleast_one = false;
		 		if(atleast_one)
				{
				pivotComponent.oldtempSelection = [];
				//oldtempSelection = tempSelection;
				for(var i:int =0 ; i<tempSelection.length ; i++)
				{
				
				pivotComponent.oldtempSelection[i] = tempSelection[i];
				}
				filterMembers=new  Array;
				this.close();
				var eventObj:EnableChangeEvent=new EnableChangeEvent("selected");
				eventObj.param=this.label;
			
				for(i= 0 ;i<members.length ; i++)
				{
					 var mname:String = OLAPMember(members[i]).displayName;
					index = tempSelection.indexOf(mname)
					if(index != -1)
					filterMembers.push(mname);
					
				} 
			
				if( tempSelection.length >0 )
				{
					index = tempSelection.indexOf("(All)");
					if( index == -1) filterMembers.push("(All)");
				} 
				eventObj.param1=filterMembers;
				dispatchEvent(eventObj);
			
			}
			else
			{
			
			
			Alert.show("Please select Atleast one item", "Alert",Alert.OK | Alert.CANCEL, this,alertListener, null, Alert.OK);	
		
		//this.popUp = PBCanvas;
			}
		}
		
	}
	
	private function alertListener(eventObj:CloseEvent):void
	{
		 if (eventObj.detail==Alert.OK) 
		 {
		 	
		 	restore();	
		 }
	}
	
	private function restore() : void
	{
		
		tempSelection = [];
		var oldtempSelection:Array = pivotComponent.oldtempSelection;
		if(oldtempSelection.length == 0)
		{
			for(var i:int=0;i<PBList.rendererArray.length;i++)
			{
				for(var j:int=0; j<PBList.rendererArray[i].length; j++)
				{
					if(PBList.rendererArray[i][j] is MyCheckBox)
					{
						MyCheckBox(PBList.rendererArray[i][j]).selected = true;
					}		
				}		
			}
			
		}
		if(oldtempSelection.length >0)
		{
		 	tempSelection = clone(oldtempSelection);
		 	for(i = 0;i<PBList.rendererArray.length;i++)
			{
				for( j =0; j<PBList.rendererArray[i].length; j++)
				{
					if(PBList.rendererArray[i][j] is MyCheckBox)
					{
						var l:String = MyCheckBox(PBList.rendererArray[i][j]).label ;
						var index:int = oldtempSelection.indexOf(l)
						if(index!=-1) 
						{
							//found 
							MyCheckBox(PBList.rendererArray[i][j]).selected = false
						}
						else
							MyCheckBox(PBList.rendererArray[i][j]).selected = true;
					}
				}
				
			}				
		}	 
			 
	}
	
	private function clone(source:Object):*
	{
    var myBA:ByteArray = new ByteArray();
    myBA.writeObject(source);
    myBA.position = 0;
    return(myBA.readObject());
	}

		/**
		 *  @private
		 */
		private function remove(event:Event):void
		{
			restore();
			this.close();
		}
	}
}				