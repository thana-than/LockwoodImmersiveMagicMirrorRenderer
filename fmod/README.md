# FMOD-Template
Basic FMOD layout and structure for the games I make.

# Version
Uses [FMOD Studio 2.02.19](https://www.fmod.com/download#fmodstudio)

# Installation
Open a bash terminal your project folder and enter:
  ```sh
  git clone --depth=1 https://github.com/thana-than/FMOD-Template.git fmod && rm -rf fmod/.git && mv fmod/FMOD_Template.fspro "fmod/$(basename "$PWD").fspro"
  ```
## Breakdown:</br>
`git clone --depth=1 https://github.com/thana-than/FMOD-Template.git fmod`<br>
Clone the repository and name the subfolder as "fmod"<br>
<br>
`rm -rf fmod/.git`<br>
Remove the .git from this template's repository folder (prevents issues with parent repos)<br>
<br>
`mv fmod/FMOD_Template.fspro "fmod/$(basename "$PWD").fspro`<br>
Rename the base FMOD file to the working directories folder name.
