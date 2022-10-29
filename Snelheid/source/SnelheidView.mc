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
    hidden var currentSpeed;
    hidden var averageSpeed;
    
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
        if (info has :currentSpeed) {
            currentSpeed = info.currentSpeed;
            averageSpeed = info.averageSpeed;

            if ((averageSpeed != null) and (averageSpeed != 0)) {
                V = ((currentSpeed - averageSpeed) * 100) / averageSpeed;
                System.println(V);
                if (V > 5) {
                    verschil = 1;
                } else if (V < -5) {
                    verschil = -1;
                }
            }

            if (currentSpeed != null) {
                mValue = currentSpeed * ((mMetric == System.UNIT_METRIC) ? (3.6) : (2.23693629));
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

        if (hoogte > 100) {
            var x;
            var aantalblokjes = 19;
            var midden = 9;
            var blokjeB = breedte / aantalblokjes;
            var blokjeH = 10;

            if (V < -35.0000 ) {midden = 0;}
            else if ((V >= -35.0000) and (V < -31.1112 )) {midden = 1;}
            else if ((V >= -31.1112) and (V < -27.2223 )) {midden = 2;}
            else if ((V >= -27.2223) and (V < -23.3334 )) {midden = 3;}
            else if ((V >= -23.3334) and (V < -19.4445 )) {midden = 4;}
            else if ((V >= -19.4445) and (V < -15.5556 )) {midden = 5;}
            else if ((V >= -15.5556) and (V < -11.6667 )) {midden = 6;}
            else if ((V >= -11.6667) and (V <  -7.7778 )) {midden = 7;}
            else if ((V >=  -7.7778) and (V <  -3.8889 )) {midden = 8;}

            else if ((V >= -3.8889) and (V < 3.8889 )) {midden = 9;}

            else if ((V <  7.7778) and (V >=  3.8889 )) {midden = 10;}
            else if ((V < 11.6667) and (V >=  7.7778 )) {midden = 11;}
            else if ((V < 15.5556) and (V >= 11.6667 )) {midden = 12;}
            else if ((V < 19.4445) and (V >= 15.5556 )) {midden = 13;}
            else if ((V < 23.3334) and (V >= 19.4445 )) {midden = 14;}
            else if ((V < 27.2223) and (V >= 23.3334 )) {midden = 15;}
            else if ((V < 31.1112) and (V >= 27.2223 )) {midden = 16;}
            else if ((V < 35.0000) and (V >= 31.1112 )) {midden = 17;}
            else if (V > 35.0000 ) {midden = 18;}

            for ( x=0; x<aantalblokjes; x+=1 ) {
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
