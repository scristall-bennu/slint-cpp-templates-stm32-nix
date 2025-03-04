# Slint MCU C++ Template with Nix

This repository is a fork of the [Slint MCU C++ Templates](https://github.com/slint-ui/slint-mcu-cpp-templates) with preliminary Nix Flakes support. This is not meant to work in NixOS specifically, but rather in any system that supports Nix Flakes.

## Prerequisites

The only prerequisite is a working Nix installation with flakes enabled.  Nix can be installed by following the instructions [here.](https://nixos.org/download/)

To enable flakes, follow the instructions [here.](https://nixos.wiki/wiki/Flakes).

## Usage

To start a nix shell, run the following command in the root of this repository:

```bash
nix develop
```

Then once inside the nix shell, you can build a project with the following example command (no need to install any dependencies, they will be automatically installed via nix):

```bash
cd stm32h735g-dk
cmake -B build
cmake --build build
```

# Slint MCU C++ Templates for STM32 Discovery Kits

This repository contains templates for different STM32 Discovery Kits to create C++ applications with Slint.

Each sub-directory corresponds to one supported board.

| Project                                          | STM32 Board                                                                      |
|--------------------------------------------------|----------------------------------------------------------------------------------|
| [stm32h747i-disco](./stm32h747i-disco/README.md) | [STM32H747I-DISCO](https://www.st.com/en/evaluation-tools/stm32h747i-disco.html): Dual-core Arm M7/M4 MCU with 4” touch LCD display module |
| [stm32h735g-dk](./stm32h735g-dk/README.md) | [STM32H735G-DK](https://www.st.com/en/evaluation-tools/stm32h735g-dk.html): Arm M7 MCU with 4” touch LCD display module |
