package com.finegamedesign.tenseconds
{
    import flash.display.MovieClip;
    import flash.events.Event;

    public final class Game
    {
        private var screen:MovieClip;

        public function Game(screen:MovieClip)
        {
            this.screen = screen;
            AnswerButton.onClick = answer;
        }

        private function answer(event:Event)
        {
            trace("Game.answer: " + event.currentTarget.name);
            if (screen.currentFrame < screen.totalFrames) {
                screen.play();
            }
            else {
                screen.gotoAndPlay(1);
            }
        }
    }
}
