# simulate.do
vlib work
vmap work work

# Compile source files in correct order
vcom src/elevator_pkg.vhd
vcom src/clock_div.vhd
vcom src/request_resolver.vhd
vcom src/unit_control.vhd
vcom src/binary_to_ssd.vhd
vcom src/ssd.vhd
vcom src/elevator_ctrl.vhd
vcom tb/elevator_ctrl_tb.vhd

# Launch simulation
vsim work.elevator_ctrl_tb

# Add all signals to waveform
add wave -r /*

# Run simulation for 200 seconds of virtual time
run 200 sec
