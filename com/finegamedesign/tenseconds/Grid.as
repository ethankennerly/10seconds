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
        internal var connections:Array;
        internal var height:int;
        internal var nodeCount:int;
        internal var rowCount:int;
        internal var width:int;
        internal var top:int;
        internal var paths:Array;
        internal var margin:int;
        internal var nodes:Array;
        internal var nodeCoordinates:Vector.<Number>;
        internal var buttonRotations:Array;

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
            nodeCount = Math.min(5, 2 + level / 10);
            nodes = specifyNodes();
            nodeCoordinates = new Vector.<Number>();
            coordinate(nodes, nodeCoordinates);
            buttonRotations = specifyButtonRotations(nodeCount);
            connections = shuffleConnections(nodeCount);
            paths = specifyPaths(nodes, buttonRotations, connections);
        }

        /**
         * Randomly distribute with room in center and at edges.
         * Leave space between.
         */
        private function specifyNodes():Array
        {
            margin = Math.ceil(nodePixelsRadius / cellPixels);
            var indexes:Array = [];
            var columnCenter:int = columnCount / 2;
            var rowCenter:int = rowCount / 2;
            for (var i:int = 0; i < cellCount; i++) {
                var c:int = i % columnCount;
                var r:int = i / columnCount;
                if (margin < c && c < columnCount - margin
                 && margin < r && r < rowCount - margin) {
                        if (c < columnCenter - margin || columnCenter + margin < c
                         || r < rowCenter - margin || rowCenter + margin < r) {
                        indexes.push(i);
                    }
                }
            }
            indexes = distribute(indexes, nodeCount, margin);
            return indexes;
        }

        /**
         * Reserve space between, with some room to jitter.
         * Corners first.  Long sides second.
         * @return  indexes     Removed.
         */
        private function distribute(indexes:Array, nodeCount:int, margin:int):Array
        {
            var nodeMargin:int = 2 * margin + 1;
            if (nodeMargin < margin) {
                throw new Error("Expected node margin at least " + margin + " cells. Got " + nodeMargin);
            }
            var succeeded:Boolean = false;
            while (!succeeded) {
                var remaining:Array = indexes.concat();
                var selected:Array = [];
                succeeded = true;
                for (var n:int = 0; n < nodeCount; n++) {
                    if (remaining.length <= 0) {
                        trace("Expected at least one remaining from " + indexes.length + " indexes at margin " + nodeMargin + " indexes " + indexes);
                        succeeded = false;
                        break;
                    }
                    var s:int = 0;  //Math.random() * 10;
                    selected.push(remaining[s]);
                    var selectedColumn:int = remaining[s] % columnCount;
                    var selectedRow:int = remaining[s] / columnCount;
                    for (var i:int = remaining.length - 1; 0 <= i; i--) {
                        var c:int = remaining[i] % columnCount;
                        var r:int = remaining[i] / columnCount;
                        if (Math.abs(r - selectedRow) <= nodeMargin && Math.abs(c - selectedColumn) <= nodeMargin) {
                            remaining.splice(i, 1);
                        }
                    }
                    shuffle(remaining);
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
         * @param   coordinates     Push in place <x0, y0, x1, y1, ...>
         */
        private function coordinate(indexes:Array, coordinates:Vector.<Number>):void
        {
            for (var i:int = 0; i < indexes.length; i++) {
                coordinates.push(cellPixels * ((indexes[i] % columnCount) + 0.5));
                coordinates.push(cellPixels * (int(indexes[i] / columnCount) + 0.5) + top);
            }
        }

        /**
         * TODO: Shuffle?
         * @return  connections     2D array of each node's button's destination node's button.  Pair, so opposite direction is omitted.  01 exists, 10 does not exist.
         */
        private function shuffleConnections(nodeCount:int):Array
        {
            var connections:Array = [];
            for (var n:int = 0; n < nodeCount - 1; n++) {
                connections.push([]);
                for (var m:int = n + 1; m < nodeCount; m++) {
                    connections[n].push(m);
                }
            }
            // trace("shuffleConnections: nodes " + nodeCount + ": " + connections);
            return connections;
        }

        /**
         * Line from each origin to destination.
         * TODO: Specify corners from start and finish of a path.
         * Increment count of paths passing through a cell.
         * Do not pass through any cell with 2 or more.
         * @param   connections     2D array of each node's button's destination node's button.
         * @return [<moveToX, moveToY, lineToX, lineToY, lineToX, lineToY, ...>, ...]
         */
        private function specifyPaths(nodes:Array, buttonRotations:Array, connections:Array):Array
        {
            var paths:Array = [];
            for (var n:int = 0; n < connections.length; n++) {
                for (var b:int = 0; b < connections[n].length; b++) {
                    var indexes:Array = [];
                    var coordinates:Vector.<Number> = new Vector.<Number>();
                    var rotation:Number = buttonRotations[n][b];
                    var origin:int = fromNode(rotation, nodes[n]);
                    if (origin <= -1) {
                        throw new Error("Expected origin on grid rotation " + rotation + " from node " + nodes[n]);
                    }
                    var origin1:int = turnFromNode(rotation, origin);
                    indexes.push(origin);
                    indexes.push(origin1);
                    rotation = buttonRotations[connections[n][b]][b];
                    var destination:int = fromNode(rotation, nodes[connections[n][b]]);
                    var destination1:int = turnFromNode(rotation, destination);
                    if (destination <= -1) {
                        throw new Error("Expected origin on grid rotation " + rotation + " from node " + nodes[n]);
                    }
                    indexes.push(destination1);
                    indexes.push(destination);
                                        
                    coordinate(indexes, coordinates);
                    paths.push(coordinates);
                }
            }
            return paths;
        }

        /**
         * @return  -1 if wrapping an edge.
         */
        private function fromNode(rotation:Number, index:int):int
        {
            var radians:Number = rotation * Math.PI / 180.0;
            var columnOffset:int = margin * Math.cos(radians);
            var rowOffset:int = margin * Math.sin(radians);
            var c:int = index % columnCount + columnOffset;
            var r:int = index / columnCount + rowOffset;
            if (c < 0 || columnCount <= c || r < 0 || rowCount <= r) {
                return -1;
            }
            var offset:int = columnOffset 
                + columnCount * rowOffset;
            index += offset;
            return index;
        }

        private function turnFromNode(rotation:Number, index:int):int
        {
            var maybes:Array = [];
            for (var i:int = -1; i < 2; i++) {
                var mayRotate:Number = rotation + 90 * i;
                var maybe:int = fromNode(mayRotate, index);
                if (0 <= maybe) {
                    maybes.push(maybe);
                }
            }
            if (maybes.length <= 0) {
                throw new Error("Expected at least one possible waypoint.");
            }
            return maybes[int(Math.random() * maybes.length)];
        }

        /**
         * 90 degree increments.
         */
        private function specifyButtonRotations(nodeCount:int):Array
        {
            var buttonRotations:Array = [];
            if (2 <= nodeCount) {
                var degree:Number = 90.0;  // 360.0 / (nodeCount - 1);
                var offset:Number = 0;  // Math.random() * degree;
                for (var n:int = 0; n < nodeCount; n++) {
                    buttonRotations.push([]);
                    for (var m:int = 0; m < nodeCount - 1; m++) {
                        var rotation:Number = m * degree + offset;
                        buttonRotations[n].push(rotation);
                    }
                }
            }
            return buttonRotations;
        }
    }
}
