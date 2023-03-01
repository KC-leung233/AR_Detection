%% Step 1: Generate Potential AR Matrix
% The original yearly vIVT matrix and the threshold (we use 98th percentile
% of monthly climatology here) are needed before generating the monthly
% potential vIVT-based ARs.The user can modify the detection scheme by
% using different original data or threshold.
clear; clc;
% Select a period you want to generate the potential ARs
Total_Detect_Series = ...
    datevec(datetime(1979, 1, 1, 0, 0, 0) : hours(6): datetime(2020, 12, 31, 23, 0, 0));
Total_yr = unique(Total_Detect_Series(:, 1));
load ERA5vIVT_98th_2020.mat % Load the threshold of ARs
data_input_path = ''; % The path of your original data
data_save_path = ''; % The path of your output data
for yr = 1 : length(Total_yr)
    vIVT_Total = load(strcat(data_input_path, string(Total_yr(yr)), '.mat'),'vIVT'); % Load the original yearly vIVT matrix
    Part_Detect_Series = Total_Detect_Series(Total_Detect_Series(:, 1) == Total_yr(yr), 2);
    Total_mo = unique(Part_Detect_Series);
    for mo  = 1 : length(Total_mo)
        vIVT = vIVT_Total(:, :, Part_Detect_Series == Total_mo(mo)); % Archive the vIVT for a specific month
        vIVT1 = vIVT;
        % Set the potential AR pixels into 1, and the non-AR pixels are 0
        vIVT1(vIVT < vIVT_98th(:, :, Total_mo(mo))) = 0;
        vIVT1(vIVT >= vIVT_98th(:, :, Total_mo(mo))) = 1;
        % Save the monthly original vIVT and the potential ARs
        save(strcat(data_save_path, 'vIVT_', ...
            datestr(datetime(Total_yr(yr), Total_mo(mo), 1), 'yyyymm'), '.mat'), 'vIVT', 'vIVT1'); 
    end
end
%% Step 2: Load basic dataset
clear; clc;
% Load the edge of Antarctica, if your resolution of the orginal data is
% 0.25degree*0.25degree, you can load An_Edge_Index_025.mat
global An_Edge_Index
load([pwd '\An_Edge_Index_1.mat'], 'An_Edge_Index');
% Load the longitude and latitude of the grid, if you resolution of the
% original data is 0.25degree*0.25degree, you can load lon_lat_025.mat
global LN LT
load([pwd '\lon_lat_1.mat'], 'lon', 'lat');
[LN, LT] = meshgrid(lon, lat);
%% Step 3: Detect Series
data_save_path = ''; % The path of your output data in Step 1
final_data_path = ''; % The path for the final AR results
% Set the detection period
Total_Detect_Series = ...
    datevec(datetime(1979, 1, 1, 0, 0, 0) : hours(6): datetime(2020, 12, 31, 23, 0, 0));
Total_yr = unique(Total_Detect_Series(:, 1));
Rerun = 0; % If it's first time to run this function, set Rerun to 0, otherwise set to 1
for yr = 1 : length(Total_yr)
    Total_mo = ...
        unique(Total_Detect_Series(Total_Detect_Series(:, 1) == Total_yr(yr), 2));
    for mo  = 1 : length(Total_mo)
        % Load the monthly sea ice region. The sea ice region is
        % archieved by averaging sea ice coverage (sea ice concentration >
        % 15%), The sea ice concentration is from NSIDC and interpolated
        % into 1degree*1degree (or 0.25degree*0.25degree, load
        % \Ice_Edge_025\)
        global SIC_Area
        Area_Name = strcat('SIC_Area_', datestr(Total_mo(mo), 'mm'));
        SIC_Area = load(strcat([pwd '\Ice_Edge_1\'], Area_Name, '.mat'));
        SIC_Area = SIC_Area.(Area_Name);
        Time_Series = ...
            datetime(Total_Detect_Series(Total_Detect_Series(:, 1) == Total_yr(yr) &...
            Total_Detect_Series(:, 2) == Total_mo(mo), :));
        % Load the potential AR matrix derived in Step 1
        load(strcat(data_save_path, 'vIVT_', ...
            datestr(datetime(Total_yr(yr), Total_mo(mo), 1), 'yyyymm'), '.mat'), 'IVT', 'IVT1');
        if Rerun == 1
            [AR_Result, AR_IndResult, AR_Rerun_Index, AR_Rerun_Num, Max_Rerun_Num] = ...
                ARDetectMainFunction(IVT, IVT1, Time_Series, ...
                AR_Rerun_Index, AR_Rerun_Num, Max_Rerun_Num);
        elseif Rerun == 0
            [AR_Result, AR_IndResult, AR_Rerun_Index, AR_Rerun_Num, Max_Rerun_Num] = ...
                ARDetectMainFunction(IVT, IVT1, Time_Series);
        end
        save Rerun_data AR_Rerun_Index AR_Rerun_Num Max_Rerun_Num
        % Save the AR occurence information (occurence date, landfall
        % sectors, intensity during landfall, etc.)
        save(strcat(final_data_path, '\AR_Result_', ...
            datestr(datetime(Total_yr(yr), Total_mo(mo), 1), 'yyyymm'), '.mat'), 'AR_Result');
        % Save the ARs map, the pixels where above 0 is the ID of an
        % AR, and 0 is the non-AR pixels
        save(strcat(final_data_path, '\AR_IndResult_', ...
            datestr(datetime(Total_yr(yr), Total_mo(mo), 1), 'yyyymm'), '.mat'), 'AR_IndResult');
        if Rerun ~= 1
            Rerun = 1; % Once run the function, Rerun will be set to 1
        end
    end
end