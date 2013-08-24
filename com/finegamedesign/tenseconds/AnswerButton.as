package com.finegamedesign.tenseconds
{
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;

    public class AnswerButton extends SimpleButton
    {
        internal static var onClick:Function;

        public function AnswerButton()
        {
            this.addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 0, true);
        }

        internal function disable():void
        {
            mouseEnabled = false;
            upState = downState;
            overState = downState;
        }
    }
}
