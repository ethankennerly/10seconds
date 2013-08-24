package com.finegamedesign.tenseconds
{
    import flash.display.MovieClip;
    import flash.events.Event;

    public dynamic class Main extends MovieClip
    {
        private var game:Game;

        public function Main()
        {
            if (null == stage) {
                addEventListener(Event.ADDED_TO_STAGE, added, false, 0, true);
            }
            else {
                added(null);
            }
        }

        private function added(event:Event)
        {
            game = new Game(this);
        }
    }
}
