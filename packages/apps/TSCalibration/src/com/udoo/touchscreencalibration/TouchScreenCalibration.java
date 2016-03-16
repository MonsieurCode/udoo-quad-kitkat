package com.udoo.touchscreencalibration;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.DataOutputStream;
import java.io.DataInputStream;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.SystemProperties;
import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.Display;
import android.view.MotionEvent;
import android.util.DisplayMetrics;
import android.widget.Toast;

public class TouchScreenCalibration extends Activity {
	
	private int ScreenWidth;
	private int ScreenHeight;
	private int CalibPointStep;
	private final int CalibOffset = 100;
	private CalibrationView CalibView;
	private PointF[] CalibPointList = new PointF[5];
	private PointF[] ScreenPointList = new PointF[5];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

	if(CheckTouchScreen() == false) {
	    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
	    alertDialog.setTitle("Warning!");
	    alertDialog.setMessage("No compatible touchscreen found");
	    alertDialog.setButton(alertDialog.BUTTON_NEUTRAL, "OK", new DialogInterface.OnClickListener() {
		public void onClick(DialogInterface dialog, int id) {
			close();
		}
	    });
	    alertDialog.show();
	    return;
	}

        for(int i = 0; i < CalibPointList.length; i++) {
        	CalibPointList[i] = new PointF();
		ScreenPointList[i] = new PointF();
        }

	CalibPointStep = 0;

	Display display = getWindowManager().getDefaultDisplay();
	Point size = new Point();
	display.getRealSize(size);
	ScreenWidth = size.x;
	ScreenHeight = size.y;
	Log.d("TSCalibration", "Screen size width:"+ScreenWidth+" height:"+ScreenHeight);

	resetCalibrationCoord();

        CalibView = new CalibrationView(this);
        setContentView(CalibView);
    }
    
    @Override public boolean onTouchEvent(MotionEvent event) {
        final int eventAction = event.getAction();

        if(eventAction == MotionEvent.ACTION_UP){
        	
		CalibPointList[CalibPointStep].x = ((event.getRawX() / (float)ScreenWidth) * (float)65536);
		CalibPointList[CalibPointStep].y = ((event.getRawY() / (float)ScreenHeight) * (float)65536);
		Log.d("TSCalibration", "Calibration point "+CalibPointStep+" x:"+CalibPointList[CalibPointStep].x+" y:"+CalibPointList[CalibPointStep].y);
		CalibPointStep++;
		CalibView.invalidate();
        	if(CalibPointStep > 4) {
        		saveCalibrationCoord();
        	}
        }
        
        return true;
    }

      static public boolean CheckTouchScreen() {

	try{
	    File TouchTypeParam = new File("/sys/module/usbtouchscreen/parameters/touchscreen_type");

	    if(TouchTypeParam.exists()) {
		InputStream TouchTypeFile = new FileInputStream(TouchTypeParam);
		byte[] TouchTypeBuffer = new byte[1];
		int TouchID;
  
		TouchTypeFile.read(TouchTypeBuffer);
		TouchTypeFile.close();

		TouchID = (TouchTypeBuffer[0] - 48);
		Log.d("TSCalibration", "Touch id: "+TouchID);

		switch(TouchID) {
		    case 1:
			Log.d("TSCalibration", "Found 3M touchscreen");
			break;
		    default:
			return false;
		}

		return true;
	    }       
	}
	catch(Exception e) {
	    Log.e("TSCalibration", "Check touchscreen EXCEPTION: "+e.toString());
	}

	return false;
    }

    static public boolean CheckCalibrationFile() {
	try{
	    File TouchCoordFile = new File("/data/data/com.udoo.touchscreencalibration/files/pointercal");
	    return TouchCoordFile.exists();
	}
	catch(Exception e) {
	    Log.e("TSCalibration", "Check calibration file EXCEPTION: "+e.toString());
	}

	return false;
    }
    
    private void close() {
    	super.finish();
    }

    private void resetCalibrationCoord() {
	writeCalibrationCoordFile("0,0,0,0,0,0,0,0,0");
    }

    private boolean writeCalibrationCoordFile(String data)
    {
	try {
	    FileOutputStream CoordFile = openFileOutput("pointercal", Context.MODE_PRIVATE);
	    CoordFile.write(data.getBytes());
	    CoordFile.flush();
	    CoordFile.getFD().sync();
	    CoordFile.close();

	    OutputStream TouchDrvDev = new FileOutputStream("/sys/module/usbtouchscreen/parameters/calibration");
	    TouchDrvDev.write(data.getBytes());
	    TouchDrvDev.close();

	    return true;
	}
	catch (IOException e) {
	    Log.e("TSCalibration", "IOException: "+e.toString());
	}
	catch (SecurityException e) {
	    Log.e("TSCalibration", "SecurityException: "+e.toString());
	}

	return false;
    }
        
    private void saveCalibrationCoord() {
    	int[] CalibDataList = new int[7];
	String rawValues = new String();
    	    	
    	ElaborateCalibrationCoord(CalibDataList);
    	 	
	rawValues = Integer.toString(CalibDataList[1])+",";
	rawValues += Integer.toString(CalibDataList[2])+",";
	rawValues += Integer.toString(CalibDataList[0])+",";
	rawValues += Integer.toString(CalibDataList[4])+",";
	rawValues += Integer.toString(CalibDataList[5])+",";
	rawValues += Integer.toString(CalibDataList[3])+",";
	rawValues += Integer.toString(CalibDataList[6])+",";
	rawValues += Integer.toString(ScreenWidth)+","+Integer.toString(ScreenHeight);
    
	if(writeCalibrationCoordFile(rawValues)) {

	    Log.d("TSCalibration", "pointercal <- "+rawValues);

	    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
	    alertDialog.setTitle("Finish");
	    alertDialog.setMessage("Calibration points saved!");
	    alertDialog.setButton(alertDialog.BUTTON_NEUTRAL, "OK", new DialogInterface.OnClickListener() {
		public void onClick(DialogInterface dialog, int id) {
			close();
		}
	    });
	    alertDialog.show();
	} else {
	    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
	    alertDialog.setTitle("Error!");
	    alertDialog.setMessage("Unable to set calibration point");
	    alertDialog.setButton(alertDialog.BUTTON_NEUTRAL, "OK", new DialogInterface.OnClickListener() {
		public void onClick(DialogInterface dialog, int id) {
			close();
		}
	    });
	    alertDialog.show();
	}
    }
    
    private void ElaborateCalibrationCoord(int[] CalibDataList) {
    	double n, x, y, x2, y2, xy, z, zx, zy;
    	double det, a, b, c, e, f, i;
    	double scaling = 65536.0;
    	int j;

	Log.d("TSCalibration", "Screen Points: x:"+ScreenPointList[0].x+",y:"+ScreenPointList[0].y+" x:"+ScreenPointList[1].x+",y:"+ScreenPointList[1].y+" x:"+ScreenPointList[2].x+",y:"+ScreenPointList[2].y+" x:"+ScreenPointList[3].x+",y:"+ScreenPointList[3].y+" x:"+ScreenPointList[4].x+",y:"+ScreenPointList[4].y);
	Log.d("TSCalibration", "Calibration Points: x:"+CalibPointList[0].x+",y:"+CalibPointList[0].y+" x:"+CalibPointList[1].x+",y:"+CalibPointList[1].y+" x:"+CalibPointList[2].x+",y:"+CalibPointList[2].y+" x:"+CalibPointList[3].x+",y:"+CalibPointList[3].y+" x:"+CalibPointList[4].x+",y:"+CalibPointList[4].y);
    	
    	n = x = y = x2 = y2 = xy = 0;
    	for(j=0;j<5;j++) {
    		n += 1.0;
    		x += (double) CalibPointList[j].x;
    		y += (double) CalibPointList[j].y;
    		x2 += (double) ( (double)CalibPointList[j].x * (double)CalibPointList[j].x );
    		y2 += (double) ( (double)CalibPointList[j].y * (double)CalibPointList[j].y );
    		xy += (double) ( (double)CalibPointList[j].x * (double)CalibPointList[j].y );
    	}
    	
    	det = n*(x2*y2 - xy*xy) + x*(xy*y - x*y2) + y*(x*xy - y*x2);
    	
    	a = (x2*y2 - xy*xy)/det;
    	b = (xy*y - x*y2)/det;
    	c = (x*xy - y*x2)/det;
    	e = (n*y2 - y*y)/det;
    	f = (x*y - n*xy)/det;
    	i = (n*x2 - x*x)/det;
    	
    	z = zx = zy = 0;
    	for(j=0;j<5;j++) {
    		z += (double)ScreenPointList[j].x;
    		zx += (double)(ScreenPointList[j].x*CalibPointList[j].x);
    		zy += (double)(ScreenPointList[j].x*CalibPointList[j].y);
    	}
    	
    	CalibDataList[0] = (int)((a*z + b*zx + c*zy)*(scaling));
    	CalibDataList[1] = (int)((b*z + e*zx + f*zy)*(scaling));
    	CalibDataList[2] = (int)((c*z + f*zx + i*zy)*(scaling));
    	
    	z = zx = zy = 0;
    	for(j=0;j<5;j++) {
    		z += (double)ScreenPointList[j].y;
    		zx += (double)(ScreenPointList[j].y*CalibPointList[j].x);
    		zy += (double)(ScreenPointList[j].y*CalibPointList[j].y);
    	}
    	
    	CalibDataList[3] = (int)((a*z + b*zx + c*zy)*(scaling));
    	CalibDataList[4] = (int)((b*z + e*zx + f*zy)*(scaling));
    	CalibDataList[5] = (int)((c*z + f*zx + i*zy)*(scaling));
    	
    	CalibDataList[6] = (int)scaling;

	Log.d("TSCalibration", "Converted: "+CalibDataList[0]+" "+CalibDataList[1]+" "+CalibDataList[2]+" "+CalibDataList[3]+" "+CalibDataList[4]+" "+CalibDataList[5]+" "+CalibDataList[6]);
    }
    
    private class CalibrationView extends View {
    	
        private Paint mPaint = new Paint();
        
        public CalibrationView(Context context) {
            super(context);
	    setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
            | View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
            );
            Toast.makeText(context, "Press the point on the screen for calibrate", Toast.LENGTH_LONG).show();
        }
                
        @Override protected void onDraw(Canvas canvas) {
	    PointF p = new PointF();
            Paint paint = mPaint;

	    switch(CalibPointStep) {
		case 0:
		    p.x = CalibOffset;
		    p.y = CalibOffset;
		    break;
		case 1:
		    p.x = ScreenWidth - CalibOffset;
		    p.y = CalibOffset;
		    break;
		case 2:
		    p.x = ScreenWidth - CalibOffset;
		    p.y = ScreenHeight - CalibOffset;
		    break;
		case 3:
		    p.x = CalibOffset;
		    p.y = ScreenHeight - CalibOffset;
		    break;
		case 4:
		    p.x = ScreenWidth / 2;
		    p.y = ScreenHeight / 2;
		    break;
		default:
		    return;
	    }

	    ScreenPointList[CalibPointStep] = p;
                        
            canvas.translate(0, 0);
            canvas.drawColor(Color.BLACK);

            paint.setColor(Color.WHITE);
            paint.setStrokeWidth(25);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.RED);
            paint.setStrokeWidth(21);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.WHITE);
            paint.setStrokeWidth(17);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.RED);
            paint.setStrokeWidth(13);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.WHITE);
            paint.setStrokeWidth(9);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.RED);
            paint.setStrokeWidth(5);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setColor(Color.WHITE);
            paint.setStrokeWidth(1);
            canvas.drawCircle(p.x, p.y, paint.getStrokeWidth(), paint);

            paint.setStrokeWidth(2);
            canvas.drawLine(p.x + 28, p.y, p.x - 28, p.y, paint);
            canvas.drawLine(p.x, p.y + 28, p.x, p.y - 28, paint);
        }
    }
}
