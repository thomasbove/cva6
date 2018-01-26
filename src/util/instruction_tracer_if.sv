// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 16.05.2017
// Description: Instruction Tracer Interface

import ariane_pkg::*;
`ifndef INSTR_TRACER_IF_SV
`define INSTR_TRACER_IF_SV
interface instruction_tracer_if (
        input clk
    );
    logic              rstn;
    logic              flush_unissued;
    logic              flush;
    // Decode
    logic [31:0]       instruction;
    logic              fetch_valid;
    logic              fetch_ack;
    // Issue stage
    logic              issue_ack; // issue acknowledged
    scoreboard_entry_t issue_sbe; // issue scoreboard entry
    // WB stage
    logic [4:0]        waddr;
    logic [63:0]       wdata;
    logic              we;
    // commit stage
    scoreboard_entry_t commit_instr; // commit instruction
    logic              commit_ack;

    // address translation
    // stores
    logic              st_valid;
    logic [63:0]       st_paddr;
    // loads
    logic              ld_valid;
    logic              ld_kill;
    logic [63:0]       ld_paddr;

    // exceptions
    exception_t        exception;
    // current privilege level
    priv_lvl_t         priv_lvl;
    // the tracer just has a passive interface we do not drive anything with it
    `ifndef SYNTHESIS
    clocking pck @(posedge clk);
        input rstn, flush_unissued, flush, instruction, fetch_valid, fetch_ack, issue_ack, issue_sbe, waddr,
              st_valid, st_paddr, ld_valid, ld_kill, ld_paddr,
              wdata, we, commit_instr, commit_ack, exception, priv_lvl;
    endclocking
    `endif

endinterface
`endif
