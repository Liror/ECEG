#!/bin/bash

source /cad/synopsys/2017-12/syn/setup.sh
dc_shell-xg-t -f compile.dc.sim.txt

rm -rf ARCH
rm -rf ENTI
rm *.svf
rm *.mr
rm *.syn
rm tmp.txt
rm command.log
