import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class ETAplusView extends WatchUi.DataField {

    hidden var mValue1;
    hidden var mValue2;
    hidden var mValue3 as Float = 0.0;
    hidden var breedte;
    hidden var eenvijfde;
    hidden var hoogte;
    hidden var etaInSeconds as Float = 0.0;

    hidden var mMetric = System.getDeviceSettings().paceUnits;

    hidden var valueView1;
    hidden var labelView1;
    hidden var valueView2;
    hidden var labelView2;
    hidden var valueView3;
    hidden var labelView3;
    
    function initialize() {
        DataField.initialize();
        mValue1 = "--:--";
        mValue2 = "--:--";
        mValue3 = 0.0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        hoogte = dc.getHeight();
        breedte = dc.getWidth();
        eenvijfde = (breedte / 5);

        View.setLayout(Rez.Layouts.Klein(dc));

        valueView1 = View.findDrawableById("value1");
        valueView1.locX = eenvijfde;
        valueView1.locY = valueView1.locY + 10;
        labelView1 = View.findDrawableById("label1") as Text;
        labelView1.locX = eenvijfde;
        labelView1.setText(Rez.Strings.label1);

        valueView2 = View.findDrawableById("value2");
        valueView2.locY = valueView2.locY + 10;
        labelView2 = View.findDrawableById("label2") as Text;
        labelView2.setText(Rez.Strings.label2);

        valueView3 = View.findDrawableById("value3");
        valueView3.locX = eenvijfde * 4;
        valueView3.locY = valueView3.locY + 10;
        labelView3 = View.findDrawableById("label3") as Text;
        labelView3.locX = eenvijfde * 4;
        labelView3.setText(Rez.Strings.label3);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if ((info.averageSpeed  != null) and (info.averageSpeed  != 0) and (info.currentSpeed != 0) and (info.distanceToDestination != null) and (info.distanceToDestination != 0)) {
            
            if ((info.currentSpeed / info.averageSpeed) >= 1.333) {
                etaInSeconds = info.distanceToDestination / (((info.averageSpeed) + info.currentSpeed * 3)/4);
            }
            else {
                etaInSeconds = info.distanceToDestination / (((info.averageSpeed * 3) + info.currentSpeed)/4);
            }
            
//////////////////
            var Uur = Math.floor(etaInSeconds / 3600);
            var Minuut = Math.floor((etaInSeconds - (Uur * 3600)) / 60);
            var Seconden = Math.floor(etaInSeconds - (Uur * 3600) - (Minuut * 60));
            if (Uur > 0) {
                mValue1 = Uur.format("%02d") + ":" + Minuut.format("%02d");
            } else {
                mValue1 = Minuut.format("%02d") + ":" + Seconden.format("%02d");
            }
//////////////////
            var tijdNu = new Time.Moment(Time.now().value());
            var tijdTegaanInSeconds = new Time.Duration(etaInSeconds.toNumber());
            tijdNu = tijdNu.add(tijdTegaanInSeconds);
            var tijdETAGregorian = Gregorian.info(tijdNu, Time.FORMAT_SHORT);
            var dateString = Lang.format(
                "$1$:$2$",
                [
                    tijdETAGregorian.hour.format("%02d"),
                    tijdETAGregorian.min.format("%02d"),
                ]
            );
            mValue2 = dateString;
            mValue3 = info.distanceToDestination;

            if (mMetric == System.UNIT_METRIC) {
                if (mValue3 < 1000) {
                    mValue3 = info.distanceToDestination;
                } else {
                    mValue3 = info.distanceToDestination / 1000;
                }
            } else {
                if (mValue3 < 1609.344) {
                    mValue3 = info.distanceToDestination * 1.093613;
                } else {
                    mValue3 = info.distanceToDestination / 1609.344;
                }
            }
//////////////////
        } else {
            mValue1 = "--:--";
            mValue2 = "--:--";
            mValue3 = 0.0;
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            valueView1.setColor(Graphics.COLOR_WHITE);
            labelView1.setColor(Graphics.COLOR_WHITE);
            valueView2.setColor(Graphics.COLOR_WHITE);
            labelView2.setColor(Graphics.COLOR_WHITE);
            valueView3.setColor(Graphics.COLOR_WHITE);
            labelView3.setColor(Graphics.COLOR_WHITE);
        } else {
            valueView1.setColor(Graphics.COLOR_BLACK);
            labelView1.setColor(Graphics.COLOR_BLACK);
            valueView2.setColor(Graphics.COLOR_BLACK);
            labelView2.setColor(Graphics.COLOR_BLACK);
            valueView3.setColor(Graphics.COLOR_BLACK);
            labelView3.setColor(Graphics.COLOR_BLACK);
        }
        if (mMetric == System.UNIT_METRIC) {
            if (mValue3 < 1000) {
                labelView3.setText(Rez.Strings.label3m);
            } else {
                labelView3.setText(Rez.Strings.label3km);
            }
        } else {
            if (mValue3 < 1609.344) {
                labelView3.setText(Rez.Strings.label3y);
            } else {
                labelView3.setText(Rez.Strings.label3ml);
            }
        }
        valueView1.setText(mValue1);
        valueView2.setText(mValue2);
        valueView3.setText(mValue3.format("%.0f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
