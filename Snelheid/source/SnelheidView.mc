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

    hidden var valueView;
    hidden var labelView;

    hidden var aantalblokjes;
    hidden var midden;
    hidden var blokjeB;
    hidden var blokjeH;
    hidden var blokjeHH;
    hidden var blokjeHHH;
    hidden var inspringen;
    
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

        valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 10;

        // plaats label "Speed" boven aan
        labelView = View.findDrawableById("label") as Text;
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

        aantalblokjes = 19;
        midden = 9;
        blokjeB = breedte / aantalblokjes;
        blokjeH = 10;
        blokjeHH = 15;
        blokjeHHH = 20;
        if (hoogte < 120) {
            blokjeH = 8;
            blokjeHH = 11;
            blokjeHHH = 14;
        }
        inspringen = (breedte - (aantalblokjes*blokjeB)) / 2;
    }

    function compute(info as Activity.Info) as Void {
        verschil = 0;
        if (info has :currentSpeed) {
            currentSpeed = info.currentSpeed;
            if (currentSpeed != null) {
                mValue = currentSpeed * ((mMetric == System.UNIT_METRIC) ? (3.6) : (2.23693629));
                averageSpeed = info.averageSpeed;
                if ((averageSpeed != null) and (averageSpeed != 0)) {
                    V = ((currentSpeed - averageSpeed) * 100) / averageSpeed;
                    verschil = (V > 5) ? 1 : ((V < -5) ? -1 : 0);
                }
            } else {
                mValue = 0.0f;
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        // Get the background color
        var achtergrond = View.findDrawableById("Background") as Text;

        switch (verschil) {
            case 0:
                achtergrond.setColor(getBackgroundColor());
                if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                    labelView.setColor(Graphics.COLOR_WHITE);
                    valueView.setColor(Graphics.COLOR_WHITE);
                } else {
                    labelView.setColor(Graphics.COLOR_BLACK);
                    valueView.setColor(Graphics.COLOR_BLACK);
                }
                break;
            case 1:
                labelView.setColor(voorgrondhoog);
                valueView.setColor(voorgrondhoog);
                achtergrond.setColor(achtergrondhoog);
                break;
            case -1:
                labelView.setColor(voorgrondlaag);
                valueView.setColor(voorgrondlaag);
                achtergrond.setColor(achtergrondlaag);
                break;
        }

        // Set the value
        valueView.setText(mValue.format("%.1f"));
        
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        if ((hoogte > 90) and (Application.Properties.getValue("displayBar"))) {
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

            for (var x=0; x<aantalblokjes; x+=1 ) {
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
                    dc.fillRoundedRectangle(inspringen + x * blokjeB, hoogte - blokjeHH, blokjeB, blokjeHH, 1);
                } else if (x == blokjehoog) {
                    dc.fillRoundedRectangle(inspringen + x * blokjeB, hoogte - blokjeHHH, blokjeB, blokjeHHH, 1);
                } else {
                    dc.fillRoundedRectangle(inspringen + x * blokjeB, hoogte - blokjeH, blokjeB, blokjeH, 1);
                }
            }
            vorigemidden = midden;
        }
    }
}
