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
	import mx.collections.ArrayCollection;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.core.IUIComponent;
	/**
 	*  The PivotListData class defines the data type of the <code>listData</code> property 
 	*  implemented by drop-in item renderers or drop-in item editors for the OLAPDataGridEx control. 
 	*  All drop-in item renderers and drop-in item editors must implement the 
 	*  IDropInListItemRenderer interface, which defines the <code>listData</code> property.
 	*
 	*  <p>While the properties of this class are writable, you should consider them to 
 	*  be read only. They are initialized by the OLAPDataGridEx class for headerRenderes, and read by an item renderer 
 	*  or item editor. Changing these values can lead to unexpected results.</p>
 	*
 	*  @see mx.controls.listClasses.IDropInListItemRenderer
 	*  @see mx.controls.AdvancedDataGrid
 	*/
	public class PivotListData extends AdvancedDataGridListData
	{
		
		
		//------------------------------------------------------------------------
		//
		// Constructor
		//
		//------------------------------------------------------------------------
		 /**
     	  *  Constructor.
     	  *
     	  *  @param text Text representation of the item data.
     	  * 
     	  *  @param dataField Name of the field or property 
    	  *    in the data provider associated with the column.
     	  *
     	  *  @param uid A unique identifier for the item.
     	  *
     	  *  @param owner A reference to the OLAPDataGrid control.
     	  *
     	  *  @param rowIndex The index of the item in the data provider for the AdvancedDataGrid control.
   	  	  * 
     	  *  @param columnIndex The index of the column in the currently visible columns of the 
     	  *  control.
     	  *  
     	  *  @param pbList The AdvancedDataGridListData that is propogated from super
     	  */
		public function PivotListData(text:String, dataField:String,
                                 columnIndex:int, uid:String,
                                 owner:IUIComponent, pbList:AdvancedDataGridListData,rowIndex:int = 0 )
    		
    		{   
    				super(text,dataField,columnIndex,uid,owner,rowIndex);
        			if(pbList!=null)
        			{
        			this.depth=pbList.depth;
        			this.disclosureIcon=pbList.disclosureIcon;
        			this.icon=pbList.icon;
        			this.indent=pbList.indent;
        			this.item=pbList.item;
        			this.label=pbList.label;
        			this.open=pbList.open;
        			this.owner=pbList.owner;
        			this.hasChildren=pbList.hasChildren;
        			}
    		}
			
		/**
		 * Contains <code> true </code> if the item has members
		 */ 	
		public var hasMembers:Boolean;
		/**
		 * Contains the members of the item 
		 */ 
		public var members:ArrayCollection=new ArrayCollection;
		public var oldtempSelection:Array;

		
	}
		
}		