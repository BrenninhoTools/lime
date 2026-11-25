package lime.system;

#if (lime_cffi && !macro)
import lime._internal.backend.native.NativeCFFI;
#end

#if (lime_cffi && !macro)
@:access(lime._internal.backend.native.NativeCFFI)
#end
class Hardware
{
	public static var cpuCount(get, never):Int;
	public static var cpuCacheLineSize(get, never):Int;
	public static var systemRAM(get, never):Int;
	public static var simd(get, never):SIMDFlags;
	public static var simdAlignment(get, never):Int;
	public static var processMemory(get, never):Float;
	public static var peakProcessMemory(get, never):Float;
	public static var availableMemory(get, never):Float;

	static var simdCache:Null<Int> = null;

	public static inline function hasSIMD(flag:SIMDFlags):Bool
	{
		return simd.has(flag);
	}

	public static function getPreciseTimer():Float
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_precise_timer();
		#elseif js
		return js.Browser.window.performance.now() / 1000;
		#elseif sys
		return Sys.time();
		#else
		return haxe.Timer.stamp();
		#end
	}

	public static function getTicksNS():Float
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_ticks_ns();
		#else
		return getPreciseTimer() * 1000000000;
		#end
	}

	public static function setThreadPriority(priority:ThreadPriority):Bool
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_set_thread_priority(priority);
		#else
		return false;
		#end
	}

	public static function formatBytes(bytes:Float, decimals:Int = 2):String
	{
		var units:Array<String> = ["B", "KB", "MB", "GB", "TB"];
		var index:Int = 0;
		var value:Float = Math.max(0, bytes);
		while (value >= 1024 && index < units.length - 1)
		{
			value /= 1024;
			index++;
		}
		var factor:Float = Math.pow(10, decimals);
		return Std.string(Math.round(value * factor) / factor) + " " + units[index];
	}

	static function get_cpuCount():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_cpu_count();
		#elseif js
		var count:Null<Int> = untyped js.Browser.navigator.hardwareConcurrency;
		return count != null ? count : 1;
		#else
		return 1;
		#end
	}

	static function get_cpuCacheLineSize():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_cpu_cache_line_size();
		#else
		return 64;
		#end
	}

	static function get_systemRAM():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_system_ram();
		#elseif js
		var memory:Null<Float> = untyped js.Browser.navigator.deviceMemory;
		return memory != null ? Std.int(memory * 1024) : 0;
		#else
		return 0;
		#end
	}

	static function get_simd():SIMDFlags
	{
		#if (lime_cffi && !macro)
		if (simdCache == null) simdCache = NativeCFFI.lime_hardware_get_simd_flags();
		return simdCache;
		#else
		return NONE;
		#end
	}

	static function get_simdAlignment():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_simd_alignment();
		#else
		return 16;
		#end
	}

	static function get_processMemory():Float
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_process_memory();
		#elseif js
		var memory:Dynamic = untyped js.Browser.window.performance.memory;
		return memory != null ? memory.usedJSHeapSize : 0;
		#else
		return 0;
		#end
	}

	static function get_peakProcessMemory():Float
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_peak_process_memory();
		#else
		return processMemory;
		#end
	}

	static function get_availableMemory():Float
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_available_memory();
		#else
		return 0;
		#end
	}
}
