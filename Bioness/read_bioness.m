function [OutputData,Net_table] = read_bioness(DataPath)

%Function to read Bioness data from *.ucn files
% Gildas Roudaut 15/06/2023
% Marc Picheral 18/06/2023

%INPUT
%DataPath = path to data folder with *.ucn files

%Output Matrix (OutputData)
%OutputData=[Time,Net_Pressure,Net_Depth,Net_Temp,Net_sal,Net_flow_in,Net_flow_out,Net_pitch,Volume];
%Output Table (Net_table)
%Net_table.Properties.VariableNames = [{'Net'}    {'OpenTime'}    {'OpenDuration'}    {'OpenPressure'}    {'ClosePressure'}    {'MaxPressure'}    {'MinPressure'} {'MeanPitch'} {'NetVol'}];

%DataPath='C:\Users\groudaut\Documents\Gildas\Campagnes\Apero\Bioness\apero_bioness_006\';

Extension='ucn';
OpeningString='Opening Time';
ClosingString='Closing Time';
Start_date_string='Run Start Date';
NetVolume_string='Total Swept Volume';
NetNumber_string= 'Net Number';
NetDistance_string= 'Total Distance';

Filelist=dir([DataPath,'*.',Extension]);

%preparing results matrix
OpenTime=NaN(length(Filelist),1);
CloseTime=NaN(length(Filelist),1);
StartDate=NaN(length(Filelist),1);
NetVol=NaN(length(Filelist),1);
NetNum=NaN(length(Filelist),1);

Net_Depth=[];
Net_Pressure=[];
Net_Temp=[];
Net_sal=[];
Net_flow_in = [];
Net_flow_out = [];
Net_pitch = [];
Time=[];
Volume=[];
Net=[];
Net_summary=[];
NetDist=[];

%Loop on each "Net file"
for i=1:length(Filelist)
    %read header and tailer 
    fileID = fopen([DataPath,Filelist(i).name]);
    C = textscan(fileID,'%s','Delimiter',',');
    fclose(fileID);
        
    %Data from sensors
    NumData=readtable([DataPath,Filelist(i).name],'FileType','text');

    %Net salinity
    currentNetSal=table2array(NumData(:,2));

    %Net temperature
    currentNetTemp=table2array(NumData(:,3));
   
    %Net Pressure
    currentNetPressure=table2array(NumData(:,4));

    %Net Depth
    currentNetDepth=table2array(NumData(:,5));     

    %Net Flow OUT
    currentNetFlowOut=table2array(NumData(:,6));
    
    %Net Flow IN
    currentNetFlowIn=table2array(NumData(:,7));  
    
    %Net Pitch
    currentNetPitch=table2array(NumData(:,9));

    %delete NaN values vectors
    currentNetDepth(isnan(currentNetDepth))=[];
    currentNetTemp(isnan(currentNetTemp))=[];
    currentNetSal(isnan(currentNetSal))=[];
    currentNetPressure(isnan(currentNetPressure))=[];
    currentNetFlowIn(isnan(currentNetFlowIn))=[];
    currentNetFlowOut(isnan(currentNetFlowOut))=[];
    currentNetPitch(isnan(currentNetPitch))=[];

    % Net_Depth=[Net_Depth;repmat(i-1,size(currentNetDepth,1),1),currentNetDepth];
    Net_Depth=[Net_Depth;currentNetDepth];
    Net_Pressure=[Net_Pressure;currentNetPressure];
    Net_Temp=[Net_Temp;currentNetTemp];
    Net_sal=[Net_sal;currentNetSal];
    Net_flow_in = [Net_flow_in;currentNetFlowIn];
    Net_flow_out = [Net_flow_out;currentNetFlowOut];
    Net_pitch = [Net_pitch;currentNetPitch];

    %Looking for opening time and clossing time
    for line=1:size(C{1}(:),1)
        Nchar=length(char(C{1}(line)));
        if Nchar>=length(OpeningString)
            LineTest=char(char(C{1}(line)));
            %Closing Time
            if strcmp(LineTest(1:length(ClosingString)),ClosingString)
                TimeChar=char(C{1}(line));
                CloseTime(i)=datenum(TimeChar(end-7:end));
            end
            %Opening time
            if strcmp(LineTest(1:length(OpeningString)),OpeningString)
                TimeChar=char(C{1}(line));
                OpenTime(i)=datenum(TimeChar(end-7:end));
            end
        end
        if Nchar>=length(Start_date_string)
            LineTest=char(char(C{1}(line)));
            %Start date
            if strcmp(LineTest(1:length(Start_date_string)),Start_date_string)
                TimeChar=char(C{1}(line));
                StartDate(i)=datenum(TimeChar(end-7:end));
            end
        end

        if Nchar>=length(NetVolume_string)
            LineTest=char(char(C{1}(line)));
            %net volume
            if strcmp(LineTest(1:length(NetVolume_string)),NetVolume_string)
                VolChar=char(C{1}(line));
                ind=regexp(VolChar,' ','all');
                NetVol(i)=str2num(VolChar(ind(end)+1:end));
            end
        end

        if Nchar>=length(NetDistance_string)
            LineTest=char(char(C{1}(line)));
            %net volume
            if strcmp(LineTest(1:length(NetDistance_string)),NetDistance_string)
                VolChar=char(C{1}(line));
                ind=regexp(VolChar,' ','all');
                NetDist(i)=str2num(VolChar(ind(end)+1:end));
            end
        end

        if Nchar>=length(NetNumber_string)
            LineTest=char(char(C{1}(line)));
            %net num
            if strcmp(LineTest(1:length(NetNumber_string)),NetNumber_string)
                VolChar=char(C{1}(line));
                ind=regexp(VolChar,' ','all');
                NetNum(i)=str2num(VolChar(ind(end)+1:end));
            end
        end

    end

    %Reformating dates for current net
    OpenTime=StartDate+OpenTime-floor(OpenTime);
    CloseTime=StartDate+CloseTime-floor(CloseTime);

    if CloseTime < OpenTime
        CloseTime = CloseTime + 1;
    end

    %Building time vector for each net according to sensor data length
    Net_time = interp1([1,length(currentNetDepth)],[OpenTime(i), CloseTime(i)],[1:1:length(currentNetDepth)])';
    
    %Time corrections
    if ~isempty(findstr(DataPath,'apero_bioness'))
        aa = findstr(DataPath,'apero_bioness');
        if str2num(DataPath(aa+14:aa+16)) < 12
            %Remove 2 hours before we adjust Bioness system time
            Net_time = Net_time - datenum(00,00,00,2,0,0);
            OpenTime = OpenTime - datenum(00,00,00,2,0,0);
            CloseTime = CloseTime - datenum(00,00,00,2,0,0);
        elseif str2num(DataPath(aa+14:aa+16)) == 12
            %Specific correction for bad time setting of cast 012
            Net_time = Net_time - datenum(00,00,00,02,26,11);
            OpenTime = OpenTime - datenum(00,00,00,02,26,11);
            CloseTime = CloseTime - datenum(00,00,00,02,26,11);
        elseif str2num(DataPath(aa+14:aa+16)) == 13
            %Specific correction for bad time setting of cast 012
            Net_time = Net_time - datenum(00,00,00,01,00,00);
            OpenTime = OpenTime - datenum(00,00,00,01,00,00);
            CloseTime = CloseTime - datenum(00,00,00,01,00,00);
        elseif str2num(DataPath(aa+14:aa+16)) == 14
            %Specific correction for bad time setting of cast 012
            Net_time = Net_time + datenum(2023,06,26,22,18,00) -datenum(2002,05,24,00,34,40);
            OpenTime = OpenTime + datenum(2023,06,26,22,18,00) -datenum(2002,05,24,00,34,40);
            CloseTime = CloseTime + datenum(2023,06,26,22,18,00) -datenum(2002,05,24,00,34,40);
        elseif str2num(DataPath(aa+14:aa+16)) == 15
            %Specific correction for bad time setting of cast 012
            Net_time = Net_time + datenum(2023,07,02,07,06,00) - datenum(2023,07,02,06,48,00);
            OpenTime = OpenTime + datenum(2023,07,02,07,06,00) - datenum(2023,07,02,06,48,00);
            CloseTime = CloseTime + datenum(2023,07,02,07,06,00) - datenum(2023,07,02,06,48,00);    
        elseif str2num(DataPath(aa+14:aa+16)) == 17
            %Specific correction for bad time setting of cast 012
            Net_time = Net_time + datenum(2023,07,05,05,03,00) -datenum(2023,07,05,04,49,00);
            OpenTime = OpenTime + datenum(2023,07,05,05,03,00) -datenum(2023,07,05,04,49,00);
            CloseTime = CloseTime + datenum(2023,07,05,05,03,00) -datenum(2023,07,05,04,49,00);
        end
    end 

    Time=[Time;Net_time];
    
    %Building volume vector
    Volume=[Volume;repmat(NetVol(i),length(currentNetDepth),1)];

    %Building Net vector
    Net=[Net;repmat(NetNum(i),length(currentNetDepth),1)];

    %Net summary
    duration = datevec(CloseTime(i)-OpenTime(i));
    duration_min = round((duration(5)*60 + duration(6))/60);

    %DIstance
    Distance = (duration(5)*60 + duration(6)) * mean(Net_flow_out);

    %Net volume corrected pitch & trajectory
    Corrected_area = cosd(mean(currentNetPitch));

    %SampledVol
    SampledVol = (duration(5)*60 + duration(6)) * mean(Net_flow_in) * Corrected_area;

    NetSum = [NetNum(i),OpenTime(i),duration_min,round(currentNetPressure(1)),round(currentNetPressure(end)),round(max(currentNetPressure)),round(min(currentNetPressure)),round(mean(currentNetPitch,1)),round(SampledVol),round(Corrected_area,2),round(mean(Net_flow_in),2),round(mean(Net_flow_out),2),round(Distance)];
    Net_summary = [Net_summary;NetSum];
    
end

OutputData=[Time,Net_Pressure,Net_Depth,Net_Temp,Net_sal,Net_flow_in,Net_flow_out,Net_pitch,Volume,Net];

%Trawl number
aa=split(DataPath,'\');
bb =  split(aa(end-1),'_');
trawl_num = char(bb(end));

%Output table
Net_data_table = array2table(OutputData);
Net_data_table.Properties.VariableNames = [{'Time'} {'Net_Pressure'} {'Net_Depth'} {'Net_Temp'} {'Net_sal'} {'Net_flow_in'} {'Net_flow_out'} {'Net_pitch'} {'Volume'} {'Net'}];


%Table synthétique
Net_table = array2table(Net_summary);
Net_table.Properties.VariableNames = [{'Net'}    {'OpenTime'}    {'OpenDuration [Min]'}    {'OpenPressure [dbars]'}    {'ClosePressure [dbars]'}    {'MaxPressure [dbars]'}    {'MinPressure [dbars]'} {'MeanPitch [d]'} {'NetVolCalc [m3]'}  {'NetCorArea [m2]'} {'MeanFlowIn [m/s]'} {'MeanFlowOut  [m/s]'} {'NetDistCalc [m]'}];
Net_table.OpenTime = datetime(Net_table.OpenTime,'ConvertFrom','datenum');

%Table writing
writetable(Net_data_table,[DataPath,'data_net_',trawl_num,'.csv'],'Delimiter',';','WriteRowNames',true)
writetable(Net_table,[DataPath,'sum_net_',trawl_num,'.csv'],'Delimiter',';','WriteRowNames',true)
end