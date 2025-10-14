transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/assignments/vhdl/arch_labs/lab3/registerfile.vhd}
vcom -93 -work work {D:/assignments/vhdl/arch_labs/lab3/register8bit.vhd}
vcom -93 -work work {D:/assignments/vhdl/arch_labs/lab3/DFF.vhd}

