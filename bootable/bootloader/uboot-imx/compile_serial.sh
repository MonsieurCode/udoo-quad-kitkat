#!/bin/bash

type_Qseven="QSEVEN"
type_uQseven="UQSEVEN"
type_uSBC="uSBC"

type_cpu_q="QUAD"
type_cpu_dl="DUAL_LITE"
type_cpu_s="SOLO"

type_os_linux="LINUX"
type_os_android="ANDROID"

CONFIG_FILE="./tools/sconfig"

env_MMC="MMC"
env_SATA="SATA"
env_SPI="SPI"

BACKTITLE='U-boot SECO config'

SELECTION=""
SEL_ITEM=1
SELECTION_COMP=""
SUBSEL=""
EXIT_RESPONCE=0
EXIT=0

# Default values
#MEM_SIZE=2
MEM_TYPE=1
#BOARD=${type_Qseven}
#CPU_TYPE=${type_cpu_q}
#OS_TYPE=${type_os_android}
#ENV_DEV=${env_MMC}
#CLEAN="CLEAN"
#EXTRA_UART=""
#RTC_LOW_POWER=""
COMPILER_PATH="$PWD/../../../prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-"
UBOOT_VER="imx6_seco"

SUFFIX=""



#################################################################
#																#
#						COMPILE FUNCTION						#
#																#
#################################################################

function check_mem_size () {
	echo ""
	if [ "${MEM_SIZE}" == "0" ]; then
		echo "RAM size selected: 512M,  bus size 32, active CS = 1 (256Mx2)"
		SUFFIX=${SUFFIX}-512MB
	elif [ "${MEM_SIZE}" == "1" ]; then
		echo "RAM size selected: 1Giga, bus size 32, active CS = 1 (512Mx2)"
		SUFFIX=${SUFFIX}-512MBx2
	elif [ "${MEM_SIZE}" == "2" ]; then
		echo "RAM size selected: 1Giga, bus size 64, active CS = 1 (256Mx4)"
		SUFFIX=${SUFFIX}-256MBx4
	elif [ "${MEM_SIZE}" == "3" ]; then
		echo "RAM size selected: 2Giga, bus size 64, active CS = 1 (512Mx4)"
		SUFFIX=${SUFFIX}-2GB
	elif [ "${MEM_SIZE}" == "4" ]; then
		echo "RAM size selected: 4Giga, bus size 64, active CS = 2 (512Mx8) - for QSEVEN only"
		SUFFIX=${SUFFIX}-4GB
	else
		echo "ERROR: wrong DDR size selected"
		exit 0
	fi
	echo ""
}

function check_board_type () {
	echo ""
	if [ "${BOARD}" == "${type_Qseven}" ]; then
		echo "Board type selected: Qseven module"
		SUFFIX=${SUFFIX}-Q7
	elif [ "${BOARD}" == "${type_uQseven}" ]; then
		echo "Board type selected: Micro Qseven module"
		SUFFIX=${SUFFIX}-uQ7
	elif [ "${BOARD}" == "${type_uSBC}" ]; then
                echo "Board type selected: Micro Single Board"
                SUFFIX=${SUFFIX}-uSBC
	else
		echo "ERROR: wrong board type selected"
		exit 0
	fi
	echo ""
}

function check_cpu_type () {
	echo ""
    if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
        echo "CPU Type: QUAD/DUAL"
		SUFFIX=${SUFFIX}-QD
    elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
        echo "CPU Type: DUAL LITE"
		SUFFIX=${SUFFIX}-DL
    elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
        echo "CPU Type: SOLO"
		SUFFIX=${SUFFIX}-S
    else
	    echo "ERROR: No CPU Type selected "
    fi
}

function check_os_type () {
	echo ""
    if [ "${OS_TYPE}" == "${type_os_linux}" ]; then
        echo "OS type: Linux"
		SUFFIX=${SUFFIX}-LNX
    elif [ "${OS_TYPE}" == "${type_os_android}" ]; then
        echo "OS type: Android"
		SUFFIX=${SUFFIX}-ADR
	else
		echo "ERROR: No OS Type selected "
	fi
}
		
function check_env_device_type () {
	echo ""
	if [ "${ENV_DEV}" == "${env_MMC}" ]; then
		echo "Environment selected: MMC"
	elif [ "${ENV_DEV}" == "${env_SATA}" ]; then
		echo "Environment selected: SATA"
	elif [ "${ENV_DEV}" == "${env_SPI}" ]; then
		echo "Environment selected: SPI"
	else
		echo "ERROR: wrong environment selected"
		exit 0
	fi
	echo  ""
}

function make_cpu_type () {
	echo ""
	    if [ "${CPU_TYPE}" == "${type_cpu_q}" ]; then
	        make mx6q_seco_q7_config  
	    elif [ "${CPU_TYPE}" == "${type_cpu_dl}" ]; then
	        make mx6dl_seco_q7_config 
	    elif [ "${CPU_TYPE}" == "${type_cpu_s}" ]; then
	        make mx6solo_seco_q7_config
	    fi
}

function check_compile_environment () {
	echo ""
	if [ "${ARCH}" == "" ]; then
		export ARCH=arm
	fi
	if [ "${CROSS_COMPILE}" == "" ]; then
		export CROSS_COMPILE=$COMPILER_PATH
	fi
}

function compile () {
	
	check_compile_environment

	SUFFIX=""	
	#N.B. don't change this calling order
	check_board_type	
	check_cpu_type
	check_os_type
	check_mem_size	
	check_env_device_type

	if [ "${EXTRA_UART}" == "EXTRA_UART" ]; then
		echo ""
		echo "Select the use of the EXTRA_UART"
		echo ""
	fi

	if [ "${CLEAN}" == "CLEAN" ]; then
		echo ""
		echo "Select Clean operation!"
		echo ""
		make distclean
		sleep 1
	fi
	
	if [ "${RTC_LOW_POWER}" == "RTC_LOW_POWER" ]; then
                echo ""
                echo "Select the use of the Low Power RTC"
                echo ""
        fi

	make_cpu_type
	
	SUFFIX=-imx6${SUFFIX}-${UBOOT_VER}
	echo ${SUFFIX} > ./tools/suffix
	sleep 2

	make -j20 DDR_SIZE=${MEM_SIZE} DDR_TYPE=${MEM_TYPE} BOARD_TYPE=${BOARD} CPU_TYPE=${CPU_TYPE} OS_TYPE=${OS_TYPE} ENV_DEVICE=ENV_${ENV_DEV} OPT_UART=${EXTRA_UART} OPT_RTC=${RTC_LOW_POWER} > /dev/null
#	cp u-boot.bin u-boot$(cat ./tools/suffix | awk '{print $1}')$(./tools/setlocalversion ./).bin
	cp u-boot.bin ${FOLDER}/u-boot$(cat ./tools/suffix | awk '{print $1}')$(./tools/setlocalversion ./).bin
	echo "Copy in " ${FOLDER}/u-boot$(cat ./tools/suffix | awk '{print $1}')$(./tools/setlocalversion ./).bin
}

#################################################################
#																#
#																#
#################################################################

MEM_SIZE=$1
BOARD=$2
CPU_TYPE=$3
ENV_DEV=$4
EXTRA_UART=$5
RTC_LOW_POWER=$6
OS_TYPE=$7
FOLDER=$8


compile

