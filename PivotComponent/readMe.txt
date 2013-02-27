2010/06/05	FB编译失败，但buildSWC01.bat 执行成功。

////////////////////////////////////////////////////////////////////////////
PivotComponent

Copyright (C)  Adobe  Software LLC and its licensors.
All Rights Reserved.

Contents :

	/bin/ 		- component SWC file
	/samples/	- Sample applications with source
	/src/		- component Source files 
	buildSWC.bat	- to build component SWC file
	buildSamples.bat- to build sample applications
	manifest.xml	- maps component namespace to class names. It defines the package name that the component used before being compiled into a SWC file.


Description :

The PivotComponent is used for OLAP analysis of data using either OLAPChartExtension or OLAPDataGridExtension or both.

Install Instructions :


Extract contents of zip file to any folder.

To get a compiled SWC 
A. Using Flex Builder 
	1> Create a Flex library project .
	2> Copy the folders com and mx to the projdir .[Please note that in library project you will not have a src folder]
		
	 To get a SWC of ligther size (Below steps are Optional)
	 Go to Project Properties. Library build path
		a) Under Classes tab select com . 
		b)Under Library Path tab open Frawework.swc, make its linktype as external.
		c)Under library path tab open datavisualisation.swc, make its linktype as external .

	Corresponding SWC file will be created in the bin folder

						---OR---


B. Run buildSWC.bat . pivotComponent.SWC will be created and will be in bin folder.
	

To use compiled SWC file directly in your applications use following steps:

1. Using Flex Builder select Project-> Properties add the created SWC file under "Flex Build Path"->"Library path" 
2. Using command line compiler copy the created SWC file to "\frameworks\libs" folder of your Flex SDK installation or use command line compilers "library-path" configuration parameter.


To build all samples directly run "buildSamples.bat" file alternatively you can build individual samples by using PivotComponent.SWC as library file and individual sample's mxml file as source file.
For more details about the component visit http://flexmadeeasy.blogspot.com

