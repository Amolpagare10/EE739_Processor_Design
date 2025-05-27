# Out-of-Order Superscalar Processor Datapath

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

## 🧩 Key Modules and Responsibilities

### 🧠 Controller
Manages pipeline control signals:
- Generates stall/flush for fetch/decode
- Controls resume for scheduler and execution units

### 📦 IF_ID_combined
- Latches instruction pairs from IF to ID stage
- Extracts operands and registers for decoding

### 🗃 Reservation Station
- Holds instructions waiting for execution
- Tracks operand readiness and dispatches to ALU/LSU
- Receives broadcasts from completed instructions

### ⚙️ ALU / ALU Handler
- ALU performs arithmetic operations
- Handler decodes instructions, prepares operands, and controls signal lines

### 🧮 LSU (Load/Store Unit)
- Handles memory operations
- Interfaces with the unified register file and memory subsystem

### 🧾 Unified Register File (ARF + RRF)
- Tracks speculative results using register renaming
- Handles reads, writes, and broadcast from functional units
- Supports register forwarding via tags

### ✅ Reorder Buffer (ROB)
- Commits instructions in program order
- Updates ARF and frees RRF
- Ensures precise exception handling

### 🖋 Writeback Stage
- Final commit of values to ARF from RRF upon ROB commit
- Exposes ARF externally for register state inspection

---

## 🧪 Simulation and Testbench

This module is intended for integration in a larger CPU testbench. Suggested components to develop/test alongside:

- Memory model
- Instruction fetch frontend
- Branch predictor (if applicable)
- Testcases with sequences covering RAW, WAR, WAW hazards and dual-issue behavior

---

## 🛠 TODOs

- ✅ Dual ALU and LSU pipeline support
- ⬜ Implement memory subsystem (RAM)
- ⬜ Add support for branch prediction and speculative execution
- ⬜ Add testbench and waveform examples
- ⬜ Synthesize with FPGA constraints (optional)

---

## 📚 References

- [Tomasulo’s Algorithm](https://en.wikipedia.org/wiki/Tomasulo_algorithm)
- Computer Architecture: A Quantitative Approach – Hennessy & Patterson
- Out-of-Order Execution Lecture Slides from [MIT 6.004](https://ocw.mit.edu)

---

## 📜 License

MIT License

---

## 🤝 Contributions

Contributions are welcome! Please submit an issue or pull request with proposed changes, improvements, or bug fixes.

---
