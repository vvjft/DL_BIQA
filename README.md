# Blind image quality assessment using deep neural networks
Evaluated images cannot always be compared with reference images. There is often a situation of  lack of reference images. In such cases, we evaluate the image based on, for example, sharpness, color  and contrast. For such evaluation, deep neural networks can also be used.

## Requirements
- Python 3.10
- TensorFlow 2.15
- other, listed in requirements.txt
  
For training and evaluation [LIVE](https://live.ece.utexas.edu/research/quality/subjective.htmtid2013) and [TID2013](https://www.ponomarenko.info/tid2013.htm) are used.

## Usage

1. Run `preprocessing.m` inside the directory where the LIVE dataset is stored.
2. Import the distorted_images folder into your working directory.
3. Run the CNNIQA or CNNIQA++ notebook. You can choose to use the dataset directly or perform cross-validation (use one part for training and the other for testing).

## References
TensorFlow implementations of the following papers:

[L. Kang, P. Ye, Y. Li and D. Doermann, "Convolutional Neural Networks for No-Reference Image Quality Assessment," 2014 IEEE Conference on Computer Vision and Pattern Recognition.](https://ieeexplore.ieee.org/document/6909620)

[L. Kang, P. Ye, Y. Li and D. Doermann, "Simultaneous estimation of image quality and distortion via multi-task convolutional neural networks," 2015 IEEE International Conference on Image Processing (ICIP).](https://ieeexplore.ieee.org/document/7351311)



