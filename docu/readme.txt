
1、目录与文件说明

	src/
		Chart2DDemo.mxml			演示：Flex 2D柱状图的使用
		Chart3DCanvasDemo.mxml		演示：Chart3DCanvas组件的使用
		ChartPDM.mxml				4合1局部放电检测数据图
		assets/
			chart01/			模拟数据文件目录，3维，周期-相位-放电幅值(均值)
				config.xml
				data.xml
			chart02/			模拟数据文件目录，3维，周期-相位-放电个数(阀值)
				config.xml
				data.xml
			chart03/dataC.xml	模拟数据文件目录，2维，相位-放电幅值(均值)
			chart04/dataD.xml	模拟数据文件目录，2维，相位-放电个数(阀值)
			
		info/osmatrix/rmengine/components/
			Chart3D.as			3D绘图空间，集成Sprite
			Chart3DCanvas		3D Flex组件，FlexBuilder设计环境可视，其宽高即为3D空间的宽高；
								支持调试模式，可调整摄像机位置和3D物体的位置，以改变显示效果；
			
	src_pv3d_2.1.932/	PV3D源代码
		...
		
	docu/
		power/			电力相关文档与模拟数据
		readme.txt		本文件
	
2、数据文件说明
	
	config.xml
	-------------------------------------------------------------------------------------------------
		camera		@focus-焦距；@default：设定当前生效的view的索引
			view
				point		摄像机位置(x,y,z)
				rotation	摄像机旋转
			view	其他可用view
			
		axis	图形尺寸，即像素空间大小xmax*ymax*zmax;backgroundcolor-3D图形背景区填充色（title文字背景也用到）
			z		z轴标注：标注段数；标注文字旋转；坐标轴标题；dx-标注文字x方向移动；dtitle-标题相对标注位置追加尺寸
				mark	text-标注显示的文本
				mark
				...
			x
			y
			
		position	三维物体空间定位，默认为第一个有效，其它用于备忘
			point	三维物体原点位置(x,y,z)；绕Y轴旋转角度；
			point
		
	data.xml
	-------------------------------------------------------------------------------------------------
		cube	xzoom：数据记录中x值放大倍率-一个数据点占用像素位置；width-立方体的宽度；depth-立方体的深度；
			matrial	@value:r记录中z值小于等于此数的采用这个material绘制6个面；
					@all：无用
					@front...: 六个面的颜色值
		r		数据点(x,y,z),x/y为而为坐标，z代表数据值。
	
		说明：
			x - 对应X坐标轴，x最大值(数据值)×xzoom(放大率)=xmax(像素)
			y - 对应Z坐标轴，y最大值(数据值)×yzoom(放大率)=zmax(像素)
			z - 对应Y坐标轴，z最大值(数据值)×zzoom(放大率)=ymax(像素)
	

3、其它
	未实现的其他参数
		立方体间距
	

	可用立方体颜色材质

		1）取自Eclipse BIRT 2.5.2
			front：448EBA
			right：316788
			top：4795C4
			
	遗留问题的解决办法：同样在xml文件中指定单位，然后chartAvgVerticalAxis.title = "huhj";其中chartAvgVerticalAxis是左上柱状图纵轴的id。
	将Cube移入Config.xml，到加载后插入data.xml