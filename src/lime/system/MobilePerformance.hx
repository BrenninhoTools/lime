package lime.system;

#if (android && !macro)
import lime.system.JNI;
#end

enum abstract GameMode(Int) from Int to Int
{
	var UNSUPPORTED = 0;
	var STANDARD = 1;
	var PERFORMANCE = 2;
	var BATTERY = 3;
	var CUSTOM = 4;
}

enum abstract ThermalStatus(Int) from Int to Int
{
	var UNKNOWN = -1;
	var NONE = 0;
	var LIGHT = 1;
	var MODERATE = 2;
	var SEVERE = 3;
	var CRITICAL = 4;
	var EMERGENCY = 5;
	var SHUTDOWN = 6;
}

#if (ios && lime_cffi && !macro)
@:access(lime._internal.backend.native.NativeCFFI)
#end
class MobilePerformance
{
	public static var supported(get, never):Bool;
	public static var refreshRate(get, never):Float;
	public static var supportedRefreshRates(get, never):Array<Float>;
	public static var preferredRefreshRate(get, set):Float;
	public static var sustainedPerformanceSupported(get, never):Bool;
	public static var sustainedPerformance(get, set):Bool;
	public static var powerSaveMode(get, never):Bool;
	public static var thermalStatus(get, never):ThermalStatus;
	public static var gameMode(get, never):GameMode;

	#if (android && !macro)
	static inline final CLASS:String = "org/haxe/lime/Performance";
	static var methods:Map<String, Dynamic> = new Map();
	#end

	public static function thermalHeadroom(forecastSeconds:Int = 0):Float
	{
		#if (android && !macro)
		var value:Dynamic = call("getThermalHeadroom", "(I)F", [forecastSeconds]);
		return value == null ? -1 : value;
		#else
		return -1;
		#end
	}

	public static function matchRefreshRate(framerate:Float):Float
	{
		var rates:Array<Float> = supportedRefreshRates;
		if (rates.length == 0) return refreshRate;
		var best:Float = rates[0];
		for (rate in rates)
		{
			var fits:Bool = rate + 0.5 >= framerate;
			var bestFits:Bool = best + 0.5 >= framerate;
			if ((fits && !bestFits) || (fits == bestFits && (fits ? rate < best : rate > best))) best = rate;
		}
		preferredRefreshRate = best;
		return best;
	}

	#if (android && !macro)
	static function call(name:String, signature:String, ?args:Array<Dynamic>):Dynamic
	{
		try
		{
			var key:String = name + signature;
			var method:Dynamic = methods.get(key);
			if (method == null)
			{
				method = JNI.createStaticMethod(CLASS, name, signature);
				methods.set(key, method);
			}
			return method == null ? null : Reflect.callMethod(null, method, args == null ? [] : args);
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}
	#end

	static function get_supported():Bool
	{
		#if ((android || ios) && !macro)
		return true;
		#else
		return false;
		#end
	}

	static function get_refreshRate():Float
	{
		#if (android && !macro)
		var value:Dynamic = call("getRefreshRate", "()F");
		if (value != null) return value;
		#end
		var display:Display = System.getDisplay(0);
		return display != null && display.currentMode != null && display.currentMode.refreshRate > 0 ? display.currentMode.refreshRate : 60;
	}

	static function get_supportedRefreshRates():Array<Float>
	{
		#if (android && !macro)
		var raw:Dynamic = call("getSupportedRefreshRates", "()Ljava/lang/String;");
		if (raw != null && Std.string(raw).length > 0)
		{
			var rates:Array<Float> = [];
			for (part in Std.string(raw).split(","))
			{
				var rate:Float = Std.parseFloat(part);
				if (!Math.isNaN(rate) && rates.indexOf(rate) < 0) rates.push(rate);
			}
			rates.sort(function(a, b) return a < b ? -1 : (a > b ? 1 : 0));
			return rates;
		}
		#end
		var rates:Array<Float> = [];
		var display:Display = System.getDisplay(0);
		if (display != null && display.supportedModes != null)
			for (mode in display.supportedModes)
				if (mode.refreshRate > 0 && rates.indexOf(mode.refreshRate) < 0) rates.push(mode.refreshRate);
		rates.sort(function(a, b) return a < b ? -1 : (a > b ? 1 : 0));
		return rates;
	}

	static function get_preferredRefreshRate():Float
	{
		#if (android && !macro)
		var value:Dynamic = call("getPreferredRefreshRate", "()F");
		return value == null ? 0 : value;
		#else
		return 0;
		#end
	}

	static function set_preferredRefreshRate(value:Float):Float
	{
		#if (android && !macro)
		call("setPreferredRefreshRate", "(F)V", [value]);
		#end
		return value;
	}

	static function get_sustainedPerformanceSupported():Bool
	{
		#if (android && !macro)
		return call("isSustainedPerformanceSupported", "()Z") == true;
		#else
		return false;
		#end
	}

	static function get_sustainedPerformance():Bool
	{
		#if (android && !macro)
		return call("isSustainedPerformanceMode", "()Z") == true;
		#else
		return false;
		#end
	}

	static function set_sustainedPerformance(value:Bool):Bool
	{
		#if (android && !macro)
		call("setSustainedPerformanceMode", "(Z)V", [value]);
		#end
		return value;
	}

	static function get_powerSaveMode():Bool
	{
		#if (android && !macro)
		return call("isPowerSaveMode", "()Z") == true;
		#elseif (ios && lime_cffi && !macro)
		return lime._internal.backend.native.NativeCFFI.lime_system_get_low_power_mode();
		#else
		return false;
		#end
	}

	static function get_thermalStatus():ThermalStatus
	{
		#if (android && !macro)
		var value:Dynamic = call("getThermalStatus", "()I");
		return value == null ? UNKNOWN : value;
		#elseif (ios && lime_cffi && !macro)
		return lime._internal.backend.native.NativeCFFI.lime_system_get_thermal_state();
		#else
		return UNKNOWN;
		#end
	}

	static function get_gameMode():GameMode
	{
		#if (android && !macro)
		var value:Dynamic = call("getGameMode", "()I");
		return value == null ? UNSUPPORTED : value;
		#else
		return UNSUPPORTED;
		#end
	}
}
