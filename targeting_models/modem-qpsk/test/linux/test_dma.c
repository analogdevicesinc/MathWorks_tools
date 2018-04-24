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
#include <stdbool.h>

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
#include "reg.h"

#define DEBUG 0

int INTERNAL_PACKET_GEN = 1;
int IP_LOOPBACK_MODE = 1;

#define DELAY 10000

#define MTU 			80	//1564
#define HEADER_DATA_SIZE 	8
#define HEADER_FRAME_SIZE 	8 //16
#define CRC_SIZE			8
#define PADDING_SIZE		16//12
#define TX_BUF_SIZE			HEADER_DATA_SIZE + HEADER_FRAME_SIZE + MTU + PADDING_SIZE
#define RX_BUF_SIZE			HEADER_FRAME_SIZE + MTU + PADDING_SIZE + CRC_SIZE

//extern char 	*optarg;
static char 	tx_buffer[TX_BUF_SIZE];
static char 	rx_buffer[RX_BUF_SIZE];
//static struct 	pollfd pfd[2];

uint8_t reverseBits(uint8_t num)
{
    unsigned int  NO_OF_BITS = sizeof(num) * 8;
    unsigned int reverse_num = 0;
    int i;
    for (i = 0; i < NO_OF_BITS; i++) {
        if((num & (1 << i)))
            reverse_num |= 1 << ((NO_OF_BITS - 1) - i);
    }
    return reverse_num;
}

const char *byte_to_binary(int x)
{
    static char b[9];
    b[0] = '\0';

    int z;
    for (z = 128; z > 0; z >>= 1) {
        strcat(b, ((x & z) == z) ? "1" : "0");
    }

    return b;
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

static int receive_data()
{

    // Set packet Header info
    *(uint64_t*)(&tx_buffer[0]) = MTU + PADDING_SIZE + HEADER_FRAME_SIZE;

    // Fill data into packet
    int k=0;
    for (k=0; k<TX_BUF_SIZE - HEADER_FRAME_SIZE; k=k+1)
        *(uint64_t*)(&tx_buffer[k+HEADER_DATA_SIZE]) = k;

    // Debug
#if(DEBUG>0)
    printf("Header Data:\n");
    for(int i = 0; i < HEADER_DATA_SIZE + HEADER_FRAME_SIZE; i++)
        printf("%d, ", tx_buffer[i]);
    printf("\n");
    printf("Payload Data:\n");
    for(int i = HEADER_DATA_SIZE + HEADER_FRAME_SIZE; i < TX_BUF_SIZE; i++)
        printf("%d, ", tx_buffer[i]);
    printf("\n");
#endif
    // Send to IP
    modem_write((uint64_t*)tx_buffer, TX_BUF_SIZE, 0);

    return 0;
}

void *rx_thread_fnc(void* ptr)
{

    printf(": Running Rx thread...\n");

    while(modem_running()) {
        modem_read((uint64_t*)rx_buffer, RX_BUF_SIZE);

#if(DEBUG>0)
        int i = 0;
        printf("-------Receiver Side-------\n");

        printf("Received Header Data\n");
        for(i = 0; i < HEADER_FRAME_SIZE+HEADER_FRAME_SIZE; i++)
            printf("%d, ", rx_buffer[i]);
        printf("\n");
#endif
        if(*(uint64_t*)&(rx_buffer[RX_BUF_SIZE - CRC_SIZE]))
            printf("RADIO: CRC ERROR\n");
#if(DEBUG>0)
        printf("Received Full Payload\n");
        for(i = 0; i < TX_BUF_SIZE; i++) {
            printf("%d, ", rx_buffer[i]);
        }
        printf("\n");

        if (INTERNAL_PACKET_GEN > 0) {
            printf("|");
            // Use for internal packet generation print
            for(i = 0; i < RX_BUF_SIZE; i=i+8) {
                printf("%c", rx_buffer[i]);
            }
            printf("|\n");
        }
#endif
        break;
    }

    printf("Exiting Rx thread\n");

    return NULL;
}

void fill_in_internal_pgen_data()
{
    int k, index = 0;
    char msg[] = " Hello World 0";
    for(k=0; k<TX_BUF_SIZE; k++) {
        if (k%8==0) {
            tx_buffer[k] = msg[index];
            index++;
        } else
            tx_buffer[k] = 0;
    }
}


int test_loopback()
{
    int ret;
    pthread_t rx_thread;

    ret = setup_signal_handler();
    if (ret < 0)
        return 1;


    ret = modem_setup();
    if(ret) {
        perror(": Failed to setup modem");
        return ret;
    }

    ret = modem_reset();
    if(ret) {
        perror(": Failed to reset modem");
        return 1;
    }

    ret = modem_start();
    if(ret) {
        perror(": Failed to start modem");
        return 1;
    }

    ret = pthread_create(&rx_thread, NULL, rx_thread_fnc, NULL);
    if(ret) {
        perror(": Error - pthread_create");
        return 1;
    }


    printf("Setup modem defaults\n");
    defaults(INTERNAL_PACKET_GEN, IP_LOOPBACK_MODE);

    if (INTERNAL_PACKET_GEN) {
        sleep(1);
        fill_in_internal_pgen_data();
        printf("Sending 1 packet from internal IP\n");
        reg_write(0x120, 1);
        reg_write(0x120, 0);
        sleep(3);
    } else {
        sleep(1);
        printf("Sending data\n");
        ret = receive_data();
        sleep(3);
    }
    modem_stop();
    pthread_join(rx_thread, NULL);
    modem_close();

    int i;
    bool b = false;
    for(i = 0; i < TX_BUF_SIZE-HEADER_DATA_SIZE; i++) {
        b |= rx_buffer[i] != tx_buffer[i+HEADER_DATA_SIZE];
    }

    if (b) {
        printf("\n---------RX|TX---------\n");
        for(i = 0; i < TX_BUF_SIZE-HEADER_DATA_SIZE; i++) {
            printf("%d %d\n", rx_buffer[i]>>0, tx_buffer[i+HEADER_DATA_SIZE]);
        }
    }

    printf("Exiting test\n");

    return (int) b;
}


int main()
{
    int ret;

    // IP Loopback
    IP_LOOPBACK_MODE = 0;

    INTERNAL_PACKET_GEN = 1;
    ret = test_loopback();
    if (ret>0)
        return ret;

    INTERNAL_PACKET_GEN = 0;
    ret = test_loopback();
    if (ret>0)
        return ret;

    // RF Loopback
    IP_LOOPBACK_MODE = 1;

    INTERNAL_PACKET_GEN = 1;
    ret = test_loopback();
    if (ret>0)
        return ret;

    INTERNAL_PACKET_GEN = 0;
    ret = test_loopback();
    if (ret>0)
        return ret;

    return 0;
}
