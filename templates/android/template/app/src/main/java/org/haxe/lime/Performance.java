package org.haxe.lime;


import android.app.Activity;
import android.app.GameManager;
import android.content.Context;
import android.os.Build;
import android.os.PowerManager;
import android.util.Log;
import android.view.Display;
import android.view.Window;
import android.view.WindowManager;

import java.util.ArrayList;
import java.util.List;


public class Performance {


	private static final String TAG = "LimePerformance";

	private static float preferredRefreshRate = 0;
	private static boolean sustainedPerformance = false;


	public static void apply (Activity activity, boolean highRefreshRate, boolean sustained) {

		sustainedPerformance = sustained;

		if (highRefreshRate && preferredRefreshRate <= 0) {

			preferredRefreshRate = Float.MAX_VALUE;

		}

		applyRefreshRate (activity);
		applySustainedPerformance (activity);

	}


	public static void reapply (Activity activity) {

		applyRefreshRate (activity);
		applySustainedPerformance (activity);

	}


	public static float getRefreshRate () {

		Display display = getDisplay (GameActivity.instance);
		return display != null ? display.getRefreshRate () : 60;

	}


	public static String getSupportedRefreshRates () {

		Display display = getDisplay (GameActivity.instance);
		if (display == null) return "";

		Display.Mode current = display.getMode ();
		List<Float> rates = new ArrayList<Float> ();

		for (Display.Mode mode : display.getSupportedModes ()) {

			if (current != null && (mode.getPhysicalWidth () != current.getPhysicalWidth () || mode.getPhysicalHeight () != current.getPhysicalHeight ())) continue;

			float rate = Math.round (mode.getRefreshRate () * 100) / 100f;
			if (!rates.contains (rate)) rates.add (rate);

		}

		StringBuilder builder = new StringBuilder ();

		for (int i = 0; i < rates.size (); i++) {

			if (i > 0) builder.append (',');
			builder.append (rates.get (i));

		}

		return builder.toString ();

	}


	public static void setPreferredRefreshRate (final float rate) {

		preferredRefreshRate = rate;
		runOnUi (new Runnable () {

			@Override public void run () {

				applyRefreshRate (GameActivity.instance);

			}

		});

	}


	public static float getPreferredRefreshRate () {

		return preferredRefreshRate;

	}


	public static void setSustainedPerformanceMode (final boolean enabled) {

		sustainedPerformance = enabled;
		runOnUi (new Runnable () {

			@Override public void run () {

				applySustainedPerformance (GameActivity.instance);

			}

		});

	}


	public static boolean isSustainedPerformanceSupported () {

		Context context = GameActivity.instance;
		if (context == null) return false;

		PowerManager power = (PowerManager)context.getSystemService (Context.POWER_SERVICE);
		return power != null && power.isSustainedPerformanceModeSupported ();

	}


	public static boolean isSustainedPerformanceMode () {

		return sustainedPerformance;

	}


	public static boolean isPowerSaveMode () {

		Context context = GameActivity.instance;
		if (context == null) return false;

		PowerManager power = (PowerManager)context.getSystemService (Context.POWER_SERVICE);
		return power != null && power.isPowerSaveMode ();

	}


	public static int getThermalStatus () {

		Context context = GameActivity.instance;
		if (context == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return -1;

		PowerManager power = (PowerManager)context.getSystemService (Context.POWER_SERVICE);
		return power != null ? power.getCurrentThermalStatus () : -1;

	}


	public static float getThermalHeadroom (int forecastSeconds) {

		Context context = GameActivity.instance;
		if (context == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return -1;

		PowerManager power = (PowerManager)context.getSystemService (Context.POWER_SERVICE);
		if (power == null) return -1;

		float headroom = power.getThermalHeadroom (Math.max (0, Math.min (60, forecastSeconds)));
		return Float.isNaN (headroom) ? -1 : headroom;

	}


	public static int getGameMode () {

		Context context = GameActivity.instance;
		if (context == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return 0;

		GameManager manager = (GameManager)context.getSystemService (Context.GAME_SERVICE);
		return manager != null ? manager.getGameMode () : 0;

	}


	private static void applyRefreshRate (Activity activity) {

		if (activity == null || preferredRefreshRate <= 0) return;

		Display display = getDisplay (activity);
		Window window = activity.getWindow ();
		if (display == null || window == null) return;

		Display.Mode current = display.getMode ();
		Display.Mode best = null;

		for (Display.Mode mode : display.getSupportedModes ()) {

			if (current != null && (mode.getPhysicalWidth () != current.getPhysicalWidth () || mode.getPhysicalHeight () != current.getPhysicalHeight ())) continue;

			if (best == null) {

				best = mode;
				continue;

			}

			float rate = mode.getRefreshRate ();
			float bestRate = best.getRefreshRate ();
			boolean fits = rate <= preferredRefreshRate + 0.5f;
			boolean bestFits = bestRate <= preferredRefreshRate + 0.5f;

			if ((fits && !bestFits) || (fits == bestFits && (fits ? rate > bestRate : rate < bestRate))) {

				best = mode;

			}

		}

		if (best == null) return;

		WindowManager.LayoutParams params = window.getAttributes ();

		if (params.preferredDisplayModeId != best.getModeId ()) {

			params.preferredDisplayModeId = best.getModeId ();
			window.setAttributes (params);
			Log.i (TAG, "Preferred display mode " + best.getModeId () + " at " + best.getRefreshRate () + "Hz");

		}

	}


	private static void applySustainedPerformance (Activity activity) {

		if (activity == null || activity.getWindow () == null) return;

		try {

			activity.getWindow ().setSustainedPerformanceMode (sustainedPerformance);

		} catch (Throwable error) {

			Log.w (TAG, "Sustained performance mode unavailable: " + error.getMessage ());

		}

	}


	@SuppressWarnings("deprecation")
	private static Display getDisplay (Activity activity) {

		if (activity == null) return null;

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {

			return activity.getDisplay ();

		}

		return activity.getWindowManager ().getDefaultDisplay ();

	}


	private static void runOnUi (Runnable action) {

		Activity activity = GameActivity.instance;
		if (activity != null) activity.runOnUiThread (action);

	}


}
