/******************************************************************************
 *
 * Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xscugic.h"

XScuGic InterruptController; /* Instance of the Interrupt Controller */
static XScuGic_Config *GicConfig; /* The configuration parameters of the
 controller */
void DeviceDriverHandler(void *CallbackRef);

/*
 * Create a shared variable to be used by the main thread of processing and
 * the interrupt processing
 */
volatile int InterruptProcessed = FALSE;

int main() {
	init_platform();
	int Status;

	u32 data;

	print("Hello World\n\r");

	GicConfig = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, GicConfig,
			GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly
	 */
	Status = XScuGic_SelfTest(&InterruptController);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	print("self test passed\n\r");

	XScuGic_SetPriorityTriggerType(&InterruptController, XPAR_FABRIC_UART_REG_0_IRQREQ_INTR, 0xA0, 0x3);

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler performs
	 * the specific interrupt processing for the device
	 */
	Status = XScuGic_Connect(&InterruptController, XPAR_FABRIC_UART_REG_0_IRQREQ_INTR,
			(Xil_ExceptionHandler) DeviceDriverHandler,
			(void *) &InterruptController);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	print("connection passed\n\r");
	/*
	 * Enable the interrupt for the device and then cause (simulate) an
	 * interrupt so the handlers will be called
	 */
	XScuGic_Enable(&InterruptController, XPAR_FABRIC_UART_REG_0_IRQREQ_INTR);

	print("enabled\n\r");


	print("interrupt enabled \n\r");
	/*
	 * Initialize the exception table and register the interrupt
	 * controller handler with the exception table
	 */
	Xil_ExceptionInit();

	/*
	 * Setup the Interrupt System
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			&InterruptController);

	/*
	 * Enable interrupts in the ARM
	 */
	Xil_ExceptionEnable();

	data = 0;
	Xil_Out32(XPAR_UART_REG_0_BASEADDR + 0x00, data);
	xil_printf("init status reg \t %08x\r\n", data);

	data = Xil_In32(XPAR_UART_REG_0_BASEADDR);
	xil_printf("status reg \t %08x \r\n", data);

	data = 0xff;
	Xil_Out32(XPAR_UART_REG_0_BASEADDR + 0x04, data);
	xil_printf("write TDR reg \t %08x\r\n", data);

	data = 0;
	data = Xil_In32(XPAR_UART_REG_0_BASEADDR + 0x00);
	xil_printf("read status reg \t %08x\r\n", data);

	data = 0x01;
	Xil_Out32(XPAR_UART_REG_0_BASEADDR, data);
	xil_printf("Enable status reg \t %08x\r\n", data);

	data = 0;
	data = Xil_In32(XPAR_UART_REG_0_BASEADDR + 0x00);
	xil_printf("read status reg \t %08x\r\n", data);

	data = Xil_In32(XPAR_UART_REG_0_BASEADDR);
	xil_printf("status reg \t %08x \r\n", data);

	data = 0;
	data = Xil_In32(XPAR_UART_REG_0_BASEADDR + 0x08);
	xil_printf("RDR reg \t %08x\r\n", data);

	while (1) {
		if (InterruptProcessed) {
			InterruptProcessed = FALSE;
			data = 0;
			data = Xil_In32(XPAR_UART_REG_0_BASEADDR + 0x08);
			xil_printf("RDR reg \t %08x\r\n", data);
			data = rand() % 0xff;
			Xil_Out32(XPAR_UART_REG_0_BASEADDR + 0x04, data);
			xil_printf("write TDR reg \t %08x\r\n", data);
		}
	}

	cleanup_platform();
	return 0;
}

void DeviceDriverHandler(void *CallbackRef) {
	int IntIDFull;
	/*
	 * Indicate the interrupt has been processed using a shared variable
	 */

	print("handler called!\n\r");
	InterruptProcessed = TRUE;

	IntIDFull = XScuGic_CPUReadReg(&InterruptController,
			XSCUGIC_INT_ACK_OFFSET);
	XScuGic_CPUWriteReg(&InterruptController, XSCUGIC_EOI_OFFSET, IntIDFull);
}
