
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
/* Userspace Paths */
#define IP_UIO_DEV                   "/dev/uio0"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
int			rx_dma_uio_fd;
void		*rx_dma_uio_addr;
uint32_t	rx_buff_mem_size;
uint32_t	rx_buff_mem_addr;

/***************************************************************************//**
 * @brief get_file_info
*******************************************************************************/
int32_t get_file_info_R(const char *filename, uint32_t *info)
{
	int32_t ret;
	FILE* fp;

	fp = fopen(filename,"r");
	if (!fp) {
		printf("%s: File %s cannot be opened.", __func__, filename);
		return -1;
	}
	ret = fscanf(fp,"0x%x", info);
	if (ret < 0) {
		printf("%s: Cannot read info from file %s.", __func__, filename);
		return -1;
	}
	fclose(fp);

	return 0;
}

/***************************************************************************//**
 * @brief uio_read
*******************************************************************************/
void uio_read_R(void *uio_addr, uint32_t reg_addr, uint32_t *data)
{
	*data = (*((unsigned *) (uio_addr + reg_addr)));
}

/***************************************************************************//**
 * @brief uio_write
*******************************************************************************/
void uio_write_R(void *uio_addr, uint32_t reg_addr, uint32_t data)
{
	*((unsigned *) (uio_addr + reg_addr)) = data;
}

/***************************************************************************//**
 * @brief uio_write
*******************************************************************************/
int32_t ip_write_R(uint32_t reg_addr, uint32_t data)
{
	int			ip_uio_fd_rx;
	void		*ip_uio_addr_rx;

	ip_uio_fd_rx = open(IP_UIO_DEV, O_RDWR);
	if(ip_uio_fd_rx < 1) {
		printf("%s: Can't open Rx ip_uio device\n\r", __func__);

		return ip_uio_fd_rx;
	}

	ip_uio_addr_rx = mmap(NULL,
			      4096,
			      PROT_READ|PROT_WRITE,
			      MAP_SHARED,
			      ip_uio_fd_rx,
			      0);

	uio_write_R(ip_uio_addr_rx, reg_addr, data);

	munmap(ip_uio_addr_rx, 4096);

	close(ip_uio_fd_rx);

	return 0;
}

/***************************************************************************//**
 * @brief uio_write
*******************************************************************************/
int32_t ip_read_R(uint32_t reg_addr, uint32_t *data)
{
	int			ip_uio_fd_rx;
	void		*ip_uio_addr_rx;

	ip_uio_fd_rx = open(IP_UIO_DEV, O_RDWR);
	if(ip_uio_fd_rx < 1) {
		printf("%s: Can't open Rx ip_uio device\n\r", __func__);

		return ip_uio_fd_rx;
	}

	ip_uio_addr_rx = mmap(NULL,
			      4096,
			      PROT_READ|PROT_WRITE,
			      MAP_SHARED,
			      ip_uio_fd_rx,
			      0);

	uio_read_R(ip_uio_addr_rx, reg_addr, data);

	munmap(ip_uio_addr_rx, 4096);

	close(ip_uio_fd_rx);

	return 0;
}

int32_t reg_write(uint32_t reg_addr, uint32_t data)
{
	return ip_write_R(reg_addr, data);
}


void read_core(void)
{
	uint32_t data;
	ip_read_R(0x114,&data);
	printf("Packets Found: %lu\n",(unsigned long)data);
	ip_read_R(0x120,&data);
	printf("PDs Triggered: %lu\n",(unsigned long)data);
}

void set_agc_mode(void)
{

	int ret;
	
	read_core();
	printf("Reseting core\n");
	ip_write_R(0x0, 0x1);
	read_core();

	printf("Configuring setup register\n");

	// Threshold
	ip_write_R(0x100, (uint32_t)70);
	// Enable Packet Detection
	ip_write_R(0x104, (uint32_t)0);
	// Enable NCO
	ip_write_R(0x11C, (uint32_t)0);
	// Enable Output Latch
	ip_write_R(0x10C, (uint32_t)0);
	// AGC Control [0=Lock,1=Free Run,2=IP Control]
	ip_write_R(0x124, (uint32_t)1);
	// Packet Length
	//ip_write_R(0x108, (uint32_t)4096);
	ip_write_R(0x108, (uint32_t)2500);
	//ip_write_R(0x108, (uint32_t)8192);

	sleep(1);
	read_core();
	printf("Configuring runtime configuration\n");
	// Enable Packet Detection
	ip_write_R(0x104, (uint32_t)1);
	sleep(1);
	while (0)
	{
		read_core();
		sleep(1);
	}
}


/***************************************************************************//**
* @brief main
*******************************************************************************/

int main(int argc, char *argv[])
{

	set_agc_mode();
/*	int opt;

	if (argc == 1) {
            fprintf(stderr, "Usage: %s [-e Stop AGC once locked] [-o Enable continuous AGC evolution]\n", argv[0]);
	}

	while ((opt = getopt(argc, argv, "eo")) != -1) {
        switch (opt) {
        case 'e':
		printf("AGC is stop once locked\n");
		ip_write_R(0x100, (uint32_t)1);
            break;
        case 'o':
		printf("Enabling AGC Evolution\n");
		ip_write_R(0x100, (uint32_t)0);
            break;
        default:
            fprintf(stderr, "Usage: %s [-e Stop AGC once locked] [-o Enable continuous AGC evolution]\n", argv[0]);
	}
	}
*/
}

