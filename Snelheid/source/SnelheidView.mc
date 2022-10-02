import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SnelheidView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var verschil as Numeric;
    hidden var V as Numeric;
    hidden var mMetric = System.getDeviceSettings().paceUnits;
    hidden var achtergrondhoog;
    hidden var achtergrondlaag;
    hidden var voorgrondhoog;
    hidden var voorgrondlaag;
    hidden var breedte;
    hidden var hoogte;
    hidden var vorigemidden;
    
    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        verschil = 0;
        V = 0.0f;
        vorigemidden = 9;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
    	breedte = dc.getWidth();
        hoogte = dc.getHeight();
        if (hoogte < 60) {
            View.setLayout(Rez.Layouts.Klein(dc));
        } else if ((hoogte >= 60) and (hoogte < 80)) {
            View.setLayout(Rez.Layouts.Middel1(dc));
        } else if ((hoogte >= 80) and (hoogte < 100)) {
            View.setLayout(Rez.Layouts.Middel2(dc));
        } else if (hoogte >= 100) {
            View.setLayout(Rez.Layouts.Groot(dc));
        }

        var valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 10;

        // plaats label "Speed" boven aan
        var labelView = View.findDrawableById("label") as Text;
        if (mMetric == System.UNIT_METRIC) {
            labelView.setText(Rez.Strings.labelmetric);
        } else {
            labelView.setText(Rez.Strings.labelstatute);
        }

        // Achtergrond en voorgrond kleur instellingen opvragen
        achtergrondhoog  = Application.Properties.getValue("achtergrondhoog");
        achtergrondlaag  = Application.Properties.getValue("achtergrondlaag");
        voorgrondhoog  = Application.Properties.getValue("voorgrondhoog");
        voorgrondlaag  = Application.Properties.getValue("voorgrondlaag");
    }

    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        verschil = 0;
        if ((info.averageSpeed != null) and (info.averageSpeed != 0)) {
            V = (info.currentSpeed - info.averageSpeed) / info.averageSpeed;
            if (V > 0.05) {
                verschil = 1;
            }
            if (V < -0.05) {
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
        var value = View.findDrawableById("value") as Text;
        switch (verschil) {
            case 0:
                achtergrond.setColor(getBackgroundColor());
                if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                    label.setColor(Graphics.COLOR_WHITE);
                    value.setColor(Graphics.COLOR_WHITE);
                } else {
                    label.setColor(Graphics.COLOR_BLACK);
                    value.setColor(Graphics.COLOR_BLACK);
                }
                break;
            case 1:
                label.setColor(voorgrondhoog);
                value.setColor(voorgrondhoog);
                achtergrond.setColor(achtergrondhoog);
                break;
            case -1:
                label.setColor(voorgrondlaag);
                value.setColor(voorgrondlaag);
                achtergrond.setColor(achtergrondlaag);
                break;
        }

        // Set the value
        value.setText(mValue.format("%.1f"));
        
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        if (hoogte > 80) {
            var x;
            var aantalblokjes = 19;
            var midden = 9;
            var blokjeB = breedte / aantalblokjes;
            var blokjeH = 10;

            if (V < -0.350000 ) {midden = 0;}
            if ((V >= -0.350000) and (V < -0.311112 )) {midden = 1;}
            if ((V >= -0.311112) and (V < -0.272223 )) {midden = 2;}
            if ((V >= -0.272223) and (V < -0.233334 )) {midden = 3;}
            if ((V >= -0.233334) and (V < -0.194445 )) {midden = 4;}
            if ((V >= -0.194445) and (V < -0.155556 )) {midden = 5;}
            if ((V >= -0.155556) and (V < -0.116667 )) {midden = 6;}
            if ((V >= -0.116667) and (V < -0.077778 )) {midden = 7;}
            if ((V >= -0.077778) and (V < -0.038889 )) {midden = 8;}

            if ((V >= -0.038889) and (V < 0.038889 )) {midden = 9;}

            if ((V < 0.077778) and (V >= 0.038889 )) {midden = 10;}
            if ((V < 0.116667) and (V >= 0.077778 )) {midden = 11;}
            if ((V < 0.155556) and (V >= 0.116667 )) {midden = 12;}
            if ((V < 0.194445) and (V >= 0.155556 )) {midden = 13;}
            if ((V < 0.233334) and (V >= 0.194445 )) {midden = 14;}
            if ((V < 0.272223) and (V >= 0.233334 )) {midden = 15;}
            if ((V < 0.311112) and (V >= 0.272223 )) {midden = 16;}
            if ((V < 0.350000) and (V >= 0.311112 )) {midden = 17;}
            if (V > 0.350000 ) {midden = 18;}

            for ( x=0; x<aantalblokjes; x+=1 ) {
                if (verschil == 0) {
                    if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    } else {
                        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                    }
                } else if (verschil == 1) {
                    dc.setColor(voorgrondhoog, Graphics.COLOR_TRANSPARENT);
                } else if (verschil == -1) {
                    dc.setColor(voorgrondlaag, Graphics.COLOR_TRANSPARENT);
                }

                var blokjemidden = [(midden + 1), (midden - 1)];
                var blokjehoog = midden;
                if (midden > vorigemidden) {
                    blokjemidden = [(midden - 1), (midden - 2)];
                    blokjehoog = midden;
                }
                if (midden < vorigemidden) {
                    blokjemidden = [(midden + 2), (midden + 1)];
                    blokjehoog = midden;
                }

                if ((x == blokjemidden[0]) or (x == blokjemidden[1])) {
                    dc.fillRoundedRectangle(10 + x * blokjeB, hoogte - 17, blokjeB, blokjeH + 5, 1);
                } else if (x == blokjehoog) {
                    dc.fillRoundedRectangle(10 + x * blokjeB, hoogte - 22, blokjeB, blokjeH + 10, 1);
                } else {
                    dc.fillRoundedRectangle(10 + x * blokjeB, hoogte - 12, blokjeB, blokjeH, 1);
                }
            }
            vorigemidden = midden;
        }
    }
}
