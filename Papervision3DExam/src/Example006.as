package {

  import caurina.transitions.Tweener;

  import flash.display.Bitmap;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import org.papervision3d.events.InteractiveScene3DEvent;
  import org.papervision3d.materials.BitmapMaterial;
  import org.papervision3d.materials.utils.MaterialsList;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Cube;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  public class Example006 extends BasicView {

    [Embed(source="/../assets/pv3d.jpg")] private var MyTextureImage:Class;

    private static const ORBITAL_RADIUS:Number = 200;

    private var bitmap:Bitmap = new MyTextureImage();

    private var cube1:Cube;
    private var cube2:Cube;
    private var sphere1:Sphere;
    private var sphere2:Sphere;
    private var objectGroup:DisplayObject3D;

    private var doRotation:Boolean = false;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;
    private var cameraYaw:Number = -60;

    public function Example006() {
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
      camera.orbit(60, -60);
    }

    private function createScene():void {

      // create interactive bitmap material
      var bitmapMaterial:BitmapMaterial = new BitmapMaterial(bitmap.bitmapData, false);
      bitmapMaterial.interactive = true;

      // create an interactive tiled bitmap material (bitmap tiled as 2 x 2)
      var tiledBitmapMaterial:BitmapMaterial = new BitmapMaterial(bitmap.bitmapData, false);
      tiledBitmapMaterial.interactive = true;
      tiledBitmapMaterial.tiled = true;
      tiledBitmapMaterial.maxU = 2;
      tiledBitmapMaterial.maxV = 2;

      // create cube with simple bitmap material
      cube1 = new Cube(getBitmapMaterials(bitmapMaterial), 100, 100, 100);
      cube1.x =  ORBITAL_RADIUS;

      // create cube with tiled bitmap material
      cube2 = new Cube(getBitmapMaterials(tiledBitmapMaterial), 100, 100, 100);
      cube2.x = -ORBITAL_RADIUS;

      // create sphere with simple bitmap material
      sphere1 = new Sphere(bitmapMaterial, 50, 10, 10);
      sphere1.z =  ORBITAL_RADIUS;

      // create sphere with tiled bitmap material
      sphere2 = new Sphere(tiledBitmapMaterial, 50, 10, 10);
      sphere2.z = -ORBITAL_RADIUS;

      // Create a 3D object to group the spheres
      objectGroup = new DisplayObject3D();
      objectGroup.addChild(cube1);
      objectGroup.addChild(cube2);
      objectGroup.addChild(sphere1);
      objectGroup.addChild(sphere2);

      // Add a listener to each of the spheres to listen to InteractiveScene3DEvent events
      cube1.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnObject);
      cube2.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnObject);
      sphere1.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnObject);
      sphere2.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnObject);

      // Add the light and spheres to the scene
      scene.addChild(objectGroup);
    }

    private function getBitmapMaterials(bitmapMaterial:BitmapMaterial):MaterialsList {
      // create list of materials for all faces of the cube,
      //    all with the same bitmap material
      var materials:MaterialsList = new MaterialsList();
      materials.addMaterial(bitmapMaterial, "all");

      return materials;
    }

    override protected function onRenderTick(event:Event=null):void {
      // rotate the objects
      cube1.yaw(-3);
      cube2.yaw(-3);
      sphere1.yaw(-3);
      sphere2.yaw(-3);

      // rotate the group of objects
      objectGroup.yaw(1);

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
    private function onMouseDownOnObject(event:InteractiveScene3DEvent):void {
      var object:DisplayObject3D = event.displayObject3D;
      Tweener.addTween(object, {y:200, time:1, transition:"easeOutSine", onComplete:function():void {goBack(object);} });
    }

    // called when a tween created in onMouseDownOnObject has terminated
    private function goBack(object:DisplayObject3D):void {
      Tweener.addTween(object, {y:0, time:2, transition:"easeOutBounce"});
    }
  }
}
