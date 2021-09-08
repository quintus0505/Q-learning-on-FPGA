onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib divisor_opt

do {wave.do}

view wave
view structure
view signals

do {divisor.udo}

run -all

quit -force
