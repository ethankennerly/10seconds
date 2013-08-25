package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Grid
    {
        internal var cellPixels:int = 16;
        internal var cells:Array;
        internal var columnCount:int = width / cellPixels;
        internal var height:int = 640;
        internal var rowCount:int = (height - top) / cellPixels;
        internal var width:int = 640;
        internal var top:int = 60;
        internal var paths:Array;

        public function Grid(level:int)
        {
            cells = [];
            var cellCount:int = columnCount * rowCount;
            for (var i:int = 0; i < cellCount; i++) {
                cells.push(0);
            }
            paths = specifyPaths();
        }

        /**
         * @return [<moveToX, moveToY, lineToX, lineToY, lineToX, lineToY, ...>, ...]
         */
        private function specifyPaths():Array
        {
            var paths:Array = [];
            var coordinates:Vector.<Number> = new Vector.<Number>();
            coordinates.push(320.0);
            coordinates.push(0.0);
            coordinates.push(640.0);
            coordinates.push(0.0);
            paths.push(coordinates);
            return paths;
        }
    }
}
