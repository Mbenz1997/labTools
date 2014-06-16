classdef experimentData
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        metaData %experimentMetaData type
        subData %subjectData type
        data %cell array of labData type (or its subclasses: rawLabData, processedLabData, strideData)
    end
    
    properties (Dependent)
        isRaw
        isProcessed
        isStepped %or strided
        %isTimeNormalized %true if all elements in data share the same timeVector (equal sampling, not just range) 
        fastLeg
    end
    
    methods
        %Constructor
        function this=experimentData(meta,sub,data)

           if nargin>0 && isa(meta,'experimentMetaData')
               this.metaData=meta;
           else
               ME=MException('experimentData:Constructor','Experiment metaData is not an experimentMetaData type object.');
               throw(ME);
           end
           
           if nargin>1 && isa(sub,'subjectData')
               this.subData=sub;
           else
               ME=MException('experimentData:Constructor','Subject data is not a subjectData type object.');
               throw(ME);
           end
           
           if nargin>2 && isa(data,'cell')  % Has to be array of labData type cells. 
               aux=cellfun('isempty',data);
               aux2=find(~aux,1);
               if ~isempty(aux2) && isa(data{aux2},'labData') %This should be changed to test that ALL cells contain labData objects, instead of just the first non-empty one.
                    this.data=data;
               else
                   ME=MException('experimentData:Constructor','Data is not a cell array of labData (or one of its subclasses) objects.');
                   throw(ME);
               end
           else
               ME=MException('experimentData:Constructor','Data is not a cell array.');
               throw(ME);
           end
        end
        
        %Getters for Dependent properties
        function a=get.isProcessed(this)
            aux=cellfun('isempty',this.data);
            idx=find(aux~=1,1); %Not empty
            a=isa(this.data{idx},'processedLabData');
        end
        
        function a=get.isStepped(this)
            aux=cellfun('isempty',this.data);
            idx=find(aux~=1,1);
            a=isa(this.data{idx},'strideData');
        end
        
        function a=get.isRaw(this)
            aux=cellfun('isempty',this.data);
            idx=find(aux~=1,1);
            a=isa(this.data{idx},'rawLabData');
        end
        
        function a=get.fastLeg(this)
            vR=[];
            vL=[];
            for trial=1:length(this.data)
                if ~this.isStepped
                    if ~isempty(this.data{trial}.beltSpeedReadData)
                        vR(end+1)=nanmean(this.data{trial}.beltSpeedReadData.getDataAsVector('R'));
                        vL(end+1)=nanmean(this.data{trial}.beltSpeedReadData.getDataAsVector('L'));
                    end
                else %Stepped trial
                    for step=1:length(this.data{trial})
                        if ~isempty(this.data{trial}{step}.beltSpeedReadData)
                            vR(end+1)=nanmean(this.data{trial}{step}.beltSpeedReadData.getDataAsVector('R'));
                            vL(end+1)=nanmean(this.data{trial}{step}.beltSpeedReadData.getDataAsVector('L'));
                        end
                    end
                end
            end
            if mean(vR)<mean(vL)
                fastLeg='L';
            else
                fastLeg='R'; %Defaults to this, even if there is no beltSpeedData
            end
        end
        
        %function to make adaptationData object
        function adaptData=makeDataObj(this)
            DATA=[];
            startind=1;
            if ~isempty(this.data)
                for i=1:length(this.data)
                    if ~isempty(this.data{i}.adaptParams)
                        labels=this.data{i}.adaptParams.getLabels;
                        dataTS=this.data{i}.adaptParams.getDataAsVector(labels);
                        DATA=[DATA; dataTS(this.data{i}.adaptParams.getDataAsVector('good')==true,:)];
                        indsInTrial{i}= startind:size(DATA,2);
                        startind=size(DATA,2)+1;
                    end
                end
            end
            conditionDescriptions=this.metaData.conditionDescription;
            trialsInCondition=this.metaData.conditionDescription;
            %labels should be the same for all trials with adaptParams
            adaptData=adaptationData(DATA,labels);
        end
        
        function stridedExp=splitIntoStrides(this)
            if ~this.isStepped && this.isProcessed
                refLeg = this.metaData.refLeg;
                for trial=1:length(this.data)
                    trialData=this.data{trial};
                    if ~isempty(trialData)
                        %Assuming that the first event of each stride is
                        %the heel strike of the refLeg! (check c3d2mat -
                        %refleg should be opposite the dominant/fast leg)
                        aux=trialData.separateIntoStrides([refLeg,'HS']);
                        strides{trial}=aux;                        
                    else
                        strides{trial}=[];                        
                    end
                end
                stridedExp=stridedExperimentData(this.metaData,this.subData,strides); 
            else
                disp('Cannot stride experiment because it is raw or already strided.');
            end
        end
        
    end
    
end

