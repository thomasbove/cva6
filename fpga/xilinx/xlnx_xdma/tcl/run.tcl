set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_xdma

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 -module_name $ipName

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
