package com.finegamedesign.tenseconds
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.Event;

    public dynamic class Main extends MovieClip
    {
        public var feedback:MovieClip;

        public function Main()
        {
            AnswerButton.onClick = answer;
        }

        public function trial():void
        {
            feedback.gotoAndPlay("none");
            stop();
        }

        public function restart():void
        {
            gotoAndPlay(1);
        }

        private function answer(event:Event):void
        {
            trace("Main.answer: " + event.currentTarget.name);
            var correct:Boolean = "correct" === event.currentTarget.name;
            if (correct) {
                feedback.gotoAndPlay("correct");
                if (currentFrame < totalFrames) {
                    play();
                }
                else {
                    gotoAndPlay(1);
                }
            }
            else {
                feedback.gotoAndPlay("wrong");
            }
        }
    }
}
