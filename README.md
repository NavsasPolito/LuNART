# LuGRE Navigation Analysis and Reporting Tool (LuNART)
LuGRE Mission's tool developed by the Navigation Signal Analysis and Simulation (NavSAS) research group from Politecnico di Torino (Turin, Italy). Funded by Agenzia Spaziale Italiana (ASI).  
Copyright (c) 2025 NavSAS Group

This project includes scripts from third-party components:

- gps-measurement-tools (Copyright 2016 Google Inc.).  
  Licensed under the Apache License, Version 2.0.

- Borre, K., Akos, D. M., Bertelsen, N., Rinder, P., & Jensen, S. H. (2007). A software-defined GPS and Galileo receiver: a single-frequency approach. Boston, MA: Birkhäuser Boston.  
  Originally licensed under "GPLv2 or later" and redistributed here under the GNU General Public License, version 3 (GPLv3).

All modifications and newly written code by Simone Zocca, Alex Minetto, Andrea Nardin, Oliviero Vouch
are licensed under the GNU General Public License, version 3 (GPLv3).
See all licence texts in `licences/` for details.

## Getting started

> [!WARNING]
> The latest release of the **LuNART**, has been developed for screen resolutions of 1920x1080. Resizing of the window is supported but it is not tested on multiple displays with different resolutions. In case of issues related to the screen size, please, move the **LuNART** main window manually if possible.

## Standalone LuNART application

> [!WARNING]
> The standalone version of **LuNART** is not available with the initial public release, we are working onit and hope to release it soon. 

It can be executed by launching the .exe file within the folder with administrator privileges. Running the executable is possible only if MATLAB Runtime v9.14 (2023b) is already installed on your PC. The folder contains specific files that enable the use of the packaged application on the target platform with the target language.

### Installation instructions

- [ ] Download and install the MATLAB Runtime Installer version 9.14 (2023b) from the MathWorks official website at the [link](https://it.mathworks.com/products/compiler/matlab-runtime.html). LuNART must operate under MATLAB Runtime Version R2023a (9.14)
- [ ] Download and install MS Word and Adobe Acrobat Reader to support automated report generation
- [ ] Execute the LuNART.exe file with administrator privileges

## Release history

### **[Current] Build v1.0 (17/10/2025)** - First open source release
* This version of LuNART is based on the tool developed for and used during the LuGRE mission. 
* It implements 9 experiments (of which 6 on raw measurements, 2 on PVT, and 1 on IQS), some of which contain operator-defined settings.
* Each experiment can automatically save all figures and generate a report.
* Multiple reports of the same operation window can be combined into an Operation Summary Report (OSR).
* Data from the LuGRE mission is not contained in this repository and needs to be downloaded separately.

## LuNART guide

Below is a list of instructions on how to operate LuNART. Please note that the application also contains tooltips to help you.

### 0. LuNART Setup 

Upon launching the tool for the first time, the user is presented with the application's GUI. The tool consists of three main tabs:

- **"Configuration"**: Allows the operator to set all necessary settings and information required to execute experiments. By default, the tool opens on this tab.
- **"Scientific Experiment"**: Operators can run various experiments and generate corresponding reports.
- **"Operation Summary Report"**: Operators can create an Operation Summary Report (OSR) from the reports generated during the scientific experiments.

Before starting to process LuGRE data, the user should provide valid input and output folders: 
- **"Input folder"** should be set as the root of the folder containing LuGRE data. Please note that the folder structure and file names **must not** be changed, otherwise the LuNART will not be able to locate the files correctly. Also, this folder should be on your machine and not on external drives.
- **"Output folder"** can be any existing folder where the operator has writing permission. This will be used as the root folder to save all results.

Once the user has selected valid folders, the lamps will turn green and you can proceed to process the data. These folders will be remembered for future use and can be changed at any time.
*(Note: This process only checks wheter the folders exist and the operator has permission, it does NOT check if the input folder has the correct structure and file names.)*
Additionally, the operator name can be selected using a drop down from a list. This list can be edited from the "settings/config.txt" file, which also contains the input and output folder names.

### 1. Session Configuration

The **Configuration** tab is composed of two main sections:

1. **Load Operation Window** (left): This section is used for loading and parsing data. The operator can choose which operation window (OP) to process from the drop down list. Once an OP has been selected, its related metadata is displayed. These informations are read from the table of operation contained in the file "Ancillary/OPTABLE.csv" in the folder of LuGRE data. As such, metadata will display only if the correct root folder has been chosen as input and the files have not been renamed. To process the OP, click on the "Load Data" button at the bottom of the panel. A progress bar will appear while the tool is parsing and saving data. This process may take up to a few minutes, depending on the amount of data in that OP.
3. **Console Message and Tool Status** (right): This area displays console messages and the tool status, summarizing the state of various operations with lamps. Each relevant operation performed by the operator will display a message upon completion. The lamps at the bottom right signals whether the data has been parsed sucessfully. If either the telemetry or the IQS are present, then the operator can proceed to perform the scientific experiments.

### 2. Scientific Experiments

1. Select the science experiment of interest from the **Science Experiments** tab (e.g., Q1.a), which is available on the right side of the GUI.
2. Change the settings of the experiment, if any. Default values are chosen in order to yield reasonable results for most cases.  
3. Press **Run Experiment** button. The associated lamp will turn yellow during excecution. 
4. Wait until the figures and output data are generated, and the experiment lamp turns green.  
5. The operator may press **Save Results** button to save the output of the experiment locally on the machine. The folder where the data is saved is displayed on the log panel in the bottom left corner. 
	- *Once results are saved, the **Run counter** at the top right of the page increases by one. This counter tracks how many times the results of a given experiment have been saved for that OP.*
6. If desired, the operator can include comments on the results in the dedicated **Operator Comment** box, which will be included in the report.
7. If desired, proceed to generate a report for the current experiment by pressing the **Generate Report** button.
	- *(Note: Once you click Generate Report, MS Word will automatically open and close. Wait for the PDF editor to open.)*
	- *(Note: Figures are included in the report with the same graphic settings as they were when the **Save Results** button was pressed. To ensure the figures appear as desired in the report, make any necessary changes before saving.)*
8. Prior to the report generation, flag options are shown in a dialogue box. Operator can select:
    - **Include in the Operation Summary Report (OSR)** if the current experiments should be included in the final report of the current operation
    - **Requiring RSPC troubleshooting** if the experiment shows unexpected/unwanted behaviour
    - **Worth of extended analysis** if the results are scientifically interesting and deserves in-depth inspection 
11. Once an experiment has been completed at least once, the corresponding lamp on the right of the tab group will turn green to remind the operator of its progress on the current OP.


### 3. Operation Summary Report (OSR) 

1. All the reports marked with **Include in the OSR** are shown in the **Operation Summary Report** tab.
2. In order to prepare the OSR for the current OP, select the desired reports from the lists (no more than one per experiment).
   - To **view the document** click on the button with lens icon
   - To **remove the document** from the list (list cleaning), press trash bin button. This action does not delete the document, it only allows for a clearer view
   - To **include the document** into the OSR, press the button with plus icon. This action adds the selected QER to the OSR by also showing the filename in the bottom panel.
5. The lists of available reports in the tab can be modified anytime and restored by pressing **Restore lists**
6. An additional operator comment can be included in the dedicated box of the GUI. Reports can be still excluded from the OSR by acting on the corresponding check-boxes.
7. Press the **Generate OSR** button to create the summary report.


### 4. Operation and operator switch

Once the operator has finished working on a given OP, it may click on the **Reset Settion** button on the bottom right of the **Configuration** page. This allows to change the operator and/or start the processing of another OP. Please note that this is equivalent to closing and re-opening the LuNART.



## MATLAB version and toolboxes

> [!NOTE]
> In order to run the **LuNaRT** on your system, we suggest to install **MATLAB 2023a** or more recent releases and the following toolboxes.

### Toolboxes dependencies

- [ ] Signal Processing Toolbox  
- [ ] Statistics and Machine Learning Toolbox  
- [ ] Aerospace Toolbox  
- [ ] MATLAB Report Generator



