#!/bin/bash
sed -i "s:/media:/media$AUDIO_SUBFOLDER" "$PATH_PEGAZ_SERVICES/$1/radio.liq"
