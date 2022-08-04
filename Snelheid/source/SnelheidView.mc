import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class SnelheidView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var vijfprocent as Numeric;
    hidden var verschil as Numeric;
    hidden var mMetric;
    hidden var gebruiktefont;
    hidden var locatieX as Numeric;
    hidden var locatieY as Numeric;
    
    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        vijfprocent = 0;
        verschil = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        // Setting edge System.UNIT_METRIC or System.UNIT_STATUTE
        mMetric = System.getDeviceSettings().paceUnits;
        var hoogte = dc.getHeight();
        if (hoogte < 60) {
            View.setLayout(Rez.Layouts.Klein(dc));
            gebruiktefont = Graphics.FONT_NUMBER_MILD;
        } else if ((hoogte >= 60) and (hoogte < 80)) {
            View.setLayout(Rez.Layouts.Middel1(dc));
            gebruiktefont = Graphics.FONT_NUMBER_MEDIUM;
        } else if ((hoogte >= 80) and (hoogte < 100)) {
            View.setLayout(Rez.Layouts.Middel2(dc));
            gebruiktefont = Graphics.FONT_NUMBER_HOT;
        } else if (hoogte >= 100) {
            View.setLayout(Rez.Layouts.Groot(dc));
            gebruiktefont = Graphics.FONT_NUMBER_THAI_HOT;
        }

        var valueView = View.findDrawableById("value");
        valueView.locX = valueView.locX - 10;
        valueView.locY = valueView.locY + 10;

        var eenheidView = View.findDrawableById("eenheid");
        locatieX = eenheidView.locX;
        locatieY = eenheidView.locY;

        // plaats label "Speed" boven aan
        var labelView = View.findDrawableById("label") as Text;
        labelView.setText(Rez.Strings.label);

        // plaats snelheid eenheid
        if (mMetric == System.UNIT_METRIC) {
            eenheidView.setText("km" + "\n" + "h");
        } else {
            eenheidView.setText("m" + "\n" + "h");
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        verschil = 0;
        if (info.averageSpeed != null){
            vijfprocent = (info.averageSpeed * 5) / 100;
            if (info.currentSpeed + vijfprocent < info.averageSpeed){
                verschil = 1;
            }
            if (info.currentSpeed - vijfprocent > info.averageSpeed){
                verschil = -1;
            }
        }
        if (info has :currentSpeed){
            if (info.currentSpeed != null){
                switch (mMetric) {
                    case System.UNIT_METRIC:
                        mValue = 3.6 * info.currentSpeed;
                        break;
                    case System.UNIT_STATUTE:
                        mValue = 2.23693629 * info.currentSpeed;
                        break;
                }
            } else {
                mValue = 0.0f;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Get the background color
        var achtergrond = View.findDrawableById("Background") as Text;

         // Set the foreground color and value
        var label = View.findDrawableById("label") as Text;
        var tekst = View.findDrawableById("value") as Text;
        var eenheid = View.findDrawableById("eenheid") as Text;
        switch (verschil) {
            case 0:
                achtergrond.setColor(getBackgroundColor());
                if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                    label.setColor(Graphics.COLOR_WHITE);
                    tekst.setColor(Graphics.COLOR_WHITE);
                    eenheid.setColor(Graphics.COLOR_WHITE);
                } else {
                    label.setColor(Graphics.COLOR_BLACK);
                    tekst.setColor(Graphics.COLOR_BLACK);
                    eenheid.setColor(Graphics.COLOR_BLACK);
                }
                break;
            case -1:
                label.setColor(Graphics.COLOR_WHITE);
                tekst.setColor(Graphics.COLOR_WHITE);
                eenheid.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_GREEN);
                break;
            case 1:
                label.setColor(Graphics.COLOR_WHITE);
                tekst.setColor(Graphics.COLOR_WHITE);
                eenheid.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_RED);
                break;
        }

        // Set the foreground color and value
        tekst.setText(mValue.format("%.1f"));

        var t=mValue.format("%.1f");
        var w=dc.getTextWidthInPixels(t, gebruiktefont);

        eenheid.setFont(Graphics.FONT_TINY);
        eenheid.locX = locatieX + 2 + (w / 2);
        eenheid.locY = locatieY;

        if (mMetric == System.UNIT_METRIC) {
            eenheid.setText("km" + "\n" + "h");
        } else {
            eenheid.setText("m" + "\n" + "h");
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
