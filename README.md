# calcium_analysis
Code for analysis of Ca2+ activity in neural stem cells

## Details of the data:
The code is suitable for the analysis of somatic imaging data. 

Example is obtained by using wide-field fluorescent microscopy of GCaMP6s. Frquency is 1 frame per 30 s. 

## Features and methods included:

* manual ROI drawing for soma and background - manual background correction is most suitable for the data from slices with uneven background 

* peak detection - threshold based algorythm(during the first round mean value is determined and threshold is *mean+ n(2 by default) standart deviation*, peaks that are found after threshold application are deleted and mean+n*std is recalculated) repeated 3 times

* the output parameters are mean **frequency** and **amplitude** of the calcium events

## Dependencies:
* Image processing toolbox
* Signal processing toolbox
