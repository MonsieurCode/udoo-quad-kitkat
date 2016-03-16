
#ifndef ANDROID_INCLUDE_IMX_CONFIG_VT1613_H
#define ANDROID_INCLUDE_IMX_CONFIG_VT1613_H

#include "audio_hardware.h"

static struct route_setting speaker_output_vt1613[] = {
    {
        .ctl_name = "Stereo Master Volume",
        .intval = 30,
    },
    {
        .ctl_name = "PCM Playback Volume",
        .intval = 30,
    },
    {
        .ctl_name = NULL,
    },
};

static struct route_setting hs_input_vt1613[] = {
    {
        .ctl_name = "MIC Recording Volume",
        .intval = 20,
    },
    {
        .ctl_name = "LINE Recording Volume",
        .intval = 20,
    },
    {
        .ctl_name = "AUX Recording Volume",
        .intval = 20,
    },
    {
        .ctl_name = NULL,
    },
};

static struct audio_card  vt1613_card = {
    .name = "vt1613-audio",
    .driver_name = "vt1613-audio",     //driver_name, which is used to scan the supported sound card.
    .supported_out_devices  = AUDIO_DEVICE_OUT_SPEAKER,
    .supported_in_devices   = AUDIO_DEVICE_IN_WIRED_HEADSET,
    .defaults            = NULL,
    .bt_output           = NULL,
    .speaker_output      = speaker_output_vt1613,
    .hs_output           = NULL,
    .earpiece_output     = NULL,
    .vx_hs_mic_input     = NULL,
    .mm_main_mic_input   = NULL,
    .vx_main_mic_input   = NULL,
    .mm_hs_mic_input     = hs_input_vt1613,
    .vx_bt_mic_input     = NULL,
    .mm_bt_mic_input     = NULL,
    .card                = 0,
    .out_rate            = 0,
    .out_channels        = 0,
    .out_format          = 0,
    .in_rate             = 0,
    .in_channels         = 0,
    .in_format           = 0,
};

#endif