import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.UserProfile;

class HeartZoneView extends WatchUi.DataField {

    hidden var mValue as Float;
    hidden var hartslag as Float;
    hidden var heartRateZones as Array<Number>;
    hidden var heartRateZone1 as Numeric;
    hidden var heartRateZone2 as Numeric;
    hidden var heartRateZone3 as Numeric;
    hidden var heartRateZone4 as Numeric;
    hidden var heartRateZone5 as Numeric;
    hidden var currentZone;
    hidden var labelView;
    hidden var valueView;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        hartslag = 0.0f;
        currentZone = 0;
        heartRateZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        heartRateZone1 = heartRateZones[1] - heartRateZones[0];
        heartRateZone2 = heartRateZones[2] - heartRateZones[1];
        heartRateZone3 = heartRateZones[3] - heartRateZones[2];
        heartRateZone4 = heartRateZones[4] - heartRateZones[3];
        heartRateZone5 = heartRateZones[5] - heartRateZones[4];
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var hoogte = dc.getHeight();

        if (hoogte < 75) {
            View.setLayout(Rez.Layouts.Middel1(dc));
        } else if ((hoogte >= 75) and (hoogte < 100)) {
            View.setLayout(Rez.Layouts.Middel2(dc));
        } else if (hoogte >= 100) {
            View.setLayout(Rez.Layouts.Groot(dc));
        }

        valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 10;

        // plaats label "Speed" boven aan
        labelView = View.findDrawableById("label") as Text;
        labelView.setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null) {
                hartslag = info.currentHeartRate as Float;
                //System.print(hartslag + "-" + heartRateZones + "-");
                if (hartslag < heartRateZones[0]) {currentZone = 0; mValue = 0.0f;}
                else if ((hartslag >= heartRateZones[0]) and (hartslag < heartRateZones[1])) {currentZone = 1; mValue = currentZone.toFloat() + ((hartslag.toFloat() - heartRateZones[0].toFloat()) / heartRateZone1.toFloat());}
                else if ((hartslag >= heartRateZones[1]) and (hartslag < heartRateZones[2])) {currentZone = 2; mValue = currentZone.toFloat() + ((hartslag.toFloat() - heartRateZones[1].toFloat()) / heartRateZone2.toFloat());}
                else if ((hartslag >= heartRateZones[2]) and (hartslag < heartRateZones[3])) {currentZone = 3; mValue = currentZone.toFloat() + ((hartslag.toFloat() - heartRateZones[2].toFloat()) / heartRateZone3.toFloat());}
                else if ((hartslag >= heartRateZones[3]) and (hartslag < heartRateZones[4])) {currentZone = 4; mValue = currentZone.toFloat() + ((hartslag.toFloat() - heartRateZones[3].toFloat()) / heartRateZone4.toFloat());}
                else if ((hartslag >= heartRateZones[4]) and (hartslag < heartRateZones[5])) {currentZone = 5; mValue = currentZone.toFloat() + ((hartslag.toFloat() - heartRateZones[4].toFloat()) / heartRateZone5.toFloat());}  
                else if (hartslag > heartRateZones[5]) {currentZone = 6; hartslag = 6.0;}
            } else {
                currentZone = 0;
                mValue = 0.0f;
            }
            System.print(mValue + "-");
            //System.print(((hartslag.toFloat() - heartRateZones[0].toFloat())/heartRateZone1.toFloat()) + "-");
            System.println(hartslag);
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        var achtergrond = View.findDrawableById("Background") as Text;

        switch (currentZone) {
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
                achtergrond.setColor(Graphics.COLOR_LT_GRAY);
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
            case 2:
                achtergrond.setColor(Graphics.COLOR_DK_BLUE);
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
            case 3:
                achtergrond.setColor(Graphics.COLOR_DK_GREEN);
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
            case 4:
                achtergrond.setColor(0xFAA918);  //Graphics.COLOR_ORANGE
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
            case 5:
                achtergrond.setColor(Graphics.COLOR_RED);
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
            case 6:
                achtergrond.setColor(Graphics.COLOR_DK_RED);
                labelView.setColor(Graphics.COLOR_WHITE);
                valueView.setColor(Graphics.COLOR_WHITE);
                break;
        }

        valueView.setText(mValue.format("%.1f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
