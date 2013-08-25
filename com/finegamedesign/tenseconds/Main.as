package com.finegamedesign.tenseconds
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.utils.getTimer;

    public dynamic class Main extends MovieClip
    {
        public var feedback:MovieClip;
        public var highScore_txt:TextField;
        public var level_txt:TextField;
        public var maxLevel_txt:TextField;
        public var score_txt:TextField;

        private var highScore:int;
        private var inTrial:Boolean;
        private var remaining:int;
        private var score:int;
        private var startTime:int;
        private var timeLimit:int = 10000;

        public function Main()
        {
            Board.filters = new WireFilter().getChildAt(0).filters;
            AnswerButton.onClick = answer;
            inTrial = false;
            addEventListener(Event.ENTER_FRAME, updateTime, false, 0, true);
            score = 0;
            highScore = 0;
            remaining = 0;
            Trial.level = 0;
            level_txt.text = Trial.level.toString();
            maxLevel_txt.text = Trial.maxLevel.toString();
            updateScoreText();
        }

        internal static function fuseButton():FuseButton
        {
            return new FuseButton();
        }

        public function trial():void
        {
            stop();
            for (var c:int = 0; c < numChildren; c++) {
                var trial:Trial = getChildAt(c) as Trial;
                if (null != trial) {
                    trial.replace();
                    break;
                }
            }
            startTime = getTimer();
            inTrial = true;
            mouseChildren = true;
        }

        public function restart():void
        {
            score = 0;
            remaining = 0;
            gotoAndPlay(1);
            mouseChildren = true;
        }

        public function next():void
        {
            if (currentLabel == "start" && 30 <= Trial.level) {
                gotoAndPlay("random");
            }
            else if (currentFrame < totalFrames) {
                play();
            }
            else {
                restart();
            }
            mouseChildren = true;
        }

        private function scoreUp():void
        {
            score += Trial.level * remaining;
            if (highScore < score) {
                highScore = score;
            }
            updateScoreText();
        }

        private function updateScoreText():void
        {
            // trace("updateScoreText: ", score, highScore);
            score_txt.text = score.toString();
            highScore_txt.text = highScore.toString();
        }

        private function updateTime(event:Event):void
        {
            if (inTrial) {
                var timeTextField:TextField = getChildByName("time_txt") as TextField;
                if (null != timeTextField) {
                    remaining = timeLimit + startTime - getTimer();
                    if (remaining < 0) {
                        wrong();
                    }
                    var seconds:int = Math.max(0, Math.ceil(remaining / 1000));
                    timeTextField.text = "0:" + (10 <= seconds ? "" : "0") + seconds.toString();
                    score_txt.text = (score + int(Trial.level * remaining / 1000 / Trial.level) * 1000 * Trial.level).toString();
                }
                else {
                    remaining = 0;
                }
            }
            else {
                remaining = 0;
            }
        }

        private function answer(event:Event):void
        {
            var target:AnswerButton = AnswerButton(event.currentTarget);
            trace("Main.answer: " + target.name);
            target.disable();
            var correct:Boolean = "correct" == target.name;
            if (correct) {
                Trial.level = Math.min(Trial.maxLevel, Trial.level + 5);
                level_txt.text = Trial.level.toString();
                if (inTrial) {
                    scoreUp();
                }
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
            Trial.level = Math.max(0, Trial.level - 20);
            level_txt.text = Trial.level.toString();
            updateScoreText();
        }
    }
}
