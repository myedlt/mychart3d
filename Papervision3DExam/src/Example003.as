package {

  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;

  import org.papervision3d.core.geom.Lines3D;
  import org.papervision3d.core.geom.renderables.Line3D;
  import org.papervision3d.core.geom.renderables.Vertex3D;
  import org.papervision3d.core.proto.MaterialObject3D;
  import org.papervision3d.materials.WireframeMaterial;
  import org.papervision3d.materials.special.LineMaterial;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  public class Example003 extends BasicView {

    private static const ORBITAL_RADIUS:Number = 200;

    private var sphere:Sphere;
    private var theta:Number = 0;

    public function Example003() {
      super(0, 0, true, false);

      // set up the stage
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;

      // Initialise Papervision3D
      init3D();

      // Create the 3D objects
      createScene();

      // Start rendering the scene
      startRendering();
    }

    private function init3D():void {

      // position the camera
      camera.x = -200;
      camera.y =  200;
      camera.z = -500;
    }

    private function createScene():void {

      // First object : a sphere

      // Create a new material for the sphere : simple white wireframe
      var sphereMaterial:MaterialObject3D = new WireframeMaterial(0xFFFFFF);

      // Create a new sphere object using wireframe material, radius 50 with
      //   10 horizontal and vertical segments
      sphere = new Sphere(sphereMaterial, 50, 10, 10);

      // Position the sphere (default = [0, 0, 0])
      sphere.x = -ORBITAL_RADIUS;

      // Second object : x-, y- and z-axis

      // Create a default line material and a Lines3D object (container for Line3D objects)
      var defaultMaterial:LineMaterial = new LineMaterial(0xFFFFFF);
      var axes:Lines3D = new Lines3D(defaultMaterial);

      // Create a different colour line material for each axis
      var xAxisMaterial:LineMaterial = new LineMaterial(0xFF0000);
      var yAxisMaterial:LineMaterial = new LineMaterial(0x00FF00);
      var zAxisMaterial:LineMaterial = new LineMaterial(0x0000FF);

      // Create a origin vertex
      var origin:Vertex3D = new Vertex3D(0, 0, 0);

      // Create a new line (length 100) for each axis using the different materials and a width of 2.
      var xAxis:Line3D = new Line3D(axes, xAxisMaterial, 2, origin, new Vertex3D(100, 0, 0));
      var yAxis:Line3D = new Line3D(axes, yAxisMaterial, 2, origin, new Vertex3D(0, 100, 0));
      var zAxis:Line3D = new Line3D(axes, zAxisMaterial, 2, origin, new Vertex3D(0, 0, 100));

      // Add lines to the Lines3D container
      axes.addLine(xAxis);
      axes.addLine(yAxis);
      axes.addLine(zAxis);

      // Add the sphere and the lines to the scene
      scene.addChild(sphere);
      scene.addChild(axes);
    }

    override protected function onRenderTick(event:Event=null):void {

      // rotate the sphere
      sphere.yaw(-4);

      // change the position of the sphere
      theta += 3;
      var x:Number = - Math.cos(theta * Math.PI / 180) * ORBITAL_RADIUS;
      var z:Number =   Math.sin(theta * Math.PI / 180) * ORBITAL_RADIUS;
      sphere.x = x;
      sphere.z = z;

      // call the renderer
      super.onRenderTick(event);
    }

  }
}
