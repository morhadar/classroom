# %%
import numpy as np
from scipy import ndimage
import matplotlib.pyplot as plt

##
a = np.zeros((20,20))
a[5:15,5:15] = 1
b = a.copy()
b = ndimage.rotate(b, 45, reshape=False)
b[b>0.5] = 1
b[b<0.5] = 0
# plt.matshow(a)
# plt.matshow(b)

a = a.astype('bool')
b = b.astype('bool')
def iou(a, b):
    "intersection over union for 2 classes only."
    intersection = (a & b).sum()
    union = a.sum() + b.sum() - intersection
    return intersection/union

def f1_score(a,b):
    "aka Dice coefficient"
    twos_intersection = 2* (a & b).sum()
    all = a.sum() + b.sum()
    return twos_intersection/all

print(f' iou= {iou(a,b)}')
print(f' f1= {f1_score(a,b)}')

#%% #! resources:
# https://tomkwok.com/posts/iou-vs-f1/
# https://stats.stackexchange.com/questions/273537/f1-dice-score-vs-iou/276144#276144 
# https://ilmonteux.github.io/2019/05/10/segmentation-metrics.html
