import cv2
import numpy as np

im =  cv2.transpose(np.reshape(np.arange(0,16,  dtype='uint8'), (4,4)))

out = cv2.resize(im, None, fx = 2, fy = 2, interpolation = cv2.INTER_LINEAR)