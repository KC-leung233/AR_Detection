%% AR Detect Main Funtion
% The AR Detect Main Function is controlled by the the
% Control_AR_Detection_new.mat
function [AR_Result, AR_IndResult, AR_Now_Index, AR_Now_Num, Max_AR_Num] = ...
    ARDetectMainFunction(Raw_Data, Potential_Data, Time_Series, AR_Now_Index, AR_Now_Num, Max_AR_Num)
    %% Sets
    Time_String = string(datestr(Time_Series, 'yyyymmddHH'));
    global LN LT
    if nargin == 3
        Max_AR_Num = 0;
        AR_Now_Index = cell(10,1);
        AR_Now_Num = [];
    end
    AR_Result = cell(1, 11);
    AR_IndResult = [];
    Result_Row = 1;
    %% Detect AR
    for time = 1 : length(Time_Series)
        AR_Label = bwlabel(Potential_Data(: ,:, time))';
        AR_Raw = (Raw_Data(:, :, time))';
        
        %% Calibrate the AR cross 180 degree
        Redge = AR_Label(:, size(AR_Raw, 2));
        Ledge = AR_Label(:, 1);
        Edgediff = AR_Label(:, size(AR_Raw, 2)) .* AR_Label(:, 1);
        Edgenum = nonzeros(unique(Edgediff));
        % If an AR cross 180 degree, use the ID in the east side
        for i = 1 : length(Edgenum)
            Diffind = find(Edgediff == Edgenum(i), 1);
            AR_Label(AR_Label == Ledge(Diffind)) = Redge(Diffind);
        end
        
        %% Abandon too little high IVT area
%         AR_Area = cell2mat(struct2cell(regionprops(AR_Label, 'Area')));
%         % Consider the IVT area less than ~27500km2 could not be an AR
%         AR_Abandon = find(AR_Area <= 1000);
%         for i = 1 : length(AR_Abandon)
%             AR_Label(AR_Label == AR_Abandon(i)) = 0;
%         end
        
        %% Detect the AR satisfy the geometry threshold
        AR_Number = nonzeros(unique(AR_Label));
        % Output the centroid of the AR
        AR_Centroid = cell2mat(struct2cell(regionprops(AR_Label, 'Centroid')));
        y = rmmissing(round(AR_Centroid(2:2:end)));
        x = rmmissing(round(AR_Centroid(1:2:end)));
        for i = 1 : length(x)
            AR_CenLon(i) = LN(y(i),x(i));
            AR_CenLat(i) = LT(y(i),x(i));
        end
        AR_Last_Index = AR_Now_Index;
        AR_Last_Num = AR_Now_Num;
        AR_Now_Index = cell(10,1);
        AR_Now_Num = [];
        k = 1;
        for i = 1 : length(AR_Number)
            AR_Index = find(AR_Label == AR_Number(i));
            AR_LN = LN(AR_Index);
            AR_LT = LT(AR_Index);
%             Result = ARGeometryDetection(AR_LN, AR_LT);
            Match_Flag = 0;
            if abs(max(AR_LT) - min(AR_LT)) < 20 %Result == 0% Geometry threshold
                AR_Label(AR_Index) = 0;
            else
                %% Detect the continuity of the AR
                if time ~= 1 || nargin == 6
                    for j = 1 : length(AR_Last_Index)
                        AR_Inter = intersect(AR_Index, AR_Last_Index{j});
                        % Consider two AR in the last time and present time
                        % have intersection, and it accounts for 50% of the
                        % present AR, two AR is considered as a continuous AR
                        if ~isempty(AR_Inter)%length(AR_Inter)/length(AR_Index) >= 0.3%
                            AR_Now_Index(k) = {AR_Index};
                            AR_Now_Num(k) = AR_Last_Num(j);
                            AR_Label(AR_Index) = AR_Now_Num(k) .* 10000;
                            [AR_Result(Result_Row, :)] = ...
                                AR_Result_Save(AR_Index, AR_LN, AR_LT, Time_String(time), ...
                                AR_Last_Num(j), AR_CenLon(i), AR_CenLat(i), AR_Raw);
                            Result_Row = Result_Row + 1;
                            k = k + 1;
                            Match_Flag = 1; % The present AR can match an AR in the last timestep
                        end
                    end
                    % If an AR can not match an AR in the last timestep, it
                    % will be defined as a new born AR
                    if Match_Flag == 0
                        AR_Now_Index(k) = {AR_Index};
                        Max_AR_Num = Max_AR_Num + 1;
                        AR_Now_Num(k) = Max_AR_Num;
                        AR_Label(AR_Index) = AR_Now_Num(k) .* 10000;
                        [AR_Result(Result_Row, :)] = ...
                            AR_Result_Save(AR_Index, AR_LN, AR_LT, Time_String(time), ...
                            Max_AR_Num, AR_CenLon(i), AR_CenLat(i), AR_Raw);
                        Result_Row = Result_Row + 1;
                        k = k + 1;
                    end
                elseif time == 1 && nargin == 3
                    AR_Now_Index(k) = {AR_Index};
                    AR_Now_Num(k) = k;
                    AR_Label(AR_Index) = AR_Now_Num(k) .* 10000;
                    [AR_Result(Result_Row, :)] = ...
                        AR_Result_Save(AR_Index, AR_LN, AR_LT, Time_String(time), ...
                        k, AR_CenLon(i), AR_CenLat(i), AR_Raw);
                    Result_Row = Result_Row + 1;
                    k = k + 1;
                    Max_AR_Num = Max_AR_Num + 1;
                end
            end
        end
        AR_Label = floor(AR_Label ./ 10000);
        AR_IndResult = cat(3, AR_IndResult, AR_Label);
    end
end