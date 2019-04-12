/*
    Simple udp client
*/
#include<stdio.h> //printf
#include<string.h> //memset
#include <unistd.h>
#include<stdlib.h> //exit(0);
#include<arpa/inet.h>
#include<sys/socket.h>
 

#define BUFLEN 512  //Max length of buffer
#define PORT 8888   //The port on which to send data
 
void die(char *s)
{
    perror(s);
    exit(1);
}
 
int main(void)
{
    struct sockaddr_in temp;
    int s=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    if(s<0){
        die("Socket");
        exit(0);
    }
    temp.sin_family=AF_INET;
    temp.sin_port=htons(12345);
    temp.sin_addr.s_addr=inet_addr("127.0.0.1");
    char msg[100];
    printf("Enter a message for client\n");
    fgets(msg,100,stdin);
    int l=sendto(s,msg,strlen(msg),0,(struct sockadddr*)&temp,sizeof(temp));
    if(l!=strlen(msg))
    {
        die("Send Error");
        exit(0);
    }
    l=recvfrom(s,msg,99,0,(struct sockaddr*)&temp,sizeof(temp));
    if(l<0)
    {
        die("Recv error");
        exit(0);
    }
    msg[l]='\0';
    printf("%s\n",msg);
    close(s);
    return 0;
}
