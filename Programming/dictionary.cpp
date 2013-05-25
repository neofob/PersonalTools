/*
Filename: dictionary.cpp
Compile: g++ -O3 -o dictionary dictionary.cpp -lpthread

* search for existence of a word in the dictionary
* insert a word in the dictionary if it doesn't exist
* delete a word from the dictionary

./dictionary {-insert <word> | -search <word> | -delete <word>}

The first execution of dictionary will act as a master for now.

TODO: * modify the specs to handle how to terminate the program
so we can clean up the lock file and FIFO file.

author: tuan t. pham
last update: 01/07/11
*/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/inotify.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <pthread.h>
#include <limits.h>
#include <signal.h>

#include <map>
#include <string>
#include <iostream>

using namespace std;

#define LOCK(x) pthread_mutex_lock(&x)
#define UNLOCK(x) pthread_mutex_unlock(&x)

pthread_mutex_t mux0 = PTHREAD_MUTEX_INITIALIZER;

#define FILE_LOCK "dictionary.lock"
#define FILE_MODE O_WRONLY | O_CREAT | O_EXCL
#define FIFO_NAME "dictionary.fifo"
#define FIFO_MODE S_IWUSR | S_IRUSR | S_IRGRP | S_IROTH // 0644
#define FIFO_WMODE O_WRONLY
#define FIFO_RMODE O_RDONLY | O_NONBLOCK

#define BUF_LEN (sizeof (struct inotify_event) + 16)

bool checkFirstRun();

void processCmd(char** argv);
void sendCmd(char** argv);

void* sendCmdThr(void* arg);

void setSigHandler();   // setup SIGUSR1 and SIGINT handler
void sigHandler(int signo, siginfo_t *info, void* context);

int main(int argc, char** argv)
{
  // first run?
  if (checkFirstRun())
  {
    setSigHandler(); // set USR1 handler
    processCmd(argv);
  }
  else
  {
    sendCmd(argv);
  }
  return 0;
}

/* checkFirstRun()
* check whether we are the first execution by checking if the FILE_LOCK exists
* -------------------------------------------------------
* errno | fd    | wtd (what to do)
*   X   | != -1 | return true
* EEXIST| == -1 | return false
*   X   | == -1 | print error to stderr and return false
*/
bool checkFirstRun()
{
  bool ret = false;
  int fd = open(FILE_LOCK, FILE_MODE);

  if (-1 != fd)
  {
    if (-1 == mkfifo(FIFO_NAME, FIFO_MODE))
    {
      cerr<<"Failed to create FIFO \""<<FIFO_NAME<<"\""<<endl;
      exit(1); // cannot continue!
    }
    close(fd);
    ret = true;
  }
  else if (-1 == fd && EEXIST != errno )
  {
    cerr<<"Failed to open file \""<<FILE_LOCK<<"\", errno="<<errno<<endl;
  }

  return ret;
}

void processCmd(char** argv)
{
  map<string, string> dictMap;
  char                cmdCode;
  string              wordStr;
  pthread_t           tid;
  int                 ret, fd, fd1, wd;
  map<string, string>::iterator it;
  FILE*               fp;
  bool                result;
  char                line[LINE_MAX];
  char                buf[BUF_LEN];
  size_t              len;

  // we need to open one end of the pipe first
  LOCK(mux0);
  fd = open(FIFO_NAME, FIFO_RMODE);
  fp = fdopen(fd, "r");

  fd1 = inotify_init();
  wd = inotify_add_watch(fd1, FIFO_NAME, IN_MODIFY);

  ret = pthread_create(&tid, NULL, sendCmdThr, argv);
  if (0 != ret)
  {
    cerr<<"Failed to create a thread, errno = "<<ret<<endl;
  }
  pthread_detach(tid);

  // unlock the sending thread to send ourselves a command
  UNLOCK(mux0);

  while (1)
  {
    // blocks here till the next event -- preemptible
    len = read(fd1, buf, BUF_LEN);
    // read a command
    if (NULL != fgets(line, LINE_MAX, fp))
    {
      cmdCode = *(char*) strtok(line, " \t\n");
      wordStr = string(strtok(NULL, " \t\n"));
      cout<<cmdCode<<":"<<wordStr<<endl;

      if ('0' == cmdCode)       // insert
      {
        cout<<"inserting \""<<wordStr<<"\""<<endl;
        dictMap[wordStr]="";
      }
      else if('1' == cmdCode)   // search
      {
        cout<<"searching \""<<wordStr<<"\""<<endl;
        it = dictMap.find(wordStr);
        result = (dictMap.end() == it) ? false : true;
        cout<<"result = "<<result<<endl;
      }
      else if('2' == cmdCode)   // delete
      {
        cout<<"deleting \""<<wordStr<<"\""<<endl;
        it = dictMap.find(wordStr);
        if (dictMap.end() != it)
        {
          dictMap.erase(it);
        }
      }
      else
      {
        cerr<<"Cannot parse cmd \""<<line<<"\""<<endl;
      }
    }
    else
    {
      // use inotify later
      clearerr(fp);
    }
  }
}

/* sendCmd
*  write the command to FIFO_NAME
*  assume that there is no error in the input for now
*  data packet = {cmdCode\tWord\n}
*  cmdCode  | Command
*     '0'   | insert
*     '1'   | search
*     '2'   | delete
*/
void sendCmd(char** argv)
{
  int   fd;
  char  cmdCode = 'X';
  char  tab = '\t';
  char  nl = '\n';
  int   len = 0;
  char  buffer[LINE_MAX];

  fd = open(FIFO_NAME, FIFO_WMODE);

  if (-1 == fd)
  {
    cerr<<"Failed to send the command to FIFO \""<<FIFO_NAME<<"\""<<endl;
    exit(1);
  }

  // insert
  if (0 == strcmp("-insert", argv[1]))
  {
    cmdCode = '0';
  }

  // search
  else if (0 == strcmp("-search", argv[1]))
  {
    cmdCode = '1';
  }

  // delete
  else if (0 == strcmp("-delete", argv[1]))
  {
    cmdCode = '2';
  }
  else
  {
    close(fd);
    cerr<<"wrong command"<<endl;
    exit(1);
  }

  memcpy((void*) buffer, &cmdCode, sizeof(char));
  len += sizeof(char);

  memcpy((void*) &buffer[len], &tab, sizeof(char));
  len += sizeof(char);

  memcpy((void*) &buffer[len], argv[2], strlen(argv[2]));
  len += strlen(argv[2]);

  memcpy((void*) &buffer[len], &nl, sizeof(char));
  len += sizeof(char);

  write(fd, buffer, len);
  close(fd);
}

void* sendCmdThr(void* arg)
{
  char** argv = (char**) arg;
  LOCK(mux0);
  UNLOCK(mux0);
  sendCmd(argv);

  return NULL;
}

// install signal handler for SIGUSR1 and SIGINT
void setSigHandler()
{
  sigset_t          block_mask;
  struct sigaction  event_sig;

  sigfillset(&block_mask);  // block everything when we are shutting down
  event_sig.sa_sigaction = sigHandler;
  event_sig.sa_mask = block_mask;
  event_sig.sa_flags = SA_RESTART;
  sigaction(SIGUSR1, &event_sig, NULL);
  sigaction(SIGINT, &event_sig, NULL);
}

void sigHandler(int signo, siginfo_t *info, void* context)
{
    // clean up and shutdown
    unlink(FILE_LOCK);
    unlink(FIFO_NAME);
    exit(0);
}
