package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;
    import asunit.framework.TestCase;
    
    public class TestGrid extends TestCase 
    {
        internal static function visualizeNodes(parent:Sprite, coordinates:Vector.<Number>, radius:Number):void
        {
            for (var xy:int = 0; xy < coordinates.length - 1; xy+=2) {
                parent.graphics.drawCircle(coordinates[xy], coordinates[xy + 1], radius);
            }
        }

        public function testSample():void 
        {
            var parent:Sprite = new Sprite();
            var columns:int = 10;
            for (var i:int = 0; i < columns * columns; i++) {
                var grid:Grid = new Grid(i);
                var board:Board = new Board(grid);
                visualizeNodes(board.display, grid.nodeCoordinates, grid.nodePixelsRadius);
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
