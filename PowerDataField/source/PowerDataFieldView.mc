import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PowerDataFieldView extends WatchUi.DataField {

    hidden var mValue as Numeric;
    hidden var ftp;

    hidden var currentPower;
    hidden var powerGemiddeldeArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    hidden var powerGemiddeldeTijd;
    hidden var teller;
    hidden var powerZone;
    hidden var powerZoneProcenten = [0, 0, 0, 0, 0, 0, 0 ];



    function initialize() {
        DataField.initialize();
        mValue = 0;
        teller = 0;
        powerZone = 0;
        ftp = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
    	var breedte = dc.getWidth();
        var hoogte = dc.getHeight();
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
                achtergrond.setColor(Graphics.COLOR_LT_GRAY);
                break;
            case 1:
                achtergrond.setColor(Graphics.COLOR_DK_BLUE);
                break;
            case 2:
                achtergrond.setColor(Graphics.COLOR_DK_GREEN);
                break;
            case 3:
                achtergrond.setColor(Graphics.COLOR_YELLOW);
                break;
            case 4:
                achtergrond.setColor(Graphics.COLOR_ORANGE);
                break;
            case 5:
                achtergrond.setColor(Graphics.COLOR_RED);
                break;
            case 6:
                achtergrond.setColor(Graphics.COLOR_DK_RED);
                break;
        }

        label.setColor(Graphics.COLOR_WHITE);
        value.setColor(Graphics.COLOR_WHITE);

        // Set the value
        value.setText(mValue.format("%0d"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
