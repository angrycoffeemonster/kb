/*
 * To compile and install:
 *    sudo gcc ed2k.c -Wall -o /usr/bin/ed2k
 */

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
 
int main(int argc, char *argv[])
{
	int fd, i;
	
	umask(0);
	fd = open("/home/venator/Desktop/ed2klinks", O_RDWR|O_CREAT|O_APPEND, 0644);
	for(i=1; i<argc; ++i)
	{
 		write(fd, argv[i], strlen(argv[i]));
	 	write(fd, "\n", 1);
	}
	close(fd);
	return 0;
}
