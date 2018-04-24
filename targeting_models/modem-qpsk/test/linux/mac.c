
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
#include "mac.h"

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
/* Userspace Paths */
#define RX_DMA_UIO_DEV				"/dev/uio1"
#define RX_BUFF_MEM_SIZE			"/sys/class/uio/uio1/maps/map1/size"
#define RX_BUFF_MEM_ADDR			"/sys/class/uio/uio1/maps/map1/addr"
#define TX_DMA_UIO_DEV				"/dev/uio2"
#define TX_BUFF_MEM_SIZE			"/sys/class/uio/uio2/maps/map1/size"
#define TX_BUFF_MEM_ADDR			"/sys/class/uio/uio2/maps/map1/addr"

#define MODEM_UIO_DEV				"/dev/uio0"

/* DMAC Registers */
#define DMAC_REG_IRQ_MASK			0x80
#define DMAC_REG_IRQ_PENDING		0x84
#define DMAC_REG_IRQ_SOURCE			0x88

#define DMAC_REG_CTRL				0x400
#define DMAC_REG_TRANSFER_ID		0x404
#define DMAC_REG_START_TRANSFER		0x408
#define DMAC_REG_FLAGS				0x40c
#define DMAC_REG_DEST_ADDRESS		0x410
#define DMAC_REG_SRC_ADDRESS		0x414
#define DMAC_REG_X_LENGTH			0x418
#define DMAC_REG_Y_LENGTH			0x41c
#define DMAC_REG_DEST_STRIDE		0x420
#define DMAC_REG_SRC_STRIDE			0x424
#define DMAC_REG_TRANSFER_DONE		0x428
#define DMAC_REG_ACTIVE_TRANSFER_ID 0x42c
#define DMAC_REG_STATUS				0x430
#define DMAC_REG_CURRENT_DEST_ADDR	0x434
#define DMAC_REG_CURRENT_SRC_ADDR	0x438
#define DMAC_REG_DBG0				0x43c
#define DMAC_REG_DBG1				0x440

/* DMAC_REG_CTRL */
#define DMAC_CTRL_ENABLE			(1 << 0)
#define DMAC_CTRL_PAUSE				(1 << 1)

/* DMAC_REG_IRQ_PENDING */
#define DMAC_IRQ_SOT				(1 << 0)
#define DMAC_IRQ_EOT				(1 << 1)

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
static uint32_t rx_buf_start_address;
static int		rx_dma_uio_fd;
static void		*rx_dma_uio_addr;
static uint32_t	rx_buff_mem_size;
static uint32_t	rx_buff_mem_addr;
static int 		rx_dev_mem_fd = 0;
static void 	*rx_buff_virt_addr;

static int		tx_dma_uio_fd;
static void		*tx_dma_uio_addr;
static uint32_t	tx_buff_mem_size;
static uint32_t	tx_buff_mem_addr;
static void		*tx_buff_virt_addr;
static int		tx_dev_mem_fd = 0;

static int32_t 	running = 0;

/***************************************************************************//**
 * @brief get_file_info
*******************************************************************************/
int32_t get_file_info(const char *filename, uint32_t *info)
{
	int32_t ret;
	FILE* fp;

	fp = fopen(filename,"r");
	if (!fp) {
		fprintf(stderr, "MODEM: %s: File %s cannot be opened.", __func__, filename);
		return -1;
	}
	ret = fscanf(fp,"0x%x", info);
	if (ret < 0) {
		fprintf(stderr, "MODEM: %s: Cannot read info from file %s.", __func__, filename);
		return -1;
	}
	fclose(fp);

	return 0;
}

/***************************************************************************//**
 * @brief uio_read
*******************************************************************************/
void uio_read(void *uio_addr, uint32_t reg_addr, uint32_t *data)
{
	*data = (*((uint32_t *) (uio_addr + reg_addr)));
}

/***************************************************************************//**
 * @brief uio_write
*******************************************************************************/
void uio_write(void *uio_addr, uint32_t reg_addr, uint32_t data)
{
	*((uint32_t *) (uio_addr + reg_addr)) = data;
}

/***************************************************************************//**
 * @brief adc_capture
*******************************************************************************/
int32_t adc_capture(uint32_t size)
{
	uint32_t reg_val;
	uint32_t transfer_id;
	
	if(size > rx_buff_mem_size) {
		fprintf(stderr, "MODEM: %s: Desired length (%d) is bigger than the buffer size (%d).",
		__func__, size, rx_buff_mem_size);

		return -1;
	}	
	
	uio_write(rx_dma_uio_addr, DMAC_REG_CTRL, 0x0);
	uio_write(rx_dma_uio_addr, DMAC_REG_CTRL, DMAC_CTRL_ENABLE);
	uio_write(rx_dma_uio_addr, DMAC_REG_IRQ_MASK, 0x0);

	uio_read(rx_dma_uio_addr, DMAC_REG_TRANSFER_ID, &transfer_id);
	uio_read(rx_dma_uio_addr, DMAC_REG_IRQ_PENDING, &reg_val);
	uio_write(rx_dma_uio_addr, DMAC_REG_IRQ_PENDING, reg_val);
	
	uio_write(rx_dma_uio_addr, DMAC_REG_DEST_ADDRESS, rx_buf_start_address);
	uio_write(rx_dma_uio_addr, DMAC_REG_DEST_STRIDE, 0x0);
	uio_write(rx_dma_uio_addr, DMAC_REG_X_LENGTH, size - 1);
	uio_write(rx_dma_uio_addr, DMAC_REG_Y_LENGTH, 0x0);

	uio_write(rx_dma_uio_addr, DMAC_REG_START_TRANSFER, 0x1);
	/* Wait until the new transfer is queued. */
	do {
		uio_read(rx_dma_uio_addr, DMAC_REG_START_TRANSFER, &reg_val);
	} while(reg_val == 1 && running);
	
	/* Wait until the current transfer is completed. */
	do {
		uio_read(rx_dma_uio_addr, DMAC_REG_IRQ_PENDING, &reg_val);
	} while(reg_val != (DMAC_IRQ_SOT | DMAC_IRQ_EOT) && running);
	uio_write(rx_dma_uio_addr, DMAC_REG_IRQ_PENDING, reg_val);
	
	/* Wait until the transfer with the ID transfer_id is completed. */
	do {
		uio_read(rx_dma_uio_addr, DMAC_REG_TRANSFER_DONE, &reg_val);
	} while((reg_val & (1 << transfer_id)) != (uint32_t)(1 << transfer_id) && running);

	return 0;
}

/***************************************************************************//**
 * @brief rx_setup
*******************************************************************************/
int32_t rx_setup(void)
{
	rx_dma_uio_fd = open(RX_DMA_UIO_DEV, O_RDWR);
	if(rx_dma_uio_fd < 1) {
		fprintf(stderr, "MODEM: %s: Can't open rx_dma_uio device\n\r", __func__);

		return rx_dma_uio_fd;
	}
	
	rx_dma_uio_addr = mmap(NULL,
			  4096,
			  PROT_READ|PROT_WRITE,
			  MAP_SHARED,
			  rx_dma_uio_fd,
			  0);
			  
	get_file_info(RX_BUFF_MEM_SIZE, &rx_buff_mem_size);
	get_file_info(RX_BUFF_MEM_ADDR, &rx_buff_mem_addr);
	rx_buf_start_address = rx_buff_mem_addr;
	
	return 0;
}

/***************************************************************************//**
 * @brief rx_close
*******************************************************************************/
int32_t rx_close(void)
{
	munmap(rx_dma_uio_addr, 4096);

	close(rx_dma_uio_fd);
	
	close(rx_dev_mem_fd);
	
	return 0;
}

/***************************************************************************//**
 * @brief modem_read
*******************************************************************************/
int32_t modem_read(uint64_t* buf, uint32_t size)
{
	uint32_t index;
	void *mapping_addr;
	uint32_t mapping_length, page_mask, page_size;
	
	adc_capture(size);

	if(!rx_dev_mem_fd)
	{	
		rx_dev_mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
		if(rx_dev_mem_fd == -1) {
			fprintf(stderr, "MODEM: %s: Can't open /dev/mem device\n\r", __func__);
			rx_dev_mem_fd = 0;
			
			return -1;
		}

		page_size = sysconf(_SC_PAGESIZE);
		mapping_length = ((((size * 8) / page_size) + 1) * page_size);
		page_mask = (page_size - 1);
		mapping_addr = mmap(NULL,
				   mapping_length,
				   PROT_READ | PROT_WRITE,
				   MAP_SHARED,
				   rx_dev_mem_fd,
				   (rx_buff_mem_addr & ~page_mask));
		if(mapping_addr == MAP_FAILED) {
			fprintf(stderr, "MODEM: %s: mmap error\n\r", __func__);

			return -1;
		}

		rx_buff_virt_addr = (mapping_addr + (rx_buff_mem_addr & page_mask));
	}
	
	memcpy(buf, rx_buff_virt_addr, size);

	return 0;
}

/***************************************************************************//**
 * @brief tx_setup
*******************************************************************************/
int32_t tx_setup(void)
{
	uint32_t	mapping_length, page_mask, page_size;
	void		*mapping_addr;
	
	tx_dma_uio_fd = open(TX_DMA_UIO_DEV, O_RDWR);
	if(tx_dma_uio_fd < 1) {
		fprintf(stderr, "MODEM: %s: Can't open tx_dma_uio device\n\r", __func__);

		return tx_dma_uio_fd;
	}

	tx_dma_uio_addr = mmap(NULL,
			      4096,
			      PROT_READ|PROT_WRITE,
			      MAP_SHARED,
			      tx_dma_uio_fd,
			      0);

	get_file_info(TX_BUFF_MEM_SIZE, &tx_buff_mem_size);
	get_file_info(TX_BUFF_MEM_ADDR, &tx_buff_mem_addr);
	
	tx_dev_mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
	if(tx_dev_mem_fd == -1) {
		fprintf(stderr, "MODEM: %s: Can't open /dev/mem device\n\r", __func__);

		return tx_dev_mem_fd;
	}

	page_size = sysconf(_SC_PAGESIZE);
	mapping_length = (((tx_buff_mem_size / page_size) + 1) * page_size);
	page_mask = (page_size - 1);
	mapping_addr = mmap(NULL,
			   mapping_length,
			   PROT_READ | PROT_WRITE,
			   MAP_SHARED,
			   tx_dev_mem_fd,
			   (tx_buff_mem_addr & ~page_mask));
	if(mapping_addr == MAP_FAILED) {
		fprintf(stderr, "MODEM: %s: mmap error\n\r", __func__);

		return -1;
	}

	tx_buff_virt_addr = (mapping_addr + (tx_buff_mem_addr & page_mask));
	
	return 0;
}

/***************************************************************************//**
 * @brief tx_close
*******************************************************************************/
int32_t tx_close(void)
{
	munmap(tx_dma_uio_addr, 4096);

	close(tx_dma_uio_fd);
	
	close(tx_dev_mem_fd);
	
	return 0;
}

/***************************************************************************//**
 * @brief modem_write
*******************************************************************************/
int32_t modem_write(uint64_t* buffer, uint32_t size, uint32_t cyclic)
{
	uint32_t index;
	
	for (index = 0; index < size/sizeof(uint64_t); index++) {
		*(((uint64_t*)tx_buff_virt_addr) + index) = buffer[index];
	}

	printf("Reseting TX DMA\n");
	uio_write(tx_dma_uio_addr, DMAC_REG_CTRL, 0);
	uio_write(tx_dma_uio_addr, DMAC_REG_CTRL, DMAC_CTRL_ENABLE);
	uio_write(tx_dma_uio_addr, DMAC_REG_FLAGS, cyclic);
	uio_write(tx_dma_uio_addr, DMAC_REG_SRC_ADDRESS, tx_buff_mem_addr);
	uio_write(tx_dma_uio_addr, DMAC_REG_SRC_STRIDE, 0x0);
	uio_write(tx_dma_uio_addr, DMAC_REG_X_LENGTH, size - 1);
	uio_write(tx_dma_uio_addr, DMAC_REG_Y_LENGTH, 0x0);
	uio_write(tx_dma_uio_addr, DMAC_REG_START_TRANSFER, 0x1);
	
	return size;
}

/***************************************************************************//**
 * @brief modem_reset
*******************************************************************************/
int32_t modem_reset(void)
{
	int			modem_uio_fd;
	void		*modem_uio_addr;

	modem_uio_fd = open(MODEM_UIO_DEV, O_RDWR);
	if(modem_uio_fd < 1) {
		fprintf(stderr, "MODEM: %s: Can't open modem_uio device\n\r", __func__);

		return modem_uio_fd;
	}

	modem_uio_addr = mmap(NULL,
			      4096,
			      PROT_READ|PROT_WRITE,
			      MAP_SHARED,
			      modem_uio_fd,
			      0);

	uio_write(modem_uio_addr, 0x0, 0x1);

	munmap(modem_uio_addr, 4096);

	close(modem_uio_fd);

	return 0;
}

/***************************************************************************//**
 * @brief modem_setup
*******************************************************************************/
int32_t modem_setup(void)
{
	int32_t ret;
	
	ret = tx_setup();
	if(ret)
    {
        fprintf(stderr, "MODEM: Failed to setup Tx");
        return ret;
    }

	ret = rx_setup();
	if(ret)
    {
        fprintf(stderr, "MODEM: Failed to setup Rx");
        return ret;
    }
	
	return ret;
}

/***************************************************************************//**
 * @brief modem_start
*******************************************************************************/
int32_t modem_start(void)
{
	running = 1;
	
	return 0;
}

/***************************************************************************//**
 * @brief modem_reset
*******************************************************************************/
int32_t modem_stop(void)
{
	running = 0;
	
	return 0;
}

/***************************************************************************//**
 * @brief modem_reset
*******************************************************************************/
int32_t modem_close(void)
{
	rx_close();
	tx_close();
	
	return 0;
}

/***************************************************************************//**
 * @brief modem_running
*******************************************************************************/
int32_t modem_running(void)
{
	return running;
}



