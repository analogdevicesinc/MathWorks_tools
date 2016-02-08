/*
 * adsb_decode - ADS-B signals decoding example
 *
 * Copyright (C) 2015 Analog Devices Inc.
 *
 **/

#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <signal.h>
#include <stdio.h>
#include <iio.h>
#include <math.h>

#include "rtwtypes.h"
#include "DecodeBits_ADI_types.h"
#include "DecodeBits_ADI.h"
#include "DecodeBits_ADI_terminate.h"
#include "DecodeBits_ADI_initialize.h"

/* helper macros */
#define MHZ(x) ((long long)(x*1000000.0 + .5))
#define GHZ(x) ((long long)(x*1000000000.0 + .5))

/* RX is input, TX is output */
enum iodev { RX, TX };

/* common RX and TX streaming params */
struct stream_cfg {
	long long bw_hz; // Analog banwidth in Hz
	long long fs_hz; // Baseband sample rate in Hz
	long long lo_hz; // Local oscillator frequency in Hz
	const char* rfport; // Port name
	const char* agc_mode; // AGC mode - manual, slow_attack, fast_attack
};

/* static scratch mem for strings */
static char tmpstr[64];

/* IIO structs required for streaming */
static struct iio_context *ctx   = NULL;
static struct iio_channel *rx0_i = NULL;
static struct iio_channel *rx0_q = NULL;
static struct iio_buffer  *rxbuf = NULL;

/* cleanup and exit */
void shutdown(int s)
{
	printf("* Destroying buffers\n");
	if (rxbuf) { iio_buffer_destroy(rxbuf); }

	printf("* Disabling streaming channels\n");
	if (rx0_i) { iio_channel_disable(rx0_i); }
	if (rx0_q) { iio_channel_disable(rx0_q); }

	printf("* Destroying context\n");
	if (ctx) { iio_context_destroy(ctx); }
	exit(0);
}

/* check return value of attr_write function */
static void errchk(int v, const char* what) {
	 if (v < 0) { fprintf(stderr, "Error %d writing to channel \"%s\"\nvalue may not be supported.\n", v, what); shutdown(0); }
}

/* write attribute: long long int */
static void wr_ch_lli(struct iio_channel *chn, const char* what, long long val)
{
	errchk(iio_channel_attr_write_longlong(chn, what, val), what);
}

/* write attribute: string */
static void wr_ch_str(struct iio_channel *chn, const char* what, const char* str)
{
	errchk(iio_channel_attr_write(chn, what, str), what);
}

/* helper function generating channel names */
static char* get_ch_name(const char* type, int id)
{
	snprintf(tmpstr, sizeof(tmpstr), "%s%d", type, id);
	return tmpstr;
}

/* returns ad9361 phy device */
static struct iio_device* get_ad9361_phy(struct iio_context *ctx)
{
	struct iio_device *dev =  iio_context_find_device(ctx, "ad9361-phy");
	assert(dev && "No ad9361-phy found");
	return dev;
}

/* finds AD9361 streaming IIO devices */
static bool get_ad9361_stream_dev(struct iio_context *ctx, enum iodev d, struct iio_device **dev)
{
	switch (d) {
	case TX: *dev = iio_context_find_device(ctx, "cf-ad9361-dds-core-lpc"); return *dev != NULL;
	case RX: *dev = iio_context_find_device(ctx, "cf-ad9361-lpc");  return *dev != NULL;
	default: assert(0); return false;
	}
}

/* finds AD9361 streaming IIO channels */
static bool get_ad9361_stream_ch(struct iio_context *ctx, enum iodev d, struct iio_device *dev, int chid, struct iio_channel **chn)
{
	*chn = iio_device_find_channel(dev, get_ch_name("voltage", chid), d == TX);
	if (!*chn)
		*chn = iio_device_find_channel(dev, get_ch_name("altvoltage", chid), d == TX);
	return *chn != NULL;
}

/* finds AD9361 phy IIO configuration channel with id chid */
static bool get_phy_chan(struct iio_context *ctx, enum iodev d, int chid, struct iio_channel **chn)
{
	switch (d) {
	case RX: *chn = iio_device_find_channel(get_ad9361_phy(ctx), get_ch_name("voltage", chid), false); return *chn != NULL;
	case TX: *chn = iio_device_find_channel(get_ad9361_phy(ctx), get_ch_name("voltage", chid), true);  return *chn != NULL;
	default: assert(0); return false;
	}
}

/* finds AD9361 local oscillator IIO configuration channels */
static bool get_lo_chan(struct iio_context *ctx, enum iodev d, struct iio_channel **chn)
{
	switch (d) {
	 // LO chan is always output, i.e. true
	case RX: *chn = iio_device_find_channel(get_ad9361_phy(ctx), get_ch_name("altvoltage", 0), true); return *chn != NULL;
	case TX: *chn = iio_device_find_channel(get_ad9361_phy(ctx), get_ch_name("altvoltage", 1), true); return *chn != NULL;
	default: assert(0); return false;
	}
}

/* applies streaming configuration through IIO */
bool cfg_ad9361_streaming_ch(struct iio_context *ctx, struct stream_cfg *cfg, enum iodev type, int chid)
{
	struct iio_channel *chn = NULL;

	// Configure phy and lo channels
	printf("* Acquiring AD9361 phy channel %d\n", chid);
	if (!get_phy_chan(ctx, type, chid, &chn)) {	return false; }
	wr_ch_str(chn, "rf_port_select",     cfg->rfport);
	wr_ch_lli(chn, "rf_bandwidth",       cfg->bw_hz);
	wr_ch_lli(chn, "sampling_frequency", cfg->fs_hz);
	wr_ch_str(chn, "gain_control_mode",	 cfg->agc_mode);

	// Configure LO channel
	printf("* Acquiring AD9361 %s lo channel\n", type == TX ? "TX" : "RX");
	if (!get_lo_chan(ctx, type, &chn)) { return false; }
	wr_ch_lli(chn, "frequency", cfg->lo_hz);
	return true;
}

static void main_DecodeBits_ADI(boolean_T *bv0, double input_lat, double input_long)
{
	char type;
	double lng;
	double lat;
	double alt;
	double aV;
	double eV;
	double nV;
	double id[6];
	double speed;

	/* Initialize function 'DecodeBits_ADI' input arguments. */
	/* Initialize function input argument 'bits'. */
	/* Call the entry-point 'DecodeBits_ADI'. */
	DecodeBits_ADI(bv0, input_lat, input_long, 
					&nV, &eV, &aV, &alt,
					&lat, &lng, &type, id);
	speed = sqrt(eV*eV + nV*nV);					
	
	switch(type)
	{
		case 'A':
			printf("Aircraft ID: %x%x%x%x%x%x is travelling at %.6f knots\n", (int)id[0], (int)id[1], (int)id[2], (int)id[3], (int)id[4], (int)id[5], speed);
			printf("Direction %s at %f knots, direction %s at %f knots\n", 
					eV < 0 ? "West" : "Est", eV < 0 ? -eV : eV,
					nV < 0 ? "South" : "North", nV < 0 ? -nV : nV);
			
			printf("Aircraft ID: %x%x%x%x%x%x is going %s at %f feet/min\n\n", (int)id[0], (int)id[1], (int)id[2], (int)id[3], (int)id[4], (int)id[5],
					aV < 0 ? "Down" : "Up",
					aV < 0 ? -aV : aV);			
			break;
		case 'L':
			printf("Aircraft ID: %x%x%x%x%x%x is at altitude %d\n", (int)id[0], (int)id[1], (int)id[2], (int)id[3], (int)id[4], (int)id[5],
					(int)alt);
			
			printf("Aircraft ID: %x%x%x%x%x%x is at latitude %4.3f, longitude %4.3f\n\n", (int)id[0], (int)id[1], (int)id[2], (int)id[3], (int)id[4], (int)id[5],
					lat, lng);
			break;
	}
}

/* simple configuration and streaming */
int main (int argc, char **argv)
{
	// Current position coordinates
	double input_lat, input_long;
	
	// Streaming devices
	struct iio_device *rx;

	// Stream configurations
	struct stream_cfg rxcfg;

	// Listen to ctrl+c and assert
	signal(SIGINT, shutdown);

	// RX stream config
	rxcfg.bw_hz = MHZ(4.0);   		// RF bandwidth
	rxcfg.fs_hz = MHZ(12.5);  		// Rx sample rate
	rxcfg.lo_hz = GHZ(1.09);  		// LO frequency
	rxcfg.rfport = "A_BALANCED"; 	// Rx port selection
	rxcfg.agc_mode = "fast_attack";	// AGC mode

	// Get current position
	if(argc < 3)
	{
		printf("Not enough input arguments!\n");
		printf("Usage:\n    - adsb_decode latitude logitude\n");
		printf("    - where: latitude - current latitude in degrees (negative values for southern hemisphere) (example: 42.36 for Boston)\n");
		printf("    - where: longitude - current longitude in degrees (negative values for western hemisphere) (example: -71.06 for Boston)\n");
		printf("    - example: adsb_decode 42.36 -71.06\n");
		
		return 0;
	}
	else
	{
		sscanf(argv[1], "%lf", &input_lat); 
		sscanf(argv[2], "%lf", &input_long); 
	}	
	
	printf("* Acquiring IIO context\n");
	assert((ctx = iio_create_default_context()) && "No context");
	assert(iio_context_get_devices_count(ctx) > 0 && "No devices");

	printf("* Acquiring AD9361 streaming devices\n");
	assert(get_ad9361_stream_dev(ctx, RX, &rx) && "No rx dev found");

	printf("* Configuring AD9361 for streaming\n");
	assert(cfg_ad9361_streaming_ch(ctx, &rxcfg, RX, 0) && "RX port 0 not found");

	printf("* Initializing AD9361 IIO streaming channels\n");
	assert(get_ad9361_stream_ch(ctx, RX, rx, 0, &rx0_i) && "RX chan i not found");
	assert(get_ad9361_stream_ch(ctx, RX, rx, 1, &rx0_q) && "RX chan q not found");


	printf("* Enabling IIO streaming channels\n");
	iio_channel_enable(rx0_i);
	iio_channel_enable(rx0_q);


	printf("* Creating non-cyclic IIO buffers with 1 MiS\n");
	rxbuf = iio_device_create_buffer(rx, 4*1024*1024, false);


	printf("* Starting IO streaming (press CTRL+C to cancel)\n");

	// Initialize the ADS-B decoding
	DecodeBits_ADI_initialize();

	while (1)
	{
		ssize_t nbytes_rx;
		void *p_dat, *p_end;
		ptrdiff_t p_inc;

		static const int packet_length = 111;
		int idx = 0;
		int bit_idx = 0;
		boolean_T bv0[112];

		// Refill RX buffer
		nbytes_rx = iio_buffer_refill(rxbuf);
		if (nbytes_rx < 0) { printf("Error refilling buf %d\n",(int) nbytes_rx); shutdown(0); }

		// Process the data in the Rx buffer
		p_inc = iio_buffer_step(rxbuf);
		p_end = iio_buffer_end(rxbuf);
		for (p_dat = iio_buffer_first(rxbuf, rx0_i) + packet_length * p_inc, idx = 0; p_dat < p_end; p_dat += p_inc, idx += p_inc) 
		{
			// Find the frame valid marker
			if(((int16_t*)p_dat)[1] == 1)
			{
				// Copy the data frame from the Rx buffer into a temporary buffer
				for(bit_idx = packet_length; bit_idx > 0; bit_idx--)
				{
					bv0[bit_idx] = ((int16_t*)(p_dat - (packet_length-bit_idx) * p_inc))[0];
				}
				
				// Decode and display the ADS-B data
				main_DecodeBits_ADI(bv0, input_lat, input_long);
			}
		}
	}

	// Terminate the ADS-B decoding
	DecodeBits_ADI_terminate();

	shutdown(0);

	return 0;
}
