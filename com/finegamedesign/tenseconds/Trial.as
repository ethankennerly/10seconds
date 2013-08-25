package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Trial extends Sprite
    {
        internal static var level:int = 0;

        /**
         * Replace contents with a board.
         */
        public function Trial()
        {
            super();
            for (var c:int = numChildren - 1; 0 <= c; c--) {
                removeChildAt(c);
            }
            var grid:Grid = new Grid(level);
            var board:Board = new Board(grid);
            TestGrid.visualizeNodes(board.display, 
                grid.nodeCoordinates, grid.nodePixelsRadius);
            addChild(board.display);
        }
    }
}
