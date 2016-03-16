package com.udoo.touchscreencalibration;

import java.io.FileReader;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import com.udoo.touchscreencalibration.TouchScreenCalibration;

// Added to allow for automatic startup
public class StartupIntentReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

	Log.d("TSCalibration", "Check touchscreen info");
        if(TouchScreenCalibration.CheckTouchScreen() == true) {
	    if(TouchScreenCalibration.CheckCalibrationFile() == false) {
		Log.d("TSCalibration", "No calibration file found, start calibration");
		Intent starterIntent = new Intent(context, TouchScreenCalibration.class);
		starterIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(starterIntent);
	    }
	}
    }
}
 
