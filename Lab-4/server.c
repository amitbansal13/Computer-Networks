#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#define MAXPENDING 5
#define BUFFERSIZE 32
int stringToInt(char *arr)
{
  int i=0;
  double ans=0,p=10;

  while(arr[i])
  {
    if(arr[i]=='.')break;
    ans=ans*10.0+arr[i]-'0';
    i++;
  }
  if(arr[i]=='.')i++;
  while(arr[i])
  {
    ans=ans+(arr[i]-'0')/p;
    p*=10;
    i++;
  }
  return ceil(ans);
}
int main ()
{
 /*CREATE A TCP SOCKET*/
	int serverSocket = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (serverSocket < 0) { printf ("Error while server socket creation"); exit (0); } 
	printf ("Server Socket Created\n"); 

 /*CONSTRUCT LOCAL ADDRESS STRUCTURE*/
	struct sockaddr_in serverAddress, clientAddress;
	memset (&serverAddress, 0, sizeof(serverAddress));
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_port = htons(12345);
	serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1");
	printf ("Server address assigned\n");

	int temp = bind(serverSocket, (struct sockaddr*) &serverAddress,  sizeof(serverAddress));
	if (temp < 0) 
	{
		printf ("Error while binding\n"); 
		exit (0);
	}
 	printf ("Binding successful\n");
	int temp1 = listen(serverSocket, MAXPENDING);
	if (temp1 < 0) 
	{  printf ("Error in listen"); 
	 exit (0);
	}
	printf ("Now Listening\n");
	char msg[BUFFERSIZE];
 
  	int clientLength = sizeof(clientAddress);
  	int clientSocket = accept (serverSocket, (struct sockaddr*) &clientAddress, &clientLength);
  	if (clientLength < 0) {printf ("Error in client socket"); exit(0);}
  	if(fork()==0)
  	{
  		close(serverSocket);
		printf ("Handling Client %s\n", inet_ntoa(clientAddress.sin_addr));
		int temp2 = recv(clientSocket, msg, BUFFERSIZE, 0);
		if (temp2 < 0) 
		{ printf ("problem in temp 2"); 
		  exit (0);
		}
		msg[temp2] = '\0';
		int ans=stringToInt(msg);
		//printf ("ENTER MESSAGE FOR CLIENT\n");
		printf("%s\n",msg);
		sprintf(msg,"%d",ans);

		int bytesSent = send (clientSocket,msg,strlen(msg),0);
		if (bytesSent != strlen(msg)) 
		{
			printf ("Error while sending message to client");   
			exit(0);
		}
		close(clientSocket);
		exit(0);
	}
	close(clientSocket);
}
