import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ETAView extends WatchUi.DataField {

    hidden var mValue as String;
    hidden var breedte;
    hidden var hoogte;
    hidden var tijdDisplay;

    function initialize() {
        DataField.initialize();
        mValue = "--:--:--";
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
      	breedte = dc.getWidth();
        hoogte = dc.getHeight();
        System.print(hoogte);
        if (hoogte < 70) {
            View.setLayout(Rez.Layouts.Klein(dc));
        } else if ((hoogte >= 70) and (hoogte < 80)) {
            View.setLayout(Rez.Layouts.Middel1(dc));
        } else if ((hoogte >= 80) and (hoogte < 100)) {
            View.setLayout(Rez.Layouts.Middel2(dc));
        } else if (hoogte >= 100) {
            View.setLayout(Rez.Layouts.Groot(dc));
        }

        var valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 10;

        var labelView = View.findDrawableById("label") as Text;
        labelView.setText(Rez.Strings.label);

        tijdDisplay = Application.Properties.getValue("tijdDisplay");
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        var tijdNow = Time.now();
        var tijdNowGregorian = Gregorian.info(tijdNow, Time.FORMAT_SHORT);
        if ((info.averageSpeed  != null) and (info.averageSpeed  != 0) and (info.distanceToDestination != 0)) {
            var etaInSeconds = info.distanceToDestination / info.averageSpeed;
            var tijdInSeconds = new Time.Duration(etaInSeconds);

            if (tijdDisplay == 0) {
//////////////////
                var tijdInSecondsUur = Math.floor(etaInSeconds / 3600);
                var tijdInSecondsMinuut = Math.floor((etaInSeconds - (tijdInSecondsUur * 3600)) / 60);
                var tijdInSecondsSeconde = Math.floor(etaInSeconds - (tijdInSecondsUur * 3600) - (tijdInSecondsMinuut * 60));
                mValue = tijdInSecondsUur.format("%02d") + ":" + tijdInSecondsMinuut.format("%02d") + ":" + tijdInSecondsSeconde.format("%02d");
//////////////////
            } else {
                var tijdETA = tijdNow.add(tijdInSeconds);
                var tijdETAGregorian = Gregorian.info(tijdETA, Time.FORMAT_SHORT);
                var dateString = Lang.format(
                    "$1$:$2$:$3$",
                    [
                        tijdETAGregorian.hour.format("%02d"),
                        tijdETAGregorian.min.format("%02d"),
                        tijdETAGregorian.sec.format("%02d")
                    ]
                );
                mValue = dateString;
//////////////////
            }
        } else {
            mValue = "--:--:--";
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
//        value.setText(mValue.format("%.2f"));
        value.setText(mValue);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
