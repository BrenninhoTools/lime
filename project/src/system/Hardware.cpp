#include <system/Hardware.h>

#include <SDL3/SDL.h>

#if defined(_WIN32)
#ifndef PSAPI_VERSION
#define PSAPI_VERSION 2
#endif
#include <windows.h>
#include <psapi.h>
#elif defined(__APPLE__)
#include <mach/mach.h>
#include <sys/resource.h>
#include <unistd.h>
#else
#include <stdio.h>
#include <string.h>
#include <sys/resource.h>
#include <unistd.h>
#endif

namespace lime
{

	int Hardware::GetCPUCount()
	{
		return SDL_GetNumLogicalCPUCores();
	}

	int Hardware::GetCPUCacheLineSize()
	{
		return SDL_GetCPUCacheLineSize();
	}

	int Hardware::GetSystemRAM()
	{
		return SDL_GetSystemRAM();
	}

	int Hardware::GetSIMDFlags()
	{
		int flags = 0;

		if (SDL_HasMMX()) flags |= SIMD_MMX;
		if (SDL_HasSSE()) flags |= SIMD_SSE;
		if (SDL_HasSSE2()) flags |= SIMD_SSE2;
		if (SDL_HasSSE3()) flags |= SIMD_SSE3;
		if (SDL_HasSSE41()) flags |= SIMD_SSE41;
		if (SDL_HasSSE42()) flags |= SIMD_SSE42;
		if (SDL_HasAVX()) flags |= SIMD_AVX;
		if (SDL_HasAVX2()) flags |= SIMD_AVX2;
		if (SDL_HasAVX512F()) flags |= SIMD_AVX512F;
		if (SDL_HasAltiVec()) flags |= SIMD_ALTIVEC;
		if (SDL_HasARMSIMD()) flags |= SIMD_ARMSIMD;
		if (SDL_HasNEON()) flags |= SIMD_NEON;
		if (SDL_HasLSX()) flags |= SIMD_LSX;
		if (SDL_HasLASX()) flags |= SIMD_LASX;

		return flags;
	}

	int Hardware::GetSIMDAlignment()
	{
		return (int)SDL_GetSIMDAlignment();
	}

	double Hardware::GetProcessMemory()
	{
#if defined(_WIN32)
		PROCESS_MEMORY_COUNTERS counters;

		if (GetProcessMemoryInfo(GetCurrentProcess(), &counters, sizeof(counters)))
		{
			return (double)counters.WorkingSetSize;
		}

		return 0;
#elif defined(__APPLE__)
		mach_task_basic_info_data_t info;
		mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;

		if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS)
		{
			return (double)info.resident_size;
		}

		return 0;
#else
		FILE *file = fopen("/proc/self/statm", "r");

		if (!file)
		{
			return 0;
		}

		long pages = 0;
		long resident = 0;
		int read = fscanf(file, "%ld %ld", &pages, &resident);
		fclose(file);

		if (read != 2)
		{
			return 0;
		}

		return (double)resident * (double)sysconf(_SC_PAGESIZE);
#endif
	}

	double Hardware::GetPeakProcessMemory()
	{
#if defined(_WIN32)
		PROCESS_MEMORY_COUNTERS counters;

		if (GetProcessMemoryInfo(GetCurrentProcess(), &counters, sizeof(counters)))
		{
			return (double)counters.PeakWorkingSetSize;
		}

		return 0;
#elif defined(__APPLE__)
		mach_task_basic_info_data_t info;
		mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;

		if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS)
		{
			return (double)info.resident_size_max;
		}

		return 0;
#else
		struct rusage usage;

		if (getrusage(RUSAGE_SELF, &usage) == 0)
		{
			return (double)usage.ru_maxrss * 1024.0;
		}

		return 0;
#endif
	}

	double Hardware::GetAvailableMemory()
	{
#if defined(_WIN32)
		MEMORYSTATUSEX status;
		status.dwLength = sizeof(status);

		if (GlobalMemoryStatusEx(&status))
		{
			return (double)status.ullAvailPhys;
		}

		return 0;
#elif defined(__APPLE__)
		vm_statistics64_data_t stats;
		mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

		if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&stats, &count) == KERN_SUCCESS)
		{
			return ((double)stats.free_count + (double)stats.inactive_count) * (double)getpagesize();
		}

		return 0;
#else
		FILE *file = fopen("/proc/meminfo", "r");

		if (!file)
		{
			return 0;
		}

		char line[256];
		double available = 0;

		while (fgets(line, sizeof(line), file))
		{
			long value = 0;

			if (sscanf(line, "MemAvailable: %ld kB", &value) == 1)
			{
				available = (double)value * 1024.0;
				break;
			}
		}

		fclose(file);
		return available;
#endif
	}

	int Hardware::GetPowerState()
	{
		return (int)SDL_GetPowerInfo(NULL, NULL);
	}

	int Hardware::GetBatteryPercent()
	{
		int percent = -1;
		SDL_GetPowerInfo(NULL, &percent);
		return percent;
	}

	int Hardware::GetBatterySeconds()
	{
		int seconds = -1;
		SDL_GetPowerInfo(&seconds, NULL);
		return seconds;
	}

	double Hardware::GetPreciseTimer()
	{
		static Uint64 frequency = 0;

		if (frequency == 0)
		{
			frequency = SDL_GetPerformanceFrequency();
		}

		Uint64 counter = SDL_GetPerformanceCounter();
		Uint64 seconds = counter / frequency;
		Uint64 remainder = counter % frequency;

		return (double)seconds + (double)remainder / (double)frequency;
	}

	double Hardware::GetTicksNS()
	{
		return (double)SDL_GetTicksNS();
	}

	bool Hardware::SetThreadPriority(int priority)
	{
		if (priority < SDL_THREAD_PRIORITY_LOW)
		{
			priority = SDL_THREAD_PRIORITY_LOW;
		}
		else if (priority > SDL_THREAD_PRIORITY_TIME_CRITICAL)
		{
			priority = SDL_THREAD_PRIORITY_TIME_CRITICAL;
		}

		return SDL_SetCurrentThreadPriority((SDL_ThreadPriority)priority);
	}

}
