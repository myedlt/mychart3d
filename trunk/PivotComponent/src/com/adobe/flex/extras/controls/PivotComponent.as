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

package com.adobe.flex.extras.controls
{
	import com.adobe.flex.extras.controls.myEvent.EnableChangeEvent;
	import com.adobe.flex.extras.controls.pivotComponentClasses.OLAPChartExtension;
	import com.adobe.flex.extras.controls.pivotComponentClasses.OLAPDataGridExtension;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.CubeEvent;
	import mx.olap.OLAPAttribute;
	import mx.olap.OLAPCube;
	import mx.olap.OLAPDimension;
	import mx.olap.OLAPMeasure;
	import mx.olap.OLAPMember;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
 	 *  Dispatched when either dataProvider, dimensions
 	 *  or measures that can change the cube, is changed
 	 */
	[Event(name="dataChanged", type="flash.events.Event")]
	
	/**
 	 *  Dispatched when either rowFields or columnFields etc...
 	 *  that can change only the result to be shown but not the
 	 *  cube, is changed
 	 */
	[Event(name="queryChanged", type="flash.events.Event")]
	[Event(name="dimensionDelete", type="flash.events.Event")]
	
	
	/**
	 *  The PivotComponent is a container that holds
	 *  a DimensionList, MeasuresList, OLAPChartExtension
	 *  and / or OLAPDataGridExtension
	 * 
	 *  <p> It prepares a cube depending on its <code>dataProvider</code>
	 *  and underlying DimensionList and MeasuresList's <code>dataProvider</code>.
	 *  This cube can be used by  OLAPChartExtension and/or OLAPDataGridExtension
	 *  to run queries and display result
	 * 
 	 *  @mxml
 	 *  
     *  <p>The <code>&lt;mx:PivotComponentt&gt;</code> tag inherits all the
     *  properties of its parent classes and adds the following properties:</p>
     *  
     *  <pre>
     *  &lt;mx:PivotComponent
     *    <strong>Properties</strong>
     *    columnFields="<i>No default/i>"
     *    dataProvider="<i>No default/i>"
     *    dimensions="<i>No default/i>"
     *    displayedFacts="<i>No default/i>"
     *    facts="<i>No default/i>"
     *    filterMembers="<i>No default/i>"
     *    rowFields="<i>No default/i>"
     *    slicerFields="<i>No default/i>"
     * 
     *    <strong>Events</strong>
 	 *    queryChanged="<i>Event; No default</i>"
 	 *    dataChanged="<i>Event; No default</i>"   
     *  /&gt;
 	 *  </pre>
     */
	public class PivotComponent extends Canvas 
	{
		private var dimensionsChanged:Boolean = false;
		private var measuresChanged:Boolean = false;
		private var dataChanged:Boolean = false;
		private var rowsChanged:Boolean = false;
		private var columnsChanged:Boolean = false;
		private var slicersChanged:Boolean = false;
		private var filtersChanged:Boolean = false;
		private var displayedFactsChanged:Boolean = false;
		private var slicerFlag:Boolean=false;
		private var rowFlag:Boolean=false;
		private var columnFlag:Boolean=false;
		public var oldtempSelection:Array = new Array;
		
		public function PivotComponent():void
		{
			super();
			this.addEventListener("filterChanged", filterChange);
			this.addEventListener("deleteDimension",deletePropog);
			this.addEventListener("resetPivotTable",resetGrid);
			this.addEventListener("resetChart",resetChart);
			this.addEventListener("deleteChartSlicer",deleteChartSlicer);
			//this.a	ddEventListener("deleteDimensionForGrid",deletePropogForGrid);
			cube.addEventListener(CubeEvent.CUBE_COMPLETE,cubecompleteHandler);
		}
		
		//--------------------------------------------
		// dataProvider
		//--------------------------------------------
		[Bindable]
		private var _dataProvider:Object;
		
		/**
		 *  Assigns dataProvider to cube
		 */
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			if(value is String)				//treat is as URL
			{
				var hs:HTTPService = new HTTPService();
				hs.url=value.toString();
				hs.makeObjectsBindable=false;
				hs.addEventListener(ResultEvent.RESULT, serviceResultHandler);
				hs.send();
			}
			else							//treat it as collection
			{
				cube.dataProvider = value as ICollectionView;
			}		
				
			dataChanged = true;
		}
		
		/**
		 *  @private
		 */
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		//---------------------------------------
		// 	rowFields
		//---------------------------------------
		[Bindable]
		private var _rowFields:Array = [];
		
		/**
		 *  Array of dimensions on rowAxis
		 */
		public function set rowFields(value:Array):void
		{
			_rowFields = value;
			rowsChanged = true;
			invalidateProperties();
		}
		
		/**
		 *  @private
		 */
		public function get rowFields():Array
		{
			return _rowFields;
		}
		
		//----------------------------------------
		//	columnFields
		//----------------------------------------
		[Bindable]
		private var _columnFields:Array = [];
		
		/**
		 *  Array of dimensions on columnAxis
		 */
		public function set columnFields(value:Array):void
		{
			_columnFields = value;
			columnsChanged = true;
			invalidateProperties();
		}
		
		/**
		 *  @private
		 */
		public function get columnFields():Array
		{
			return _columnFields;
		}
		
		//-----------------------------------------
		//	slicerFields
		//-----------------------------------------
		[Bindable]
		private var _slicerFields:Array = [];
		
		/**
		 * Array of dimensions on slicerAxis
		 */
		public function set slicerFields(value:Array):void
		{
			_slicerFields = value;
			slicersChanged = true;
			invalidateProperties();
		}
		
		/**
		 *  @private
		 */
		public function get slicerFields():Array
		{
			return _slicerFields;
		}
		
		//------------------------------------------
		//	filterMembers
		//------------------------------------------
		[Bindable]
		private var _filterMembers:Array = [];
		
		/**
		 *  Array of filtered values in dimensions
		 */
		public function set filterMembers(value:Array):void
		{
			_filterMembers = value;
			filtersChanged = true;
			invalidateProperties();
		}
		
		/**
		 *  @private
		 */
		public function get filterMembers():Array
		{
			return _filterMembers;
		}
		
		
		/**
		 * The uncommited List of members for the itemRendering / recycling problem
		 */
		 
		
		
		//-----------------------------------------
		//	displayedFacts
		//-----------------------------------------
		[Bindable]
		private var _displayedFacts:Array = new Array();
		
		/**
		 *  Measures to be shown as result
		 */
		public function set displayedFacts(value:Array):void
		{
			_displayedFacts = value;
			displayedFactsChanged = true;
			invalidateProperties();			
		}
		
		/**
		 *  @private
		 */
		public function get displayedFacts():Array
		{
			return _displayedFacts;
		}
		
		//--------------------------------------
		//	dimensions
		//--------------------------------------
		[Bindable]
		private var _dimensions:Array;
		
		/**
		 *  Dimensions of the cube
		 */
		public function set dimensions(value:Array):void
		{
			var newCube:OLAPCube=new OLAPCube;
			newCube.dataProvider=cube.dataProvider;
			newCube.addEventListener(CubeEvent.CUBE_COMPLETE,cubecompleteHandler);
			cube=newCube;
			
			
			
			_dimensions = value;
			var dimensionsList:IList=new ArrayCollection;
			cube.dimensions=dimensionsList;
			for(var i:int = 0; i < value.length; i++)
			{
				var d:OLAPDimension = new OLAPDimension(value[i]);
                var attr:OLAPAttribute = d.addAttribute(value[i], value[i]) as OLAPAttribute;
               // attr.dataFunction = titleFunction;
               // attr.dataCompareFunction = compareFunction;
                dimensionsList.addItem(d);
   			}
   			if(columnFields.length==0 || rowFields.length == 0 )
   			{
   				d = new OLAPDimension("All");
   				d.addAttribute("All","All");
   				dimensionsList.addItem(d);
   			}
   			cube.dimensions=dimensionsList;
			dimensionsChanged = true;
			cube.measures=cubeMeasures;
			invalidateProperties();

		}
		
		/**
		 * Compare function
		 */
		 
		 
		/**
		 *  @private
		 */
		public function get dimensions():Array
		{
			return _dimensions;
		}
		
		//-----------------------------------------
		//	facts
		//-----------------------------------------
		[Bindable]
		private var _facts:Array;
		
		/**
		 * Facts of the cube
		 */
		 private var cubeMeasures:ArrayCollection = new ArrayCollection();
		public function set facts(value:Array):void
		{
			_facts = value;
			
			for(var i:int = 0; i < value.length; i++)
			{
				var m:OLAPMeasure = new OLAPMeasure(value[i], value[i]);
				m.dataField = value[i];
				cubeMeasures.addItem(m);		
			}
			cube.measures = cubeMeasures;
			measuresChanged = true;
			invalidateProperties();
		}
		
		public function modifyFacts(measureName:String,aggregatorName:String="",aggregatorObject:Object=null):void
		{
			var dim:OLAPDimension;
			if(cube && (dim = OLAPDimension(cube.findDimension("Measures"))))
  			{
	  			var value:ArrayCollection = ArrayCollection(dim.members);
    			var m:OLAPMember;
        		 //Include the measures Specified
        		for( var i:int = 0; i < value.length; i++)
        	  	{
        	  		if(OLAPMeasure(value[i]).displayName==measureName)
        	  			{
        	  				if(aggregatorName!="") 
        	  				{
        	  					OLAPMeasure(value[i]).aggregator=aggregatorName
        	  				}
        	  				else
        	  				if(aggregatorObject!=null)
        	  				{
        	  					OLAPMeasure(value[i]).aggregator=aggregatorObject;
        	  				}
        	  				break;
        	  			}			
           	   }
           	   
           	   
           	   
           	   
        	}
		
		   measuresChanged=true;
		   invalidateProperties();
		}	
		/**
		 *  @private
		 */
		public function get facts():Array
		{
			return _facts;
		}
		
		//-----------------------------------------
		//	cube
		//-----------------------------------------
		[Bindable]
		private var _cube:OLAPCube = new OLAPCube();
		
		/**
		 *  Cube of this pivot component
		 */
		public function set cube(value:OLAPCube):void
		{
			_cube = value;
		}
		
		/**
		 *  @private
		 */
		public function get cube():OLAPCube
		{
			return _cube;
		}
		
		//----------------------------------------------------------------------------------------
		//
		//						Overridden Methods
		//
		//-----------------------------------------------------------------------------------------
		private var count:int=0;
		/**
		 *  @inheritDoc
		 */
		override protected function commitProperties():void
		{
			
			if(rowsChanged || columnsChanged || slicersChanged || displayedFactsChanged)
			{
				if(slicersChanged==true) slicerFlag=true;
				if(rowsChanged==true) rowFlag=true;
				if(columnsChanged==true) columnFlag=true;
				
				rowsChanged = false;
				columnsChanged = false;
				slicersChanged = false;
				filtersChanged = false;
				displayedFactsChanged = false;
				setDimensions();
				
				
				/* if(dimensions && facts)
				{
					if(cube.dataProvider)
						cube.refresh();
				} */
				//dispatchChangeForChildren("queryChanged");
			}
			if((measuresChanged || dimensionsChanged || dataChanged) && facts && facts.length)
			{
				dataChanged = false;
				dimensionsChanged = false;
				measuresChanged = false;
				if(dimensions && facts && ( rowFields.length || columnFields.length || slicerFields.length))
				{
					if(cube.dataProvider)
						cube.refresh();
				}
				if(!(rowsChanged || columnsChanged || slicersChanged || displayedFactsChanged))
				{
					dispatchChangeForChildren("dataChanged");
				}
				count++;	
			}
		}
		
		private function setDimensions():void
		{
			var nArray:Array=new Array;
			if(rowFields || columnFields || slicerFields )
			{
				nArray=rowFields.concat(columnFields);
				nArray=nArray.concat(slicerFields);
				dimensions=nArray;
			}
		}
		
		//--------------------------------------------------------------------------------
		//
		//								Methods
		//
		//---------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  This method dispatches change event to pivot component's children
		 */
		private function dispatchChangeForChildren(eventName:String):void
	   	{
	   		var length:int = this.numChildren;
	   		for (var i:int = 0; i < length; i++)
	   		{
	   			dispatchChangeForInnerChildren(this.getChildAt(i), eventName);
       		}
    	}
    	
    	/**
    	 *  @private 
    	 *  This method dispatches change event to children of pivot component's children recursively
    	 */
    	private function dispatchChangeForInnerChildren(obj:DisplayObject, eventName:String):void
    	{
    		if(obj is UIComponent)
    		{
    			var length:int = UIComponent(obj).numChildren;
	   			for (var i:int = 0; i < length; i++)
    			{
    				if(UIComponent(obj).getChildAt(i) is OLAPChartExtension)
    				{
    					OLAPChartExtension(UIComponent(obj).getChildAt(i)).dispatchEvent(new Event(eventName));
    				}
    				else if(UIComponent(obj).getChildAt(i) is OLAPDataGridExtension)
    				{
    					OLAPDataGridExtension(UIComponent(obj).getChildAt(i)).dispatchEvent(new Event(eventName));
    				}
    				else
    				{
    					dispatchChangeForInnerChildren(UIComponent(obj).getChildAt(i), eventName);
    				}
    			}
    			if(UIComponent(obj) is OLAPChartExtension)
    			{
    				OLAPChartExtension(UIComponent(obj)).dispatchEvent(new Event(eventName));
    			}
    			else if(UIComponent(obj) is OLAPDataGridExtension)
    			{
    				OLAPDataGridExtension(UIComponent(obj)).dispatchEvent(new Event(eventName));
    			}
    		}
    	}
    	
    	/**
		 * @private
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
    	
    	//---------------------------------------------------------------------------------------
    	//
    	//						Event handlers
    	//
    	//---------------------------------------------------------------------------------------
    	
    	private function serviceResultHandler(event:ResultEvent):void
		{
			var data:ICollectionView = new ArrayCollection(event.result.root.row);
			cube.dataProvider = data;
		}
		
		private function filterChange(event:Event):void
		{
			dispatchChangeForChildren("queryChanged");
		}
		
		private function cubecompleteHandler(event:CubeEvent):void
		{
			if(slicerFlag)
			{
				dispatchChangeForChildren("queryChanged");
				slicerFlag=false;
			}
			
			if(rowFlag)
			{
				dispatchChangeForChildren("rowsChaged");
				rowFlag=false;
			}	
			
			if(columnFlag)
			{
				dispatchChangeForChildren("columnsChaged");
				columnFlag=false;
			}
			dispatchChangeForChildren("cubeChanged");
		}	
			
	public var deleteName:String ;
	public var deletePos:String;	
	private function deletePropog(event:EnableChangeEvent):void
	{
		deleteName = event.param;
		deletePos = event.param2;
		dispatchChangeForChildren("dimensionDelete");	
	}		
		
	private function resetGrid(event:Event):void
	{
		dispatchChangeForChildren("resetPivotTable");
	}	
	
	private function resetChart(event:Event):void
	{
		dispatchChangeForChildren("resetOLAPChart");
	}
	private function deleteChartSlicer(event:Event):void
	{
		
	}
			
	}
}