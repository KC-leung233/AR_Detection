# AR_Detection_Algorithm
Our AR detection algorithm is developed by referring Wille et al. (2021). When the meridional distance of a potential AR is more than 20°,
it will be classified into an AR (Wille et al., 2021). And ARs in different schemes (integrated water vapour (IWV), 
integrated water vapour transport (IVT), v-component integrated water vapour transport (vIVT), etc.), with 
different thresholds and detection periods can be flexiblely detected only by changing the original data, 
threshold and time period.

Meaning of AR Results
The meaning of each columns in AR_Result:
	1: The date of ARs, the format is: yyyymmddhh
	2: The ID of AR
	3: AR occurence in Indian Ocean (20E-90E), the first value is the state of AR occurence (occured is 1, absent is 0), 
	and the second value is the maximum IVT value among the sea ice sector. Note that, the AR may fall on 
	more than ONE sea ice setors simultaneously.Column 3-7 are similar but in different sea ice sectors. The division
	of sea ice sectors is refered to Ionita et al. 2018 and Turner et al., 2017.
	4: AR occurence in western Pacific Ocean (90E-160E)
	5: AR occurence in Ross Sea (160E-130W)
	6: AR occurence in Amundsen-Bellingshausen Sea (130W-60W)
	7: AR occurence in Weddell Sea (60W-20E)
	8: The maximum IVT value among the pixels which intersect with the edge
	of the Antarctic continent.
	9: The sector where the maximum value occureed. If the value equals 1
	indicating that the maximum occures in this setor. The sectors are 0-90,
	90-180, 180-270 and 270-360 degree east of the edge of Antarctic continent (Wille et al., 2019). 
The meaning of AR_IndResult:
	The pixels where above 0 is the ID of an AR, and 0 is the non-AR pixels

The sea ice concentration utlized to generate the sea ice mask is NOAA/NSIDC Science Quality Climate Data Record of 
Passive Microwave Sea Ice Concentration Version 3, Science Quality, Monthly, Antarctic. 
The data is available at https://doi.org/10.7265/N59P2ZTG.

The Antarctic continent edge is derived by using the topography in ERA5 data. 
The data is available at https://doi.org/10.24381/cds.adbb2d47

Reference:
Wille, J. D., Favier, V., Gorodetskaya, I. V., Agosta, C., Kittel, C., Beeman, J. C., et al. (2021). 
	Antarctic Atmospheric River Climatology and Precipitation Impacts. 
	Journal of Geophysical Research: Atmospheres, 126(8). https://doi.org/10.1029/2020JD033788
Ionita, M., Scholz, P., Grosfeld, K., & Treffeisen, R. (2018). 
	Moisture transport and Antarctic sea ice: Austral spring 2016 event. 
	Earth System Dynamics, 9. https://doi.org/10.5194/esd-9-939-2018
Turner, J., Phillips, T., Marshall, G. J., Hosking, J. S., Pope, J. O., Bracegirdle, T. J., & Deb, P. (2017). 
	Unprecedented springtime retreat of Antarctic sea ice in 2016: The 2016 Antarctic Sea Ice Retreat. 
	Geophysical Research Letters, 44(13), 6868–6875. https://doi.org/10.1002/2017GL073656
Wille, J. D., Favier, V., Dufour, A., Gorodetskaya, I. V., Turner, J., Agosta, C., & Codron, F. (2019). 
	West Antarctic surface melt triggered by atmospheric rivers. 
	Nature Geoscience, 12(11), 911–916. https://doi.org/10.1038/s41561-019-0460-1
