package {

  import caurina.transitions.Tweener;

  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.papervision3d.core.proto.MaterialObject3D;
  import org.papervision3d.events.InteractiveScene3DEvent;
  import org.papervision3d.lights.PointLight3D;
  import org.papervision3d.materials.shadematerials.CellMaterial;
  import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
  import org.papervision3d.materials.shadematerials.GouraudMaterial;
  import org.papervision3d.materials.shadematerials.PhongMaterial;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  public class Example005 extends BasicView {

    private static const ORBITAL_RADIUS:Number = 200;

    private var sphere1:Sphere;
    private var sphere2:Sphere;
    private var sphere3:Sphere;
    private var sphere4:Sphere;
    private var sphereGroup:DisplayObject3D;
    private var light:PointLight3D;

    private var doRotation:Boolean = false;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;
    private var cameraYaw:Number = -60;

    public function Example005() {
      // specify that we want the scene to be interactive
      super(0, 0, true, true);

      // set up the stage
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;

      // Initialise Papervision3D
      init3D();

      // Create the 3D objects
      createScene();

      // Listen to mouse up and down events on the stage
      stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      // Start rendering the scene
      startRendering();
    }

    private function init3D():void {
      // position the camera
      camera.z = -500;
      camera.orbit(cameraPitch, cameraYaw);
    }

    private function createScene():void {
      // Specify a point light source and its location
      light = new PointLight3D(true);
      light.x = 400;
      light.y = 1000;
      light.z = -400;

      // Create a new material (flat shaded) and make it interactive
      var flatShadedMaterial:MaterialObject3D = new FlatShadeMaterial(light, 0x6654FF, 0x060433);
      flatShadedMaterial.interactive = true;
      sphere1 = new Sphere(flatShadedMaterial, 50, 10, 10);
      sphere1.x = -ORBITAL_RADIUS;

      // Create a new material (flat shaded) and make it interactive
      var gouraudMaterial:MaterialObject3D = new GouraudMaterial(light, 0x6654FF, 0x060433);
      gouraudMaterial.interactive = true;
      sphere2 = new Sphere(gouraudMaterial, 50, 10, 10);
      sphere2.x =  ORBITAL_RADIUS;

      // Create a new material (flat shaded) and make it interactive
      var phongMaterial:MaterialObject3D = new PhongMaterial(light, 0x6654FF, 0x060433, 150);
      phongMaterial.interactive = true;
      sphere3 = new Sphere(phongMaterial, 50, 10, 10);
      sphere3.z = -ORBITAL_RADIUS;

      // Create a new material (flat shaded) and make it interactive
      var cellMaterial:MaterialObject3D = new CellMaterial(light, 0x6654FF, 0x060433, 5);
      cellMaterial.interactive = true;
      sphere4 = new Sphere(cellMaterial, 50, 10, 10);
      sphere4.z =  ORBITAL_RADIUS;

      // Create a 3D object to group the spheres
      sphereGroup = new DisplayObject3D();
      sphereGroup.addChild(sphere1);
      sphereGroup.addChild(sphere2);
      sphereGroup.addChild(sphere3);
      sphereGroup.addChild(sphere4);

      // Add a listener to each of the spheres to listen to InteractiveScene3DEvent events
      sphere1.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnSphere);
      sphere2.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnSphere);
      sphere3.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnSphere);
      sphere4.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnSphere);

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

      // If the mouse button has been clicked then update the camera position
      if (doRotation) {

        // convert the change in mouse position into a change in camera angle
        var dPitch:Number = (mouseY - lastMouseY) / 2;
        var dYaw:Number = (mouseX - lastMouseX) / 2;

        // update the camera angles
        cameraPitch -= dPitch;
        cameraYaw -= dYaw;
        // limit the pitch of the camera
        if (cameraPitch <= 0) {
          cameraPitch = 0.1;
        } else if (cameraPitch >= 180) {
          cameraPitch = 179.9;
        }

        // reset the last mouse position
        lastMouseX = mouseX;
        lastMouseY = mouseY;

        // reposition the camera
        camera.orbit(cameraPitch, cameraYaw);
      }

      // call the renderer
      super.onRenderTick(event);
    }

    // called when mouse down on stage
    private function onMouseDown(event:MouseEvent):void {
      doRotation = true;
      lastMouseX = event.stageX;
      lastMouseY = event.stageY;
    }

    // called when mouse up on stage
    private function onMouseUp(event:MouseEvent):void {
      doRotation = false;
    }

    // called when mouse down on a sphere
    private function onMouseDownOnSphere(event:InteractiveScene3DEvent):void {
      var object:DisplayObject3D = event.displayObject3D;
      Tweener.addTween(object, {y:200, time:1, transition:"easeOutSine", onComplete:function():void {goBack(object);} });
    }

    // called when a tween created in onMouseDownOnSphere has terminated
    private function goBack(object:DisplayObject3D):void {
      Tweener.addTween(object, {y:0, time:2, transition:"easeOutBounce"});
    }
  }
}