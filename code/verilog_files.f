// =======================================================
// Verilog Source File List for a Single-Cycle CPU Project
// =======================================================

// --- Header/Definition Files ---
// It's good practice to list definition files first,
// as other files might `include` them.
ctrl_encode_def.v

// --- CPU Core Sub-modules ---
// These are the individual components instantiated inside the SCPU.
alu.v
ctrl.v
EXT.v
NPC.v
PC.v
RF.v

// --- Main CPU Core Module ---
// This module ties all the sub-modules above together.
SCPU.v

// --- System-Level Components ---
// These are components at the same level as the SCPU,
// instantiated by the top-level module.
dm.v
im.v

// --- Top-Level System Module ---
// This is the main "motherboard" module that connects
// the SCPU, dm, and im.
sccomp.v

// --- Testbench File ---
// The testbench should be listed last. While linters might see it,
// for synthesis, you would typically use a different file list
// that excludes the testbench.
sccomp_tb.v

//pipeline_cpu.v
pipeline_reg.v
if_id_reg.v
id_ex_reg.v
ex_mem_reg.v
comparator.v
