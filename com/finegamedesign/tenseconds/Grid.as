package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Grid
    {
        internal var nodePixelsRadius:int;
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
            nodePixelsRadius = 60;
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

        /**
         * Randomly distribute with room in center and at edges.
         * Leave space between.
         */
        private function specifyNodes():Array
        {
            var margin:int = Math.ceil(nodePixelsRadius / cellPixels);
            var indexes:Array = [];
            var columnCenter:int = columnCount / 2;
            var rowCenter:int = rowCount / 2;
            for (var i:int = 0; i < cellCount; i++) {
                var c:int = i % columnCount;
                var r:int = i / rowCount;
                if (margin < c && c < columnCount - margin && (c < columnCenter - margin || columnCenter + margin < c)) {
                    if (margin < r && r < rowCount - margin && (r < rowCenter - margin || rowCenter + margin < r)) {
                        indexes.push(i);
                    }
                }
            }
            indexes = distribute(indexes, 4, margin);
            return indexes;
        }

        /**
         * Reserve space between, with some room to jitter.
         * @return  indexes     Removed.
         */
        private function distribute(indexes:Array, nodeCount:int, margin:int):Array
        {
            var nodeMargin:int = margin; // ((columnCount - 4 * margin) * (rowCount - 4 * margin)) / (nodeCount + margin + 8);
            if (nodeMargin < margin) {
                throw new Error("Expected node margin at least " + margin + " cells. Got " + nodeMargin);
            }
            var remaining:Array = indexes.concat();
            var selected:Array = [];
            for (var n:int = 0; n < nodeCount; n++) {
                if (remaining.length <= 0) {
                    throw new Error("Expected at least one remaining from " + indexes.length + " indexes at margin " + nodeMargin + " indexes " + indexes);
                }
                shuffle(remaining);
                selected.push(remaining[0]);
                var selectedColumn:int = remaining[0] % columnCount;
                var selectedRow:int = remaining[0] / columnCount;
                for (var i:int = remaining.length - 1; 0 <= i; i--) {
                    var c:int = remaining[i] % columnCount;
                    var r:int = remaining[i] / rowCount;
                    if (Math.abs(r - selectedRow) < nodeMargin || Math.abs(c - selectedColumn) < nodeMargin) {
                        remaining.splice(i, 1);
                    }
                }
            }
            return selected;
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
