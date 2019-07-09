# mathworks_tools
### Analog Devices, Inc. Board Support Packages

Scripts and tools created by ADI to be used with MATLAB and Simulink with ADI products.

License : [![License](https://img.shields.io/badge/license-LGPL2-blue.svg)](https://github.com/analogdevicesinc/MathWorks_tools/blob/master/COPYING.txt)
Latest Release : [![GitHub release](https://img.shields.io/github/release/analogdevicesinc/MathWorks_tools.svg)](https://github.com/analogdevicesinc/MathWorks_tools/releases/latest)
Downloads :  [![Github All Releases](https://img.shields.io/github/downloads/analogdevicesinc/MathWorks_tools/total.svg)](https://github.com/analogdevicesinc/MathWorks_tools/releases/latest)

As with many open source packages, we use [GitHub](https://github.com/analogdevicesinc/MathWorks_tools) to do develop and maintain the source, and [GitLab](https://GitLab.com/) for continuous integration.
  - If you want to just use MathWorks_tools, we suggest using the [latest release](https://github.com/analogdevicesinc/MathWorks_tools/releases/latest).
  - If you think you have found a bug in the release, or need a feature which isn't in the release, try the latest **untested** builds from the master branch.

| HDL Branch        | GitHub master status  | MATLAB Release |  Installer Package  |
|:-----------------------:|:---------------------:|:-------:|:-------------------:|
| 2018_R2                 | [![pipeline status](https://gitlab.com/tfcollins/MathWorks_tools/badges/master/pipeline.svg)](https://gitlab.com/tfcollins/MathWorks_tools/commits/master) | 2019a | <a href="https://gitlab.com/tfcollins/MathWorks_tools/-/jobs/artifacts/master/download?job=deploy"><img src="https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png" data-canonical-src="https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png" height="40" /></a>|

If you use it, and like it - please let us know. If you use it, and hate it - please let us know that too.

## Supported Tools and Releases

We provide support across two releases of MATLAB. This does not mean older releases will not work but they are not maintained. Currently supported tools are:
- Bug fixes only: MATLAB R2018b with Vivado 2017.4
- Bug fixes and new features: MATLAB R2019a with Vivado 2018.2

## Support and Documentation

All support questions should be posted in our [EngineerZone](https://ez.analog.com/linux-device-drivers/linux-software-drivers) forums. Documentation is included within the toolbox but additional documentation is avaible on the [ADI Wiki](https://wiki.analog.com/resources/eval/user-guides/matlab_bsp).

## Building & Installing

If you don't want to use the toolbox installers you can manually build the BSP. Should be a quick matter of `make build`:

```
rgetz@pinky:~/MathWorks_tools$ make -C CI/scripts/ build 
```

Then simply add the `hdl_wa_bsp` folder to your MATLAB path `addpath(genpath('hdl_wa_bsp'))`

