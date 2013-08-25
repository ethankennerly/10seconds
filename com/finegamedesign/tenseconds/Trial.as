package com.finegamedesign.tenseconds
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;

    public class Trial extends Sprite
    {
        internal static var level:int = 0;
        internal static var maxLevel:int = 100;

        /**
         * Replace contents with a board.
         */
        public function Trial()
        {
            super();
            replace();
        }

        internal function replace():void
        {
            for (var c:int = numChildren - 1; 0 <= c; c--) {
                removeChildAt(c);
            }
            var grid:Grid = new Grid(level);
            var board:Board = new Board(grid);
            addChild(board.display);
            addNodes(grid.nodeCoordinates, grid.buttonRotations);
        }

        /**
         * First two are correct.
         */
        private function addNodes(coordinates:Vector.<Number>, rotations:Array):void
        {
            for (var xy:int = 0; xy < coordinates.length - 1; xy += 2) {
                var i:int = xy / 2;
                var explosive:Boolean = xy == 0 || xy == 2;
                for (var r:int = 0; r < rotations[i].length; r++) {
                    var button:DisplayObject = explosive ? new FuseButton() : new DistractorButton();
                    button.x = coordinates[xy];
                    button.y = coordinates[xy + 1];
                    button.rotation = rotations[i][r];
                    button.name = explosive && r == 0 ? "correct" : "distractor";
                    addChild(button);
                }
                var node:Sprite = explosive ? new Explosive : new Distractor();
                node.x = coordinates[xy];
                node.y = coordinates[xy + 1];
                node.mouseChildren = false;
                node.mouseEnabled = false;
                addChild(node);
            }
        }
    }
}
