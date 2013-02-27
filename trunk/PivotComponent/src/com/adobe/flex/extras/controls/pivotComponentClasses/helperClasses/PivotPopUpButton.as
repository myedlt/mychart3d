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
import com.adobe.flex.extras.controls.pivotComponentClasses.OLAPDataGridEx;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.List;
import mx.controls.PopUpButton;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.core.ClassFactory;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.olap.OLAPMember;
use namespace mx_internal;
	
/**
 *  Dispatched when selection changes in the underlying
 *  list
*/
[Event(name="selected" , type="myEvent.EnableChange")] 
/**
 *  @private
 *  PivotPopUpButton control is used in
 *  rowAxis, columnAxis and slicerAxis of
 *  OLAPDataGridExtension as a renderer to show underlying 
 *  members of an attribute. It also helps to filter out
 *  certian members from the result 
 */
public class PivotPopUpButton extends PopUpButton
{
	//-------------------------------------
	//
	// Constructor
	//
	//-----------------------------------
	
	/**
	 * @private
	 */ 
	public function PivotPopUpButton()
	{
		this.addEventListener("open",traceOpen);
		addEventListener("click",clickHandlerButton);
		
		
		
		//addEventListener("uncheckAll",uncheckAll);
		//this.addEventListener(FlexEvent.UPDATE_COMPLETE, checkAll)
	}
		
	//-----------------------------------------------
	//
	//  Variables
	//
	//-----------------------------------------------
	/**
	 * @private
	 */ 
	private var memb:Boolean;
	/**
	 *@private
	 */  
	private var  PBCanvas:Canvas=null;
	/**
	 * @private
	 */ 
	private var PBList:List=null;
	/**
	 * @private
	 */ 
	private var filterMembers:Array;
	/**
	 * private 
	 */
	 private var createdNow:Boolean =true;
	 /**
	 * @private
	 */
	 private var pivotComponent:PivotComponent;
	 private var delButton:Button ;
	
	//------------------------------------------------------------
	//
	// Properties
	//
	//---------------------------------------------------------
	[Bindable]
	private var _members:ArrayCollection;  
	
	/**
	 *  @private
	 *  Sets the members of the 
	 *  attribute represented by this renderer
	 */
	public function set members(value:ArrayCollection):void
	{
		
		if(value)
		{
			_members = value;
			//members.addEventListener(CollectionEvent.COLLECTION_CHANGE,changeHandler);
		}	
		
	}	
		
	/**
	 *  @private
	 */
	public function get members():ArrayCollection
	{
		return _members;
	}
	
	/**
	 * Temperorary Selection
	 */
	 
	public var tempSelection:Array=[]; 
	
	//--------------------------------------------------------
	//
	//   Overridden properties
	//
	//-------------------------------------------------------
	/**
	 * @private 
	 * _listdata
	 */ 
	private var _listdata:BaseListData;
	/**
	 * @private
	 */	
	override public function get listData():BaseListData
	{
		return _listdata;
	}
	
	/* override protected  function createChildren():void
	{
		if(!delButton) 
		{
			delButton = new Button ();
			delButton.addEventListener("click" , deleteDimension );
		}
		super.createChildren();
	}
	
	override protected function measure():void
	{
		super.measure();
		var w:Number = measuredWidth + delButton.width ;
		measuredWidth = w;
		
		
			
		
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth,unscaledHeight);
		var popupButtonwidth:Number = this.width ; 
		delButton.setActualSize(10, unscaledHeight);
		delButton.move( popupButtonwidth + 10,4);
	} */
	
	
	/**
	 * @private
	 * Checks if we have a PivotListData , if so set the members 
	 */ 
	override public function set listData(value:BaseListData):void
	{
		_listdata=value;	
	  	if(value is PivotListData) 
		{
			this.label=PivotListData(value).dataField;		
			if(PivotListData(value).hasMembers==true)
			{
				memb=false;
				members=PivotListData(value).members;
				
			}
		}
		
	   if (value is AdvancedDataGridListData)
		{
			if ( AdvancedDataGridListData(value).dataField=="All")
				this.label="All"	
		}
		checkAll();
		if(label != "All")
		setMembers(members);		
	}
	
	/**
	 * 
	 * @private
	 */

	private function checkAll():void
	{
		getPivotComponent();
		try
		{		
			if(pivotComponent.filterMembers.hasOwnProperty(this.label))
			{
				if( PBCanvas && PBList)
				{
					for(var i:int=0;i<PBList.rendererArray.length;i++)
					{
						for(var j:int=0; j<PBList.rendererArray[i].length; j++)
						{
							if(PBList.rendererArray[i][j] is MyCheckBox)
							{
								var cname:String=MyCheckBox(PBList.rendererArray[i][j]).label;
								if(memberPresent(pivotComponent.filterMembers[this.label],cname))
									{
										MyCheckBox(PBList.rendererArray[i][j]).selected = true;
									//	MyCheckBox(PBList.rendererArray[i][j]).addEventListener("uncheckAll",uncheckAll);
									}
									else
									{
										MyCheckBox(PBList.rendererArray[i][j]).selected = false ; 
									//	MyCheckBox(PBList.rendererArray[i][j]).addEventListener("uncheckAll",uncheckAll);
									}
							}		
						}
					}
				
				
				
				} 
			}
			
			
			//this.popUp=PBCanvas;
			//invalidateProperties();
		}
		catch(e:Error)
		{
			;
		}		
	}		
	
	/* override protected function commitProperties():void
	{
		if(PBCanvas)
		{
			this.popUp=PBCanvas;
		}	
		super.commitProperties();
		
	}
		 */
	/**
	 * @private 
	 */
	 private function memberPresent(arr:ArrayCollection,memberName:String):Boolean
	 {
	 	if(!arr) return false;
	 	for(var i:int=0;i<arr.length;i++)
	 		{
	 			
	 			if(OLAPMember(arr[i]).displayName==memberName)
	 				return true;
	 		}
	 		
	 	return false;				
	 }
	  
	/**
	 * @private 
	 * called when user clicks the "down" arrow 
	 * Populate the list with the members of the 
	 * dimension 
	 */ 
	
	private function traceOpen(event:Event):void
	{
		
		//checkAll(event);	
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
	
	private function deleteDimension(event:Event):void
	{
		trace("hi");	
	}	
	/**
	 * @private
	 */ 	
	
	public function setMembers(members:ArrayCollection):void
	{
		
		if(!PBCanvas)
		{	
			PBCanvas=new Canvas
			var VB:VBox=new VBox;
			var HB:HBox=new HBox;
			var okButton:Button=new Button;
			var cancelButton:Button=new Button;
			if(members==null) return;
			okButton.label="OK";
			okButton.x=46;
			okButton.y=30;
			okButton.addEventListener("click",commit)
			cancelButton.label="Cancel";
			cancelButton.x=109;
			cancelButton.addEventListener("click",remove);
			HB.addChild(okButton);
			HB.addChild(cancelButton);
			VB.addChild(HB);
			PBCanvas.width=200;
			PBCanvas.height=200;
			PBList=new List;
			PBList.height = 155;
			PBList.width = 180;
			PBList.itemRenderer=ListClassFactory();
			//PBList.editable=true;
			PBList.dataProvider=members
			//PBList.labelField="displayName";
			//PBList.editorDataField="selected";
			PBList.allowMultipleSelection=true;
			VB.addChild(PBList);
			PBCanvas.addChild(VB);
			PBCanvas.setStyle("borderThickness",5);
			PBCanvas.setStyle("borderStyle","solid");
			PBCanvas.setStyle("backgroundColor","white");
			
			this.popUp=PBCanvas;
			
		}
		
		if(!popUp && PBCanvas) this.popUp = PBCanvas;
	
		
			
	}
	/**
	 * @private
	 */  
	private function ListClassFactory():ClassFactory
	{
		var temp:ClassFactory=new ClassFactory;
		temp.generator=MyCheckBox;
		return temp;	
	}
		
		
	/**
	 * @private 
	 * commit the filtering
	 */ 	
	private function commit(event:Event):void
	{	
		var atleast_one:Boolean = true ;
		var index:int;
		var i:int ;
		getPivotComponent();
		if(members)
		if(tempSelection.length == members.length) atleast_one = false;
		if(atleast_one)
		{
			pivotComponent.oldtempSelection = [];
			//oldtempSelection = tempSelection;
			for(i =0 ; i<tempSelection.length ; i++)
			{
				
				pivotComponent.oldtempSelection[i] = tempSelection[i];
			}
			filterMembers=new  Array;
			this.close();
			var eventObj:EnableChangeEvent=new EnableChangeEvent("selected");
			eventObj.param=this.label;
			
			for( i = 0 ;i<members.length ; i++)
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
	
	private function alertListener(eventObj:CloseEvent):void
	{
		 if (eventObj.detail==Alert.OK) 
		 {
		 	
		 	restore();	
		 }
	}
	
	
	private function restore() : void
	{
		var odgex:OLAPDataGridEx ;
		tempSelection = [];
		var i:int ;
		var j:int;
		var oldtempSelection:Array = pivotComponent.oldtempSelection;
		if(oldtempSelection.length == 0)
		{
			for( i = 0;i<PBList.rendererArray.length;i++)
			{
				for(j=0; j<PBList.rendererArray[i].length; j++)
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
				for(j =0; j<PBList.rendererArray[i].length; j++)
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

	private function clickHandlerButton(event:MouseEvent):void
	{
		trace("hi");
	}
	
	/**
	 * @private 
	 */ 
	private function remove(event:Event):void
	{	
		
		restore(); 
		this.close();
		
	}	
	
}
}				