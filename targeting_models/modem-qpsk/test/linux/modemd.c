#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/signalfd.h>
#include <sys/socket.h>
#include <unistd.h>
#include <math.h>

#include <arpa/inet.h>
#include <linux/if.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>
#include <net/route.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include "mac.h"

#define DEBUG 3

#define IP(a, b, c, d) ((a << 24) | (b << 16) | (c << 8) | d)

#define INTERFACE_NAME "adi_radio"
#define INTERFACE_ADDRESS htonl(IP(192, 168, 23, 1))
#define INTERFACE_NETMASK htonl(IP(255, 255, 255, 0))
#define DELAY 10000

#define MTU 				68//1564
#define HEADER_DATA_SIZE 	8
#define HEADER_FRAME_SIZE 	16
#define CRC_SIZE			8
#define PADDING_SIZE		12
#define TX_BUF_SIZE			HEADER_DATA_SIZE + HEADER_FRAME_SIZE + MTU + PADDING_SIZE
#define RX_BUF_SIZE			HEADER_FRAME_SIZE + MTU + PADDING_SIZE + CRC_SIZE

extern char 	*optarg;
static char 	tx_buffer[TX_BUF_SIZE];
static char 	rx_buffer[RX_BUF_SIZE];
static struct 	pollfd pfd[2];

uint8_t reverseBits(uint8_t num)
{
    unsigned int  NO_OF_BITS = sizeof(num) * 8;
    unsigned int reverse_num = 0;
    int i;
    for (i = 0; i < NO_OF_BITS; i++)
    {
        if((num & (1 << i)))
           reverse_num |= 1 << ((NO_OF_BITS - 1) - i);  
   }
    return reverse_num;
}

static int tun_alloc(const char *name, int flags)
{
	static const char *clonedev = "/dev/net/tun";
	struct ifreq ifr;
	int fd, ret;

	fd = open(clonedev, O_RDWR);
	if (fd < 0)
		return -errno;

	memset(&ifr, 0, sizeof(ifr));

	ifr.ifr_flags = flags;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);

	ret = ioctl(fd, TUNSETIFF, &ifr);
	if (ret < 0) {
		close(fd);
		return -errno;
	}

	return fd;
}

static int set_ip(const char *name, in_addr_t addr)
{
	struct ifreq ifr;
	struct sockaddr_in sin;
	int ret, fd;

	memset(&ifr, 0, sizeof(struct ifreq));
	memset(&sin, 0, sizeof(struct sockaddr_in));
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	sin.sin_addr.s_addr = addr;
	sin.sin_family = AF_INET;
	memcpy(&ifr.ifr_addr, &sin, sizeof(struct sockaddr_in));

	fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0)
		return -errno;
	ret = ioctl(fd, SIOCSIFADDR, &ifr);
	if (ret < 0) {
		ret = -errno;
		goto err;
	}

	ret = ioctl(fd, SIOCGIFFLAGS, &ifr);
	if (ret < 0) {
		ret = -errno;
		goto err;
	}
	ifr.ifr_flags |= IFF_UP | IFF_RUNNING;
	ioctl(fd, SIOCSIFFLAGS, &ifr);
	if (ret < 0)
		ret = -errno;
err:
	close(fd);

	if (ret < 0)
		return ret;

	return 0;
}

static int add_route(const char *dev, in_addr_t host_addr, in_addr_t mask)
{
	struct sockaddr_in *addr;
	struct rtentry route;
	int fd, ret;

	memset(&route, 0, sizeof(route));

	/* gateway IP */
	addr = (struct sockaddr_in *)&route.rt_gateway;
	addr->sin_family = AF_INET;
	addr->sin_addr.s_addr = INADDR_ANY;

	/* target IP */
	addr = (struct sockaddr_in *)&route.rt_dst;
	addr->sin_family = AF_INET;
	addr->sin_addr.s_addr = host_addr & mask;

	/* subnet mask */
	addr = (struct sockaddr_in *)&route.rt_genmask;
	addr->sin_family = AF_INET;
	addr->sin_addr.s_addr = mask;

	route.rt_flags = RTF_UP;
	route.rt_metric = 0;
	route.rt_dev = (char *)dev;

	fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (fd < 0)
		return -errno;
 	ret = ioctl(fd, SIOCADDRT, &route);
	if (ret < 0)
		ret = -errno;
	close(fd);

	if (ret < 0)
		return ret;

	return 0;
}

static int setup_signal_handler(void)
{
	sigset_t mask;
	int ret;

	sigemptyset(&mask);
	sigaddset(&mask, SIGINT);
	sigaddset(&mask, SIGPIPE);
	sigaddset(&mask, SIGHUP);
	sigaddset(&mask, SIGTERM);

	ret = sigprocmask(SIG_BLOCK, &mask, NULL);
	if (ret) {
		perror("Failed to setup signal mask");
		return -errno;
	}

	ret = signalfd(-1, &mask, 0);
	if (ret < 0) {
		perror("Failed to create signalfd");
		return -errno;
	}

	return ret;
}

static int receive_data(int fd)
{
	int ret;

	do {
		ret = read(fd, &tx_buffer[HEADER_DATA_SIZE + HEADER_FRAME_SIZE], MTU);
	} while (ret == -1 && errno == EAGAIN);

	if (ret < 0) {
		perror("Failed to receive data");
		return -errno;
	}

#if(DEBUG >= 2)	
	printf("ETH: Received %d bytes of data....\n", ret);
#endif
	
#if(DEBUG >= 3)	
	//for(int i = 16; i < ret + 16; i++)
	//	printf("%x, ", tx_buffer[i]);
	for(int i = HEADER_DATA_SIZE + HEADER_FRAME_SIZE; i < ret; i++)
		printf("%x, ", tx_buffer[i]);
	printf("\n");
#endif
#if(DEBUG >= 2)	
	printf("Sending Modem %d bytes of data....\n", ret);
#endif

	uint8_t ps = MTU + PADDING_SIZE + HEADER_FRAME_SIZE;
	unsigned psr = reverseBits(ps);
	*(uint64_t*)(&tx_buffer[0]) = psr;//MTU + PADDING_SIZE + HEADER_FRAME_SIZE;
	*(uint64_t*)(&tx_buffer[HEADER_DATA_SIZE]) = ret;
	*(uint64_t*)(&tx_buffer[HEADER_FRAME_SIZE]) = ret;
	modem_write((uint64_t*)tx_buffer, TX_BUF_SIZE, 0);

#if(DEBUG >= 3)	
	printf("Payload Size: %d | %d\n",MTU + PADDING_SIZE + HEADER_FRAME_SIZE,psr);
	for(int i = 0; i < ret + HEADER_FRAME_SIZE + HEADER_DATA_SIZE; i++)
		printf("%x, ", tx_buffer[i]);
	printf("\n");
#endif
	
#if(DEBUG >= 2)	
	printf("ETH: Received Done\n");
#endif
	
	return 0;
}


const char *byte_to_binary(int x)
{
    static char b[9];
    b[0] = '\0';

    int z;
    for (z = 128; z > 0; z >>= 1)
    {
        strcat(b, ((x & z) == z) ? "1" : "0");
    }

    return b;
}

static int send_data(int fd, unsigned char* buf, size_t len)
{
	int ret;
#if(DEBUG >= 3)	
	int i;
#endif

#if(DEBUG >= 2)	
	printf("RADIO: Sent %d bytes of data\n", len);
#endif
	/*	
	for(i = 0-HEADER_FRAME_SIZE; i < 8*11; i++)
	{
		//uint8_t rb = reverseBits((uint8_t) buf[i]);
		//printf("%s, ", byte_to_binary(rb) );
		printf("%x, ", buf[i]);
	}
	printf("\n");
	*/	
	printf("Buffer Full Frame: |");
	for(i = 0-HEADER_FRAME_SIZE; i < 8*11; i=i+8)
		printf("%c", (char) buf[i] );
	printf("|\n");	

	if(len > MTU)
	{
#if(DEBUG >= 1)
		printf("RADIO: ERROR frame larger than MTU\n");
#endif	
		return -1;
	}

#if(DEBUG >= 3)
	printf("Buffer Full Frame\n");
	for(i = 0; i < len; i++)
		printf("%x, ", buf[i]);
	printf("\n");	
#endif
	
	do {
		ret = write(fd, buf, len);
	} while (ret == -1 && errno == EAGAIN);

	if (ret < 0) {
		perror("RADIO: Failed to send data");
		return -errno;
	}

#if(DEBUG >= 2)	
	printf("RADIO: Sent Done\n");
#endif

	return 0;
}

void *rx_thread_fnc(void* ptr) 
{
#if(DEBUG >= 3)	
	int i = 0;
#endif
	
	printf("TUN/TAP: Running Rx thread...\n");
	
	while(modem_running())
	{
		modem_read((uint64_t*)rx_buffer, RX_BUF_SIZE);
#if(DEBUG >= 2)	
	printf("GOT DATA FROM RADIO!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
#endif

	#if(DEBUG >= 3)	
		printf("Recevied HEADER DATA\n");	
		for(i = 0; i < HEADER_FRAME_SIZE; i++)
			printf("%x, ", rx_buffer[i]);
		printf("\n");
	#endif
	#if(DEBUG >= 1)	
		if(*(uint64_t*)&(rx_buffer[RX_BUF_SIZE - CRC_SIZE]))
			printf("RADIO: CRC ERROR\n");
	#endif	
		//if(*(uint64_t*)&(rx_buffer[RX_BUF_SIZE - CRC_SIZE]) == 0)
			send_data(pfd[1].fd, (unsigned char*)&rx_buffer[HEADER_FRAME_SIZE], *(uint64_t*)&rx_buffer[HEADER_FRAME_SIZE/2]);
	}	

	printf("TUN/TAP: Exiting Rx thread\n");
	
	return NULL;
}

int main(int argc, char *argv[])
{
	int ret;
	int opt;
	pthread_t rx_thread;
	struct in_addr addr;
	struct in_addr mask;
	unsigned int usec_delay;
	int net_type;
	
	addr.s_addr = INTERFACE_ADDRESS;
	mask.s_addr = INTERFACE_NETMASK;
	usec_delay = DELAY;
	net_type = IFF_TUN;
	
	while ((opt = getopt(argc, argv, "a:m:d:n:")) != -1) {
        switch (opt) {
        case 'a':
			if (inet_aton(optarg, &addr) == 0) {
				perror("Invalid IP address\n");
				return 1;
			}
            break;
		case 'm':
			if (inet_aton(optarg, &mask) == 0) {
				perror("Invalid IP mask\n");
				return 1;
			}
            break;
		case 'd':
			usec_delay = atoi(optarg);
            break;
		case 'n':
			if (strcasecmp(optarg, "tun") && strcasecmp(optarg, "tap")) {
				perror("Invalid netowrk interface type, should be TUN or TAP\n");
				return 1;
			}
			net_type = strcasecmp(optarg, "tun") ? IFF_TAP : IFF_TUN;
            break;	
        default: /* '?' */
            fprintf(stderr, "Usage: %s [-a IP address] [-m IP mask] [-d us delay between frames] [-n tun or tap interface]\n", argv[0]);
		}
    }

	printf("Running %s daemon...\n", net_type == IFF_TUN ? "TUN" : "TAP");
	printf("   *IP address: %s\n", inet_ntoa(addr));
	printf("   *Netmask: %s\n", inet_ntoa(mask));
	printf("   *Max data rate: %d kBps\n", (unsigned int)(((float)MTU / usec_delay) * 1e3f));
	
	ret = setup_signal_handler();
	if (ret < 0)
		return 1;

	pfd[0].fd = ret;
	pfd[0].events = POLLIN;

	ret = tun_alloc(INTERFACE_NAME, net_type | IFF_NO_PI);
	if (ret < 0) {
		perror("TUN/TAP: Failed to create TUN device");
		return 1;
	}

	pfd[1].fd = ret;
	pfd[1].events = POLLIN;

	ret = set_ip(INTERFACE_NAME, addr.s_addr);
	if (ret < 0) {
		perror("TUN/TAP: Failed to set IP address on TUN device");
		return 1;
	}

	ret = add_route(INTERFACE_NAME, addr.s_addr, mask.s_addr);
	if (ret < 0) {
		perror("TUN/TAP: Failed to create route");
		return 1;
	}

	ret = modem_setup();
	if(ret)
    {
        perror("TUN/TAP: Failed to setup modem");
        return ret;
    }
	
	ret = modem_reset();
	if(ret)
    {
        perror("TUN/TAP: Failed to reset modem");
        return 1;
    }
	
	ret = modem_start();
	if(ret)
    {
        perror("TUN/TAP: Failed to start modem");
        return 1;
    }

	ret = pthread_create(&rx_thread, NULL, rx_thread_fnc, NULL);
    if(ret)
    {
        perror("TUN/TAP: Error - pthread_create");
        return 1;
    }
	
	while (1) {
		printf("Checking ETH FOR DATA\n");
		do {
			ret = poll(pfd, 2, -1);
		} while (ret == -1 && errno == EINTR);

		/* If any signals are pending cleanup and exit */
		if (pfd[0].revents & POLLIN)
			break;

		if (pfd[1].revents & POLLIN) {
			ret = receive_data(pfd[1].fd);
			if (ret < 0)
				break;
			usleep(usec_delay);
		}
	}
	
	modem_stop();
	pthread_join(rx_thread, NULL);
	modem_close();
	
	close(pfd[1].fd);
	close(pfd[0].fd);

	printf("Exiting TUN/TAP daemon\n");

	return 0;
}
