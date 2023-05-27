import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.UserProfile;

class HeartZoneView extends WatchUi.DataField {

    hidden var mValue as Float;
    hidden var hartslag as Float;
    hidden var heartRateZones as Array<Number>;
    hidden var heartRateZoneFloat1 as Numeric;
    hidden var heartRateZoneFloat2 as Numeric;
    hidden var heartRateZoneFloat3 as Numeric;
    hidden var heartRateZoneFloat4 as Numeric;
    hidden var heartRateZoneFloat5 as Numeric;
    hidden var heartRateZonesFloat0 as Float;
    hidden var heartRateZonesFloat1 as Float;
    hidden var heartRateZonesFloat2 as Float;
    hidden var heartRateZonesFloat3 as Float;
    hidden var heartRateZonesFloat4 as Float;
    hidden var currentZone;
    hidden var labelView;
    hidden var valueView;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        hartslag = 0.0f;
        currentZone = 0;
        heartRateZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        heartRateZoneFloat1 = (heartRateZones[1] - heartRateZones[0]).toFloat();
        heartRateZoneFloat2 = (heartRateZones[2] - heartRateZones[1]).toFloat();
        heartRateZoneFloat3 = (heartRateZones[3] - heartRateZones[2]).toFloat();
        heartRateZoneFloat4 = (heartRateZones[4] - heartRateZones[3]).toFloat();
        heartRateZoneFloat5 = (heartRateZones[5] - heartRateZones[4]).toFloat();
        heartRateZonesFloat0 = heartRateZones[0].toFloat();
        heartRateZonesFloat1 = heartRateZones[1].toFloat();
        heartRateZonesFloat2 = heartRateZones[2].toFloat();
        heartRateZonesFloat3 = heartRateZones[3].toFloat();
        heartRateZonesFloat4 = heartRateZones[4].toFloat();
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
                if (hartslag < heartRateZones[0]) {currentZone = 0; mValue = 0.0f;}
                else if ((hartslag >= heartRateZones[0]) and (hartslag < heartRateZones[1])) {currentZone = 1; mValue = 1.0 + ((hartslag.toFloat() - heartRateZonesFloat0) / heartRateZoneFloat1);}
                else if ((hartslag >= heartRateZones[1]) and (hartslag < heartRateZones[2])) {currentZone = 2; mValue = 2.0 + ((hartslag.toFloat() - heartRateZonesFloat1) / heartRateZoneFloat2);}
                else if ((hartslag >= heartRateZones[2]) and (hartslag < heartRateZones[3])) {currentZone = 3; mValue = 3.0 + ((hartslag.toFloat() - heartRateZonesFloat2) / heartRateZoneFloat3);}
                else if ((hartslag >= heartRateZones[3]) and (hartslag < heartRateZones[4])) {currentZone = 4; mValue = 4.0 + ((hartslag.toFloat() - heartRateZonesFloat3) / heartRateZoneFloat4);}
                else if ((hartslag >= heartRateZones[4]) and (hartslag < heartRateZones[5])) {currentZone = 5; mValue = 5.0 + ((hartslag.toFloat() - heartRateZonesFloat4) / heartRateZoneFloat5);}  
                else if (hartslag > heartRateZones[5]) {currentZone = 6; hartslag = 6.0;}
            } else {
                currentZone = 0;
                mValue = 0.0f;
            }
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
