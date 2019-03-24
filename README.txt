The final working codes are in the folder - final_codes

DepthMap.m -- implements qualitative DepthMap and calls geometric_depthMap function and at the end returns the final depthmap

geometric_depthMap.m  -- finds the geometric Depthmap of the given rgb image

Ms.m --- calls the MeanShiftCluster function and assign the values of the centroids to all the data present in its respective clusters

MeanShiftCluster.m -- implements Mean Shift Clustering Algorithm

VO.m  --- finds the Geometric Depthmap for those images which are classified as outdoor without geometric elements

To Run the code:

final_depthMap = DepthMap(filename);  where filename is the image filename


Link to input images and output images : 

https://drive.google.com/drive/folders/12GHrCV6ORsIqnvTKefukMqEKVbmpsqyC?usp=sharing
