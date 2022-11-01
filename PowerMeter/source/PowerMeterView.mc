import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PowerMeterView extends WatchUi.DataField {

    hidden var mValue as Number;
    hidden var verschil as Number;
    hidden var V as Number;
    hidden var achtergrondhoog;
    hidden var achtergrondlaag;
    hidden var voorgrondhoog;
    hidden var voorgrondlaag;
    hidden var breedte;
    hidden var hoogte;
    hidden var vorigemidden;
    hidden var currentPower;
    hidden var averagePower;
    hidden var powerGemiddeldeArray;
    hidden var powerGemiddeldeTijd;
    hidden var teller;

    hidden var valueView;
    hidden var labelView;

    function initialize() {
        DataField.initialize();
        mValue = 0;
        verschil = 0;
        V = 0;
        vorigemidden = 9;
        teller = 0;

        powerGemiddeldeTijd = Application.Properties.getValue("powerGemiddeldeTijd");
        powerGemiddeldeArray = new [powerGemiddeldeTijd];
        for (var x=0; x<powerGemiddeldeTijd; x++) { powerGemiddeldeArray[x] = 0; }

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

        labelView = View.findDrawableById("label") as Text;
        labelView.setText(Rez.Strings.label);

        // Achtergrond en voorgrond kleur instellingen opvragen
        achtergrondhoog = Application.Properties.getValue("achtergrondhoog");
        achtergrondlaag = Application.Properties.getValue("achtergrondlaag");
        voorgrondhoog = Application.Properties.getValue("voorgrondhoog");
        voorgrondlaag = Application.Properties.getValue("voorgrondlaag");
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        verschil = 0;
        if (info has :currentPower){
            if (info.currentPower != null){
                currentPower = info.currentPower;

                if (powerGemiddeldeTijd > 0) {
                    powerGemiddeldeArray[teller] = currentPower;
                    teller = (teller < (powerGemiddeldeTijd-1)) ? (teller+1) : 0;
                    mValue = Math.mean(powerGemiddeldeArray);
                } else {
                    mValue = currentPower;
                }
                if ((info.averagePower != null) and (info.averagePower != 0)) {
                    averagePower = info.averagePower;
                    V = ((mValue - averagePower) * 100) / averagePower;
                    verschil = (V > 5) ? 1 : ((V < -5) ? -1 : 0);
                }
            } else {
                mValue = 0;
            }
        }
    }
    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
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
        valueView.setText(mValue.format("%0d"));
        
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        if (hoogte > 100) {
            var x;
            var aantalblokjes = 19;
            var midden = 9;
            var blokjeB = breedte / aantalblokjes;
            var blokjeH = 10;

            if (V < -35 ) {midden = 0;}
            else if ((V >= -35) and (V < -32 )) {midden = 1;}
            else if ((V >= -32) and (V < -28 )) {midden = 2;}
            else if ((V >= -28) and (V < -24 )) {midden = 3;}
            else if ((V >= -24) and (V < -20 )) {midden = 4;}
            else if ((V >= -20) and (V < -16 )) {midden = 5;}
            else if ((V >= -16) and (V < -13 )) {midden = 6;}
            else if ((V >= -13) and (V < -9 )) {midden = 7;}
            else if ((V >= -9) and (V < -5 )) {midden = 8;}

            else if ((V >= -5) and (V < 5 )) {midden = 9;}

            else if ((V < 9) and (V >= 5 )) {midden = 10;}
            else if ((V < 13) and (V >= 9 )) {midden = 11;}
            else if ((V < 16) and (V >= 13 )) {midden = 12;}
            else if ((V < 20) and (V >= 16 )) {midden = 13;}
            else if ((V < 24) and (V >= 20 )) {midden = 14;}
            else if ((V < 28) and (V >= 24 )) {midden = 15;}
            else if ((V < 32) and (V >= 28 )) {midden = 16;}
            else if ((V < 35) and (V >= 32 )) {midden = 17;}
            else if (V > 35 ) {midden = 18;}

            for ( x=0; x<aantalblokjes; x+=1 ) {
                var blokjemidden = [(midden - 1), (midden + 1)];
                var blokjehoog = midden;
                if (midden > vorigemidden) {
                    blokjemidden = [(midden - 2), (midden - 1)];
                    blokjehoog = midden;
                }
                if (midden < vorigemidden) {
                    blokjemidden = [(midden + 1), (midden + 2)];
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
