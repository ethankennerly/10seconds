package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Grid
    {
        internal var cellCount:int;
        internal var cellPixels:int;
        internal var cells:Array;
        internal var columnCount:int;
        internal var height:int;
        internal var rowCount:int;
        internal var width:int;
        internal var top:int;
        internal var paths:Array;
        internal var nodes:Array;
        internal var nodeCoordinates:Vector.<Number>;

        public function Grid(level:int)
        {
            cellPixels = 16;
            height = 480;
            top = 60;
            width = 640;
            columnCount = width / cellPixels;
            rowCount = (height - top) / cellPixels;
            cells = [];
            cellCount = columnCount * rowCount;
            for (var i:int = 0; i < cellCount; i++) {
                cells.push(0);
            }
            nodes = specifyNodes();
            nodeCoordinates = coordinate(nodes);
            paths = specifyPaths();
        }

        private function specifyNodes():Array
        {
            var indexes:Array = [];
            for (var i:int = 0; i < cellCount; i++) {
                indexes.push(i);
            }
            shuffle(indexes);
            var nodes:Array = indexes.slice(0, 2);
            return nodes;
        }

        private function shuffle(elements:Array):void
        {
            for (var i:int = elements.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var jNew:* = elements[i];
                elements[i] = elements[j];
                elements[j] = jNew;
            }
        }

        /**
         * Position at center of cell at each index.
         * @return  <x0, y0, x1, y1, ...>
         */
        private function coordinate(indexes:Array):Vector.<Number>
        {
            var coordinates:Vector.<Number> = new Vector.<Number>();
            for (var i:int = 0; i < indexes.length; i++) {
                coordinates.push(cellPixels * ((indexes[i] % columnCount) + 0.5));
                coordinates.push(cellPixels * (int(indexes[i] / columnCount) + 0.5) + top);
            }
            return coordinates;
        }

        /**
         * Specify corners from start and finish of a path.
         * Increment count of paths passing through a cell.
         * Do not pass through any cell with 2 or more.
         * @return [<moveToX, moveToY, lineToX, lineToY, lineToX, lineToY, ...>, ...]
         */
        private function specifyPaths():Array
        {
            var paths:Array = [];
            var coordinates:Vector.<Number> = new Vector.<Number>();
            testPushCoordinates(coordinates);
            paths.push(coordinates);
            paths.push(nodeCoordinates);
            return paths;
        }

        private function testPushCoordinates(coordinates:Vector.<Number>):void
        {
            coordinates.push(20.0);
            coordinates.push(0.0);
            coordinates.push(620.0);
            coordinates.push(0.0);
        }
    }
}
