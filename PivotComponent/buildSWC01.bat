

if (%SDKDIR%)==() set SDKDIR="D:\Adobe\FlexSDK\3.0.0"

:checkCompc

if exist "%SDKDIR:"=%\bin\compc.exe" goto :build
echo Error: Could not find compc.exe, please install FlexBuilder or set SDKDIR environment variable to flex framework directory.
exit /b

:build
"%SDKDIR:"=%\bin\compc.exe"  -source-path src   -output bin\PivotComponent.swc -include-namespaces=http://www.adobe.com/2006/fc -namespace http://www.adobe.com/2006/fc manifest.xml -include-classes com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.ChartPopUpButton com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotListData com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotListHeader com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.PivotPopUpButton com.adobe.flex.extras.controls.pivotComponentClasses.olapChartClasses.OLAPCategoryAxis com.adobe.flex.extras.controls.pivotComponentClasses.olapChartClasses.OLAPChart  com.adobe.flex.extras.controls.pivotComponentClasses.DimensionList com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.MeasuresComboBox com.adobe.flex.extras.controls.pivotComponentClasses.MeasuresList com.adobe.flex.extras.controls.pivotComponentClasses.OLAPChartExtension com.adobe.flex.extras.controls.pivotComponentClasses.OLAPDataGridEx com.adobe.flex.extras.controls.pivotComponentClasses.OLAPDataGridExtension com.adobe.flex.extras.controls.myEvent.EnableChangeEvent com.adobe.flex.extras.controls.PivotComponent mx.controls.PopUpButton
 