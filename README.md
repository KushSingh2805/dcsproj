# Performance Analysis of Geometrically Shaped High-Order QAM over 5G Wireless Channels

A MATLAB-based simulation study investigating the performance of **Geometrically Shaped High-Order Quadrature Amplitude Modulation (QAM)** over practical wireless channel conditions.

The project is based on the systematic geometric constellation shaping approach proposed by **Kurihara and Ochiai**, and extends the analysis from the original AWGN channel evaluation to **Rayleigh and Rician fading channels**.

---

## 📌 Overview

High-order QAM is widely used in modern wireless communication systems to achieve high spectral efficiency. However, conventional QAM uses uniformly spaced constellation points, which is not necessarily optimal for transmission over noisy channels.

**Geometric Constellation Shaping (GCS)** improves the achievable information rate by modifying the positions of constellation points while maintaining equal probability for the transmitted symbols.

The reference work by Kurihara and Ochiai proposes a systematic shaping method in which the entire constellation can be generated using a **single shaping parameter α** based on a truncated Gaussian distribution. The original study evaluates the method primarily over an **AWGN channel** and demonstrates improvements in achievable information rate and BER.

This project extends the investigation by evaluating geometrically shaped high-order QAM under:

* AWGN channel
* Rayleigh fading channel
* Rician fading channel

The performance of shaped and conventional QAM is compared for different modulation orders using **BER, SER, and EVM**.

---

## 🎯 Objectives

The main objectives of this project are:

1. Study conventional high-order QAM modulation.
2. Implement systematic geometric constellation shaping.
3. Generate shaped QAM constellations using the shaping parameter **α**.
4. Compare conventional and geometrically shaped constellations.
5. Simulate AWGN, Rayleigh, and Rician wireless channels.
6. Evaluate the effect of fading on shaped constellations.
7. Compare different modulation orders:

   * 64-QAM
   * 256-QAM
   * 1024-QAM
8. Analyze system performance using:

   * Bit Error Rate (BER)
   * Symbol Error Rate (SER)
   * Error Vector Magnitude (EVM)
9. Investigate how the effectiveness of geometric shaping changes with channel conditions and modulation order.

---

## 🔬 Research Motivation

The reference paper demonstrates that systematic geometric shaping can provide a performance advantage over standard uniformly spaced constellations while requiring only a low-complexity parameter optimization. The proposed constellation is generated using a truncated Gaussian distribution controlled by a single parameter α.

However, the reference work focuses its main coded-modulation performance evaluation on the **AWGN channel**.

Practical wireless systems experience fading due to multipath propagation and line-of-sight conditions. Therefore, this project investigates:

> **How does geometric constellation shaping perform when the communication channel is changed from AWGN to Rayleigh and Rician fading?**

This forms the central extension investigated in this project.

---

## 🧩 System Model

The overall simulation follows the communication chain:

```text
Random Bits
     ↓
Geometric Constellation Shaping
     ↓
QAM Mapping
     ↓
Wireless Channel
     ↓
Equalization
     ↓
QAM Demapping
     ↓
Recovered Bits
     ↓
BER / SER / EVM
     ↓
Performance Comparison
```

The same basic transmission framework is used for both conventional and geometrically shaped QAM so that their performance can be compared under equivalent simulation conditions.

---

## 📐 Geometric Constellation Shaping

The shaping method is based on modifying a Gaussian cumulative distribution function (CDF).

For an M-point PAM constellation, the tentative constellation points are generated according to:

$$
\hat{a}_k =
\operatorname{erf}^{-1}
\left[
\alpha
\left(
\frac{2k+1}{M}-1
\right)
\right]
$$

where:

* \(M\) = number of constellation points in one dimension
* \(k = 0,1,\ldots,M-1\)
* \(\alpha\) = geometric shaping parameter
* \(\operatorname{erf}^{-1}\) = inverse error function

The shaping parameter is related to the truncation level \(b\) through:

$$
\alpha = \operatorname{erf}(b)
$$

with:

$$
0 \leq \alpha \leq 1
$$

The generated constellation is subsequently normalized to satisfy the required average-energy constraint. This formulation allows the constellation to be generated systematically using a **single parameter**.

### Effect of α

The parameter α controls the amount of geometric shaping.

* **α → 0:** constellation approaches uniformly spaced standard QAM.
* **Increasing α:** constellation becomes increasingly Gaussian-like.
* **α → 1:** constellation approaches the Gaussian-like CDF-based design.

The reference paper shows that the optimum α depends on the target modulation and operating SNR rather than simply using α = 1.

---

## 📡 Channel Models

### 1. AWGN Channel

The AWGN channel is represented by:

$$
y = x+n
$$

where:

* \(x\) = transmitted signal
* \(n\) = additive white Gaussian noise
* \(y\) = received signal

AWGN provides the baseline against which the effects of fading can be evaluated.

---

### 2. Rayleigh Fading Channel

For Rayleigh fading, the received signal is modeled as:

$$
y = hx+n
$$

where \(h\) is a complex fading coefficient.

Rayleigh fading represents a multipath environment without a dominant line-of-sight component.

The project uses Rayleigh fading to investigate whether the shaping gains observed under AWGN remain effective when the signal experiences random amplitude and phase variations.

---

### 3. Rician Fading Channel

The Rician channel is also modeled as:

$$
y = hx+n
$$

but the channel coefficient contains a dominant line-of-sight component in addition to scattered components.

The Rician \(K\)-factor characterizes the relative strength of the line-of-sight component to the scattered component.

This allows the project to study channel conditions between severe multipath fading and a channel with a stronger direct propagation component.

---

## 🔄 Receiver Processing

For fading channels, the received signal contains both amplitude and phase distortion due to the channel coefficient.

Therefore, receiver-side equalization is applied before demapping.

The basic equalization concept is:

$$
\hat{x} = \frac{y}{h}
$$

for zero-forcing type equalization when the channel coefficient is known.

The equalized signal is subsequently passed to the QAM demapper to recover the transmitted symbols and bits.

The implementation can also incorporate **MMSE equalization** where applicable.

---

## 📊 Modulation Schemes

The project evaluates three high-order QAM formats:

| Modulation | Bits/Symbol | Points |
| ---------- | ----------: | -----: |
| 64-QAM     |           6 |     64 |
| 256-QAM    |           8 |    256 |
| 1024-QAM   |          10 |   1024 |

Higher-order QAM provides greater spectral efficiency but generally becomes more sensitive to noise and channel distortion.

The project therefore investigates whether geometric shaping provides a greater relative benefit as the modulation order increases.

---

## 📈 Performance Metrics

### Bit Error Rate — BER

BER measures the fraction of incorrectly detected bits:

$$
BER =
\frac{\text{Number of erroneous bits}}
{\text{Total number of transmitted bits}}
$$

BER is the primary measure used to evaluate the reliability of the communication system.

---

### Symbol Error Rate — SER

SER measures the fraction of incorrectly detected modulation symbols:

$$
SER =
\frac{\text{Number of erroneous symbols}}
{\text{Total number of transmitted symbols}}
$$

SER provides a symbol-level view of the system performance.

---

### Error Vector Magnitude — EVM

EVM measures the difference between the received/equalized constellation points and their ideal reference locations.

The RMS EVM is calculated as:

$$
EVM_{RMS} =
\sqrt{
\frac{\sum |x_{rx}-x_{ref}|^2}
{\sum |x_{ref}|^2}
}
$$

A lower EVM indicates that the received constellation is closer to the ideal reference constellation.

---

## 🧪 Experimental Comparison

The project compares:

### Constellation

* Conventional uniformly spaced QAM
* Geometrically shaped QAM

### Channels

* AWGN
* Rayleigh
* Rician

### Modulation Orders

* 64-QAM
* 256-QAM
* 1024-QAM

### Performance Measures

* BER
* SER
* EVM

This produces a systematic comparison of the effect of constellation shaping across different modulation orders and channel conditions.

---

## 📁 MATLAB Program Structure

The MATLAB implementation is organized into separate modules:

```text
├── main.m
│
├── generate_bits.m
│   └── Generates the random input bit sequence
│
├── shape_constellation.m
│   └── Generates the geometrically shaped constellation
│
├── channel_model.m
│   └── Implements AWGN, Rayleigh and Rician channels
│
├── equalize_demap.m
│   └── Performs channel equalization and symbol/bit demapping
│
├── compute_metrics.m
│   └── Calculates BER, SER and EVM
│
├── plot_results.m
│   └── Generates constellation and performance plots
│
└── results/
    ├── constellation_plots/
    ├── BER/
    ├── SER/
    └── EVM/
```

> The exact filenames may vary depending on the version of the MATLAB implementation included in this repository.

---

## ⚙️ Simulation Workflow

### Step 1 — Generate Bits

A random binary information sequence is generated.

### Step 2 — Generate Constellation

Two constellations are generated:

1. Standard QAM
2. Geometrically shaped QAM

The shaped constellation is generated using the α parameter.

### Step 3 — QAM Mapping

The generated bits are mapped onto the corresponding constellation points.

### Step 4 — Channel Transmission

The modulated signal is passed through one of the selected channel models:

```text
AWGN
Rayleigh
Rician
```

### Step 5 — Equalization

For fading channels, the received signal is equalized using the estimated/known channel coefficient.

### Step 6 — Demapping

The equalized signal is mapped back to the corresponding constellation symbols and bits.

### Step 7 — Metric Calculation

The transmitted and recovered data are compared to calculate:

* BER
* SER
* EVM

### Step 8 — Comparison

The performance curves of standard and shaped QAM are plotted against the relevant SNR/\(E_s/N_0\) values.

---

## 📊 Expected Analysis

The simulations are intended to answer the following questions:

1. Does geometric shaping improve BER compared with conventional QAM?
2. Does the shaping advantage observed under AWGN remain under Rayleigh fading?
3. How does Rician fading affect the shaping gain?
4. Does the shaping benefit increase with QAM order?
5. Which modulation order provides the best trade-off between spectral efficiency and reliability?
6. How does geometric shaping affect EVM?
7. Is the shaping gain consistent across different channel conditions?

---

## 🔍 Key Research Extension

The reference paper establishes systematic geometric shaping for high-order QAM and evaluates its performance primarily over AWGN channels. It demonstrates that the proposed approach can improve achievable information rate and BER while retaining a relatively low-complexity constellation design.

This project extends the investigation by introducing:

```text
Reference Work
      │
      ▼
Systematic Geometric Shaping
      │
      ▼
High-Order QAM
      │
      ▼
AWGN Channel
```

to:

```text
Systematic Geometric Shaping
             │
             ▼
       High-Order QAM
             │
      ┌──────┼──────┐
      ▼      ▼      ▼
    AWGN  Rayleigh Rician
      │      │      │
      └──────┼──────┘
             ▼
       BER / SER / EVM
             │
             ▼
     Performance Analysis
```

The focus is therefore not on proposing a new shaping equation, but on **evaluating the behavior of the systematic shaping approach under practical fading channel conditions**.

---

## 💻 Requirements

### Software

* MATLAB
* Communications Toolbox (if required by the implementation)

### Recommended MATLAB Environment

A recent MATLAB release is recommended for compatibility with modulation, channel, and communication-system functions.

---

## 🚀 Running the Simulation

1. Clone or download this repository.
2. Open the project directory in MATLAB.
3. Ensure all `.m` files are available in the MATLAB path.
4. Run:

```matlab
main
```

5. Select or configure:

   * Modulation order
   * Channel model
   * SNR range
   * Shaping parameter α
   * Number of transmitted bits/symbols
6. Run the simulation.
7. Examine the generated constellation, BER, SER, and EVM plots.

---

## 📌 Reference Paper

The project is based on:

**E. Kurihara and H. Ochiai**,
*"Design of Low-Complexity Coded Modulation Employing High-Order QAM With Systematic Geometric Constellation Shaping,"*
IEEE Open Journal of the Communications Society, Vol. 5, 2024.

DOI:

`10.1109/OJCOMS.2024.3421518`

The reference paper introduces the single-parameter truncated-Gaussian geometric shaping approach and evaluates high-order QAM, including 1024-QAM and 16384-QAM, over AWGN channels.

---

## 📚 Related Project Material

The accompanying project presentation describes the intended extension to **64-QAM, 256-QAM, and 1024-QAM** over **AWGN, Rayleigh, and Rician** channels, with BER, SER, and EVM used as the primary evaluation metrics.

---

## 👥 Authors

**Anish Deshpande**
**Kushagra Singh**

VIT — School of Electronics Engineering

Under the guidance of:

**Prof. T. Illavarasan**

---

## 📄 License / Attribution

This repository contains a MATLAB implementation and analysis based on the methodology described in the referenced research paper.

The original theoretical method is attributed to the authors of the reference work:

**Eito Kurihara and Hideki Ochiai.**

Please refer to the original publication for the complete mathematical derivations and theoretical analysis.

---

## ⭐ Summary

This project investigates the use of **geometric constellation shaping for high-order QAM in 5G-oriented wireless channel conditions**.

The study compares conventional and shaped QAM across multiple modulation orders and channel models, with the objective of determining how geometric shaping affects **BER, SER, and EVM** under AWGN, Rayleigh, and Rician fading.

The project provides a MATLAB-based framework for studying the relationship between:

**Constellation Geometry → Channel Conditions → Modulation Order → Receiver Performance**

