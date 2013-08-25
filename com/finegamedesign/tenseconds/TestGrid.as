package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;
    import asunit.framework.TestCase;
    
    public class TestGrid extends TestCase 
    {
        public function testSample():void 
        {
            var parent:Sprite = new Sprite();
            var columns:int = 10;
            for (var i:int = 0; i < columns * columns; i++) {
                var board:Board = new Board(new Grid(i));
                board.display.x = 640 * (i % columns) / columns;
                board.display.y = 480 * int(i / columns) / columns;
                board.display.scaleX = 1.0 / columns;
                board.display.scaleY = 1.0 / columns;
                parent.addChild(board.display);
            }
            addChild(parent);
        }
    }
}
