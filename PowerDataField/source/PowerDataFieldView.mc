import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PowerDataFieldView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var ftp;

    hidden var currentPower;
    hidden var averagePower;
    hidden var V as Number;
    hidden var powerGemiddeldeArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    hidden var powerGemiddeldeTijd;
    hidden var teller;
    hidden var powerZone;
    hidden var powerZoneProcenten = [0, 0, 0, 0, 0, 0, 0 ];

    hidden var breedte;
    hidden var hoogte;
    hidden var vorigemidden;

    function initialize() {
        DataField.initialize();
        mValue = 0;
        teller = 0;
        powerZone = 0;
        ftp = 0;
        V = 0;
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

        // plaats label "Power" boven aan
        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);

        ftp = Application.Properties.getValue("ftp");
        powerGemiddeldeTijd = Application.Properties.getValue("powerGemiddeldeTijd");

        powerZoneProcenten[0] = 0;
        powerZoneProcenten[1] = (ftp * 54) /100;
        powerZoneProcenten[2] = (ftp * 75) /100;
        powerZoneProcenten[3] = (ftp * 89) /100;
        powerZoneProcenten[4] = (ftp * 105) /100;
        powerZoneProcenten[5] = (ftp * 120) /100;
        powerZoneProcenten[6] = (ftp * 150) /100;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if (info has :currentPower){
            if (info.currentPower != null){
                currentPower = info.currentPower;
                if (powerGemiddeldeTijd != 0) {
                    if (teller == powerGemiddeldeTijd) {teller = 0;}
                    powerGemiddeldeArray[teller] = currentPower;
                    teller += 1;
                    mValue = 0;
                    for (var y=0; y<powerGemiddeldeTijd; y++) {
                        mValue += powerGemiddeldeArray[y];
                    }
                    mValue = mValue / powerGemiddeldeTijd;
                } else {
                    mValue = currentPower;
                }
                if ((info.averagePower != null) and (info.averagePower != 0)) {
                    averagePower = info.averagePower;
                    V = ((mValue - averagePower) * 100) / averagePower;
                }
            } else {
                mValue = 0;
            }
            if (mValue < powerZoneProcenten[1]) {powerZone = 0;}
            else if ((mValue >= powerZoneProcenten[1]) and (mValue < powerZoneProcenten[2])) {powerZone = 1;}
            else if ((mValue >= powerZoneProcenten[2]) and (mValue < powerZoneProcenten[3])) {powerZone = 2;}
            else if ((mValue >= powerZoneProcenten[3]) and (mValue < powerZoneProcenten[4])) {powerZone = 3;}
            else if ((mValue >= powerZoneProcenten[4]) and (mValue < powerZoneProcenten[5])) {powerZone = 4;}
            else if ((mValue >= powerZoneProcenten[5]) and (mValue < powerZoneProcenten[6])) {powerZone = 5;}
            else if (mValue >= powerZoneProcenten[6]) {powerZone = 6;}
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

        switch (powerZone) {
            case 0:
                label.setColor(Graphics.COLOR_WHITE);
                value.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_LT_GRAY);
                break;
            case 1:
                label.setColor(Graphics.COLOR_WHITE);
                value.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_BLUE);
                break;
            case 2:
                label.setColor(Graphics.COLOR_WHITE);
                value.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_GREEN);
                break;
            case 3:
                label.setColor(Graphics.COLOR_BLACK);
                value.setColor(Graphics.COLOR_BLACK);
                achtergrond.setColor(0xFFFF00);  //Graphics.COLOR_YELLOW
                break;
            case 4:
                label.setColor(Graphics.COLOR_BLACK);
                value.setColor(Graphics.COLOR_BLACK);
                achtergrond.setColor(0xFFAA55);  //Graphics.COLOR_ORANGE
                break;
            case 5:
                label.setColor(Graphics.COLOR_WHITE);
                value.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_RED);
                break;
            case 6:
                label.setColor(Graphics.COLOR_WHITE);
                value.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_RED);
                break;
        }

        // Set the value
        value.setText(mValue.format("%0d"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        if (hoogte > 80) {
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
