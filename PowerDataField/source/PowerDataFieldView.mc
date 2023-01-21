import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.UserProfile;

class PowerDataFieldView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var ftp;

    hidden var currentPower;
    hidden var averagePower;
    hidden var V as Number;
    hidden var SSlow as Number;
    hidden var SShigh as Number;
    hidden var powerGemiddeldeArray;
    hidden var powerGemiddeldeTijd;
    hidden var teller;
    hidden var powerZone;
    hidden var powerZoneProcenten = new [6];

    hidden var breedte;
    hidden var hoogte;
    hidden var vorigemidden;

    hidden var valueView;
    hidden var labelView;
    hidden var sweetspotView;
    hidden var sweetSpot;

    hidden var gewicht;
    hidden var displayW;

    function initialize() {
        DataField.initialize();
        mValue = 0;
        teller = 0;
        powerZone = 0;
        ftp = 0;
        V = 0;
        SSlow = 0;
        SShigh = 0;
        sweetSpot = false;
        powerGemiddeldeTijd = 0;
        vorigemidden = 9;

        var profile = UserProfile.getProfile();
        gewicht = profile.weight;

        powerGemiddeldeTijd = Application.Properties.getValue("powerGemiddeldeTijd");
        powerGemiddeldeArray = new [powerGemiddeldeTijd];
        for (var x=0; x<powerGemiddeldeTijd; x++) { powerGemiddeldeArray[x] = 0; }

        ftp = Application.Properties.getValue("ftp");
        powerZoneProcenten[0] = (ftp * 54) / 100;
        powerZoneProcenten[1] = (ftp * 75) / 100;
        powerZoneProcenten[2] = (ftp * 89) / 100;
        powerZoneProcenten[3] = (ftp * 105) / 100;
        powerZoneProcenten[4] = (ftp * 120) / 100;
        powerZoneProcenten[5] = (ftp * 150) / 100;
        SSlow = (ftp * 86) / 100;
        SShigh = (ftp * 95) / 100;

        displayW = Application.Properties.getValue("display");
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

        valueView = View.findDrawableById("value") as Text;
        valueView.locY = valueView.locY + 10;

        sweetspotView = View.findDrawableById("sweetspot") as Text;
        sweetspotView.locX = breedte - 15;

        labelView = View.findDrawableById("label") as Text;
        if (displayW) {
            labelView.setText(Rez.Strings.wattperkg);
        } else {
            labelView.setText(Rez.Strings.label);
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if (info has :currentPower){
            currentPower = info.currentPower;
            if (currentPower != null) {
                if (powerGemiddeldeTijd > 0) {
                    powerGemiddeldeArray[teller] = currentPower;
                    teller = (teller < (powerGemiddeldeTijd-1)) ? (teller+1) : 0;
                    mValue = Math.mean(powerGemiddeldeArray);
                } else {
                    mValue = currentPower;
                }
                if (ftp != 0) {
                    V = ((mValue - ftp) * 100) / ftp;
                }
            } else {
                mValue = 0;
            }
            if (mValue < powerZoneProcenten[0]) {powerZone = 0;}
            else if ((mValue >= powerZoneProcenten[0]) and (mValue < powerZoneProcenten[1])) {powerZone = 1;}
            else if ((mValue >= powerZoneProcenten[1]) and (mValue < powerZoneProcenten[2])) {powerZone = 2;}
            else if ((mValue >= powerZoneProcenten[2]) and (mValue < powerZoneProcenten[3])) {powerZone = 3;}
            else if ((mValue >= powerZoneProcenten[3]) and (mValue < powerZoneProcenten[4])) {powerZone = 4;}
            else if ((mValue >= powerZoneProcenten[4]) and (mValue < powerZoneProcenten[5])) {powerZone = 5;}
            else if (mValue >= powerZoneProcenten[5]) {powerZone = 6;}

            if ((mValue >= SSlow) and (mValue <= SShigh)) {
                sweetSpot = true;
            } else {
                sweetSpot = false;
            }

            if (displayW) {
                mValue = mValue * 1000 / gewicht;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Get the background color
        var achtergrond = View.findDrawableById("Background") as Text;

        if (sweetSpot) {
            sweetspotView.setText(Rez.Strings.sweetspot);
        } else {
            sweetspotView.setText("");
        }

         // Set the foreground color and value
        switch (powerZone) {
            case 0:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(0x808080); // (Graphics.COLOR_GRAY);
                break;
            case 1:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_BLUE);
                break;
            case 2:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_GREEN);
                break;
            case 3:
                labelView.setColor(Graphics.COLOR_BLACK);
                valueView.setColor(Graphics.COLOR_BLACK);
                sweetspotView.setColor(Graphics.COLOR_BLACK);
                achtergrond.setColor(0xFFFF00);  //Graphics.COLOR_YELLOW
                break;
            case 4:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(0xFAA918);  //Graphics.COLOR_ORANGE
                break;
            case 5:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_RED);
                break;
            case 6:
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                sweetspotView.setColor(Graphics.COLOR_WHITE);
                achtergrond.setColor(Graphics.COLOR_DK_RED);
                break;
        }

        // Set the value
        if (displayW) {
            valueView.setText(mValue.format("%0.2f"));
        } else {
            valueView.setText(mValue.format("%0d"));
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        if ((hoogte > 100) and (Application.Properties.getValue("displayBar"))) {
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
