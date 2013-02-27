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

package com.adobe.flex.extras.controls.pivotComponentClasses
{

import com.adobe.flex.extras.controls.PivotComponent;
import com.adobe.flex.extras.controls.myEvent.EnableChangeEvent;
import com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotListData;
import com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotListHeader;
import com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotPopUpButton;
import com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PopupButtonCover;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.controls.Alert;
import mx.controls.List;
import mx.controls.OLAPDataGrid;
import mx.controls.Text;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.ClassFactory;
import mx.core.DragSource;
import mx.core.EdgeMetrics;
import mx.core.FlexSprite;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.managers.CursorManager;
import mx.managers.DragManager;
import mx.olap.IOLAPMember;
import mx.olap.OLAPAxisPosition;
import mx.olap.OLAPDimension;
import mx.olap.OLAPHierarchy;
import mx.olap.OLAPLevel;
import mx.olap.OLAPMeasure;
import mx.olap.OLAPMember;
import mx.olap.OLAPQuery;
import mx.olap.OLAPQueryAxis;
import mx.olap.OLAPResult;
import mx.olap.OLAPResultAxis;
import mx.olap.OLAPSet;
import mx.rpc.AsyncResponder;
import mx.rpc.AsyncToken;
import mx.skins.halo.ListDropIndicator;
import mx.utils.StringUtil;
use namespace mx_internal;
//--------------------------------------
//  Events
//--------------------------------------

/**
 *  For still not decided 
 *  @eventType flash.events.Event
 */
[Event (name="removeSlicer", type="flash.events.Event")]
[Event (name="updateSlicerBox", type="flash.events.Event")]

/**
 *  The OLAPDataGridEX control is an extension of 
 *  OLAPDataGrid  control which allows user to  
 *  drag and drop OLAPDimension for OLAP analysis.
 *  User can also perform filtering . User needs to set 
 * <code> dataProvider </code> property of the control to 
 *  an ArrayCollection which has the flat data. 
 *  User also needs to set DimensionList , MeasuresList and 
 *  SlicerList before using Pivot Table
 *  @mxml
 *
 *  <p>The <code>&lt;OLapDataGridEx&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;OLapDataGridEx
 *    <b>Properties</b>
 *    showALL="true"
 *    Measures=[]
 *  /&gt;
 *  </pre>
 *  
 *  @includeExample ../../../../../../docs/com/adobe/flex/extras/controls/example/PivotTable/PivotTableSample.as
 *
 *  @see fc.DimensionsList
 *  @see fc.MeasuresList
 *  @see fc.PivotClasses.PivotListData
 *  @see fc.PivotClasses.PivotListHeader
 *  @see fc.PivotClasses.MyPopUpButton
 */
 public class OLAPDataGridEx extends OLAPDataGrid
{
		
	//--------------------------------------------------------------------------
	//
	//  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	
	public function OLAPDataGridEx():void
	{
		this.enabled = false;
		 this.minColumnWidth = 100;
		 dropEnabled = true;
        dragEnabled = true;
        dragMoveEnabled = true;
        filteredMembersList=new Array;
		//resetPivotTable();	
		
		addEventListener("cubeChanged",cubeCompleteHandler);
		addEventListener("creationComplete", initializePivotTable);
		addEventListener("selected",filter);
       	addEventListener("dataChanged",handleDataChange);
       	addEventListener("queryChanged",setQueryFlag);	
       	addEventListener("delete",deleteDimensions);
       	addEventListener("resetGrid",resetPivotGrid);
       //	addEventListener("deleteDimension",deleteDimensions);
	}
	
	//------------------------------------------------------------------------------------
	//
	//Variables
	//
	//------------------------------------------------------------------------------------*/
	
	/**
	 * @private
	 */	
	private var sampleDataInUse:Boolean;
	/**
	 * @private 
	 */
	 private var flatDataProvider:ICollectionView;
	/**
	 * @private 
	 */
	 private var dataProviderChanged:Boolean;
	/**
	 * @private 
	 */
	 private var currentQuery:OLAPQuery;

	 /**
	 * @private 
	 */
	 private var cubeCreationComplete:Boolean;
	/**
	 * @private 
	 */
	private var dropSprite:Sprite;
	/**
	 * @private 
	 */
	[Bindable]
	private var cubeMeasures:ArrayCollection;
	/**
	 * @private 
	 */
	public var filteredMembersList:Array;	
	/**
	 * @private 
	 */
	private var gridConfigChanged:Boolean; 
	/**
	 * @private 
	 */
	private var sliceArray:Array=[];
	
	/**
	 * @private 
	 */
    private var fields:Array=[];
    
    /**
    * @private
    */ 
    private var filterMembers:Array;
    /**
    * @private
    */
    private var pivotComponent:PivotComponent;
    /**
    * @private
    */
    private var newQuery:Boolean  
	//-----------------------------------------------------------------------------------
	//
	//      Properties
	//
	//------------------------------------------------------------------------------------*/
	/**
	 * @private
	 */ 
	private var rowFieldsChanged:Boolean;
	private var columnFieldsChanged:Boolean;
	private var factsChanged:Boolean;
	private var measuresChanged:Boolean;
	
	
		
	//--------------------------------------------------------------------------------
	//
	// Overidden Properties
	//-------------------------------------------------------------------------------*/
	
	/**
	 * @private
	 * Convert The flatData ArrayCollection to OLAPCube 
	 * If cube is created form new query and fire. 
	 * For all the columnHeaders set the headerRenderer.
	 */
	override protected function commitProperties():void
    {
	
		getPivotComponent();	
		if(pivotComponent)
		{
			super.commitProperties();
			if( pivotComponent.cube && gridConfigChanged && 
			  			newQuery)
    	    {
       			prepareNewQuery();
       			newQuery=false;
            	executeQuery();
            	gridConfigChanged = false;
        	}
        
        	if(visibleHeaderInfos && visibleHeaderInfos.length!=0)
        	{
       			var root:AdvancedDataGridColumnGroup = visibleHeaderInfos[visibleHeaderInfos.length-1].column;
            	root.headerRenderer=new ClassFactory(PivotListHeader);
        	}
        
  		}
    }
	
	/**
	 * @private 
	 * Initially we use dummy Data (sampleData) to give the default look of
	 * PivotTable , Once user drag drops any fields call updateDisplayList
	 * of super
	 */
	override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
    {
    	/* if(!sampleDataInUse && columns && columns.length)
    	{
    		var rowCount:int = 0 ;
    		for( rowCount = 0 ; rowCount<pivotComponent.rowFields.length ; rowCount ++)
    		{
    			var c:AdvancedDataGridColumn = columns[rowCount];
    			c.width = 200 ;    			
    		}
    		
    		for(var j:int = rowCount ; j<columns.length ; j++)
    		{
    			var c:AdvancedDataGridColumn = columns[j];
    			c.width = 100;
    		}
    		
    	} */
    	
    	if (sampleDataInUse && columns && columns.length)
        {
        	var c:AdvancedDataGridColumn = columns[0];
           	c.width = 0.60*unscaledWidth;
           	this.headerRenderer = new ClassFactory( mx.controls.Text);
            sampleDataInUse = false;
        	
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
	}

	/**
	 * @private
	 * Here from DataProvider we create Dimensions
	 */
	override public function set dataProvider(value:Object):void
	{
		if(!value)
        {
        	resetPivotTable();
            return;
        }
    
        value = reviseDataProvider(value);
		var obj:Object=value[0];
    
       	for (var f:String in obj)
        {
        	fields.push(f);
      	}
		
		if(value && value.length && value is ICollectionView)
        {
        	flatDataProvider = value as ICollectionView;
            dataProviderChanged = true;
            invalidateProperties();
       	}
       	
	}
		
	/**
	 * @private
	 * We add a dummy field called "All" for all objects 
	 * in the ArrayCollection . 
	 * This adjustment is done to simulate the expected behaviour
	 * when user drops the first field on column or Row
	 */ 	
	private function reviseDataProvider(value:Object):ICollectionView
	{
		if(value && value.length && value is ICollectionView)
		{
			for(var i:int=0;i<value.length;i++)
				{
					value[i]["All"]="";
				}
		}
			
		return value as ICollectionView ;
	}
	
	/**
	 * @private
	 * Add the listener to the headerRenderes( MyPopUpButtons) for 
	 * columnHeaders
	 */ 
	override protected function createHeaders(left:Number, top:Number):void
	{
		var rootItem:IListItemRenderer;
		super.createHeaders(left,top);
		rootItem=visibleHeaderInfos[visibleHeaderInfos.length-1].headerItem;
		var numChildren:int=DisplayObjectContainer(rootItem).numChildren;
		for(var i:int=0;i<numChildren;i++)
		{
			var r:Object=DisplayObjectContainer(rootItem).getChildAt(i);
			r.addEventListener("selected",filter);
			r.addEventListener("delete",deleteDimensions);
		}
	}		

	/**
	 * @private 
	 * Add listener to headerRenderes( MyPopUpButtons) for 
	 * rowHeaders
	 */ 
	override protected function getHeaderRenderer(c:AdvancedDataGridColumn):IListItemRenderer
	{
		var renderer:IListItemRenderer=super.getHeaderRenderer(c);
		if(renderer is PopupButtonCover)
			{
				renderer.addEventListener("selected",filter);
				renderer.addEventListener("delete",deleteDimensions);
			}
		trace((renderer is PopupButtonCover));
		return(renderer);
	}	
	
	/**
	 * 
	 * Prepares pivotListdata
	 */ 
	override protected function makeListData(data:Object, uid:String, rowNum:int, columnNum:int, column:AdvancedDataGridColumn):BaseListData
	{
		var pbList:AdvancedDataGridListData=super.makeListData(data,uid,rowNum,columnNum,column)as AdvancedDataGridListData;
		if(data is AdvancedDataGridColumn && pivotComponent.rowFields && pivotComponent.rowFields.length !=0 ) 
		{ 	
			var pvListData:PivotListData=new PivotListData(pbList.label, column.dataField, 
                                                           columnNum, uid, this, pbList,rowNum);
			var m:String=StringUtil.trim(pbList.label);
			if(m!="" && (pivotComponent.rowFields.indexOf(m)!=-1))
			{
				var membs:ArrayCollection=ArrayCollection(pivotComponent.cube.findDimension(m).findAttribute(m).members);
				trace(membs);
				pvListData.hasMembers=true;
				pvListData.members=membs;
				return pvListData;
			}
		}

		return pbList as AdvancedDataGridListData;
	}
	//----------------------------------------------------------------------------
	//
	//    DragDrop code
	//
	//---------------------------------------------------------------------------
	
	/**
	 * Checks out if its a drag or not 
	 * Add the MypopUpButton to Dragmanager if 
	 * dragged
	 */
	 private var isDraging:Boolean = false ; 
	override protected function mouseMoveHandler(event:MouseEvent):void
	{
		var pt:Point = new Point(event.localX, event.localY);
       	pt = DisplayObject(event.target).localToGlobal(pt);
        var mouseDownPoint:Point = globalToLocal(pt);
        var DRAG_THRESHOLD:int=6;
        
        
        if(event.target is  PivotPopUpButton )
		{
			//if(event.target is UIComponent  ) return ;
			if(!isDraging)
			
			if (event.buttonDown && mouseDownPoint &&(Math.abs(mouseDownPoint.x - pt.x) > DRAG_THRESHOLD ||Math.abs(mouseDownPoint.y - pt.y) > DRAG_THRESHOLD))
        	{
        		
        		isDraging = true ;
            	if (dragEnabled && !DragManager.isDragging && mouseDownPoint)
            	{
            		
            		var dragSource:DragSource= new DragSource();
            		dragSource.addData([PivotPopUpButton(event.target).label], "items");
            		DragManager.doDrag(this, dragSource, event, dragImage,
                    		       			 0, 0, 0.5, dragMoveEnabled);
            	}
            }
    	}
    		
    	super.mouseMoveHandler(event);
  	}		
 	
 	/**
 	 * dragOverHandler
 	 */
 	  
	override protected function dragOverHandler(event:DragEvent):void
	{
		
		if(event.ctrlKey) 
		{ 
			event.action = DragManager.COPY;
		}
		else if (event.shiftKey) 
		{ 
			event.action = DragManager.LINK;
		}
		else 
		{ 

			event.action = DragManager.MOVE;
		}
		var field:String;
		var index:int;
		if (event.isDefaultPrevented())
        	return;
		if (event.dragSource.hasFormat("items") )
  		{
  			var items:Array = event.dragSource.dataForFormat("items") as Array;
  			
  			 if(items.length == 0) return ;
             else
             {
             	if(items[0].hasOwnProperty("label"))
	            	field = items[0].label as String;
			  	else
					field=items[0] as String ;
             }
            if(field == "All") return ; 
            if( items[0] is mx.olap.OLAPAxisPosition)
            {
            	hideDropFeedback(event);
           		DragManager.showFeedback(DragManager.NONE);
           		return;
            	
            }
           	
           	if(event.dragInitiator is List)
           	{
           		index = (pivotComponent.rowFields.indexOf(field) + pivotComponent.columnFields.indexOf(field) + 
           				pivotComponent.slicerFields.indexOf(field) + pivotComponent.displayedFacts.indexOf(field));
           		if(index != -4) 
           		{
           			hideDropFeedback(event);
           			DragManager.showFeedback(DragManager.NONE);
           			return;
           			
           		}
  				   
  				var pt:Point = new Point(event.localX, event.localY);
            	pt = DisplayObject(event.target).localToGlobal(pt);
            	pt = listContent.globalToLocal(pt);
            	var rect:Object = findHeaderRenderer(pt);
            	if(rect && rect.type == "cellData")
        	    	{
            			if(pivotComponent.rowFields.length == 0 && pivotComponent.columnFields.length == 0 )
            			{
            				hideDropFeedback(event);
           					DragManager.showFeedback(DragManager.NONE);
           					return;
            				
            			} 
            			
            			index= pivotComponent.facts.indexOf(field);
            			if(index == -1)
            			{
            				hideDropFeedback(event);
           					DragManager.showFeedback(DragManager.NONE);
           					return;
            			}
            			
            		}      
           	}
        	var show:Boolean = insideHeader(event);
           	DragManager.showFeedback(show ? DragManager.COPY : DragManager.NONE);
           	showDropFeedback(event);
            return;
        }

		hideDropFeedback(event);
	    DragManager.showFeedback(DragManager.NONE);
	}
 	
 	/**
 	 * dragDropHandler
 	 * Here we add the dropped Field into pivotComponent.rowFields or pivotComponent.columnFields as 
 	 * user has dropped.
 	 */ 
	override protected function dragDropHandler(event:DragEvent):void
    {
    	getPivotComponent();
    	if (event.isDefaultPrevented())
        	return;
		hideDropFeedback(event);
        if (event.dragSource.hasFormat("items"))
        {
  	    	if (dropSprite)
            {
            	listContent.removeChild(dropSprite);
                dropSprite = null;
            }
            var pt:Point = new Point(event.localX, event.localY);
            pt = DisplayObject(event.target).localToGlobal(pt);
            pt = listContent.globalToLocal(pt);
            var rect:Object = findHeaderRenderer(pt);
            if(rect)
            {
                var items:Array = event.dragSource.dataForFormat("items") as Array;
                //Assuming that only one field will be droppped at a time
                var field:String;
                if(items.length == 0) return ;
                else
             		{if(items[0].hasOwnProperty("label"))
	                	field = items[0].label as String;
					else
						field=items[0] as String ;
             		}
             		
             	if(field == "All") 
             	{
             		hideDropFeedback(event);
             		DragManager.showFeedback(DragManager.NONE);
             		return ;
             	}
             	
             	if( items[0] is mx.olap.OLAPAxisPosition )
             	{
             		hideDropFeedback(event);
             		DragManager.showFeedback(DragManager.NONE);
             		return ;
             	}
             	
             	
             	if(event.dragInitiator is List )
             	{
					var indexC:int  = (pivotComponent.rowFields.indexOf(field) + pivotComponent.columnFields.indexOf(field) +
									 pivotComponent.slicerFields.indexOf(field) + pivotComponent.displayedFacts.indexOf(field));
           			if(indexC != -4) 
           			{
           				Alert.show("Dimension already exists");
           				return ;
           			}
           	  	}
                //If the field dropped is no there in the fields list
                // simply ignore it
               /*  if(pivotComponent.dimensions.indexOf(field) == -1 && pivotComponent.facts.indexOf(field) == -1)
                    return; */
                var newRowFields:Array = [];
                var newColumnFields:Array = [];
                
                //We ignore the possibility of a field on more than one axis
                trace("type "+rect.type+" "+field);
                switch(rect.type)
                {
                    case "row":
                        var index:int = pivotComponent.rowFields.indexOf(field);
                        newColumnFields = pivotComponent.columnFields;
                        if( index == -1)
                        {
                            var cIndex:int = pivotComponent.columnFields.indexOf(field);
							// If present on column remove it from there
                            if( cIndex != -1)
                            {
                                pivotComponent.columnFields.splice(cIndex, 1);
                                newColumnFields = pivotComponent.columnFields;
                                pivotComponent.columnFields=newColumnFields;
                                columnFieldsChanged = true;
                            }
                            pivotComponent.rowFields.splice(rect.index, 0 , field);
        					pivotComponent.rowFields=pivotComponent.rowFields;
        					
                            rowFieldsChanged = true;
                        }

                        //Case when there is a re-order of fields on an axis
                        else if(index != rect.index)
                        {
                            //First lets remove that field
                            newRowFields = pivotComponent.rowFields.splice(index, 1);
                             //Now re-insert it at the new place
                            pivotComponent.rowFields.splice(rect.index, 0 , field);
                           	pivotComponent.rowFields=pivotComponent.rowFields
                            rowFieldsChanged = true;
                        }
                        break;

                    case "col":
                        index = pivotComponent.columnFields.indexOf(field);
                        newRowFields = pivotComponent.rowFields;
                        if( index == -1)
                        {
                            var rIndex:int = pivotComponent.rowFields.indexOf(field);
							// If present on row remove it 
                            if( rIndex != -1)
                            {
                                pivotComponent.rowFields.splice(rIndex, 1);
                                newRowFields = pivotComponent.rowFields;
                               	pivotComponent.rowFields=newRowFields;
                               rowFieldsChanged = true;
                            }
         //                   removeFromList(field,"Dimensions");
                            pivotComponent.columnFields.splice(rect.index, 0 , field);
                            pivotComponent.columnFields=pivotComponent.columnFields;
                            columnFieldsChanged = true;
                        }
                        //Case when there is a re-order of fields on an axis
                        else if(index != rect.index)
                        {
                            //First lets remove that field
                           newColumnFields = pivotComponent.columnFields.splice(index, 1);

                             //Now re-insert it at the new place
                            pivotComponent.columnFields.splice(rect.index, 0 , field);
                         	pivotComponent.columnFields=pivotComponent.columnFields;  
                            columnFieldsChanged = true;
                        }
                        break;
                    case "cellData":
                        //Check that the thing dropped on cell area is indeed a fact
                        if(pivotComponent.facts.indexOf(field) != -1)
                        {	
                        	 
                          	var queryAxis:OLAPQueryAxis;
							 queryAxis = new OLAPQueryAxis(2);
            				/*sliceArray.pop();
            				sliceArray.push(field);
            				queryAxis.addSet(getNewSet(sliceArray));
            				currentQuery.setAxis(2, queryAxis);
            				//executeQuery();
							gridConfigChanged = true;                            
                            //measuresChanged = false;
                            */
                            removeFromList(field,"Measures");
                        	pivotComponent.displayedFacts.push(field);
                          	pivotComponent.displayedFacts=pivotComponent.displayedFacts;
                        }
                        else
                        Alert.show("Please drop a measure");
                        break;
                }
                
                gridConfigChanged =rowFieldsChanged || columnFieldsChanged || measuresChanged;
              //  invalidateProperties();
            }
        }
    } 
    
    override public function showDropFeedback(event:DragEvent):void
	{
		if(!insideHeader(event))
        	return;
		var pt:Point = new Point(event.localX, event.localY);
        pt = DisplayObject(event.target).localToGlobal(pt);
       	pt = listContent.globalToLocal(pt);
        var rect:Object = findHeaderRenderer(pt);
		// Dont drop
		if (dropSprite && (!rect || rect.type != "cellData"))
        {
        	listContent.removeChild(dropSprite);
            dropSprite = null;
        }
			
		if(rect)
        {
        	if(rect.type == "cellData")
            {
            	if(!dropSprite)
                {
                	dropSprite = new FlexSprite();
            		dropSprite.name = "cellDataOverlay";
                    dropSprite.alpha = 0.3;
                    listContent.addChildAt(dropSprite, listContent.getChildIndex(selectionLayer));
               	}
               	dropSprite.x = rect.x;
               	dropSprite.y = rect.y;
                if (rect.w > 0)
               	{
               		 var g:Graphics = dropSprite.graphics;
                     g.clear();
	           	 	 g.lineStyle(3,0);
                     g.drawRect(0, 0, rect.w-4, rect.h-4);
                 }
           	 }
            else
            {
            	if(!dropIndicator)
                {
                	var dropIndicatorClass:Class = getStyle("dropIndicatorSkin");
                    if (!dropIndicatorClass)
 	                	dropIndicatorClass = ListDropIndicator;
                    dropIndicator = new dropIndicatorClass()as IFlexDisplayObject;

                   	var vm:EdgeMetrics= viewMetrics;
                    drawFocus(true);
   		            dropIndicator.visible = true;
           		    listContent.addChild(DisplayObject(dropIndicator));
       			} 

           		if(pt.x > rect.x + rect.w/2)
	            	dropIndicator.x = rect.x+rect.w;
                else
                  	dropIndicator.x = rect.x;
	            dropIndicator.y = rect.y - getStyle("paddingTop");;
    	        dropIndicator.setActualSize(rect.h+getStyle("paddingTop") + getStyle("paddingBottom"), 3);
                DisplayObject(dropIndicator).rotation = 90;
           	}
        }
	}
		
    override protected function dragCompleteHandler(event:DragEvent):void
    {
    
    	super.dragCompleteHandler(event);
    	isDraging = false ;
    }
 	//-------------------------------------------------------------------------------
	//
	//		Methods
	//
	//------------------------------------------------------------------------------*/
	/**
	 * @private 
	 * If user has not provided any flat data , reset the pivotTable
	 */ 		
	private function initializePivotTable(event:Event):void
	{
		if(!flatDataProvider )
        	resetPivotTable();
	}
	/**
	 * @private
	 * returns the factory of headerRenderer
	 */ 
	private function olapClassFactory():ClassFactory
	{
		var factory:ClassFactory=new ClassFactory(PopupButtonCover);
		return factory;	
	}
	/**
	 * @private
	 * Bring the pivot Table to its defaul view
	 * clear columnField, pivotComponent.rowFields and use 
	 * sampleData 
	 */
	private function resetPivotTable():void
	{
		sampleDataInUse = true;
    	if(pivotComponent.rowFields.length!=0 )
        	pivotComponent.rowFields=[];
        if(pivotComponent.columnFields.length!=0)
        	pivotComponent.columnFields=[];
        this.defaultCellString = " ";
        super.dataProvider = getSampleData();
   	}
	/**
	 * @private 
	 * Preapares a dummy OLAPResult and returns it 
	 * to the OlapDataGrid
	 */ 
	private function getSampleData():OLAPResult
	{
		var olapResult:OLAPResult =  new OLAPResult;
	    for( var i:int = 0; i < 2; i++)
        {	
        	var p:OLAPAxisPosition; 
        	var m:OLAPMember;
        	var k:int;
			var resultAxis:OLAPResultAxis = new OLAPResultAxis;
       		//First create levels in a hierarchy
            var childLevel:OLAPLevel = new OLAPLevel;
	        var h:OLAPHierarchy = new OLAPHierarchy("                   ", "                   ");
     	    h.levels = new ArrayCollection([childLevel]);
		    //Now add the child members, No. of child members are -1 of 
            // DATA_PLACEHOLDER length
        	p = new OLAPAxisPosition;
            m = new OLAPMember(" " , " " );
            m.level = childLevel;
            p.addMember(m);
            resultAxis.addPosition(p);
            olapResult.setAxis(i, resultAxis);
		}
		
		return olapResult;
		
	}
	
	private function removeFromChildList(obj:DisplayObject, field:String, listName:String):void
    {
    	if(obj is UIComponent)
    	{
    		var length:int = UIComponent(obj).numChildren;
	  		for (var i:int = 0; i < length; i++)
    		{
    			if(listName=="Dimensions" && UIComponent(obj).getChildAt(i) is DimensionList)
    			{
    				var temp:ArrayCollection = List(UIComponent(obj).getChildAt(i)).dataProvider as ArrayCollection;
    				var index:int = List(UIComponent(obj).getChildAt(i)).dataProvider.getItemIndex(field);
    				List(UIComponent(obj).getChildAt(i)).dataProvider.removeItemAt(index);
    				return;
    			}
    			else if(listName == "Measures" && UIComponent(obj).getChildAt(i) is MeasuresList)
    			{
    				temp = List(UIComponent(obj).getChildAt(i)).dataProvider as ArrayCollection;
    				index = List(UIComponent(obj).getChildAt(i)).dataProvider.getItemIndex(field);
    				List(UIComponent(obj).getChildAt(i)).dataProvider.removeItemAt(index);
    				return;
    			}
    			else
    			{
    				removeFromChildList(UIComponent(obj).getChildAt(i), field, listName);
    			}
    		}
    	}
    }
    private function removeFromList(field:String,listName:String):void
	{
		var length:int = pivotComponent.numChildren;
	   	for (var i:int = 0; i < length; i++)
	   	{
	   		removeFromChildList(pivotComponent.getChildAt(i), field, listName);
       	}
    }
	
	/**
	 * @private
	 * called on completion of cube
	 */ 	
	private function handleDataChange(e:Event):void
	{
    	this.enabled = true;
        cubeCreationComplete = true;
        invalidateProperties();
    }
    
    private function setQueryFlag(event:Event):void
    {
    	newQuery=true;
    	gridConfigChanged=true;
    	invalidateProperties();
    }	
	
	/**
	 * @private 
	 * Prepares new query on every drag drop action from User
	 * Some optimisations possible here. 
	 */
	private function prepareNewQuery():void
	{
		if(!currentQuery)
        	currentQuery = new OLAPQuery;
        var colSet:OLAPSet;
        var measuresSet:OLAPSet;
        var slicerAxis:OLAPQueryAxis
        var i:int;
        var defaultmem:IOLAPMember
        var queryAxis:OLAPQueryAxis;
        this.headerRenderer=olapClassFactory();
 		
 		if(pivotComponent.rowFields.length!=0 && pivotComponent.columnFields.length!=0)
 		{
        	queryAxis = new OLAPQueryAxis(0);
        	colSet = new OLAPSet()
        	colSet = getNewSet(pivotComponent.columnFields);
        	measuresSet= new OLAPSet();
        	if(pivotComponent.displayedFacts.length)
        	{
				//measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[0]));
				for(i = 0; i < pivotComponent.displayedFacts.length; i++)
				{
					measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[i]));
				}        		
        	}
        	else
        	{
        		measuresSet.addElements(pivotComponent.cube.findDimension("Measures").findHierarchy("Measures").members);
        	}
        	colSet = colSet.crossJoin(measuresSet) as OLAPSet;
            queryAxis.addSet(colSet);
            currentQuery.setAxis(0, queryAxis);
            columnFieldsChanged = false;
        	
        	queryAxis = new OLAPQueryAxis(1);
            queryAxis.addSet(getNewSet(pivotComponent.rowFields));
            currentQuery.setAxis(1, queryAxis);
            rowFieldsChanged = false;
            
            if(pivotComponent.slicerFields.length!=0)
            {
            	queryAxis=new OLAPQueryAxis(2);
            	queryAxis.addSet( getNewSet(pivotComponent.slicerFields,false,true));
				currentQuery.setAxis(2,queryAxis);
            }
        }
    	
    	else if( pivotComponent.rowFields.length !=0 || pivotComponent.columnFields.length != 0)
    	{
    		var arr:ArrayCollection=new ArrayCollection;
    		if(pivotComponent.rowFields.length==0)
    		{
    			var cqueryAxis:OLAPQueryAxis=new OLAPQueryAxis(0);
    			var rowSet:OLAPSet=new OLAPSet 
    			colSet=new OLAPSet
    			var slicerSet:OLAPSet=new OLAPSet
    			colSet=getNewSet(pivotComponent.columnFields);
    			 measuresSet = new OLAPSet();
        		if(pivotComponent.displayedFacts.length)
        		{
				//measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[0]));
					for(i = 0; i < pivotComponent.displayedFacts.length; i++)
					{
						measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[i]));
					}        		
        		}
        		else
        		{
        			measuresSet.addElements(pivotComponent.cube.findDimension("Measures").findHierarchy("Measures").members);
        		}
        		colSet = colSet.crossJoin(measuresSet) as OLAPSet;
    			cqueryAxis.addSet(colSet);
    		 	rqueryAxis=new OLAPQueryAxis(1);
    			//var fl:int=0;
    			var rqueryAxis:OLAPQueryAxis=new OLAPQueryAxis(1);
    			defaultmem=pivotComponent.cube.findDimension("All").findAttribute("All").defaultMember;
    			arr.addItem(defaultmem);
    			
    			rowSet.addElements(arr);
    			rqueryAxis.addSet(rowSet);
    			if(pivotComponent.slicerFields.length!=0)
            	{
            		
            		slicerSet= getNewSet(pivotComponent.slicerFields,false,true);
					slicerAxis = new OLAPQueryAxis(2);
					slicerAxis.addSet(slicerSet);
					currentQuery.setAxis(2,slicerAxis);
            	}
    			currentQuery.setAxis(0,cqueryAxis);
    			currentQuery.setAxis(1,rqueryAxis);
    			columnFieldsChanged=false;	
  				rowFieldsChanged=false;
    			gridConfigChanged=false;			
    		}
    		
    		if(pivotComponent.columnFields.length==0)
    		{
    			rqueryAxis =new OLAPQueryAxis(1);
    			rqueryAxis.addSet(getNewSet(pivotComponent.rowFields));
    			cqueryAxis=new OLAPQueryAxis(0);
    			//defaultmem =pivotComponent.cube.findDimension("All").findAttribute("All").defaultMember;
    			defaultmem=pivotComponent.cube.findDimension("All").findAttribute("All").defaultMember;
    			arr.addItem(defaultmem);
    			colSet = new OLAPSet 
    			colSet.addElements(arr);
    			 measuresSet = new OLAPSet();
        		if(pivotComponent.displayedFacts.length)
        		{
					//measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[0]));
					for(i = 0; i < pivotComponent.displayedFacts.length; i++)
					{
						measuresSet.addElement(pivotComponent.cube.findDimension("Measures").findMember(pivotComponent.displayedFacts[i]));
					}        		
        		}
        		else
        		{
        			measuresSet.addElements(pivotComponent.cube.findDimension("Measures").findHierarchy("Measures").members);
        		}
        		colSet = colSet.crossJoin(measuresSet) as OLAPSet;
    			
    			cqueryAxis.addSet(colSet);
    			
    			
    			currentQuery.setAxis(0,cqueryAxis);
    			currentQuery.setAxis(1,rqueryAxis);
    			rowFieldsChanged=false;	
				columnFieldsChanged=false;
    			gridConfigChanged=false;		
    		
    			if(pivotComponent.slicerFields.length!=0)
            	{
            		
            		slicerSet= getNewSet(pivotComponent.slicerFields,false,true);
					slicerAxis = new OLAPQueryAxis(2);
					slicerAxis.addSet(slicerSet);
					currentQuery.setAxis(2,slicerAxis);
            	}
    			
    			
    		}
    	}	    
    	
    	if( pivotComponent.rowFields.length == 0 && pivotComponent.columnFields.length == 0 ) 
    	{
    		sampleDataInUse=true;
    		invalidateDisplayList();
    	}
	}
	
	/**
	 * @private 
	 * fillFilteredMembers
	 * It populates with filteredMembersList with the members selected
	 * for filtering
	 */ 	  
	private var currentValidMembersList:Array=new Array;
	private function fillFilteredMembers(row:Array,column:Array,slicer:Array):void
	{
		var i:int=0;
		//filteredMembersList=new Array;
		for(i=0;i<row.length;i++)
		{
			if(!filteredMembersList.hasOwnProperty(row[i]))
				filteredMembersList[row[i]]=pivotComponent.cube.findDimension(row[i]).findAttribute(row[i]).members
		}
				
		for(i=0;i<column.length;i++)
		{
			if(!filteredMembersList.hasOwnProperty(column[i]))
				filteredMembersList[column[i]]=pivotComponent.cube.findDimension(column[i]).findAttribute(column[i]).members			
				
		}
		
		for(i=0;i<slicer.length;i++)
		{
			if(!filteredMembersList.hasOwnProperty(slicer[i]))
				filteredMembersList[slicer[i]]=pivotComponent.cube.findDimension(slicer[i]).findAttribute(slicer[i]).members			
		}
		pivotComponent.filterMembers=filteredMembersList;
		//fillValidMembers(row,column,slicer);
				
	}
	
	private function fillValidMembers(row:Array,column:Array,slicer:Array):void
	{
		var i:int=0;
		currentValidMembersList=new Array;
		for(i=0;i<row.length;i++)
		{
			//if(currentValidMembersList.hasOwnProperty(row[i]))
				currentValidMembersList[row[i]]=filterTheMembers(pivotComponent.cube.findDimension(row[i]).findAttribute(row[i]).members , row[i]);
		}
		for(i=0;i<column.length;i++)
		{
			//if(!currentValidMembersList.hasOwnProperty(column[i]))
				currentValidMembersList[column[i]]=filterTheMembers(pivotComponent.cube.findDimension(column[i]).findAttribute(column[i]).members,column[i]);
		}
		for(i=0;i<slicer.length;i++)
		{
			//if(!currentValidMembersList.hasOwnProperty(slicer[i]))
				currentValidMembersList[slicer[i]]=filterTheMembers(pivotComponent.cube.findDimension(slicer[i]).findAttribute(slicer[i]).members,slicer[i]);
		}
		
				
	}	
	
	private function filterTheMembers(members:IList,name:String):IList
	{
		var i:int=0;
		var newMembers:IList=new ArrayCollection;
		for(i=0;i<members.length;i++)
		{
			if(memberPresent(members[i],name))
				newMembers.addItem(members[i]);
		}
		
		return newMembers;
	}
	
	private function memberPresent(member:OLAPMember,name:String):Boolean
	{
		var i:int=0;
		var membersArray:IList=filteredMembersList[name];
		for(i=0;i<membersArray.length;i++)
		{
			if(OLAPMember(membersArray[i]).displayName==member.displayName)
			return true;
		}
		
		return false;
	}		
					

	/**
	 * @private 
	 * adds a AsyncResponder 
	 */ 
	private function executeQuery():void
	{
		
	    try
	    {	
			var token:AsyncToken = pivotComponent.cube.execute(currentQuery);
        	token.addResponder(new AsyncResponder(setDataProvider, setDataProvider));
        	CursorManager.setBusyCursor();
     	}
     	catch(e:Error)
    	{
        	Alert.show(e.message);
    	}	
	}
	/**
	 * @private 
	 * assign result to OLAPDataGrid
	 */ 	  
	 private function setDataProvider(value1:Object, token:Object=null):void
	 {
	 	CursorManager.removeBusyCursor();
	 	try
       	{
       		if(!value1 || !(value1 is OLAPResult))
            {
            	
            	return;
            }
            	
            	
        	sampleDataInUse = false;
        	var result:OLAPResult = value1 as OLAPResult;
        	super.dataProvider = value1 as OLAPResult;
        	dispatchEvent(new Event("updateSlicerBox"));
        }
       	catch(error:Error)
       	{
       		;
       	}
	}
	
	/**
	 * @private
	 */ 

	private function getMeasures():OLAPSet
    {
	    var s:OLAPSet = new OLAPSet;
        var dim:OLAPDimension;
        if(pivotComponent.cube && (dim = OLAPDimension(pivotComponent.cube.findDimension("Measures"))))
        {
        	var value:ArrayCollection = ArrayCollection(dim.members);
            var m:OLAPMember;
            var defaultMeasure:OLAPMeasure = dim.members[0];
            //Include the measures Specified
            for( var i:int = 0; i < value.length; i++)
            	if(value[i] == defaultMeasure)
                	s.addElement(value[i]);
                else if(pivotComponent.displayedFacts.indexOf(value[i].name)!=-1 && 
                	(m = OLAPMember(dim.findMember(value[i].name))))
            s.addElement(value[i]);
        }
        return s;
    }
	
	/**
	 * @private
	 */ 
	private function filter(event:EnableChangeEvent):void
	{
		FilterFunction(event.param1,event.param);
		pivotComponent.dispatchEvent(new Event("filterChanged"));
	}
		
	/**
	 * @private
	 * filterFunction
	 */ 
	public  function  FilterFunction(filterMembers:Array,dimension:String):void
	{
		var query:OLAPQuery =currentQuery;
		var queryAxis:OLAPQueryAxis;;
		var colSet:OLAPSet;
	    var rSet:OLAPSet;
		this.filterMembers=filterMembers;
		var collection:ArrayCollection=filteredMembersList[dimension];
		collection.filterFunction=filterNames;
		collection.refresh();
		gridConfigChanged=true;
		return;	
	}
	/**
	 * @private 
	 * Generates resultant OLAPSET with the consideration of filteredMembers
	 */ 	
	private function getNewSet(Field:Array, isMeasure:Boolean = false,isSlicer:Boolean = false ):OLAPSet
	{
		
		var Set:OLAPSet=new OLAPSet;
		var tSet:OLAPSet;
		getPivotComponent();
		fillValidMembers(pivotComponent.rowFields,pivotComponent.columnFields,pivotComponent.slicerFields);
		
		if(!visibleHeaderInfos) 
			return null;
		if (isMeasure)
        {
     		if( Field.length>0)
          	{
          		Set.addElement(pivotComponent.cube.findDimension("Measures").findMember(Field[0]));
          		Set.hierarchize();
          	}
        			
        }
       
        if(isSlicer)
        {
        	
        	var memList:ArrayCollection = currentValidMembersList[Field[0]];
        	memList.filterFunction = filterAll;
        	memList.refresh();
        	Set.addElements(memList);
        	
	 		for(var i:int=1;i<Field.length;i++)
 			{
 				tSet = new OLAPSet();
 				memList = currentValidMembersList[Field[i]];
 				memList.filterFunction=filterAll;
 				memList.refresh();
 				tSet.addElements( memList );
				Set=Set.crossJoin(tSet) as OLAPSet;
			} 
        }	
       
        else
        {
			Set.addElements(currentValidMembersList[Field[0]]);
	 		for(i =1;i<Field.length;i++)
 			{
 				tSet = new OLAPSet();
 				tSet.addElements(currentValidMembersList[Field[i]]);
				Set=Set.crossJoin(tSet) as OLAPSet;
			} 
      
        }
        
       
		return Set;  		
 	}							


	private function filterAll(item:Object):Boolean
	{
		if(OLAPMember(item).displayName=="(All)") return false;
		else return true;
	}	
	/**
	 * @private
	 */ 
	private function filterNames(item:Object):Boolean 
	{ 
		var fstr:String = String(item.name);
		if(filterMembers.indexOf(fstr)!=-1) 
			return false; 
		return true;
	}

	/**
	 * @private
	 * return true if mouse is within a header
	 */ 
	private function insideHeader(event:DragEvent):Boolean
	{
		if(!visibleHeaderInfos) 
			return false;
		if(event.target==null)
			return true;
		if(event)
		{
			var item:IListItemRenderer;
			var pt:Point = new Point(event.localX, event.localY);
            pt = DisplayObject(event.target).localToGlobal(pt);
            pt = listContent.globalToLocal(pt);
   			if(pt.y < 0)
	       		return false;
  			var lastItem:IListItemRenderer
    		var rootItem:IListItemRenderer;
            var rowHeadersWidth:Number = 0;
            var colHeadersHeight:Number = 0;
			//Check if there is a row axis 
	         if(visibleHeaderInfos.length > 1)
    	    	{
        	    	lastItem = visibleHeaderInfos[visibleHeaderInfos.length-2].headerItem;
            	    rowHeadersWidth = lastItem ? lastItem.width+lastItem.x : 0
            	}
   			//Check if there is a column axis 
       		if(visibleHeaderInfos.length > 0)
        		{
    	        	rootItem = visibleHeaderInfos[visibleHeaderInfos.length-1].headerItem;
          	    	colHeadersHeight = headerRowInfo[0].height;
       			}

   			if(pt.x < rowHeadersWidth && pt.y > colHeadersHeight)
	       		return false;

  			//For Cell data area
			 if(pt.x > rowHeadersWidth && pt.y > colHeadersHeight)
    			 return true;

  			//For row axis
  			if(lastItem && pt.x > 0 && pt.x < lastItem.x+lastItem.width
                		&& pt.y > 0 && pt.y < lastItem.y + lastItem.height)
	       		return true;

    	  //For column axis
    		if(rootItem && pt.x > rootItem.x && pt.x < rootItem.x+rootItem.width)
        		return true;

		}
			
		return false;
	}	
			
	/**@private
	 * finds which headerRenderer the mouse is currently in
	 */
	private function findHeaderRenderer(pt:Point):Object
	{
		if(!visibleHeaderInfos) 
			return null;
		var item:DisplayObject;
		var rowItem:IListItemRenderer;
        var columnItem:DisplayObject;
        var rootItem:IListItemRenderer;
		// rect defines the header
        var rect:Object = null;
       	var rowHeadersWidth:Number = 0;
        var colHeadersHeight:Number = 0;
		colHeadersHeight = groupedColumns ?  headerRowInfo[0].height : 0;
				
		// For row Axis
		if(visibleHeaderInfos.length == 1)
      		rect = {x:0, y:0, h:colHeadersHeight, w:0, index:0, 
            				    		    type:"row", name:""};
		else if(visibleHeaderInfos.length > 1)
			for( var i:int = 0; i < visibleHeaderInfos.length-1; i++)
			{
				rowItem = visibleHeaderInfos[i].headerItem;
				rowHeadersWidth = rowItem ? rowItem.width +rowItem.x : 0;
				if(rowItem && rowItem is DisplayObject && pt.x > rowItem.x && pt.x < rowItem.x+rowItem.width
                							    			&& pt.y > 0 && pt.y < rowItem.y + rowItem.height)
                {
                	item =  rowItem as DisplayObject;
                    if( item is PopupButtonCover)
                    	rect = {x:item.x, y:item.y, h:item.height, w:item.width, index:i, 
                        	        			type:"row", name:PopupButtonCover(item).label};
                        
                    else
                    	rect = {x:item.x, y:item.y, h:item.height, w:item.width, index:i, 
                                			type:"row", name:IDataRenderer(item).data.headerText};
                        
                	if(pt.x > rowItem.x+rowItem.width/2)
                    	rect.index++;
                     break;
                  } 	
			}
		if(!rect && pt.x > rowHeadersWidth)
        {
        	//For Cell data area
            if(pt.y > colHeadersHeight && pt.y < listContent.height )
            	rect = {x:rowHeadersWidth, y:colHeadersHeight, h:listContent.height - colHeadersHeight, 
                			        w:listContent.width - rowHeadersWidth , index:-1, type:"cellData"};
            
            //For column axis
            else if(visibleHeaderInfos.length > 0)
            {
           		rootItem = visibleHeaderInfos[visibleHeaderInfos.length-1].headerItem;
                pt = this.localToGlobal(pt);
               	pt = DisplayObject(rootItem).globalToLocal(pt);
                var numChildren:int = DisplayObjectContainer(rootItem).numChildren;
                for( i = 0; i < numChildren; i++)
                {
                	columnItem = DisplayObjectContainer(rootItem).getChildAt(i);
                    if(columnItem && pt.x > columnItem.x && pt.x <= columnItem.x+columnItem.width || i == numChildren - 1 )
                    {
                    	var point:Point = new Point(columnItem.x, columnItem.y);
                        point = DisplayObject(rootItem).localToGlobal(point);
                        point = this.globalToLocal(point);
                        rect = {x:point.x, y:point.y, h:columnItem.height, w:columnItem.width, index:i, 
                        	        type:"col", name:IDropInListItemRenderer(columnItem).listData.label};
              			if(pt.x > columnItem.x + columnItem.width/2)
                        	rect.index++;
                    	break;
                	 }
           		}
            }
        }	
		return rect;	
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

	private function cubeCompleteHandler(event:Event):void
	{
		fillFilteredMembers(pivotComponent.rowFields,pivotComponent.columnFields,pivotComponent.slicerFields);
		var eventObj:Event=new Event("queryChanged");
		this.dispatchEvent(eventObj);
		eventObj.stopPropagation();
		
	}		
	
	private function deleteDimensions(event:EnableChangeEvent):void
	{
		getPivotComponent();
		var pos:String = event.param2;
		
		var targetString:String = event.param ;
		var newFields:Array;
		var bFlag:Boolean = false ;
		if(pos == "")
		{
			bFlag = true ;	
			var index:Number = pivotComponent.rowFields.indexOf(event.param);
			if(index != -1) pos = "row" ;
			else 
			{
				index = pivotComponent.columnFields.indexOf(event.param);
				if(index != -1) pos = "col" ;
				else
				{
					index = pivotComponent.slicerFields.indexOf(event.param)
					if(index != -1) pos = "sli";
				}
			}
		
		}
		
		if( !(( pivotComponent.rowFields.length +  pivotComponent.columnFields.length )==1 ))
		{ 
			switch(pos)
			{
				case "row" : index = pivotComponent.rowFields.indexOf(targetString);
						  pivotComponent.rowFields.splice(index, 1);
                          newFields = pivotComponent.rowFields;
                          pivotComponent.rowFields = newFields;
						  rowFieldsChanged = true ;
						  break ;
				case "col" : 
						  index = pivotComponent.columnFields.indexOf(targetString);
						  pivotComponent.columnFields.splice(index, 1);
                          newFields = pivotComponent.columnFields;
                          pivotComponent.columnFields = newFields;
						  columnFieldsChanged = true ;
						  break ;
		   		case "sli" : 
		   				  index = pivotComponent.slicerFields.indexOf(targetString);
						  pivotComponent.slicerFields.splice(index, 1);
                          newFields = pivotComponent.slicerFields
                          pivotComponent.slicerFields = newFields;
						  break ;
			}				  
		
		}
		
		else
			{	
				sampleDataInUse = true ;
				pivotComponent.rowFields = [];
				pivotComponent.columnFields = [];
				pivotComponent.slicerFields = [];
				pivotComponent.filterMembers = [];
				filteredMembersList = new Array;
				invalidateDisplayList();
				dispatchEvent(new Event("removeSlicer"));
				pivotComponent.dispatchEvent(new Event("resetChart"));
				this.dataProvider = null;
			}	
	
	if(bFlag = true )
	{					  
		var eventObj:EnableChangeEvent = new EnableChangeEvent("deleteDimension");
		eventObj.param = targetString ;
		eventObj.param2 = pos ;
		pivotComponent.dispatchEvent(eventObj);
	}
	
	}
	
	private function resetPivotGrid(event:Event):void
	{
			sampleDataInUse = true ;
			pivotComponent.rowFields = [];
			pivotComponent.columnFields = [];
			pivotComponent.slicerFields = [];
			pivotComponent.filterMembers = [];
			filteredMembersList = new Array;
			invalidateDisplayList();
			dispatchEvent(new Event("removeSlicer"));
			this.dataProvider = null;
		
	}
	

}
}