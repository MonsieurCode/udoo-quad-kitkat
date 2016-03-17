
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>

void ShowHelp()
{
	printf("Missing param! Use 'ext' for set external OTG or 'int' for set internal OTG\n");
}

int SetGpioOutDirection(unsigned int GpioNum)
{
	char buf[256]; 
	int fd;
	
	sprintf(buf, "/sys/devices/virtual/gpio/gpio%d/direction", GpioNum);

	fd = open(buf, O_WRONLY);
	
	if(fd < 0)
	{
	    printf("Opening file '%s' Failed\n", buf);
	    printf("Error no is : %d\n", errno);
	    printf("Error description is : %s\n",strerror(errno));
	    return 0;
	}

	write(fd, "out", 3); 

	close(fd);	
	
	return 1;
}

int SetGpioValue(unsigned int GpioNum, unsigned char Value)
{
	char buf[256]; 
	int fd;
	
	sprintf(buf, "/sys/devices/virtual/gpio/gpio%d/value", GpioNum);

	fd = open(buf, O_WRONLY);
	
	if(fd < 0)
	{
	    printf("Opening file '%s' Failed\n", buf);
	    printf("Error no is : %d\n", errno);
	    printf("Error description is : %s\n",strerror(errno));
	    return 0;
	}
	
	sprintf(buf, "%u", Value);

	write(fd, buf, 1); 

	close(fd);	
	
	return 1;
}

int main(int argc, char *argv[])
{
	if(argc < 2)
	{
		ShowHelp();
		return 1;
	}
	
	//system("id");
	
	if(!SetGpioOutDirection(128))
	{
		printf("ERROR: Unable to set 'out' state for GPIO 128\n");
		return 1;
	}
	if(!SetGpioOutDirection(203))
	{
		printf("ERROR: Unable to set 'out' state for GPIO 203\n");
		return 1;
	}
	
	if(strcmp(argv[1], "ext") == 0)
	{
		if(!SetGpioValue(203, 0)
		|| !SetGpioValue(128, 0))
		{
			printf("ERROR: Unable to set GPIO state!\n");
			return 1;
		}
		printf("Set external OTG port!\n");
	}
	else if(strcmp(argv[1], "int") == 0)
	{
		if(!SetGpioValue(128, 1)
		|| !SetGpioValue(203, 1))
		{
			printf("ERROR: Unable to set GPIO state!\n");
			return 1;
		}
		printf("Set internal OTG port!\n");
	}
	else
	{
		ShowHelp();
		return 1;
	}
		
	return 0;
}