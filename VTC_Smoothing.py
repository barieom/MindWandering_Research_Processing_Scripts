# -*- coding: utf-8 -*-
"""
Created on Thu Jul 13 15:17:14 2017

@author: Barry
"""
#Opening the file
print("Opening file for smoothing...\n")
import os
workDir = 'C:/...../research/VTC Tables'
os.chdir(workDir)

subjID = input('Enter participant ID: ')

if not isinstance(subjID, str):
    subjID = str(subjID)
workFile = os.path.join(workDir, 'classified_study_codename_' + subjID + '_VTC_gender_task_data.csv')


#Will now attempt to read in the file
print("Reading in the normalized absolute deviance...\n")
with open(workFile, 'rb') as csvfile:
    import pandas as pd
    VTCtable = pd.read_csv(workFile)
    absoluteVTC = VTCtable.Absolute_RT_Variance


#Begin smoothing with kernel
print("Calculating sigma to full-width-half-maximum and setting basic precision values...\n")
import numpy as np
import matplotlib.pyplot as plt
np.set_printoptions(precision=4, suppress=True) # Make numpy print 4 significant digits for prettiness
np.random.seed(5) # To get predictable random numbers
def sigma2fwhm(sigma):
    return sigma * np.sqrt(8 * np.log(2))
def fwhm2sigma(fwhm):
    return fwhm / np.sqrt(8 * np.log(2))


sigma = 2
fwhm = sigma2fwhm(sigma)

x_vals = np.arange(0,len(absoluteVTC), 1)
y_vals = absoluteVTC
plt.bar(x_vals, y_vals)

#plt.bar(x_vals, y_vals)

#Smoothing each data point
print("Smoothing each data point with kernel now...\n")
smoothed_vals = np.zeros(y_vals.shape)
for i in range(len(absoluteVTC)):
    x_position = i
    kernel_at_pos = np.exp(-(x_vals - x_position) ** 2 / (2 *sigma ** 2))
    kernel_at_pos = kernel_at_pos / sum(kernel_at_pos)
    smoothed_vals[x_position] = sum(y_vals * kernel_at_pos)
 
plt.bar(x_vals, smoothed_vals)    
VTCtable['Smoothed_VTC_S2'] = smoothed_vals
print(VTCtable)

#Bin based on the smoothed absolute RT Variance median value
print("Binning based on the median value of the smoothed absolute RT variance")
print("Binning based on the median value of the smoothed absolute RT variance")
adjusted_bin = ["" for x in range(len(smoothed_vals))]
med = np.median(smoothed_vals)
print("Median of smoothed RT Variance: " + str(med))
for i in range(len(smoothed_vals)):
    if smoothed_vals[i] < med:
        adjusted_bin[i] = 'in-the-zone'
    elif smoothed_vals[i] > med:
        adjusted_bin[i] = 'out-of-the-zone'
    else:
        adjusted_bin[i] = 'median'
VTCtable['Adj_Zone_Val'] = adjusted_bin
print(VTCtable)

#Saving the file

print("Saving the files now...\n")
import csv
fileName = 'classified_study_codename_'+ subjID + '_VTC_gender_task_data.csv'

'''
with open(fileName, 'w') as csvfile:
    tabwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    [tabwriter.writerow(r) for r in VTCtable]
'''

#VTCtable.to_csv(fileName, sep=',', index=False)
