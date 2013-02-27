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

package com.adobe.flex.extras.controls.pivotComponentClasses.olapChartClasses
{
	import mx.charts.AxisRenderer;
	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.IAxis;
	import mx.charts.chartClasses.Series;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.BarSeries;
	import mx.charts.series.BubbleSeries;
	import mx.charts.series.ColumnSeries;
	import mx.charts.series.LineSeries;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.olap.IOLAPAxisPosition;
	import mx.olap.IOLAPCell;
	import mx.olap.IOLAPMember;
	import mx.olap.IOLAPResult;
	import mx.olap.OLAPResult;
	
	use namespace mx_internal;
	
	/**
	 *  The OLAPChart control represents OLAPResult as a series of  items
	 *  whose shape is determined by <code>type</code> property and
 	 *  whose height is determined by values in the data.
 	 * 
 	 *  @mxml
 	 *  
     *  <p>The <code>&lt;mx:CartesianChart&gt;</code> tag inherits all the
     *  properties of its parent classes and adds the following properties:</p>
     *  
     *  <pre>
     *  &lt;mx:OLAPChart
     *    <strong>Properties</strong>
     *    type="<i>Area|Column|Line|Plot</i>"
     * 
     *  /&gt;
 	 *  </pre>
     */
	public class OLAPChart extends CartesianChart
	{    	
		public function OLAPChart()
		{
			super();
			setStyle("horizontalAxisStyleNames",["hangingCategoryAxis"]);
			this.dataTipFunction = defaultDataTipFunction;
		}
		
		//---------------------------------------------------------------------------------
		//
		//						Variables
		//
		//---------------------------------------------------------------------------------
		private var _rowList:IList = null;
	    private var _rowObjects:ArrayCollection = null;
	    private var _olapDataProvider:IOLAPResult;
	    public var categories:Array = [];
	    
	    //---------------------------------------------------------------------------------
	    //
	    //						Properties
	    //
	    //---------------------------------------------------------------------------------
	    
	    //----------------------------------
		//  type
		//----------------------------------
		[Bindable]
	    private var _type:String = "Column";
	
		/**
		 *  Determines the type of series to be shown.
		 *  Supported values are Area, Column, Line and Plot
		 *  
		 *  @default Column
		 */
		[Inspectable(category="General", enumeration="Area,Column,Line,Plot", defaultValue="Column")]    
	    public function set type(value:String):void
	    {
	    	_type = value;
	    	invalidateDisplayList();
	    }
	    
	    /**
	     *  @private
	     */	 
	    public function get type():String
	    {
	    	return _type;
	    }
		
		//----------------------------------
		//  seriesRenderer (Not used in this implementation as we provide "type" property instead).
		//----------------------------------
		[Bindable]
		private var _seriesRenderer:IFactory;
		
		/**
		 *  @private
		 *  Determines the ClassFactory that is used to render series
		 */ 
		public function set seriesRenderer(value:IFactory):void
		{
			_seriesRenderer = value;
		}
		
		/**
		 *  @private
		 */
		public function get seriesRenderer():IFactory
		{
			return _seriesRenderer;
		}
		
		//----------------------------------
		//  olapDataProvider
		//----------------------------------
		/**
		 *  @private
		 */
		public function get olapDataProvider():Object
	    {
	    	return _olapDataProvider;
	    }
	    
	    //----------------------------------
		//  rowList
		//----------------------------------
		/**
		 *  @private
		 *  Contains all axis positions
		 */
		public function get rowList():IList
	    {
	    	return _rowList;
	    }
	    
	    //----------------------------------
		//  rowObjects
		//----------------------------------
		/**
		 *  @private
		 *  Contains OLAPMembers of first axis position
		 */
		public function get rowObjects():ArrayCollection
	    {
	    	return _rowObjects;
	    }
	    
	    //----------------------------------
		//  dataProvider
		//----------------------------------
	    /**
	     *  @inheritDoc  
	     *  For OLAPChart, dataProvider should be IOLAPResult.
	     */
	    override public function set dataProvider(value:Object):void
	    {
			if(!value)
			 {
				horizontalAxisRenderers = [];
				verticalAxisRenderers = [];
				series = [];
				
				invalidateProperties();
	        	invalidateSeries();
	        	invalidateData();
	        	//invalidateDisplayList();
					
			 }  
			else 
			if(value is IOLAPResult)
			{
				_rowList = value.getAxis(OLAPResult.ROW_AXIS).positions;
				var position:IOLAPAxisPosition = _rowList.getItemAt(0) as IOLAPAxisPosition;
				_rowObjects = new ArrayCollection();
				prepareMembers();
				series = generateSeries(value);

				var firstPosition:IOLAPAxisPosition = _rowList.getItemAt(0) as IOLAPAxisPosition;
				
				categories = [];
				var c:OLAPCategoryAxis = new OLAPCategoryAxis();
				c.categoryField = "memberName";
				c.dataProvider = _rowList;
				c.dataFunction = getDataForCategory;
				categories.push(c);
				if(type == "Bar")
					verticalAxis = c;
				else
					horizontalAxis = c;
				
	        	_olapDataProvider = value as IOLAPResult;
	        	
	        	if(type == "Bar")
					verticalAxisRenderers = [];
				else
					horizontalAxisRenderers = [];
	        	
	        	invalidateProperties();
	        	invalidateSeries();
	        	invalidateData();        
	  		}
	    }
		
		//-------------------------------------------------------------------------------------------
		//
		//								Methods
		//
		//-------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Default data tip function
		 */
		 	
		private function defaultDataTipFunction(hitData:HitData):String
		{
			if(type == "Bar")
				return (hitData.chartItem as Object).xValue.toString();
			else
				return (hitData.chartItem as Object).yValue.toString();
		}
		
		/**
		 *  @private
		 *  Creates renderer for OLAPCategoryAxis
		 */
  		private function createRenderers():void
  		{
  			var arr:Array = [];
			var gutterBottom:int = 0;
  			for(var i:int = 0;i < categories.length;i++)
  			{				
				var ar:AxisRenderer;
		    	ar = new AxisRenderer();
		    	ar.axis = categories[i];
		    	ar.setStyle("canDropLabels",false);
		    	ar.setStyle("canStagger",true);
		    	ar.placement = "bottom";
		    	gutterBottom += 50;
		    	arr.push(ar);
  			}
  			setStyle("gutterBottom",gutterBottom);
  			if(type == "Bar")
  				verticalAxisRenderers = arr;
  			else
  				horizontalAxisRenderers = arr;
  		}
  		
  		/**
  		 *  @private
  		 *  To get OLAPMembers of first OLAPAxisPosition
  		 */
  		private function prepareMembers():void
	    {
	    	var firstRow:IOLAPAxisPosition = _rowList.getItemAt(0) as IOLAPAxisPosition;
	    	
	    	for(var i:int = 0; i < firstRow.members.length; i++)
	    		_rowObjects.addItem(new Array());	
	    } 
	    
	    /**
	     *  @private
	     *  dataFunction for OLAPCategoryAxis
	     *  
	     *  @param axis Axis that uses this as dataFunction
	     *  @param item Item for which function should return a data value
	     *  @param index Index of item in dataProvider
	     * 
	     *  @return data value object
	     */ 
	    private function getDataForCategory(axis:IAxis,item:Object, index:int):Object
	    {   	
	    	return generateCategoryValue(index);
	    }
	    
	    /**
	     *  @private
	     *  To generate data values for a series
	     * 
	     *  @param s Series that uses this function
	     *  @param item Item for which a data value is to be returned
	     *  @param fieldName 
	     *  
	     *  @return data value object
	     */ 
	    private function getDataForSeries(s:Series,item:Object,fieldName:String):Object
	    {
	    	var index:int = _rowList.getItemIndex(item);
	    	if(type == "Bar")
	    	{
	    		if(fieldName == "xValue")
	    		{
		    		var col:int = series.indexOf(s);
		    		var olapCell:IOLAPCell = _olapDataProvider.getCell(index,col);
		    		return olapCell.value;
		    	}
		    	else
		    	{
		    		return generateCategoryValue(index);
		    	}
	    	}
	    	else
	    	{
	    		if(fieldName == "yValue")
	    		{
		    		col = series.indexOf(s);
		    		olapCell = _olapDataProvider.getCell(index,col);
		    		return olapCell.value;
		    	}	
		    	else
		    	{
		    		return generateCategoryValue(index);
		    	}
		    }
	    }
	    
	    /**
	     *  @private
	     *  Returns a data value for the item at given index
	     */ 
	    public function generateCategoryValue(index:int):Object
	    {
	    	var rowObject:Array;
		   	var obj:Object;
		   
		   	rowObject = _rowObjects.getItemAt(categories.length - 1) as Array;
		    obj = rowObject[index];
		    if(obj == null && index != -1)
		    {   		
		    	var members:IList = _rowList.getItemAt(index).members;
		    	obj = new Object();
		    	var str:String = "";
	    		var curr:IOLAPMember = members[0];
	    		str = curr.name;
	    		for (var i:int = 1; i < members.length; i++)
	    		{
	    			curr = members[i];
	    			str = str + "." + curr.name;
	    		}
	    		obj["memberName"] = str;
		    	rowObject[index] = obj;
		    }	
		    return obj;
	    }
	    
	    /**
	     *  Generates series objects to be shown in this chart
	     *  @param olapData IOLAPResult to be considered to determine the series
	     * 
	     *  @return Array of series
	     */ 
        public function generateSeries(olapData:Object):Array
	    {
	    	// Get the number of columns from the row axis.
	    	
			var position:IOLAPAxisPosition;
            var s:Array = [];
            var newSeries:IFlexDisplayObject;
            var i:int;	                        
	        var columnList:IList = olapData.getAxis(OLAPResult.COLUMN_AXIS).positions;
	        if(type == "Bar")
            {
              	horizontalAxisRenderers = [];
            }
            else
            {
              	verticalAxisRenderers = [];
            }
	        for(i = 0; i < columnList.length; i++)
	        {
	        	position = columnList.getItemAt(i) as IOLAPAxisPosition;
	            var members:IList = position.members ;
	            var str:String = "";
	            var perSeriesWidthRatio:Number = 0.65 / columnList.length;
	            var offset:Number = (1 - 0.65) / 2 +
                              (0.65/columnList.length) / 2 - 0.5;
                var linAxis:LinearAxis = new LinearAxis();           
	            //newSeries = seriesRenderer.newInstance();
	            if(type == "Column")
	            {
	            	newSeries = new ColumnSeries();
	            	ColumnSeries(newSeries).offset = offset + i * perSeriesWidthRatio;
	            	ColumnSeries(newSeries).columnWidthRatio = perSeriesWidthRatio;
	            	ColumnSeries(newSeries).verticalAxis = linAxis;
	            	verticalAxisRenderers[i] = new AxisRenderer();
	            	verticalAxisRenderers[i].axis = ColumnSeries(newSeries).verticalAxis;
	            }
	            else if(type == "Bar")
	            {
	            	newSeries = new BarSeries();
	            	BarSeries(newSeries).offset = offset + i * perSeriesWidthRatio;
	            	BarSeries(newSeries).barWidthRatio = perSeriesWidthRatio;
	            	BarSeries(newSeries).horizontalAxis = linAxis;
	           		horizontalAxisRenderers[i] = new AxisRenderer();
	           		horizontalAxisRenderers[i].horizontal = true; 
	            	horizontalAxisRenderers[i].axis = BarSeries(newSeries).horizontalAxis;   	
	            }
	            else if(type == "Line")
	            {
	            	newSeries = new LineSeries();
	            	LineSeries(newSeries).verticalAxis = linAxis;
	            	verticalAxisRenderers[i] = new AxisRenderer();
	            	verticalAxisRenderers[i].axis = linAxis;
	            }
	            else if(type == "Bubble")
	            {
	            	newSeries = new BubbleSeries();
	            	BubbleSeries(newSeries).verticalAxis = linAxis;
	            	BubbleSeries(newSeries).minRadius = 20;
	            	verticalAxisRenderers[i] = new AxisRenderer();
	            	verticalAxisRenderers[i].axis = linAxis;
	            }
	            else if(type == "Area")
	            {
	            	newSeries = new AreaSeries();
	            	AreaSeries(newSeries).verticalAxis = linAxis;
	            	verticalAxisRenderers[i] = new AxisRenderer();
	            	verticalAxisRenderers[i].axis = linAxis;
	            }
	            else if(type == "Plot")
	            {
	            	newSeries = new PlotSeries();
	            	PlotSeries(newSeries).verticalAxis = linAxis;
	            	verticalAxisRenderers[i] = new AxisRenderer();
	            	verticalAxisRenderers[i].axis = linAxis;
	            }
	            if(newSeries is Series)
	            {
	            	Series(newSeries).dataFunction = getDataForSeries;
	            	Series(newSeries).displayName = members[0].name;
	            	for(var j:int = 1;j < members.length; j++)
	            	{
   	                	Series(newSeries).displayName = Series(newSeries).displayName + "." + members[j].name;
		        	}
		        	Series(newSeries).dataProvider = _rowList;
	            }
	            if(type == "Bar")
	            	horizontalAxisRenderers[i].axis.title = Series(newSeries).displayName;
	            else
	            {
	            	verticalAxisRenderers[i].axis.title = Series(newSeries).displayName;
	            	verticalAxisRenderers[i].setStyle('verticalAxisTitleAlignment','vertical');
	            }
	            s.push(newSeries);
		     }
		     return s;
	     }
  		
  		
  		//----------------------------------------------------------------------------
  		//
  		//					Overridden methods
  		//
  		//----------------------------------------------------------------------------
  						    
	    override protected function commitProperties():void
	    {
	    	if(categories.length == 0)
	    	{
	    		categories.push(new OLAPCategoryAxis());
	    	}
	    	if(type == "Bar")
	    	{
	    		if(verticalAxisRenderers.length == 0)
	    			createRenderers();
	    	}
	    	else
	    	{
	    		if(horizontalAxisRenderers.length == 0)
	    			createRenderers();
	    	}
	    	super.commitProperties();	
	    }
	}
}