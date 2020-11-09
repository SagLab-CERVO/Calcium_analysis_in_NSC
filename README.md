# calcium_analysis
Code for analysis of Ca2+ activity in neural stem cells

## Details of the data:
The code is suitable for the analysis of somatic imaging data. 

Example is obtained by using wide-field fluorescent microscopy of GCaMP6s. Frquency is 1 frame per 30 s. 

## Features and methods included:

* manual ROI drawing for soma and background - manual background correction is most suitable for the data from slices with uneven background 

* peak detection - threshold based algorythm(during the first round mean value is determined and threshold is *mean+ n(2 by default) standart deviation*, peaks that are found after threshold application are deleted and mean+n*std is recalculated) repeated 3 times
* manual addition and removal of detected peaks in interactive window (see figure below for example)  

* the output parameters are mean **frequency** and **amplitude** of the calcium events

## Dependencies:
* Image processing toolbox
* Signal processing toolbox

![alt text](https://github.com/SagLab-CERVO/calcium_analysis/blob/main/examples/example_processing.png?raw=true)

![alt text](https://github.com/SagLab-CERVO/calcium_analysis/blob/main/examples/example_soma.png?raw=true)
