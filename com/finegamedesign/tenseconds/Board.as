package com.finegamedesign.tenseconds
{
    import flash.display.Sprite;

    public class Board
    {
        internal var display:Sprite;

        public function Board(level:int)
        {
            display = new Sprite();
            display.graphics.lineStyle(8.0, 0xFFFFFF);
            display.graphics.lineTo(320, 0);
        }
    }
}
