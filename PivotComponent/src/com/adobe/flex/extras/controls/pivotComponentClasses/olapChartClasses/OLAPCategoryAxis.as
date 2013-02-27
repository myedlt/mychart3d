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
import mx.charts.AxisLabel;
import mx.charts.CategoryAxis;
import flash.events.Event;
import mx.charts.chartClasses.AxisBase;
import mx.charts.chartClasses.AxisLabelSet;
import mx.charts.chartClasses.IAxis;
import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.collections.XMLListCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import mx.core.mx_internal;
import flash.utils.Dictionary;
import mx.utils.UIDUtil;
use namespace mx_internal;

/**
 *  The OLAPCategoryAxis class lets charts represent data
 *  grouped by a set of discrete values along an axis.
 *  You typically use the OLAPCategoryAxis class to define
 *  a set of labels that appear along an axis of a chart.
 *  For example, charts that render data according to City,
 *  Year, Business unit, and so on.
 *  
 *  <p>A OLAPCategoryAxis used in a chart does not inherit its
 *  <code>dataProvider</code> property from the containing chart.
 *  You must explicitly set the <code>dataProvider</code> property
 *  on a OLAPCategoryAxis.</p>
 *  
 *  <p>While you can use the same dataProvider to provide data
 *  to the chart and categories to the OLAPCategoryAxis, a OLAPCategoryAxis
 *  can optimize rendering if its dataProvider is relatively static.
 *  If possible, ensure that the categories are relatively static
 *  and that changing data is stored in separate dataProviders.</p>
 *  
 *  <p>The <code>dataProvider</code> property can accept
 *  either an array of strings or an array of records (objects)
 *  with a property specifying the category name.
 *  If you specify a <code>categoryField</code> property,
 *  the OLAPCategoryAxis assumes the dataProvider is an array of Objects.
 *  If <code>categoryField</code> is <code>null</code>,
 *  the OLAPCategoryAxis assumes dataProvider is an array of Strings.</p>
 *  
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:OLAPCategoryAxis&gt;</code> tag inherits all the properties
 *  of its parent classes and adds the following properties:</p>
 *  
 *  <pre>
 *  &lt;mx:OLAPCategoryAxis
 *    <strong>Properties</strong>
 *    categoryField="null"
 *    dataProvider="<i>No default</i>"
 *    labelFunction="<i>No default</i>"
 *    padding="<i>Default depends on chart type</i>"
 *    ticksBetweenLabels="<i>true</i>"
 *  /&gt;
 *  </pre>
 *
 *  @includeExample examples/HLOCChartExample.mxml
 */
public class OLAPCategoryAxis extends CategoryAxis implements IAxis
{
//    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function OLAPCategoryAxis()
    {
        super();

        workingDataProvider = new ArrayCollection();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _cursor:IViewCursor;
    
    /**
     *  @private
     */
    private var _catMap:Dictionary;

    /**
     *  @private
     */
    private var _categoryValues:Array;
    
    /**
     *  @private
     */
    private var _labelsMatchToCategoryValuesByIndex:Array;

    /**
     *  @private
     */
    private var _cachedMinorTicks:Array = null; 
    
    /**
     *  @private
     */
    private var _cachedTicks:Array = null;  

    /**
     *  @private
     */
    private var _labelSet:AxisLabelSet;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  chartDataProvider
    //----------------------------------

    /**
     *  @private
     *  Storage for the chartDataProvider property.
     */
    private var _chartDataProvider:Object;
    
    /**
     *  @private
     */
    override public function set chartDataProvider(value:Object):void
    {
        _chartDataProvider = value;

        if (!_userDataProvider)
            workingDataProvider = _chartDataProvider;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baseline
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  @inheritDoc
     */
    override public function get baseline():Number
    {
        return -_padding;
    }

    //----------------------------------
    //  categoryField
    //----------------------------------

    /**
     *  @private
     *  Storage for the categoryField property.
     */
    private var _categoryField:String = "";
    
    [Inspectable(category="General")]
    
    /**
     *  Specifies the field of the data provider
     *  containing the text for the labels.
     *  If this property is <code>null</code>, OLAPCategoryAxis assumes 
     *  that the dataProvider contains an array of Strings.
     *
     *  @default null
     */
    override public function get categoryField():String
    {
        return _categoryField;
    }
    
    /**
     *  @private
     */
    override public function set categoryField(value:String):void
    {
        _categoryField = value;

        collectionChangeHandler();
    }

    //----------------------------------
    //  dataProvider
    //----------------------------------

    /**
     *  @private
     *  Storage for the dataProvider property.
     */
    private var _dataProvider:ICollectionView;
    
    /**
     *  @private
     */
    private var _userDataProvider:Object;
    
    [Inspectable(category="General")]
    
    /**
     *  Specifies the data source containing the label names.
     *  The <code>dataProvider</code> can be an Array of Strings, an Array of Objects,
     *  or any object that implements the IList or ICollectionView interface.
     *  If the <code>dataProvider</code> is an Array of Strings,
     *  ensure that the <code>categoryField</code> property
     *  is set to <code>null</code>. 
     *  If the dataProvider is an Array of Objects,
     *  set the <code>categoryField</code> property
     *  to the name of the field that contains the label text.
     */
    override public function get dataProvider():Object
    {
        return _dataProvider;
    }
    
    /**
     *  @private
     */
    override public function set dataProvider(value:Object):void
    {
        _userDataProvider = value;

        if (_userDataProvider != null)
            workingDataProvider = _userDataProvider;
        else
            workingDataProvider = _chartDataProvider;
    }

    //----------------------------------
    //  labelFunction
    //----------------------------------

    /**
     *  @private
     *  Storage for the labelFunction property.
     */
    private var _labelFunction:Function = null;
    
    [Inspectable(category="General")]
    
    /**
     *  Specifies a function that defines the labels that are generated
     *  for each item in the OLAPCategoryAxis's <code>dataProvider</code>.
     *  If no <code>labelFunction</code> is provided,
     *  the axis labels default to the value of the category itself.
     *
     *  <p>The <code>labelFunction</code> method for a OLAPCategoryAxis
     *  has the following signature:</p>
     *  <pre>
     *    labelFunction(<i>categoryValue</i>:Object, <i>previousCategoryValue</i>:Object, 
     *      <i>axis</i>:OLAPCategoryAxis, <i>categoryItem</i>:Object):String
     *  </pre>
     *  
     *  <p>Where:</p>
     *  <ul>
     *   <li><code><i>categoryValue</i></code> is the value of the category to be represented.</li>
     *   <li><code><i>previousCategoryValue</i></code> is the value of the previous category on the axis.</li>
     *   <li><code><i>axis</i></code> is the OLAPCategoryAxis being rendered.</li>
     *   <li><code><i>categoryItem</i></code> is the item from the <code>dataProvider</code> 
     *     that is being represented.</li>
     *  </ul>
     *  
     *  <p>Flex displays the returned String as the axis label.</p>
     * 
     *  <p>If the <code>OLAPCategoryAxis.categoryField</code> property is not set, the value
     *  will be the same as the <code>categoryValue</code> property.</p>
     */ 
    override public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    override public function set labelFunction(value:Function):void
    {
        _labelFunction = value;

        invalidateCategories();
    }
    
    //----------------------------------
    //  minorTicks (private)
    //----------------------------------
 
    /**
     *  @private
     */
    private function get minorTicks():Array
    {
        if (!_cachedMinorTicks)
        {
            _cachedMinorTicks = [];

            var n:int;
            var min:Number;
            var max:Number;
            var alen:Number;
            var i:Number;
            
            if (ticksBetweenLabels == false)
            {
                n = _categoryValues.length;
                min = -_padding;
                max = n - 1 + _padding;
                alen = max - min;
                
                var start:Number = min <= -0.5 ? 0 : 1;
                var end:Number = max >= n - 0.5 ? n : n - 1
                
                for (i = start; i <= end; i++) // <= to draw final tick
                {
                    _cachedMinorTicks.push((i - 0.5 - min) / alen);
                }
            }
            else
            {
                n = _categoryValues.length;
                min = -_padding;
                max = n - 1 + _padding;
                alen = max - min;
                
                for (i = 0; i < n; i++) // <= to draw final tick
                {
                    _cachedMinorTicks.push((i - min) / alen);
                }
            }
        }

        return _cachedMinorTicks;
    }

    //----------------------------------
    //  padding
    //----------------------------------

    /**
     *  @private
     *  Storage for the padding property.
     */
    private var _padding:Number = 0.5;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the padding added to either side of the axis
     *  when rendering data on the screen.
     *  Set to 0 to map the first category to the
     *  very beginning of the axis and the last category to the end.
     *  Set to 0.5 to leave padding of half the width
     *  of a category on the axis between the beginning of the axis
     *  and the first category and between the last category
     *  and the end of the axis.
     *  
     *  <p>This is useful for chart types that render beyond the bounds
     *  of the category, such as columns and bars.
     *  However, when used as the horizontalAxis in a LineChart or AreaChart,
     *  it is reset to 0.</p>
     *  
     *  @default 0.5
     */
    override public function get padding():Number
    {
        return _padding;
    }
    
    /**
     *  @private
     */
    override public function set padding(value:Number):void
    {
        super.padding = value;

        invalidateCategories();

        dispatchEvent(new Event("mappingChange"));
        dispatchEvent(new Event("axisChange"));
    }

    //----------------------------------
    //  workingDataProvider
    //----------------------------------

    /**
     *  @private
     */
    private function set workingDataProvider(value:Object):void
    {
        if (_dataProvider != null)
        {
            _dataProvider.removeEventListener(
                CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
        }
        
        if (value is Array)
        {
            value = new ArrayCollection(value as Array);
        }
        else if (value is ICollectionView)
        {
        }
        else if (value is XMLList)
        {
            value = new XMLListCollection(XMLList(value));
        }
        else if (value != null)
        {
            value = new ArrayCollection([ value ]);
        } 
        else 
        {
            value = new ArrayCollection();
        }
            
        _dataProvider = ICollectionView(value);

        _cursor = value.createCursor();

        if (_dataProvider != null) 
        {
            // weak listeners to collections and dataproviders
            _dataProvider.addEventListener(
                CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
        }

        collectionChangeHandler();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy mx.charts.chartClasses.IAxis#mapCache()
     */
    override public function mapCache(cache:Array, field:String,
                             convertedField:String,
                             indexValues:Boolean = false):void
    {
        update();

        var n:int = cache.length;
        
        // Find the first non null item in the cache so we can determine type.
        // Since these initial values are null,
        // we can safely skip assigning values for them.
        for (var i:int = 0; i < n; i++)
        {
            if (cache[i][field] != null)
                break;
        }
        if (i == n)
            return;
        
        var value:Object = cache[i][field]
        if (value is XML ||
                 value is XMLList)
        {
            for (; i < n; i++)
            {
                cache[i][convertedField] = _catMap[UIDUtil.getUID(cache[i][field])];             
            }
        }
        else if ((value is Number || value is int || value is uint) &&
                 indexValues == true)
        {
            for (i = 0; i < n; i++)
            {
                var v:Object = cache[i];
                v[convertedField] = v[field];
            }
        }
        else
        {
            for (; i < n; i++)
            {
                cache[i][convertedField] = _catMap[UIDUtil.getUID(cache[i][field])];                
            }
        }
        
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#filterCache()
     */
    override public function filterCache(cache:Array, field:String,
                                filteredField:String):void
    {
        update();

        // Our bounds are the categories, plus/minus padding,
        // plus a little fudge factor to account for floating point errors.
        var computedMaximum:Number = _categoryValues.length - 1 +
                                     _padding + 0.000001;
        var computedMinimum:Number = -_padding - 0.000001;
        
        var n:int = cache.length;
        for (var i:int = 0; i < n; i++)
        {
            var v:Number =  cache[i][field];
            cache[i][filteredField] = v >= computedMinimum &&
                                      v < computedMaximum ?
                                      v :
                                      NaN;
        }
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#transformCache()
     */
    override public function transformCache(cache:Array, field:String,
                                   convertedField:String):void
    {
        update();

        var min:Number = -_padding;
        var max:Number = _categoryValues.length - 1 + _padding;
        var alen:Number = max - min;

        var n:int = cache.length;
        for (var i:int = 0; i < n; i++)
        {
            cache[i][convertedField] = (cache[i][field] - min) / alen;
        }
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#invertTransform()
     */
    override public function invertTransform(value:Number):Object
    {
        update();

        var min:Number = -_padding;
        var max:Number = _categoryValues.length - 1 + _padding;
        var alen:Number = max - min;

        return _categoryValues[Math.round((value * alen) + min)];
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#formatForScreen()
     */
    override public function formatForScreen(value:Object):String    
    {
        if (value is Number && value < _categoryValues.length)
        {
            var catValue:Object = _categoryValues[Math.round(Number(value))];
            return catValue == null ? value.toString() : catValue.toString();
        }

        return value.toString();    
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#getLabelEstimate()
     */
    override public function getLabelEstimate():AxisLabelSet
    {
        update();

        return _labelSet;
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#preferDropLabels()
     */
    /* public function preferDropLabels():Boolean
    {
        return false;
    } */

    /**
     *  @copy mx.charts.chartClasses.IAxis#getLabels()
     */
    override public function getLabels(minimumAxisLength:Number):AxisLabelSet
    {
        update();

        return _labelSet;
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#reduceLabels()
     */
    override public function reduceLabels(intervalStart:AxisLabel,intervalEnd:AxisLabel):AxisLabelSet
    {    	
        var skipCount:int = _catMap[intervalEnd.value] - _catMap[intervalStart.value] + 1;
        
        if (skipCount <= 0)
            return null;
            
        var newLabels:Array = [];
        var newTicks:Array = [];
        
        var min:Number = -_padding;
        var max:Number = _categoryValues.length - 1 + _padding;
        var alen:Number = (max-min);

        for (var i:int = 0; i < _categoryValues.length; i += skipCount)
        {
            newLabels.push(_labelsMatchToCategoryValuesByIndex[i]);
            newTicks.push(_labelsMatchToCategoryValuesByIndex[i].position);
        }
        
        var axisLabelSet:AxisLabelSet = new AxisLabelSet();
        axisLabelSet.labels = newLabels;
        axisLabelSet.minorTicks = minorTicks;
        axisLabelSet.ticks = generateTicks();
        return axisLabelSet;
    }

    /**
     *  @copy mx.charts.chartClasses.IAxis#update()
     */
    override public function update():void
    {
        if (!_labelSet)
        {
            var prop:Object;
            
            _catMap = new Dictionary();
            _categoryValues = [];
            _labelsMatchToCategoryValuesByIndex = [];

			var categoryItems:Array = [];
            var i:int;
            var prevValue:String = "";
            var prevProp:Object;
            var posStart:Array = [];
            var posEnd:Array = [];
            var len:int = 0;
            var j:int = 0;
            var uid:String;
            
            _cursor.seek(CursorBookmark.FIRST);
            i = 0;
			
			if(!_cursor.afterLast)
			{
				if(dataFunction != null)
                {
                	prevProp = dataFunction(this, _cursor.current, len);
               		prevValue = prevProp[_categoryField].toString();
               	}
			}
				
            while (!_cursor.afterLast)
            {
                if(dataFunction != null)
                {
                	prop = dataFunction(this, _cursor.current, len);
                	if(prop != null && prop[_categoryField].toString() != prevValue)
                	{
                		uid = UIDUtil.getUID(prevProp);
                		_catMap[uid] = i;
                		categoryItems[i] = prevProp;
                		_categoryValues[i] = prevProp[_categoryField];
                		prevValue = prop[_categoryField].toString();
                		prevProp = prop;
                		posStart[i] = j;
                		j = len;
                		posEnd[i] = len - 1;	
                		i++;
                	}
                	++len;
                }
                _cursor.moveNext()
            }
            if(prop != null)
            {
            	uid = UIDUtil.getUID(prop);
            	_catMap[uid] = i;
            	categoryItems[i] = prop;
	            _categoryValues[i] = prop[_categoryField];
	            posStart[i] = j;
	            posEnd[i] = len - 1;
	        }
			
            var axisLabels:Array = [];
            
            var min:Number = -_padding;
            var max:Number = len - 1 + _padding;
            var alen:Number = max - min;
            var label:AxisLabel;

            var n:int = _categoryValues.length;
            if (_labelFunction != null)
            {
                var previousValue:Object = null;
                for (i = 0; i < n; i++)
                {
                    if (!_categoryValues[i])
                        continue;
                        
                    label = new AxisLabel((((posEnd[i] + posStart[i]) / 2) - min) / alen, _categoryValues[i],
                        _labelFunction(_categoryValues[i], previousValue,
                        this, _categoryValues[i]));
                    _labelsMatchToCategoryValuesByIndex[i] = label;
                    axisLabels.push(label);

                    previousValue = _categoryValues[i];
                }
            }
            else
            {
                for (i = 0; i < n; i++)
                {
                    if (_categoryValues[i] == null)
                        continue;
                    
                    label = new AxisLabel((((posEnd[i] + posStart[i]) / 2) - min) / alen, categoryItems[i],
                        _categoryValues[i].toString());
                    _labelsMatchToCategoryValuesByIndex[i] = label;
                    axisLabels.push(label);
                }               
            }

            _labelSet = new AxisLabelSet();
            _labelSet.labels = axisLabels;
            _labelSet.accurate = true;
            _labelSet.minorTicks = minorTicks;
            _labelSet.ticks = generateTicks();          
        }
    }

    /**
     *  @private
     */
    private function generateTicks():Array
    {
        if (!_cachedTicks)
        {
            _cachedTicks = [];

            var n:int;
            var min:Number;
            var max:Number;
            var alen:Number;
            var i:Number;
            
            if (ticksBetweenLabels == false)
            {
                n = _categoryValues.length;
                min = -_padding;
                max = n - 1 + _padding;
                alen = max - min;
                
                for (i = 0; i < n; i++) // <= to draw final tick
                {
                    _cachedTicks.push((i - min) / alen);
                }
            }
            else
            {
                _cachedMinorTicks = [];
                
                n = _categoryValues.length;
                min = -_padding;
                max = n - 1 + _padding;
                alen = max - min;
                
                var start:Number = _padding < 0.5 ? 0.5 : -0.5;
                var end:Number = _padding < 0.5 ? n - 1.5 : n - 0.5;
                
                for (i = start; i <= end; i += 1)
                {
                    _cachedTicks.push((i - min) / alen);
                }
            }
        }

        return _cachedTicks;
    }
    
    /**
     *  @private
     */
    private function invalidateCategories():void
    {
        _labelSet = null;
        _cachedMinorTicks = null;
        _cachedTicks = null;

        dispatchEvent(new Event("mappingChange"));
        dispatchEvent(new Event("axisChange"));
    }
    
    /**
     *  @private
     */
    override mx_internal function getCategoryValues():Array
    {
    	return _categoryValues;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function collectionChangeHandler(event:CollectionEvent = null):void
    {
        if (event && event.kind == CollectionEventKind.RESET)
            _cursor = _dataProvider.createCursor();

        invalidateCategories();
    }
    
}

}
