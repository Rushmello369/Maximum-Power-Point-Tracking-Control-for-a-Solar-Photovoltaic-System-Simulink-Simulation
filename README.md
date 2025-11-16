# Maximum Power-Point-Tracking Control for a Solar Photovoltaic System Simulink Simulation

## Objectives

This project aims to design and implement an MPPT (Maximum Power Point Tracking) algorithm from scratch to optimize the power output of a solar photovoltaic (PV) system under varying environmental conditions, and learn essential engineering skillset along the way. 

## Folder Structure
/MPPT-Solar-Simulation

│

├─ models/      # Simulink models (.slx)

├─ images/      # project screenshots

│

├─ design_report.md

├─ .gitignore

└─ README.md

## Motivation

As the world transitions to renewable energy, power electronics plays a critical role in energy conversion and grid integration. MPPT controllers are essential in solar power systems, ensuring maximum utilization of solar irradiance.

As a second year student at Imperial college, this project could build up foundamental power electronic skills including:

 Power electronics simulation
 Renewable energy system analysis
 Control algorithms implementation
 Practical grid engineering relevance

## Features & Scope

 -Photovoltaic cell model based on industry I–V characteristics
 
 -DC-DC Boost Converter with PWM switching
 
 -MPPT control using Perturb & Observe algorithm
 
 -Simulation under changing:

• Irradiance

• Temperature
 
 -Data visualization of power tracking performance
 
 -Efficiency comparison of operation with and without MPPT

## Tools & Knowledge

Software: MATLAB + Simulink (no hardware required)

Power Electronics	Boost converter design, switching devices

Control Systems	MPPT feedback algorithm

Renewable Energy	PV electrical modeling

Simulation	Component modeling & waveform analysis
## Environment Setup

To run the simulations and scripts in this project, you will need the following software installed.

### 1. Software Prerequisites

* **MATLAB & Simulink (Version R2023a or newer is recommended)**
* **Git** for version control

### 2. Required MATLAB Toolboxes

This project relies on specific toolboxes for modeling power electronics. Please ensure you have the following installed:

* **Simulink®** (Core environment)
* **Simscape Electrical™** (Essential for PV array, converters, and other physical electrical components)

### 3. Clone the Repository

Open your terminal or command prompt.
Navigate to the directory where you want to store your project.
Clone this repository using the following command:
       
```bash
git clone [https://github.com/YourUsername/MPPT-Solar-Simulation.git](https://github.com/YourUsername/MPPT-Solar-Simulation.git)
cd MPPT-Solar-Simulation
```

### 4. Verify Your Environment

You can check if you have the correct toolboxes installed by running the following command in the MATLAB Command Window:

```matlab
ver
```

## Project Structure
Stage	Description	Deliverable
 Research	Learn PV modeling & MPPT algorithms	System design report
 System Modeling	Build PV + DC-DC converter in Simulink	Functional simulation
 MPPT Controller	Implement P&O control	Working module with plots
 Dynamic Testing	Apply environment changes	Performance data & graphs
 Documentation	README + Report + GitHub Repo	Publishable portfolio project
## Expected Outcomes

 Achieve maximum power point operation
 Demonstrate controller response to real-world variations
 Visualize efficiency improvement
