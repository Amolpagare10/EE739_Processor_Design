# Out-of-Order Superscalar Processor 

This repository contains the Verilog implementation of a pipelined, out-of-order superscalar processor datapath. The design integrates a range of components including reservation stations, reorder buffer, unified register file, ALUs, load/store units, and more.

---

## 📁 Repository Structure

```
├── datapath.v
├── 1. Controller
│ └── controller.v
├── 2. Execution Pipeline
│ ├── alu.v
│ ├── alu_tb.v
│ ├── data_mem.v
│ ├── load_buffer.v
│ ├── load_buffer tb.v
│ ├── Isu.v
│ └── Isu_tb.v
├── 3. Fetch & Decode Stage
│ ├── IF_ID_combined.v
│ ├── a. Decode
│ │ ├── alu_handler.v
│ │ ├── branch_handler.v
│ │ ├── ID_Stage.v
│ │ ├── ID_tb.v
│ │ ├── jump_handler.v
│ │ ├── lm_sm_handler.v
│ │ ├── Isu_handler.v
│ │ └── sign_extender_6_16.v
│ ├── b. Fetch
│ │ ├── IF.v
│ │ └── IF_tb.v
│ └── c. IF_ID Reg
│ └── IF_ID_reg.v
├── 4. Register Files
│ ├── ARF.v
│ ├── ARF_tb.v
│ ├── RRF.v
│ ├── RRF_tb.v
│ └── combined_RF.v
├── 5. Reorder Buffer
│ ├── reorder_buffer.v
│ └── ROB_tb.v
├── 6. Reservation Station
│ └── reservation_station.v
├── 7. Writeback Stage
│ └── wb_stage.v
```


---

## 🚀 Overview

The datapath is designed to:

- Support **dual-issue** ALU and LSU pipelines.
- Schedule and dispatch instructions via **reservation stations**.
- Use a **unified register file** for physical register management (ARF + RRF).
- Commit instructions in-order via a **reorder buffer (ROB)**.
- Integrate **broadcast forwarding** for register value availability.
- Handle pipeline hazards via **controller-generated stall and flush signals**.

---

## 🔧 Top-Level I/O

### Inputs
- `clk`: System clock
- `rst`: Asynchronous reset
- `register_address [2:0]`: Architectural register address to inspect from outside

### Outputs
- `register_data [15:0]`: Value from ARF corresponding to the input address

---