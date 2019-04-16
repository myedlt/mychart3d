package {

  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;

  import org.papervision3d.core.proto.MaterialObject3D;
  import org.papervision3d.lights.PointLight3D;
  import org.papervision3d.materials.shadematerials.CellMaterial;
  import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
  import org.papervision3d.materials.shadematerials.GouraudMaterial;
  import org.papervision3d.materials.shadematerials.PhongMaterial;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  public class Example004 extends BasicView {

    private static const ORBITAL_RADIUS:Number = 200;

    private var sphere1:Sphere;
    private var sphere2:Sphere;
    private var sphere3:Sphere;
    private var sphere4:Sphere;
    private var sphereGroup:DisplayObject3D;

    public function Example004() {
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

      // Specify a point light source and its location
      var light:PointLight3D = new PointLight3D(true);
      light.x = 400;
      light.y = 1000;
      light.z = -400;

      // Create a new material (flat shaded) and apply it to a sphere
      var flatShadedMaterial:MaterialObject3D = new FlatShadeMaterial(light, 0x6654FF, 0x060433);
      sphere1 = new Sphere(flatShadedMaterial, 50, 10, 10);
      sphere1.x = -ORBITAL_RADIUS;

      // Create a new material (Gouraud shaded) and apply it to a sphere
      var gouraudMaterial:MaterialObject3D = new GouraudMaterial(light, 0x6654FF, 0x060433);
      sphere2 = new Sphere(gouraudMaterial, 50, 10, 10);
      sphere2.x =  ORBITAL_RADIUS;

      // Create a new material (Phong shaded) and apply it to a sphere
      var phongMaterial:MaterialObject3D = new PhongMaterial(light, 0x6654FF, 0x060433, 150);
      sphere3 = new Sphere(phongMaterial, 50, 10, 10);
      sphere3.z = -ORBITAL_RADIUS;

      // Create a new material (cell shaded) and apply it to a sphere
      var cellMaterial:MaterialObject3D = new CellMaterial(light, 0x6654FF, 0x060433, 5);
      sphere4 = new Sphere(cellMaterial, 50, 10, 10);
      sphere4.z =  ORBITAL_RADIUS;

      // Create a 3D object to group the spheres
      sphereGroup = new DisplayObject3D();
      sphereGroup.addChild(sphere1);
      sphereGroup.addChild(sphere2);
      sphereGroup.addChild(sphere3);
        sphereGroup.addChild(sphere4);

      // Add the light and spheres to the scene
      scene.addChild(sphereGroup);
      scene.addChild(light);
    }

    override protected function onRenderTick(event:Event=null):void {

      // rotate the spheres
      sphere1.yaw(-8);
      sphere2.yaw(-8);
      sphere3.yaw(-8);
      sphere4.yaw(-8);

      // rotate the group of spheres
      sphereGroup.yaw(3);

      // call the renderer
      super.onRenderTick(event);
    }

  }
}
