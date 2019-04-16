package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;


	public class Papervision3DExam extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var viewport:Viewport3D;
		private var renderer:BasicRenderEngine;

		public function Papervision3DExam() {
			// set up the stage
			// 当影片输出的时候，整个影片相对浏览器的左上方对齐
			stage.align=StageAlign.TOP_LEFT;
			// 影片不会跟随浏览的尺寸大小而发生缩放。
			stage.scaleMode=StageScaleMode.NO_SCALE;

			// Initialise Papervision3D
			init3D();

			// Create the 3D objects
			createScene();

			// Initialise Event loop
			// 为场景注册一个事件监听器，每当场景ENTER_FRAME的时候，就执行一次loop函数
			// ,ENTER_FRAME的频率就是输出影片时设置的每秒帧数。
			this.addEventListener(Event.ENTER_FRAME,loop);

		}
		private function init3D():void {

			// create viewport
			viewport=new Viewport3D(0,0,true,false);
			addChild(viewport);

			// Create new camera with fov of 60 degrees (= default value)
			camera=new Camera3D(60);

			// initialise the camera position (default = [0, 0, -1000])
			camera.x=-100;
			camera.y=-100;
			camera.z=-500;

			// target camera on origin
			camera.target=DisplayObject3D.ZERO;

			// Create a new scene where our 3D objects will be displayed
			scene=new Scene3D  ;

			// Create new renderer
			renderer=new BasicRenderEngine  ;
		}

		private function createScene():void {

			// First object : a sphere

			// Create a new material for the sphere : simple white wireframe
			var sphereMaterial:MaterialObject3D=new WireframeMaterial(0xFFFFFF);

			// Create a new sphere object using wireframe material, radius 50 with
			//   10 horizontal and vertical segments
			var sphere:Sphere=new Sphere(sphereMaterial,50,10,10);

			// Position the sphere (default = [0, 0, 0])
			sphere.x=-100;

			// Second object : x-, y- and z-axis

			// Create a default line material and a Lines3D object (container for Line3D objects)
			var defaultMaterial:LineMaterial=new LineMaterial(0xFFFFFF);
			var axes:Lines3D=new Lines3D(defaultMaterial);

			// Create a different colour line material for each axis
			var xAxisMaterial:LineMaterial=new LineMaterial(0xFF0000);
			var yAxisMaterial:LineMaterial=new LineMaterial(0x00FF00);
			var zAxisMaterial:LineMaterial=new LineMaterial(0x0000FF);

			// Create a origin vertex
			var origin:Vertex3D=new Vertex3D(0,0,0);

			// Create a new line (length 100) for each axis using the different materials and a width of 2.
			var xAxis:Line3D=new Line3D(axes,xAxisMaterial,2,origin,new Vertex3D(100,0,0));
			var yAxis:Line3D=new Line3D(axes,yAxisMaterial,2,origin,new Vertex3D(0,100,0));
			var zAxis:Line3D=new Line3D(axes,zAxisMaterial,2,origin,new Vertex3D(0,0,100));

			// Add lines to the Lines3D container
			axes.addLine(xAxis);
			axes.addLine(yAxis);
			axes.addLine(zAxis);

			// Add the sphere and the lines to the scene
			scene.addChild(sphere);
			scene.addChild(axes);
		}

		private function loop(event:Event):void {
			// Render the 3D scene
			renderer.renderScene(scene,camera,viewport);
		}
	}
}