/******************************************************************************
 * Filename: pi.c
 * Coder: Tuan Pham
 * Test POSIX thread conditional variables.
 *
 * This program is a crude implementation of the Gauss-Legendre Algorithm
 * to compute Pi.
 * a_0 = 1    b_0 = 1/sqrt(2)    t_0 = 1/4  p_0 = 1
 *
 * a_n1 = (a_n+b_n)/2  b_n1 = sqrt(a_n*b_n)  t_n1 = t_n -p_n(a_n - a_n1)^2
 * p_n1 = 2p_n
 *
 * Pi ~ {(a_n+b_n)^2} / 4t_n
 * 
 * We use four different threads to compute a_n, b_n, t_n, p_n
 * and the main thread to compute the current Pi
 * 
 * pthread_cond_init()
 * pthread_cond_wait()
 * pthread_cond_signal()
 * pthread_cond_broadcast()
 * 
 * pthread_barrier and pthread_barrier_init are implemented
 * using conditional variables instead of using libpthread's calls.
 * 
 * gcc -o pi pi.c -lpthread -lm
 */
#include <errno.h>
#include <limits.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define NAP() usleep(rand()%5000+100000)
#define LOCK(x) pthread_mutex_lock(&x)
#define UNLOCK(x) pthread_mutex_unlock(&x)

#define PTHREAD_BARRIER_SERIAL_THREAD -1
struct m_barrier_t
{
  pthread_mutex_t  mutex;
  pthread_cond_t  convar;
  unsigned int  counter;
  unsigned int  threshold;
};

/* global variables */
long double a_n = 1.0;
long double a_n1 = 1.0;

long double b_n =  0.707106781186547;  /* 1/sqrt(2) */
long double b_n1 = 0.707106781186547;

long double t_n = 0.25;
long double t_n1 = 0.25;

long double p_n = 1;
long double p_n1 = 1;

long double PI_n = 0;

int  n_loops = 7;

struct m_barrier_t g0_barrier;
struct m_barrier_t g1_barrier;
pthread_mutex_t  a_n1_mutex = PTHREAD_MUTEX_INITIALIZER;
int  a_n1_flag = 0;

/* --- mutexes --- */

int t_barrier_init(struct m_barrier_t* barrier, unsigned int count);
int t_barrier_wait(struct m_barrier_t* barrier);


void* thr_an(void* arg);
void* thr_bn(void* arg);
void* thr_tn(void* arg);
void* thr_pn(void* arg);

void init();

int main(int argc, char** argv)
{
  pthread_t  an_tid, bn_tid, tn_tid, pn_tid;
  int    i;
  long double  Pi;

  n_loops = atoi(argv[1]); /* number of iteration to run */

  init();

  pthread_create(&an_tid, NULL, thr_an, NULL);
  pthread_create(&bn_tid, NULL, thr_bn, NULL);
  pthread_create(&tn_tid, NULL, thr_tn, NULL);
  pthread_create(&pn_tid, NULL, thr_pn, NULL);


  /* run for a few thousand loops */
  for (i=0; i<n_loops; i++)
  {
    NAP(); /* simulate some work */
    t_barrier_wait(&g0_barrier);

    /* print current Pi */
    Pi = (a_n*a_n + 2*a_n*b_n + b_n*b_n)/(4*t_n);
    printf("Pi = %.64Lf\n", Pi);

    NAP(); /* simulate some work */
    t_barrier_wait(&g1_barrier);
  }

  pthread_join(an_tid, NULL);
  pthread_join(bn_tid, NULL);
  pthread_join(tn_tid, NULL);
  pthread_join(pn_tid, NULL);

  return 0;
}

int
t_barrier_init(struct m_barrier_t* barrier, unsigned int count)
{
  if (0 == count)
    return EINVAL;

  barrier->counter = count;
  barrier->threshold = count;
  pthread_mutex_init(&barrier->mutex, NULL);
  pthread_cond_init(&barrier->convar, NULL);

  return 0;
}


void*
thr_an(void* arg)
{
  int i;

  printf("thread thr_an started\n");
  for (i=0; i < n_loops; i++)
  {
    NAP(); /* simulate some work */
    LOCK(a_n1_mutex);
    t_barrier_wait(&g0_barrier);
    a_n1 = a_n/2 + b_n/2;
    UNLOCK(a_n1_mutex);
    NAP();
    t_barrier_wait(&g1_barrier);

    /* update a_n  here */
    a_n = a_n1;
  }

  pthread_exit(NULL);
}

void* thr_bn(void* arg)
{
  int i;

  printf("thread thr_bn started\n");
  for (i = 0; i < n_loops; i++)
  {
    NAP(); /* simulate some work */
    t_barrier_wait(&g0_barrier);
    b_n1 = sqrtl(a_n) * sqrtl(b_n);
    NAP();
    t_barrier_wait(&g1_barrier);
    b_n = b_n1;
  }
  pthread_exit(NULL);

}

void* thr_tn(void* arg)
{
  int i;
  long double ts0, ts1;

  printf("thread thr_tn started\n");
  for (i = 0; i < n_loops; i++)
  {
    NAP(); /* simulate some work */
    t_barrier_wait(&g0_barrier);
    ts0 = t_n - p_n*a_n*a_n;

    /* let thread thr_an finish computing a_n1 */
    LOCK(a_n1_mutex);
    UNLOCK(a_n1_mutex);
    /* now we can compute using new a_n1 */
    ts1 = 2*p_n*a_n*a_n1 - p_n*a_n1*a_n1;
    t_n1 = ts0 + ts1;
    NAP();
    t_barrier_wait(&g1_barrier);

    t_n = t_n1;
  }
  pthread_exit(NULL);

}

void* thr_pn(void* arg)
{
  int i;

  printf("thread thr_pn started\n");
  for (i=0; i<n_loops; i++)
  {
    NAP(); /* simulate some work */
    t_barrier_wait(&g0_barrier);
    p_n1 = 2*p_n;
    NAP();
    t_barrier_wait(&g1_barrier);
    p_n = p_n1;
  }

  pthread_exit(NULL);
}

/* This barrier will reset the counter if it is the last thread */

int
t_barrier_wait(struct m_barrier_t* barrier)
{
  int result = 0;

  if (NULL == barrier)
    return EINVAL;

  if (0 != pthread_mutex_lock(&barrier->mutex))
    return EINVAL;

  barrier->counter--;
  if (0 != barrier->counter) {
    pthread_cond_wait(&barrier->convar, &barrier->mutex);
  }
  else /* last thread that reaches barrier */
  {
    barrier->counter = barrier->threshold;
    result = PTHREAD_BARRIER_SERIAL_THREAD;
    pthread_cond_broadcast(&barrier->convar);
  }
  pthread_mutex_unlock(&barrier->mutex);

  return result;
}

void
init(void)
{
  printf("long double size = %d bytes\n", (int) sizeof(long double));
  srandom(11235);

  if (0 != t_barrier_init(&g0_barrier, 5))
  {
    printf("t_barrier_init() fails on g0_barrier\n");
    exit(1);
  }

  if (0 != t_barrier_init(&g1_barrier, 5))
  {
    printf("t_barrier_init() fails on g1_barrier\n");
    exit(1);
  }
}
