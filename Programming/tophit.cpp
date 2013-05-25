/* tophit.cpp
 * cheesy parsing for a top requested URL
 * O(nlogn) : sum(O(log(i)),1,N) = O(nlog) with STL map (red-black tree)
 * written by Tuan T. Pham
 * last updated: 12/07/2010
 * compile: g++ -O3 -o tophit tophit.cpp
 */
#include <stdlib.h>
#include <unistd.h>
#include <string.h>  // to use strcmp, not very nice w/ <string>
#include <sys/inotify.h>

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>

using namespace std;

#define BUF_LEN (sizeof (struct inotify_event) + 16)

// container data structure for a hit: URL and hitcount
typedef struct hitStruct
{
  string    URL;
  long long  counter;

  // default constructor
  hitStruct():counter(0)
  {
  }
} hitType;

void Tokenize(const string& str, vector<string>& tokens, const string &delim);
void Help(char* execName);
void Process(int tokenPos, char* inputFile, char* outputFile);

int main(int argc, char **argv)
{
  long secs;
  int tokenPos;

  if ((5!=argc) || ((5 == argc) && (0 != strcmp("-p",argv[1]))) )
  {
    Help(argv[0]);
    return 1;
  }

  tokenPos = atoi(argv[2]);

  Process(tokenPos, argv[3], argv[4]);
  return 0;  // unreachabl
}

void
Help(char* execName)
{
  cout<<"Correct syntax:"<<endl;
  cout<<execName<<" -p tokenPosition inputFile outputFile"<<endl;
}

/* Code snippet from C++ Programming HOW-TO: The Standard C++ Library
 * string class
 */
void
Tokenize(const string& str, vector<string>& tokens, const string &delim)
{
  // Skip delimiters at beginning.
  string::size_type lastPos = str.find_first_not_of(delim, 0);
  // Find first "non-delimiter".
  string::size_type pos   = str.find_first_of(delim, lastPos);

  while (string::npos != pos || string::npos != lastPos)
  {
    // Found a token, add it to the vector.
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    // Skip delimiters.  Note the "not_of"
    lastPos = str.find_first_not_of(delim, pos);
    // Find next "non-delimiter"
    pos = str.find_first_of(delim, lastPos);
  }
}

void
Process(int tokenPos, char* inputFile, char* outputFile)
{
  string      aLine;
  ifstream    iFile(inputFile);
  ofstream    oFile(outputFile);
  map<string, long long>  hitMap;
  hitType     topHit;
  long long   tmpCount;
  vector<string>    tokens;

  int         fd, wd, ret, aPos;
  size_t      len;
  char        buf[BUF_LEN];

  aPos = tokenPos;
  // First pass
  while (std::getline(iFile, aLine))  // string's getline
  {
    Tokenize(aLine, tokens, " ");
    if (aPos < tokens.size())
    {
      tmpCount = ++hitMap[tokens[aPos]];
      if (topHit.counter < tmpCount)
      {
        topHit.URL = tokens[aPos];
        topHit.counter = tmpCount;
      }
    }
      tokens.resize(0);
  }

  oFile.seekp(0);
  oFile<<topHit.URL<<"\t"<<topHit.counter<<endl;
  oFile.flush();
  iFile.clear();  // clear filestream error flags

  fd = inotify_init();
  wd = inotify_add_watch(fd, inputFile, IN_MODIFY);
  // wait for the file to be updated
  while (1)
  {
    // blocking call here for the next event
    len = read(fd, buf, BUF_LEN);

    while (std::getline(iFile, aLine))  // string's getline
    {
      Tokenize(aLine, tokens, " ");
      if (aPos < tokens.size())
      {
        tmpCount = ++hitMap[tokens[aPos]];
        if (topHit.counter < tmpCount)
        {
          topHit.URL = tokens[aPos];
          topHit.counter = tmpCount;
        }
      }
      tokens.resize(0);
    }

    oFile.seekp(0);
    oFile<<topHit.URL<<"\t"<<topHit.counter<<endl;
    oFile.flush();
    iFile.clear();  // clear filestream error flags
  }
}
