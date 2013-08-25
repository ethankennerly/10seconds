package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Board
    {
        internal static var filters:Array = [];
        internal var display:Sprite;

        public function Board(grid:Grid)
        {
            display = new Sprite();
            drawPaths(display, grid.paths, filters);
        }

        /**
         * Compatible with Flash Player 9 that does not support drawPaths.
         */
        private function drawPaths(display:Sprite, paths:Array, filters:Array):void
        {
            display.graphics.lineStyle(8.0, 0xFFFFFF);
            for (var p:int = 0; p < paths.length; p ++) {
                var path:Vector.<Number> = paths[p];
                display.graphics.moveTo(path[0], path[1]);
                for (var xy:int = 2; xy < path.length - 1; xy += 2) {
                    display.graphics.lineTo(path[xy], path[xy + 1]);
                }
            }
        }
    }
}
