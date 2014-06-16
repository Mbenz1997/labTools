classdef derivedMetaData < labMetaData
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess=private)
        parentMetaData
    end

    
    methods
        %Constructor
        function this=derivedMetaData(ID,date,experimenter,desc,obs,refLeg,parentMeta)
            this@labMetaData(ID,date,experimenter,desc,obs,refLeg);
            if isa(parentMeta,'labMetaData');
                this.parentMetaData=parentMeta;
            else
                ME=MException('derivedMetaData:Constructor','parentMetaData is not a labMetaData object.');
                throw(ME);
            end
        end
        
    end
    
end

