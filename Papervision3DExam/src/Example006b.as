package {
 
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
 
  import org.papervision3d.materials.BitmapMaterial;
  import org.papervision3d.materials.utils.MaterialsList;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Cube;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  [SWF(backgroundColor="#FFFFFF")]

  public class Example006b extends BasicView {
 
    [Embed(source="/../assets/pv3d.jpg")] private var PV3D:Class;

    private static const ORBITAL_RADIUS:Number = 100;
 
    private var bitmap:Bitmap = new PV3D();

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
   
    public function Example006b() {
      var background:Sprite = new Sprite();
      background.graphics.beginFill(0x000000);
      background.graphics.moveTo(0, 0);
      background.graphics.lineTo(320, 0);
      background.graphics.lineTo(320, 240);
      background.graphics.lineTo(0, 240);
      background.graphics.endFill();
      addChild(background);
     
      super(320, 240, true, false);

      // Initialise Papervision3D
      init3D();
     
      // Create the 3D objects
      createScene();

      // Listen to mouse up and down events on the stage
      background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      background.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      background.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      // Start rendering the scene
      startRendering();
    }
   
    private function init3D():void {
      // position the camera
      camera.z = -500;
      camera.orbit(cameraPitch, cameraYaw);
    }

    private function createScene():void {

      // create interactive bitmap material
      var bitmapMaterial:BitmapMaterial = new BitmapMaterial(bitmap.bitmapData, false);

      // create an interactive tiled bitmap material (bitmap tiled as 2 x 2)
      var tiledBitmapMaterial:BitmapMaterial = new BitmapMaterial(bitmap.bitmapData, false);
      tiledBitmapMaterial.tiled = true;
      tiledBitmapMaterial.maxU = 2;
      tiledBitmapMaterial.maxV = 2;
     
      // create cube with simple bitmap material
      cube1 = new Cube(getBitmapMaterials(bitmapMaterial), 50, 50, 50);
      cube1.x =  ORBITAL_RADIUS;

      // create cube with tiled bitmap material
      cube2 = new Cube(getBitmapMaterials(tiledBitmapMaterial), 50, 50, 50);
      cube2.x = -ORBITAL_RADIUS;
 
      // create sphere with simple bitmap material
      sphere1 = new Sphere(bitmapMaterial, 25, 10, 10);
      sphere1.z =  ORBITAL_RADIUS;

      // create sphere with tiled bitmap material
      sphere2 = new Sphere(tiledBitmapMaterial, 25, 10, 10);
      sphere2.z = -ORBITAL_RADIUS;

      // Create a 3D object to group the spheres
      objectGroup = new DisplayObject3D();
      objectGroup.addChild(cube1);
      objectGroup.addChild(cube2);
      objectGroup.addChild(sphere1);
      objectGroup.addChild(sphere2);

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

      // call the renderer
      super.onRenderTick(event);
    }

    // called when mouse down on stage
    public function onMouseDown(event:MouseEvent):void {
      doRotation = true;
      lastMouseX = event.stageX;
      lastMouseY = event.stageY;
    }

    // called when mouse up on stage
    public function onMouseUp(event:MouseEvent):void {
      doRotation = false;
    }
   
    // called when the mouse moves over the stage
    public function onMouseMove(event:MouseEvent):void {
      // If the mouse button has been clicked then update the camera position     
      if (doRotation) {
       
        // convert the change in mouse position into a change in camera angle
        var dPitch:Number = (event.stageY - lastMouseY) / 2;
        var dYaw:Number = (event.stageX - lastMouseX) / 2;
       
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
        lastMouseX = event.stageX;
        lastMouseY = event.stageY;
       
        // reposition the camera
        camera.orbit(cameraPitch, cameraYaw);
      }
     
    }
   
  }
}
