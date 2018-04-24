#ifndef __MAC_H__
#define __MAC_H__

int32_t modem_reset(void);
int32_t modem_setup(void);
int32_t modem_start(void);
int32_t modem_stop(void);
int32_t modem_close(void);
int32_t modem_running(void);
int32_t modem_write(uint64_t* buf, uint32_t size, uint32_t cyclic);
int32_t modem_read(uint64_t* buf, uint32_t size);

#endif /*__MAC_H__ */

