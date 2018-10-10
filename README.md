# mathworks_tools: 
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
| 2018_R1                 | [![pipeline status](https://gitlab.com/tfcollins/MathWorks_tools/badges/master/pipeline.svg)](https://gitlab.com/tfcollins/MathWorks_tools/commits/master) | 2018b | [![Latest Windows installer](https://raw.githubusercontent.com/wiki/analogdevicesinc/libiio/img/win_box.png)](https://gitlab.com/tfcollins/MathWorks_tools/-/jobs/artifacts/master/download?job=deploy) |

If you use it, and like it - please let us know. If you use it, and hate it - please let us know that too.


## Building & Installing

should be a quick matter of `make build`:

```
rgetz@pinky:~/MathWorks_tools$ make -C CI/scripts/ build 
```

Then simply add the `hdl_wa_bsp` folder to your MATLAB path `addpath(genpath('hdl_wa_bsp'))`

