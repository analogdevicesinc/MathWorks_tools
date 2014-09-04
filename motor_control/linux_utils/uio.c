/***************************************************************************//**
 * Copyright 2014(c) Analog Devices, Inc.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  - Neither the name of Analog Devices, Inc. nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *  - The use of this software may or may not infringe the patent rights
 *    of one or more patent holders.  This license does not release you
 *    from the requirement that you obtain separate licenses from these
 *    patent holders to use this software.
 *  - Use of the software either in source or binary form, must be run
 *    on or directly connected to an Analog Devices Inc. component.
 *
 * THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
	int uio_fd;
	void *uio_addr;
	unsigned int reg_addr;
	unsigned int reg_val;

	uio_fd = open(argv[1], O_RDWR);
	if(uio_fd < 1)
	{
		printf("error: invalid uio_fd\n\r");
		return -1;
	}
	
	uio_addr = mmap(NULL, 24576, PROT_READ|PROT_WRITE, MAP_SHARED, uio_fd, 0);
	
	if(strcmp(argv[2], "r")==0)
	{
		reg_addr = atoi(argv[3]);
		reg_val = *((unsigned *) (uio_addr + reg_addr));
		printf("r: reg[0x%x] = 0x%x\n\r", reg_addr, reg_val);
	}
	else
	{
		reg_addr = atoi(argv[3]);
		reg_val = atoi(argv[4]);
		*((unsigned *) (uio_addr + reg_addr)) = reg_val;
		printf("w: reg[0x%x] = 0x%x\n\r", reg_addr, reg_val);
	}

	munmap(uio_addr, 24576);
	close(uio_fd);

	return 0;
}

