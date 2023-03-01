%% Save AR Result
function [AR_Result] = AR_Result_Save(AR_Index, AR_LN, AR_LT, Time, AR_ID, AR_CenLon, AR_CenLat, Raw)
    global An_Edge_Index
    global SIC_Area
    AR_Result = cell(1, 11);
    AR_Result(1, 1) = {Time};
    AR_Result(1, 2) = {AR_ID};

    % Detect AR landfall in which section
    AR_Land_Inter = intersect(An_Edge_Index, AR_Index);
    AR_Landfall_Sec = zeros(1, 4);
    if ~isempty(AR_Land_Inter)
        [AR_Intensity, AR_Landfall] = max(Raw(AR_Land_Inter));
        AR_Result(1, 8) = {AR_Intensity};
        AR_Landfall_Lon = AR_LN(AR_Index == AR_Land_Inter(AR_Landfall));
        if AR_Landfall_Lon>=0 && AR_Landfall_Lon<90
            AR_Landfall_Sec(1) = 1;
        elseif AR_Landfall_Lon>=90 && AR_Landfall_Lon<=180
            AR_Landfall_Sec(2) = 1;
        elseif AR_Landfall_Lon>=-180 && AR_Landfall_Lon<-90
            AR_Landfall_Sec(3) = 1;
        elseif AR_Landfall_Lon>=-90 && AR_Landfall_Lon<0
            AR_Landfall_Sec(4) = 1;
        end
    else
        AR_Result(1, 8) = {nan};
    end
    AR_Result(1, 9) = {AR_Landfall_Sec};

    % Detect AR fall on sea ice and its intensity
    for i = 1 : 5
        AR_Ice_Inter = intersect(SIC_Area{i}, AR_Index);
        if ~isempty(AR_Ice_Inter)
            AR_Result(1, i + 2) = {[1; max(Raw(AR_Ice_Inter))]};
        else
            AR_Result(1, i + 2) = {[0; 0]};
        end
    end
end