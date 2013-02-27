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
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.olapDataGridClasses.OLAPDataGridHeaderRenderer;
	import mx.olap.OLAPAttribute;
	import mx.olap.OLAPHierarchy;
	/**
 	 *  The PivotListHeader is a container which contains
 	 *  one header for each row of on the column axis. This header describes 
 	 *  the name of the hierarchy to which a particular member belongs. 
 	 *  
 	 *  Because of the limitation that a valid column grouping should be in a tree
 	 *  form, a fake top level column is created to give the required functionality of
 	 *  column axis headers to OLAPDataGrid . 
 	 *
 	 *  @see mx.controls.OLAPDataGrid
	 *  @see mx.controls.olapDataGridClasses.OLAPDataGridHeaderRendererProvider
 	 */

	public class PivotListHeader extends OLAPDataGridHeaderRenderer
	{
		
		public function PivotListHeader()
		{
			super();
		}
		
		/**
     	*  Creates a new PivotListData instance and populates the fields based on
     	*  the input data provider item (In case of OLAPDataGrid it is an IOLAPHierarhcy). 
     	*  
     	*/
		
		override protected function makeListData(data:Object, uid:String, 
                                             rowNum:int, columnNum:int, column:AdvancedDataGridColumn):BaseListData

		{
			   if(data is OLAPAttribute)
  		 	{
  	  		var pvListData:PivotListData=new   PivotListData(data.name,data.dataField, columnNum, uid, listData.owner,null,rowNum);
  	 		 pvListData.members=OLAPAttribute(data).members as ArrayCollection;
     		 pvListData.hasMembers=true; 
	 		return pvListData;   
    		}
    
  			
  	     return	super.makeListData(data,uid,rowNum,columnNum,column)as AdvancedDataGridListData;
  	}	
  	
  	/**
  	 * @private 
  	 * This is to avoid adding of "Measures" to column Headers
  	 * Its always with ateast 2 members on column
  	 */
  	 
  	 override protected function commitProperties():void
  	 {
  	 	super.commitProperties();
  	 	if(numChildren>1)
  	 	{
  	 		if(dataProvider[dataProvider.length-1] is OLAPHierarchy)
  	 		{
  	 			if(OLAPHierarchy(dataProvider[dataProvider.length-1]).displayName=="Measures")
  	 			{
  	 				 dataProvider.pop();
  	 				factories.pop();
  	 				this.removeChildAt(numChildren-1); 
  	 			}
  	 		}
  	 	}	
  	 }
  	 					
  	 
  	 
  	 	 
 }
 
}		
    
    	
