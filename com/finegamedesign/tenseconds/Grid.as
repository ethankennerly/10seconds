package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Grid
    {
        private static var shuffleNodes:Boolean = true;
        private static var turn:Boolean = true;

        internal var buttonRotations:Array;
        internal var noButtonHeres:Array;
        internal var cellCount:int;
        internal var cellPixels:int;
        internal var cells:Array;
        internal var columnCount:int;
        internal var connections:Array;
        internal var height:int;
        internal var margin:int;
        internal var nodes:Array;
        internal var nodeCoordinates:Vector.<Number>;
        internal var nodeCount:int;
        internal var nodePixelsRadius:int;
        internal var paths:Array;
        internal var pathsHorizontal:Array;
        internal var pathsVertical:Array;
        internal var rowCount:int;
        internal var width:int;
        internal var top:int;
        internal var turnMax:int;

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
            pathsVertical = [];
            pathsHorizontal = [];
            cellCount = columnCount * rowCount;
            for (var i:int = 0; i < cellCount; i++) {
                cells.push(0);
                pathsVertical[i] = false;
                pathsHorizontal[i] = false;
            }
            nodeCount = Math.max(2, Math.min(5, 2 + level / 20));
            turnMax = Math.min(8, 0 + level / 10);
            nodes = specifyNodes();
            nodeCoordinates = new Vector.<Number>();
            coordinate(nodes, nodeCoordinates);
            buttonRotations = specifyButtonRotations(nodeCount);
            connections = connect(nodeCount);
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
            var margin2:int = margin * 5 / nodeCount;
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
                    if (shuffleNodes) {
                        shuffle(remaining);
                    }
                    var s:int = 0;
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
        private function coordinate(indexes:Array, coordinates:Vector.<Number>, offset:int=0):void
        {
            for (var i:int = 0; i < indexes.length; i++) {
                coordinates.push(cellPixels * ((indexes[i] % columnCount) + 0.5) + offset);
                coordinates.push(cellPixels * (int(indexes[i] / columnCount) + 0.5) + top + offset);
            }
        }

        /**
         * @return  connections     2D array of each node's button's destination node's button.  Pair, so opposite direction is omitted.  01 exists, 10 does not exist.
         */
        private function connect(nodeCount:int):Array
        {
            var connections:Array = [];
            for (var n:int = 0; n < nodeCount - 1; n++) {
                connections.push([]);
                for (var m:int = n + 1; m < nodeCount; m++) {
                    connections[n].push(m);
                }
            }
            // trace("connect: nodes " + nodeCount + ": " + connections);
            return connections;
        }

        /**
         * Line from each origin to destination.
         * Axis-aligned lines.
         * TODO: Avoid button areas.
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
                    var waypoints:Array = [];
                    var coordinates:Vector.<Number> = new Vector.<Number>();
                    var rotation:Number = buttonRotations[n][n + b];
                    var origin:int = fromNode(rotation, nodes[n], margin);
                    if (origin <= -1) {
                        throw new Error("Expected origin on grid rotation " 
                            + rotation + " from node " + nodes[n]);
                    }
                    waypoints.push({index: origin, rotation: rotation});
                    if (turn) {
                        turns(turnMax, waypoints);
                    }
                    rotation = buttonRotations[connections[n][b]][n];
                    var destination:int = fromNode(rotation, nodes[connections[n][b]], margin);
                    if (destination <= -1) {
                        throw new Error("Expected origin on grid rotation " 
                            + rotation + " from node " + nodes[n]);
                    }
                    if (turn) {
                        var reverse:Array = [{index: destination, rotation: rotation}];
                        turns(turnMax, reverse);
                        reverse.reverse();
                        turnToward(waypoints[waypoints.length - 1], reverse[0], waypoints);
                        waypoints = waypoints.concat(reverse);
                    }
                    else {
                        waypoints.push({index: destination, rotation: rotation});
                    }
                    for (var i:int = 0; i < waypoints.length; i++) {
                        indexes.push(waypoints[i].index);
                    }
                    coordinate(indexes, coordinates, (n + b) * cellPixels / connections.length);
                    paths.push(coordinates);
                }
            }
            return paths;
        }

        private function turns(turnMax:int, waypoints:Array):void
        {
            var waypoint:Object = waypoints[waypoints.length - 1];
            for (var turnCount:int = 0; turnCount < turnMax; turnCount++) { 
                waypoint = turnFromNode(waypoint["rotation"], waypoint["index"]);
                waypoints.push(waypoint);
                etch(waypoints[waypoints.length - 2].index, 
                    waypoints[waypoints.length - 1].index);
            }
        }

        /**
         * TODO: If would backtrack, turn around.  Append to waypoints.
         * Rotate first toward second.
         */
        private function turnToward(from:Object, to:Object, waypoints:Array):void
        {
            var fromC:int = from.index % columnCount;
            var fromR:int = from.index / columnCount;
            var toC:int = to.index % columnCount;
            var toR:int = to.index / columnCount;
            var bridge:* = {index: fromC + toR * columnCount, 
                rotation: 0};
            if (fromC == toC) {
                if (fromR < toR) {
                    if (from.rotation == 0) {
                    }
                }
            }
            waypoints.push(bridge);
        }

        /**
         * Record path horizontals and path verticals.
         */
        private function etch(from:int, to:int):void
        {
            var fromC:int = from % columnCount;
            var fromR:int = from / columnCount;
            var toC:int = to % columnCount;
            var toR:int = to / columnCount;
            var i:int;
            if (fromC == toC) {
                for (var r:int = Math.min(fromR, toR); r < Math.max(fromR, toR); r++) {
                    i = fromC + r * columnCount;
                    pathsVertical[i] = true;
                }
            }
            else if (fromR == toR) {
                for (var c:int = Math.min(fromC, toC); c < Math.max(fromC, toC); c++) {
                    i = c + fromR * columnCount;
                    pathsHorizontal[i] = true;
                }
            }
        }
    
        /**
         * TODO: Avoid parallel overlap.  Select cell before this.
         */
        private function avoidParallelOverlap(waypoint:Object):void
        {
            var i:int, t:int; 
            if (0 == int(Math.round(waypoint.rotation)) % 180) {
                for (i = waypoint.index, t = 0; 
                    (pathsHorizontal[i] || pathsVertical[i]) && t < margin - 1; 
                    i -= relative(waypoint.rotation).x, t++) {}
                waypoint.index = i;
            }
            else {
                for (i = waypoint.index, t = 0; 
                    (pathsHorizontal[i] || pathsVertical[i]) && t < margin - 1; 
                    i -= relative(waypoint.rotation).y, t++) {}
                waypoint.index = i;
            }
        }

        /**
         * @return  -1 if wrapping an edge.
         */
        private function fromNode(rotation:Number, index:int, margin:int):int
        {
            var columnOffset:int = margin * relative(rotation).x;
            var rowOffset:int = margin * relative(rotation).y;
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

        private function relative(degrees:Number):Object
        {
            var radians:Number = degrees * Math.PI / 180.0;
            return {x: Math.cos(radians), y: Math.sin(radians)};
        }

        /**
         * Avoid button areas.
         * @return  waypoint with a rotation and index.
         */
        private function turnFromNode(rotation:Number, index:int):Object
        {
            var maybes:Array = [];
            for (var i:int = -1; i < 2; i++) {
                var mayRotate:Number = rotation + 90 * i;
                var maybe:int = fromNode(mayRotate, index, 2 + margin * Math.random());
                if (0 <= maybe) {
                    maybes.push({index: maybe, rotation: mayRotate});
                }
            }
            if (maybes.length <= 0) {
                throw new Error("Expected at least one possible waypoint.");
            }
            var clears:Array = [];
            for (var m:int = 0; m < maybes.length; m++) {
                if (noButtonHere(maybes[m].index)) {
                    clears.push(maybes[m]);
                }
            }
            if (1 <= clears.length) {
                maybes = clears;
            }
            else {
                trace("Grid.turnFromHere: Must go through button.");
            }
            var waypoint:Object = maybes[drawTurn() % maybes.length];
            avoidParallelOverlap(waypoint);
            return waypoint;
        }

        private var deck:Array;

        private function drawTurn():int
        {
            if (null == deck || deck.length <= 0) {
                deck = [];
                for (var i:int = 0; i < 3; i++) {
                    deck.push(i);
                }
                shuffle(deck);
            }
            return deck.shift();
        }

        private function noButtonHere(index:int):Boolean
        {
            if (null == noButtonHeres) {
                noButtonHeres = [];
                for (var i:int = 0; i < cellCount; i++) {
                    noButtonHeres[i] = true;
                }
                for (var n:int = 0; n < nodes.length; n++) {
                    var node:int = nodes[n];
                    for (var c:int = Math.max(0, node % columnCount - margin); 
                            c < Math.min(columnCount - 1, node % columnCount + margin);
                            c++) {
                        for (var r:int = Math.max(0, int(node / columnCount) - margin); 
                                r < Math.min(columnCount - 1, int(node / columnCount) + margin);
                                r++) {
                            noButtonHeres[c + r * c] = false;
                        }
                    }
                }
            }
            return noButtonHeres[index];
        }

        /**
         * 90 degree increments.  Shuffle correct.
         */
        private function specifyButtonRotations(nodeCount:int):Array
        {
            var buttonRotations:Array = [];
            if (2 <= nodeCount) {
                var degree:Number = 90.0;
                for (var n:int = 0; n < nodeCount; n++) {
                    buttonRotations.push([]);
                    for (var rotation:int = 0; rotation < 360.0; rotation += degree) {
                        buttonRotations[n].push(rotation);
                    }
                    shuffle(buttonRotations[n]);
                    buttonRotations[n].splice(nodeCount - 1);
                }
            }
            return buttonRotations;
        }
    }
}
