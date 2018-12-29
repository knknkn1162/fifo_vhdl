create_clock -name clk -period 20 [get_ports {clk}]
# Automatically apply a generate clock on the output of phase-locked loops (PLLs)
# This command can be safely left in the SDC even if no PLLs exist in the design
derive_pll_clocks
# calculate and apply setup and hold clock uncertainties for clock-to-clock transfers found in the design.
derive_clock_uncertainty
set_input_delay -clock {clk} 1 [all_inputs]
set_output_delay -clock {clk} 1 [all_outputs]
