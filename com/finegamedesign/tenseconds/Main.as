package com.finegamedesign.tenseconds
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.utils.getTimer;

    public dynamic class Main extends MovieClip
    {
        public var feedback:MovieClip;
        private var inTrial:Boolean;
        private var startTime:int;
        private var timeLimit:int = 10000;

        public function Main()
        {
            AnswerButton.onClick = answer;
            inTrial = false;
            addEventListener(Event.ENTER_FRAME, updateTime, false, 0, true);
        }

        public function trial():void
        {
            stop();
            startTime = getTimer();
            inTrial = true;
            mouseChildren = true;
        }

        public function restart():void
        {
            gotoAndPlay(1);
            mouseChildren = true;
        }

        public function next():void
        {
            if (currentFrame < totalFrames) {
                play();
            }
            else {
                gotoAndPlay(1);
            }
            mouseChildren = true;
        }

        private function updateTime(event:Event):void
        {
            if (inTrial) {
                var timeTextField:TextField = getChildByName("time") as TextField;
                if (null != timeTextField) {
                    var passed:int = timeLimit + startTime - getTimer();
                    if (passed < 0) {
                        wrong();
                    }
                    var seconds:int = Math.max(0, Math.ceil(passed / 1000));
                    timeTextField.text = "0:" + (10 <= seconds ? "" : "0") + seconds.toString();
                }
            }
        }

        private function answer(event:Event):void
        {
            var target:AnswerButton = AnswerButton(event.currentTarget);
            trace("Main.answer: " + target.name);
            target.disable();
            var correct:Boolean = "correct" == target.name;
            if (correct) {
                inTrial = false;
                mouseChildren = false;
                feedback.gotoAndPlay("correct");
            }
            else {
                wrong();
            }
        }

        private function wrong():void
        {
            inTrial = false;
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
        }
    }
}
