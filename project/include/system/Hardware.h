#ifndef LIME_SYSTEM_HARDWARE_H
#define LIME_SYSTEM_HARDWARE_H

namespace lime
{

	enum HardwareSIMD
	{
		SIMD_MMX = 1 << 0,
		SIMD_SSE = 1 << 1,
		SIMD_SSE2 = 1 << 2,
		SIMD_SSE3 = 1 << 3,
		SIMD_SSE41 = 1 << 4,
		SIMD_SSE42 = 1 << 5,
		SIMD_AVX = 1 << 6,
		SIMD_AVX2 = 1 << 7,
		SIMD_AVX512F = 1 << 8,
		SIMD_ALTIVEC = 1 << 9,
		SIMD_ARMSIMD = 1 << 10,
		SIMD_NEON = 1 << 11,
		SIMD_LSX = 1 << 12,
		SIMD_LASX = 1 << 13
	};

	class Hardware
	{
	public:
		static int GetCPUCount();
		static int GetCPUCacheLineSize();
		static int GetSystemRAM();
		static int GetSIMDFlags();
		static int GetSIMDAlignment();
		static double GetProcessMemory();
		static double GetPeakProcessMemory();
		static double GetAvailableMemory();
		static int GetPowerState();
		static int GetBatteryPercent();
		static int GetBatterySeconds();
		static double GetPreciseTimer();
		static double GetTicksNS();
		static bool SetThreadPriority(int priority);
	};

}

#endif
