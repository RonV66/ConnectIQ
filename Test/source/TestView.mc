import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TestView extends WatchUi.DataField {

    hidden var mValue as String;
    hidden var breedte;
    hidden var hoogte;
    hidden var x = 0;
    hidden var valueView;
    hidden var labelView;

    function initialize() {
        DataField.initialize();
        mValue = "---";
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {

/*
      	breedte = dc.getWidth();
        hoogte = dc.getHeight();
        if (hoogte < 60) {
            View.setLayout(Rez.Layouts.Klein(dc));
        } else if ((hoogte >= 60) and (hoogte < 95)) {
            View.setLayout(Rez.Layouts.Middel1(dc));
        } else if ((hoogte >= 95) and (hoogte < 100)) {
            View.setLayout(Rez.Layouts.Middel2(dc));
        } else if (hoogte >= 100) {
            View.setLayout(Rez.Layouts.Groot(dc));
        }
*/
        View.setLayout(Rez.Layouts.MainLayout(dc));
        labelView = View.findDrawableById("label");
        labelView.locY = labelView.locY - 16;
        valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 7;

        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
        (View.findDrawableById("value") as Text).setText(Rez.Strings.label);

        System.println(Graphics.getFontHeight(Graphics.FONT_XTINY));
        System.println(Graphics.getFontHeight(Graphics.FONT_TINY));
        System.println(Graphics.getFontHeight(Graphics.FONT_SMALL));
        System.println(Graphics.getFontHeight(Graphics.FONT_MEDIUM));
        System.println(Graphics.getFontHeight(Graphics.FONT_LARGE));
        System.println(Graphics.getFontHeight(Graphics.FONT_NUMBER_MILD));
        System.println(Graphics.getFontHeight(Graphics.FONT_NUMBER_MEDIUM));
        System.println(Graphics.getFontHeight(Graphics.FONT_NUMBER_HOT));
        System.println(Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT));


    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.\
        //mValue = "01:00";
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        //(View.findDrawableById("Background") as Text).setColor(Graphics.COLOR_BLACK);

        // ((hoogte < 60) {
        //View.setLayout(Rez.Layouts.Klein(dc));
        // ((hoogte >= 60) and (hoogte < 95)) {
        //View.setLayout(Rez.Layouts.Middel1(dc));
        // ((hoogte >= 95) and (hoogte < 100)) {
        //View.setLayout(Rez.Layouts.Middel2(dc));
        // (hoogte >= 100) {
        //View.setLayout(Rez.Layouts.Groot(dc));

        //labelView.setColor(Graphics.COLOR_BLACK);
        x = x + 1;
        if (x == 1) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_TINY);
            mValue = "01:00";
        } else if (x == 2) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_NUMBER_MILD);
            mValue = "02:00";
        } else if (x == 3) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_NUMBER_MEDIUM);
            mValue = "03:00";
        } else if (x == 4) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_NUMBER_HOT);
            mValue = "04:00";
        } else if (x == 5) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_NUMBER_THAI_HOT);
            mValue = "05:00";
        } else if (x == 6) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_GLANCE);
            mValue = "06:00";
        } else if (x == 7) {
            (View.findDrawableById("value") as Text).setFont(Graphics.FONT_GLANCE_NUMBER);
            mValue = "07:00";
        }
        if (x == 7) {
            x = 0;
        }
//        System.println(x);

        // Set the foreground color and value
        //valueView = View.findDrawableById("value") as Text;
        //valueView.setColor(Graphics.COLOR_BLACK);
        valueView.setText(mValue);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
