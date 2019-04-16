package {
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  

  public class DrawTool extends Sprite {

    private var isDrawing:Boolean = false;

    public function DrawTool() {

      // create a drawing surface
      graphics.beginFill(0xEEEEEE);
      graphics.moveTo(0, 0);
      graphics.lineTo(320, 0);
      graphics.lineTo(320, 240);
      graphics.lineTo(0, 240);
      graphics.endFill();
     
      // create text and format
      var textFormat:TextFormat = new TextFormat();
      textFormat.size = 30;
      textFormat.font = "Arial";
     
      var text:TextField = new TextField();
      text.x = 50;
      text.y = 100;
      text.textColor = 0x222222;
      text.text = "click to draw!";
      text.setTextFormat(textFormat);
      text.autoSize = TextFieldAutoSize.LEFT;
      text.selectable = false;
      addChild(text);
     
      // listen to mouse events
      this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
     
    }
   
    // start drawing circles
    private function onMouseDown(event:MouseEvent):void {
      isDrawing = true;
      drawCircle(event.stageX, event.stageY);
    }
   
    // stop drawing circles
    private function onMouseUp(event:MouseEvent):void {
      isDrawing = false;
    }
   
    // draw a circle
    private function onMouseMove(event:MouseEvent):void {
      if (isDrawing) {
        drawCircle(event.stageX, event.stageY);
      }
    }

    // circle drawing function
    private function drawCircle(x:int, y:int):void {
      graphics.beginFill(Math.random() * 0xFFFFFF, 0.5);
      graphics.drawCircle(x, y, 5);
      graphics.endFill();
    }
   
  }
}