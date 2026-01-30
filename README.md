# Goodix 55b4 Fingerprint Driver for Ubuntu 25.10 / Zorin OS 18 

An automated installer to enable the Goodix `27c6:55b4` fingerprint sensor on Zorin OS 18, Ubuntu 24.04, and related distributions.

This script automates the process of:
1. Installing dependencies (including `opencv`, `meson`, `python-periphery`).
2. Flashing the modified TLS firmware to the sensor.
3. Compiling the patched `libfprint` driver (from `TheWeirdDev`, branch `55b4-experimental`).
4. Linking the driver correctly for the OS to detect it.

## ⚠️ Requirements & Warnings
* **Device:** Goodix Fingerprint Reader (ID `27c6:55b4`).
* **OS:** Zorin OS 18 or Ubuntu 25.10.
* **Dual Boot Warning:** If you have Windows installed, **disable the fingerprint device in Windows Device Manager** before using this. Windows may try to overwrite the firmware, breaking the Linux driver.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/goodix-55b4-zorin.git](https://github.com/YOUR_USERNAME/goodix-55b4-zorin.git)
    cd goodix-55b4-zorin
    ```

2.  **Run the installer:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Follow the prompts.** When the script finishes, enroll your finger:
    The script might seem to be stuck at some point but you just have to touch the fingerprint scanner to let it clip your scan.
    ```bash
    fprintd-enroll
    ```

5.  **Enable Login:**
    Run `sudo pam-auth-update`, select "Fingerprint authentication" with the Spacebar, and press Enter.

## Credits
* **Driver:** [TheWeirdDev/libfprint](https://github.com/TheWeirdDev/libfprint)
* **Firmware Tool:** [mpi3d/goodix-fp-dump](https://github.com/mpi3d/goodix-fp-dump)
