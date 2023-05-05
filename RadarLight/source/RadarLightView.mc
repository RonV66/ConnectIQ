import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.AntPlus;

class RadarLightView extends WatchUi.View {

    var mijnList;

    function initialize() {
        View.initialize();
        var mLightNetworkListener = new AntPlus.LightNetworkListener();
        var mLightNetwork = new AntPlus.LightNetwork(mLightNetworkListener);
        mijnList = mLightNetwork.getBikeLights();
        System.println(mLightNetwork.getBikeLights());
        //System.println(mLightNetworkListener.data);
        //System.println(mLightNetwork.getNetworkMode());
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.drawText(
                10,
                10,
                Graphics.FONT_TINY,
                mijnList.toString(),
                Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
