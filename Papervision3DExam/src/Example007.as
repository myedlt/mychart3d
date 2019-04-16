package {

  import flash.display.Bitmap;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;

  import org.papervision3d.events.InteractiveScene3DEvent;
  import org.papervision3d.lights.PointLight3D;
  import org.papervision3d.materials.BitmapMaterial;
  import org.papervision3d.materials.shaders.CellShader;
  import org.papervision3d.materials.shaders.EnvMapShader;
  import org.papervision3d.materials.shaders.FlatShader;
  import org.papervision3d.materials.shaders.GouraudShader;
  import org.papervision3d.materials.shaders.PhongShader;
  import org.papervision3d.materials.shaders.ShadedMaterial;
  import org.papervision3d.materials.shaders.Shader;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Sphere;
  import org.papervision3d.view.BasicView;

  public class Example007 extends BasicView {

    [Embed(source="/../assets/pv3d.jpg")] private var Pv3dBitmapImage:Class;
    [Embed(source="/../assets/randomBump.jpg")] private var BumpImage:Class;
    [Embed(source="/../assets/mountains.jpg")] private var EnvImage:Class;

    private var pv3dBitmap:Bitmap = new Pv3dBitmapImage();
    private var bumpMap:Bitmap = new BumpImage();
    private var envMap:Bitmap = new EnvImage();

    private var bitmapMaterial:BitmapMaterial;

    private var sphere:Sphere;
    private var light:PointLight3D;

    private var doRotation:Boolean = false;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;
    private var cameraYaw:Number = -60;

    private var shaders:Array = ["flat", "cell", "gouraud", "phong", "phongBump", "env", "envBump"];
    private var shaderIndex:int = 0;

    private var shaderText:TextField;
    private var textFormat:TextFormat;
    public function Example007() {
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

      stage.addChild(shaderText);

      // Start rendering the scene
      startRendering();
    }

    private function init3D():void {
      // position the camera
      camera.z = -500;
      camera.orbit(60, -60);
    }

    private function createScene():void {
      // create text and format to display current shader type
      textFormat = new TextFormat();
      textFormat.size = 20;
      textFormat.font = "Arial";

      shaderText = new TextField();
      shaderText.x = 50;
      shaderText.y = 50;
      shaderText.textColor = 0xFFFFFF;
      shaderText.text = "flat";
      shaderText.setTextFormat(textFormat);
      shaderText.autoSize = TextFieldAutoSize.LEFT;

      // Specify a point light source and its location
      light = new PointLight3D(true);
      light.x = 500;
      light.y = 500;
      light.z = -200;

      // create bitmap material with smoothing
      bitmapMaterial = new BitmapMaterial(pv3dBitmap.bitmapData, false);
      bitmapMaterial.smooth = true;

      // create sphere
      sphere = new Sphere(getShadedBitmapMaterial(bitmapMaterial, "flat"), 150, 20, 20);

      // Add a listener to the spheres to listen to InteractiveScene3DEvent events
      sphere.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onMouseDownOnObject);

      // Add the light and sphere to the scene
      scene.addChild(sphere);
      scene.addChild(light);
    }

    private function getShadedBitmapMaterial(bitmapMaterial:BitmapMaterial, shaderType:String):ShadedMaterial {
      var shader:Shader;

      if (shaderType == "flat") {
        // create new flat shader
        shader = new FlatShader(light, 0xFFFFFF, 0x333333);

      } else if (shaderType == "cell") {
        // create new cell shader with 5 colour levels
        shader = new CellShader(light, 0xFFFFFF, 0x333333, 5);

      } else if (shaderType == "gouraud") {
        // create new gouraud shader
        shader = new GouraudShader(light, 0xFFFFFF, 0x333333);

      } else if (shaderType == "phong") {
        // create new phong shader
        shader = new PhongShader(light, 0xFFFFFF, 0x333333, 50);

      } else if (shaderType == "phongBump") {
        // create new phong shader with bump map
        shader = new PhongShader(light, 0xFFFFFF, 0x333333, 50, bumpMap.bitmapData);

      } else if (shaderType == "env") {
        // create new environment map shader
        shader = new EnvMapShader(light, envMap.bitmapData, envMap.bitmapData, 0x333333);

      } else if (shaderType == "envBump") {
        // create new environment map shader with bump map
        shader = new EnvMapShader(light, envMap.bitmapData, envMap.bitmapData, 0x333333, bumpMap.bitmapData);
      }

      // create new shaded material by combining the bitmap material with shader
      var shadedMaterial:ShadedMaterial =  new ShadedMaterial(bitmapMaterial, shader);
      shadedMaterial.interactive = true;

      return shadedMaterial;
    }

    override protected function onRenderTick(event:Event=null):void {
      // rotate the sphere
      sphere.yaw(-1);

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

      // calculate index of next shader
      shaderIndex++;
      if (shaderIndex == shaders.length) {
        shaderIndex = 0;
      }

      // dynamically modify the material of the object and update text
      object.material = getShadedBitmapMaterial(bitmapMaterial, shaders[shaderIndex]);
      shaderText.text = shaders[shaderIndex];
      shaderText.setTextFormat(textFormat);
    }
  }
}
