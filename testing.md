## Introduction

### 1.1. The Context: The Need for Smart Renewables

The global transition towards decarbonized energy is a primary engineering challenge of our time. As utilities like National Grid work to achieve Net Zero, the integration of renewable energy sources, particularly Solar Photovoltaic (PV) systems, has become a top priority. However, unlike traditional power plants, the output from a solar panel is intermittent and highly dependent on environmental factors. This creates a complex problem: how do we extract the maximum possible energy from a source that is constantly changing?

### 1.2. The Problem: The Non-Linearity of Solar Panels

A solar panel is a non-linear device. Its power output is not fixed; it is a complex function of the solar irradiance (sunlight intensity) and the panel's own cell temperature.

For any given set of conditions, a PV panel has a "Power-Voltage" (P-V) curve that shows a single, distinct peak. This peak is the **Maximum Power Point (MPP)**.

* If the system draws too little voltage, power is lost.
* If the system draws too much voltage, power is lost.
* To make matters worse, this peak *moves*. When a cloud passes, the irradiance drops, and the entire P-V curve shifts, establishing a new, lower MPP.



A simple system that just connects a panel directly to a load would be extremely inefficient, as it would almost never be operating at this peak.

### 1.3. The Solution: Maximum Power Point Tracking (MPPT)

The engineering solution is to "decouple" the panel from the load using a **DC-DC power converter** (like a Boost or Buck-Boost converter). This converter acts as a variable "gearbox" for the electrical energy.

This system is governed by a control algorithm called **Maximum Power Point Tracking (MPPT)**. This algorithm is the "brain" that continuously:
1.  **Measures** the panel's current voltage and current.
2.  **Calculates** the current power.
3.  **Decides** how to change the converter's duty cycle to *search* for a higher power output.
4.  **Repeats** this process thousands of times per second to actively track the MPP, even as it moves.

### 1.4. Project Objective

This report details the design, simulation, and validation of a complete PV system with a closed-loop MPPT controller, built entirely within the **MATLAB & Simulink** environment.

The primary objective is to build a robust simulation that proves the effectiveness of the **Perturb and Observe (P&O)** algorithm—one of the most common and foundational MPPT techniques.

This project is broken down into four key phases, which this report will detail:
1.  **Component Modeling:** Building and testing the individual `PV Array` and `DC-DC Boost Converter` in Simscape Electrical.
2.  **Control Design:** Implementing the P&O logic in a MATLAB Function block and integrating it with the power electronics.
3.  **System Testing:** Validating the controller's performance under both steady-state and dynamic (variable irradiance) conditions.
4.  **Analysis:** Analyzing the results, including the key engineering trade-off between tracking speed and steady-state efficiency.
---
