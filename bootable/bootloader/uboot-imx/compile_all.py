#! /bin/python

import sys
import os
import string
import subprocess
import hashlib
import getpass
import time
import uuid
import shutil


type_os_android	= "ANDROID"

type_Qseven   = "QSEVEN"
type_uQseven  = "UQSEVEN"
type_uSBC     = "uSBC"

type_cpu_q   = "QUAD"
type_cpu_dl  = "DUAL_LITE"
type_cpu_s   = "SOLO"

type_ram_dd3   = 0
type_ram_lddr  = 1

size_ram_256x2  = 0  # 512M,  bus size 32, active CS = 1 (256Mx2)
size_ram_512x2  = 1  # 1Giga, bus size 32, active CS = 1 (512Mx2)
size_ram_256x4  = 2  # 1Giga, bus size 64, active CS = 1 (256Mx4)
size_ram_512x4  = 3  # 2Giga, bus size 64, active CS = 1 (512Mx4)
size_ram_512x8  = 4  # 4Giga, bus size 64, active CS = 2 (512Mx8) - for QSEVEN only

env_MMC   = "MMC"
env_SATA  = "SATA"
env_SPI   = "SPI" 

opt_uart = ''
opt_rtc  = ''


CONFS =[[type_Qseven, type_cpu_q, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_Qseven, type_cpu_q, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_Qseven, type_cpu_q, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_Qseven, type_cpu_q, size_ram_512x8, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_Qseven, type_cpu_dl, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_Qseven, type_cpu_dl, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_Qseven, type_cpu_dl, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_Qseven, type_cpu_dl, size_ram_512x8, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_Qseven, type_cpu_s, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_Qseven, type_cpu_s, size_ram_512x2, env_MMC, opt_uart, opt_rtc, type_os_android],
	

	[type_uQseven, type_cpu_q, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_uQseven, type_cpu_q, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_uQseven, type_cpu_q, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_uQseven, type_cpu_dl, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uQseven, type_cpu_dl, size_ram_512x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uQseven, type_cpu_dl, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uQseven, type_cpu_dl, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_uQseven, type_cpu_s, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uQseven, type_cpu_s, size_ram_512x2, env_MMC, opt_uart, opt_rtc, type_os_android],


	[type_uSBC, type_cpu_q, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_uSBC, type_cpu_q, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
	[type_uSBC, type_cpu_q, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_uSBC, type_cpu_dl, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uSBC, type_cpu_dl, size_ram_256x4, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uSBC, type_cpu_dl, size_ram_512x4, env_MMC, opt_uart, opt_rtc, type_os_android],

	[type_uSBC, type_cpu_s, size_ram_256x2, env_MMC, opt_uart, opt_rtc, type_os_android],
        [type_uSBC, type_cpu_s, size_ram_512x2, env_MMC, opt_uart, opt_rtc, type_os_android],

]


def genUUID ():
        return str(uuid.uuid4())


def createUUIDfolder (root):
        exists = True
        while (exists == True):
                name = genUUID ()
                if not os.path.exists(os.path.join(root, name)):
                        os.makedirs(os.path.join(root, name))
                        exists = False
        return os.path.join(root, name)


def createfolder (root, fname):
	if os.path.exists(os.path.join(root, fname)):
		shutil.rmtree(os.path.join(root, fname))		
        os.makedirs(os.path.join(root, fname))
        return os.path.join(root, fname)
	

def copyFile (src, dest):
        if (isFileValid (src) != 0):
                return 0
        if (isDir (dest)):
                dest_file = os.path.join (dest, GetFileName(src))
        else:
                dest_file = dest
        shutil.copyfile(src, dest_file)
        subprocess.Popen (['sync'], stdout=subprocess.PIPE)
        return 1



FOLDER_BOARD = ['928-Q7', '962-uQ7', '984-uSBC']
FOLDER_CPU   = ['QUAD', 'DL', 'SOLO']


curr_folder = os.getcwd()
#folder = createUUIDfolder (os.path.join(curr_folder, '../'))
folder = createfolder (os.path.join(curr_folder, './'), 'uboot_binaries')
for fboard in FOLDER_BOARD:
	fb = createfolder (folder, fboard)
	for cfolder in FOLDER_CPU:
		fc = createfolder (fb, cfolder)


compilation = 0

for conf in CONFS:
	print ''
	DDR_SIZE    = conf[2]
	BOARD_TYPE  = conf[0]
	CPU_TYPE    = conf[1]
	ENV_DEVICE  = conf[3]
	OPT_UART    = conf[4]
	OPT_RTC     = conf[5]
	OS_TYPE     = conf[6]
	compilation = compilation + 1

	print ('\n\n\n=============================================================');
	print ('=============================================================');
	print ('    compilation %d of %d'% (compilation, len(CONFS)))
	print conf
	print ('=============================================================');
	print ('=============================================================');
	
	fb = ''
	fc = ''
	
	if (BOARD_TYPE == type_Qseven):
		fb = FOLDER_BOARD[0]	
	if (BOARD_TYPE == type_uQseven):
		fb = FOLDER_BOARD[1]	
	if (BOARD_TYPE == type_uSBC):
		fb = FOLDER_BOARD[2]	
	
	if (CPU_TYPE == type_cpu_q):
		fc = FOLDER_CPU[0]
	if (CPU_TYPE == type_cpu_dl):
		fc = FOLDER_CPU[1]
	if (CPU_TYPE == type_cpu_s):
		fc = FOLDER_CPU[2]

	f = os.path.join (os.path.join (folder, fb), fc)
	
	comp = subprocess.Popen (["./compile_serial.sh", str(DDR_SIZE), BOARD_TYPE, CPU_TYPE, ENV_DEVICE, OPT_UART, OPT_RTC, OS_TYPE, f])
	print comp.communicate()[0]

	


	



