/******************************************************************************
 * File Name: threads.c
 * Author:    Tuan T. Pham <tuan@vt.edu>
 * 
 * Description: Simple program to demonstrate a few thread functions
 * 
 * sleep() (this is per-thread)
 * pthread_create()
 * pthread_exit()
 * pthread_mutex_lock()
 * pthread_mutex_unlock()
 * pthread_self()
 * pthread_join()
 * get_pid()
 * 
 */

/*   - Spawn off n worker threads.
 *    - Each thread will acquire the mutex and compute the next Fibonacci
 *    sequence and stop if it is greater than 0x7000000000000000
 *    - Main thread will join all threads.
 *
 * Note: at terminal, use this to find which thread implementation you have
 * $ getconf GNU_LIBPTHREAD_VERSION
 *
 * th_worker prints the result to stderr
 * => run ./threads 2> out.log for a clean screen
 */

#include <pthread.h>
#include <signal.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#define THREAD_MAX  1024
#define BUFSIZE    256
#define SLEEP_TIME  500

pthread_t  thread_array[THREAD_MAX];
int    th_counter = 0;
int    no_threads;

static unsigned long  a = 1, b = 1;

static pthread_t        main_tid;
static pthread_mutex_t  mutex = PTHREAD_MUTEX_INITIALIZER;

static void*
th_worker(void *arg);

int main(int argc, char **argv)
{
  pid_t    pid;
  int    i, ret;
  pthread_t  tid;

  pid = getpid();
  printf("my process id = %d\n", pid);
  main_tid = tid = pthread_self();
  printf("main thread id = %lu\n", tid);

  no_threads = atoi(argv[1]);

  for (i = 0; i < no_threads; i++)
  {

    if (0 != pthread_create(&thread_array[i], NULL, th_worker, NULL))
    {
      perror("Cannot spawn a thread");
      exit(1);
    }

    printf("spawned a thread with tid %lu\n", thread_array[i]);
  }

  for (i = 0; i < no_threads; i++)
  {
    ret = pthread_join(thread_array[i], NULL);
    printf("joined thread %lu ret=%d\n", thread_array[i], ret);
  }


  ret = pthread_join(pthread_self(), NULL);
  printf("joined main_thread ret=%d\n", ret);

  printf("main thread is exiting...\n");

  return 0;
}

static void* th_worker(void *arg)
{
  pthread_t tid;
  pid_t     pid;
  int       counter = 0;

  tid = pthread_self();
  pid = getpid();
  printf("proc %d : thread %lu is spawned\n", pid, tid);
  printf("address of pid is %p\n", &pid);
  while (counter++ < 50)
  {
    sleep(1);
    /* compute the fib sequence */
    /* acquire lock */
    pthread_mutex_lock(&mutex);
    printf("b = %lu %lu\n", b, tid);
    if (0x7000000000000000 < b)
    {
      /* release lock */
      pthread_mutex_unlock(&mutex);
      return (void*) NULL;
    }
    b = a + b;
    a = b - a;      /* a = b */
    /* release lock */
    pthread_mutex_unlock(&mutex);
  }

  fflush(stdout);
  pthread_exit(NULL);
}
