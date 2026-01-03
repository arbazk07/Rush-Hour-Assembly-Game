# 🚖 Rush Hour Taxi (x86 Assembly)

> A high-performance console arcade game built entirely in **x86 Assembly Language** (MASM), featuring dynamic traffic, collision physics, and binary serialization.

## 🚀 Project Overview
This project demonstrates the power of low-level systems programming by implementing a real-time traffic simulation without the overhead of modern game engines. The game logic manages memory directly using register-based offsets (`ESI`/`EDI`) to simulate a 2D grid within a 1D linear array.

It was developed to master **Computer Organization** concepts, including stack management, hardware interrupts for sound, and direct console buffer manipulation.

## ⚙️ Technical Architecture
* **Language:** x86 Assembly (MASM Syntax)
* **Libraries:** Irvine32 (Win32 API Wrappers)
* **Memory Model:** Flat Memory Model (Protected Mode)
* **Rendering:** Direct Console Output (ASCII `254` blocks)

### Key Engineering Features
* **1. Linear Memory Mapping:**
The game board is a 1000-byte array (`boardMap`). To simulate 2D movement (X, Y), the engine calculates memory addresses manually using the formula:
`Address = Base + (Y * Width) + X`
* **2. Binary Persistence:**
Unlike text-based saves, this engine performs **Binary Dump Serialization**. It takes the entire memory block of variables and writes them directly to `savegame.bin`, allowing exact state restoration.
* **3. State Machine Logic:**
The `PlayGame` procedure acts as the main kernel, cycling through Input -> Logic -> Rendering -> Wait States at approximately 60Hz.

## 🎮 Game Mechanics
* **3 Game Modes:**
    * **Career:** Reach 500 points to win.
    * **Time Attack:** Race against a 60-second hardware timer.
    * **Endless:** An infinite survival gameplay.
* **Dynamic Traffic:** NPC cars spawn and move logically across the grid. They detect board boundaries and reverse direction autonomously.
* **Collision System:** Real-time checking of Player Index vs. Obstacle Index.
    * `Red Taxi`: High durability, slower speed.
    * `Yellow Taxi`: High speed, lower durability.

## 📂 File Structure
```text
RushHourTaxi/
├── main.asm          # The Core Engine (Logic, AI, Rendering)
├── savegame.bin      # Binary save file (Generated at runtime)
├── highscores.txt    # Leaderboard log (Generated at runtime)
└── Irvine32.inc      # Linker dependencies
```

## 🕹️ Controls

| Input Key | Command | Description |
| :--- | :--- | :--- |
| **Arrow Keys** | **Navigation** | Move the Taxi (Up, Down, Left, Right). |
| **'P' Key** | **Pause/Resume** | Freezes the game loop instantly. |
| **'S' Key** | **Quick Save** | Serializes board state & score to `savegame.bin`. |
| **Keys 1-6** | **Menu Select** | Used for navigating Game Modes and Difficulty. |

## 🏗️ How to Build & Run
 **Prerequisites**
* Visual Studio 2019/2022 (with C++ workload).
* MASM (Microsoft Macro Assembler).
* **Irvine32 Library:** Download from the Official Guide (https://asmirvine.com/gettingStartedVS2019/index.htm)

## Author

**Arbaz, BS Artificial Intelligence @ FAST NUCES**
