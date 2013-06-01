/* A simple way to log your debug message to STDOUT/STDERR
 * No warranty that it will work or fix the problem(s) for you.
 * Author: Tuan T. Pham < tuan at vt dot edu >
 */
#ifndef __LOG_H__
#define __LOG_H__

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <pthread.h>
#define __TID__ pthread_self()
#define __PID__  getpid()

#ifndef LOG_OUTPUT
#define LOG_OUTPUT stderr
#endif

// Define/undef this to turn on/off the message
#ifdef OUTPUT_ENABLED
#define LOG(format, args...) {\
	fprintf(LOG_OUTPUT, "%s:%d %llu:%llx ", __FILE__, __LINE__,\
	__PID__, __TID__);\
	fprintf(LOG_OUTPUT, format, ##args);\
	fprintf(LOG_OUTPUT, "\n");\
}

#define LOG_ENTER() {\
	DLOG("Entering %s", __func__);\
}

#define LOG_EXIT() {\
	DLOG("Exiting %s", __func__);\
}

#else	// OUTPUT_ENABLED
#define LOG(format, args...) {}
#define LOG_ENTER() {}
#define LOG_EXIT() {}
#endif // OUTPUT_ENABLED

#endif // __LOG_H
