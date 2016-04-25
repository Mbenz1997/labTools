classdef BiofeedbackPerception
    %Class BiofeedbackMD houses metadata and methods to process step length
    %biofeedback trials
    %
    %Properties:
    %
    %           subjectcode = '' string containing subject code, e.g. 'SLP001'
    %
    %           date='' Date of the experiment, lab date object
    %           labDate(dd,mm,yyyy)
    %
    %           sex = '' string designates subject sex e.g. 'f'
    %
    %           dob='' lab date object with date of birth labDate(dd,mm,yyyy)
    %
    %           dominantleg='' string designate dominant leg, e.g. 'r'
    %
    %           dominanthand = '' string designate dominant hand e.g. 'r'
    %
    %           fastleg = '' string designates which leg was fast
    %
    %           height=[];  cm
    %           weight=[];  kg
    %           age=[];  years
    %
    %           triallist={};  cell array of trial #'s, filenames, and type of
    %               trial. Construct instance with blank cell, can input data using a
    %               method instead of copying and pasting into inputs
    %
    %           Rtmtarget=[]; right leg step length target as determined by treadmill baseline
    %
    %           Ltmtarget=[]; left leg step length target as determined by treadmill baseline
    %
    %
    %     Methods:
    %
    %       AnalyzePerformance(flag) -- computes step length errors for each
    %                                   biofeedback trial,
    %
    %       editTriallist() -- select filenames, edit trial #'s and type and
    %                          category, input num is the # of trials, or rows in the list
    %
    %   saveit() -- saves the instance with filename equal to the ID
    %
    %   comparedays() -- makes bar plots comparing day1 and day2
    
    
    properties
        subjectcode = ''
        date=''
        sex = ''
        dob=''
        dominantleg=''
        dominanthand = ''
        fastleg = ''
        height=[];
        weight=[];
        age=[];
        triallist={};
        Rtmtarget=[];
        Ltmtarget=[];
        datalocation=pwd;
        data={};
        dataheader={};
        
        
    end
    
    methods
        %constuctor
        function this=BiofeedbackPerception(ID,date,sex,dob,dleg,dhand,fastleg,height,weight,age,triallist,Rtarget,Ltarget)
            
            if nargin ~= 13
                %                 disp('Error, incorrect # of input arguments provided');
                cprintf('err','Error: incorrect # of input arguments provided\n');
            else
                
                if ischar(ID)
                    this.subjectcode=ID;
                else
                    this.subjectcode='';
                    cprintf('err','WARNING: invalid subject ID input, must be a string\n');
                end
                
                if isa(date,'labDate')
                    this.date = date;
                else
                    cprintf('err','WARNING: incorrect experiment date format provided, must be class labDate\n');
                    this.date='';
                end
                
                if ischar(sex)
                    this.sex = sex;
                else
                    cprintf('err','WARNING: input for sex must be a string\n');
                    this.sex='';
                end
                
                if isa(dob,'labDate')
                    this.dob=dob;
                else
                    cprintf('err','WARNING: date of birth is not the correct format\n');
                    this.dob=[];
                end
                
                if ischar(dleg)
                    this.dominantleg=dleg;
                else
                    cprintf('err','WARNING: incorrect format for dominant leg input, must be a string\n');
                    this.dominantleg='';
                end
                
                if ischar(dhand)
                    this.dominanthand=dhand;
                else
                    cprintf('err','WARNING: incorrect format for dominant hand input, must be a string\n');
                    this.dominanthand='';
                end
                
                if ischar(fastleg)
                    this.fastleg=fastleg;
                else
                    cprintf('err','WARNING: incorrect format for fast leg, must be a string\n');
                    this.fastleg='';
                end
                
                if isnumeric(height)
                    this.height = height;
                else
                    cprintf('err','WARNING: input height is not numeric\n');
                    this.height=[];
                end
                
                if isnumeric(weight)
                    this.weight = weight;
                else
                    cprintf('err','WARNING: input weight is not numeric\n');
                    this.weight=[];
                end
                
                if isa(age,'labDate')
                    this.age = age;
                else
                    cprintf('err','WARNING: input age is not class labDate\n');
                    this.age=[];
                end
                
                if iscell(triallist)
                    this.triallist=triallist;
                else
                    cprintf('err','WARNING: triallist input is not a cell format.\n');
                    this.triallist={};
                end
                
                if isnumeric(Rtarget)
                    this.Rtmtarget = Rtarget;
                else
                    cprintf('err','WARNING: Right step length target is not numeric type.\n');
                    this.Rtmtarget = [];
                end
                
                if isnumeric(Ltarget)
                    this.Ltmtarget = Ltarget;
                else
                    cprintf('err','WARNING: Left step length target is not numeric type.\n');
                    this.Ltmtarget = [];
                end
                
                
            end
            
            
            
        end
        
        function []=AnalyzePerformance(this)
            
            global rhits
            global lhits
            
            if isempty(this.triallist)
                cprintf('err','WARNING: no trial information available to analyze');
            else
                filename = this.triallist(:,1);
                
                if iscell(filename)%if more than one file is selected for analysis
                    %
                    %                     rhits = {0};
                    %                     lhits = {0};
                    %                     rlqr = {0};
                    %                     llqr = {0};
                    %                     color = {};
%                                          WB = waitbar(0,'Processing Trials...');
                    %                     for z = 1:length(filename)
                    %                         tempname = filename{z};
                    %                         waitbar((z-1)/length(filename),WB,['Processing Trial ' num2str(z)]);
                    %
                    %                         if strcmp(this.triallist{z,4},'Familiarization')
                    %                             color{z} = [189/255,15/255,18/255];%red
                    %                         elseif strcmp(this.triallist{z,4},'Base Map')
                    %                             color{z} = [48/255,32/255,158/255];%blue
                    %                         elseif strcmp(this.triallist{z,4},'Base Clamp')
                    %                             color{z} = [1,.8,0];%
                    %                         elseif strcmp(this.triallist{z,4},'Post Clamp')
                    %                             color{z} = [91/255,122/255,5/255];%green
                    %                         elseif strcmp(this.triallist{z,4},'Post Map')
                    %                             color{z} = [9/255,109/255,143/255];%bluegrey
                    %                         end
                    %                         %                        keyboard
                    %
                    %
                    %                         %check to see if data is already processed, it will
                    %                         %save time...
                    %                         if length(this.data)<z
                    %                             disp('Parsing data...');
                    %
                    %                             f = fopen(filename{z});
                    %                             g = fgetl(f);
                    %                             fclose(f);
                    %
                    %                             if strcmp(g(1),'[')
                    %                                 [header,data] = JSONtxt2cell(filename{z});
                    %                                 this.data{z} = data;
                    %                                 this.dataheader = header;
                    %                             else
                    %                                 S = importdata(filename{z},',',1);
                    %                                 data = S.data;
                    %                                 this.data{z} = S.data;
                    %                                 this.dataheader = S.textdata;
                    %                             end
                    %
                    %
                    %                         else
                    %                             data = cell2mat(this.data(z));
                    %                             header = this.dataheader;
                    %                         end
                    %                         [~,n] = size(data);
                    %                         %                        keyboard
                    %                         data2 = unique(data,'rows','stable');%remove duplicate frames
                    %                         data2(:,1) = data2(:,1)-data2(1,1)+1;%set frame # to start at 1
                    %
                    %                         %check for monotonicity
                    %                         checkers = find(diff(data2(:,1))<1);
                    %                         while ~isempty(checkers)
                    %                             for y=1:length(checkers)
                    %                                 data2(checkers(y),:)=[];
                    %                             end
                    %                             checkers = find(diff(data2(:,1))<1);
                    %                         end
                    %                         %                        keyboard
                    %                         for zz = 1:n
                    %                             data3(data2(:,1),zz) = data2(:,zz);
                    %                         end
                    %                         frame = data3(:,1);
                    %                         frame2 = 1:1:data2(end,1);
                    %                         %                        keyboard
                    %                         Rz2 = interp1(data2(:,1),data2(:,2),frame2,'linear');
                    %                         Lz2 = interp1(data2(:,1),data2(:,3),frame2,'linear');
                    %                         Rgamma2 = interp1(data2(:,1),data2(:,10),frame2,'linear');
                    %                         Lgamma2 = interp1(data2(:,1),data2(:,11),frame2,'linear');
                    %                         target = interp1(data2(:,1),data2(:,14),frame2,'linear');
                    %
                    %                         %detect HS
                    %                         for zz = 1:length(Rz2)-1
                    %                             if Rz2(zz) > -10 && Rz2(zz+1) <= -10
                    %                                 RHS(zz) = 1;
                    %                             else
                    %                                 RHS(zz) = 0;
                    %                             end
                    %                         end
                    %                         [~,trhs] = findpeaks(RHS,'MinPeakDistance',100);
                    %                         RHS = zeros(length(RHS),1);
                    %                         RHS(trhs) = 1;
                    %                         for zz = 1:length(Lz2)-1
                    %                             if Lz2(zz) > -10 && Lz2(zz+1) <= -10
                    %                                 LHS(zz) = 1;
                    %                             else
                    %                                 LHS(zz) = 0;
                    %                             end
                    %                         end
                    %                         [~,tlhs] = findpeaks(LHS,'MinPeakDistance',100);
                    %                         LHS = zeros(length(LHS),1);
                    %                         LHS(tlhs) = 1;
                    %                         %                        keyboard
                    %                         %%!!!!!!!!!!!!!!!!!!!!!!!%%!!!!!!!!!!!!!!!!!%%%!!!!!!!!!!!!!!!!
                    %                         %calculate errors
                    %                         %                        tamp = abs(Rgamma2(find(RHS)))'-this.Rtmtarget;
                    %                         %                        tamp2 = abs(Lgamma2(find(LHS)))'-this.Ltmtarget;
                    %                         tamp = Rgamma2(find(RHS))-target(find(RHS)-1);
                    %                         tamp2 = Lgamma2(find(LHS))-target(find(LHS)-1);
                    %                         tamp3 = target(find(RHS));
                    %                         tamp4 = target(find(LHS));
                    %
                    %                         %delete 5 strides at each transistion
                    %                         K = find(diff(tamp3));
                    %                         K2 = find(diff(tamp4));
                    %                         for y = 1:length(K)
                    %                             tamp(K(y):K(y)+5)=100;
                    %                             tamp3(K(y):K(y)+5)=100;
                    %                         end
                    %                         for y = 1:length(K2)
                    %                             tamp2(K2(y):K2(y)+5)=100;
                    %                             tamp4(K2(y):K2(y)+5)=100;
                    %                         end
                    %                         tamp(tamp==100)=[];
                    %                         tamp2(tamp2==100)=[];
                    %                         tamp3(tamp3==100)=[];
                    %                         tamp4(tamp4==100)=[];
                    %
                    %                         rhits{z} = tamp;
                    %                         lhits{z} = tamp2;
                    %                         rts{z} = tamp3;
                    %                         lts{z} = tamp4;
                    %
                    %                         clear RHS LHS tamp tamp2
                    %                      end
                    
                    [rhits, lhits, rts, lts, color]=getHits(this);
                    
                    
                    this.saveit();
%                     
%                     waitbar(1,WB,'Processing complete...');
%                     pause(0.5);
%                     close(WB);
                    clear z
                    
                    %load triallist to look for categories
                    tlist = this.triallist;
                    
                    train = find(strcmp(tlist(:,4),'Familiarization'));%logicals of where training trials are
                    base = find(strcmp(tlist(:,4),'Base Map'));
                    adapt = find(strcmp(tlist(:,4),'Base Clamp'));
                    wash = find(strcmp(tlist(:,4),'Post Clamp'));
                    wash2 = find(strcmp(tlist(:,4),'Post Map'));
                    %                     keyboard
                    figure(2)
                    if this.fastleg == 'r'
                        subplot(2,1,1)
                    else
                        subplot(2,1,2)
                    end
                    hold on
                    %                    keyboard
                    %fill([0 length(cell2mat(rhits(train))) length(cell2mat(rhits(train))) 0],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    fill([0 length(cell2mat(rhits(train))) length(cell2mat(rhits(train))) 0],[0.255 0.255 -0.255 -0.255],[150 150 150]./256)
                    fill([length(cell2mat(rhits(train))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))  length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))  length(cell2mat(rhits(train)))],[0.255 0.255 -0.255 -0.255],[256 256 256]./256);
                    fill([length(cell2mat(rhits(train)))+length(cell2mat(rhits(base))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    %fill([length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash)))+length(cell2mat(rhits(wash2))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash)))+length(cell2mat(rhits(wash2))) length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash)))],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    fill([length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))  length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash)))   length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))+length(cell2mat(rhits(wash)))   length(cell2mat(rhits(train)))+length(cell2mat(rhits(base)))+length(cell2mat(rhits(adapt)))  ],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    
                    h = 0;
                    for z = 1:length(filename)
                        figure(2)
                        if this.fastleg == 'r'
                            subplot(2,1,1)
                        else
                            subplot(2,1,2)
                        end
                        hold on
                        %                         g = gscatter([1:length(rhits{z})]+h,rhits{z},rts{z},color{z},['s','o','d']);
                        %                         for y = 1:length(g)
                        %                             set(g(y),'MarkerFaceColor',color{z});
                        %                             set(g(y),'MarkerEdgeColor','k');
                        %                         end
                        g=gscatter([1:length(rhits{z})]+h,rhits{z},rts{z},['b', 'k' ,'r'],['s','o','d']);
                        if z==1 || z==3 || z==4
                            colorCODE=['b', 'k' ,'r'];
                            for y = 1:length(g)
                                set(g(y),'MarkerFaceColor',colorCODE(y));
                                set(g(y),'MarkerEdgeColor','k');
                            end
                        end
                        
                        %                        plot([h h+length(rhits{z})],[nanmean(rhits{z})+rlqr{z}/2 nanmean(rhits{z})+rlqr{z}/2],'Color',[0.5 0 0.5],'LineWidth',2);%tolerance lines
                        %                        plot([h h+length(rhits{z})],[nanmean(rhits{z})-rlqr{z}/2 nanmean(rhits{z})-rlqr{z}/2],'Color',[0.5 0 0.5],'LineWidth',2);%tolerance lines
                        h = h+length(rhits{z});
                    end
                    plot([0 h+length(rhits{z})],[0.02 0.02],'k');%tolerance lines
                    plot([0 h+length(rhits{z})],[-0.02 -0.02],'k');
                    figure(2)
                    if this.fastleg == 'r'
                        subplot(2,1,1)
                        title([this.subjectcode ' Step Length Error Fast Leg']);
                    else
                        subplot(2,1,2)
                        title([this.subjectcode ' Step Length Error Slow Leg']);
                    end
                    ylim([-0.15 0.15]);
                    xlim([0 h+10]);
                    %                    title([this.subjectcode ' Step Length Error Fast Leg']);
                    xlabel('step #');
                    ylabel('Error (m)');
                    legend('Familiarization', 'Spatial Map', 'Error Clamp','Error Clamp',  'Short Vision', 'Mid Vision', 'Long Vision', 'Short No Vision', 'Mid No Vision', 'Long No Vision')
                    
                    figure(2)
                    if this.fastleg == 'l'
                        subplot(2,1,1)
                    else
                        subplot(2,1,2)
                    end
                    hold on
                    fill([0 length(cell2mat(lhits(train))) length(cell2mat(lhits(train))) 0],[0.255 0.255 -0.255 -0.255],[150 150 150]./256);
                    fill([length(cell2mat(lhits(train)))+length(cell2mat(lhits(base))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    %                     fill([length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash)))+length(cell2mat(lhits(wash2))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash)))+length(cell2mat(lhits(wash2))) length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash)))],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    fill([length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))  length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash)))   length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))+length(cell2mat(lhits(wash)))   length(cell2mat(lhits(train)))+length(cell2mat(lhits(base)))+length(cell2mat(lhits(adapt)))  ],[0.255 0.255 -0.255 -0.255],[230 230 230]./256);
                    
                    
                    h = 0;
                    for z = 1:length(filename)
                        figure(2)
                        if this.fastleg == 'l'
                            subplot(2,1,1)
                        else
                            subplot(2,1,2)
                        end
                        %                         scatter([1:length(lhits{z})]+h,lhits{z},75,color{z},'fill','MarkerEdgeColor','k');
                        %                         gscatter([1:length(lhits{z})]+h,lhits{z},lts{z},color{z},['s','o','d']);
                        %                         g = gscatter([1:length(lhits{z})]+h,lhits{z},lts{z},color{z},['s','o','d']);
                        %                         for y = 1:length(g)
                        %                             set(g(y),'MarkerFaceColor',color{z});
                        %                             set(g(y),'MarkerEdgeColor','k');
                        %                         end
                        g = gscatter([1:length(lhits{z})]+h,lhits{z},lts{z},['b', 'k' ,'r'],['s','o','d']);
                        if z==1 || z==3 || z==4
                            colorCODE=['b', 'k' ,'r'];
                            for y = 1:length(g)
                                set(g(y),'MarkerFaceColor',colorCODE(y));
                                set(g(y),'MarkerEdgeColor','k');
                            end
                        end
                        
                        plot([h h+length(lhits{z})],[0.02 0.02],'k');%tolerance lines
                        plot([h h+length(lhits{z})],[-0.02 -0.02],'k');
                        %                        plot([h h+length(lhits{z})],[nanmean(lhits{z})+llqr{z}/2 nanmean(lhits{z})+llqr{z}/2],'Color',[0.5 0 0.5],'LineWidth',2);%tolerance lines
                        %                        plot([h h+length(lhits{z})],[nanmean(lhits{z})-llqr{z}/2 nanmean(lhits{z})-llqr{z}/2],'Color',[0.5 0 0.5],'LineWidth',2);%tolerance lines
                        h = h+length(lhits{z});
                        %         h = h+length(lhits{z});
                    end
                    figure(2)
                    if this.fastleg == 'l'
                        subplot(2,1,1)
                        title([this.subjectcode ' Step Length Error Fast Leg']);
                    else
                        subplot(2,1,2)
                        title([this.subjectcode ' Step Length Error Slow Leg']);
                    end
                    ylim([-0.15 0.15]);
                    xlim([0 h+10]);
                    %                    title([this.subjectcode ' Step Length Error Slow Leg']);
                    xlabel('step #');
                    ylabel('Error (m)');
                    
                    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    %organize the data
                    PossibleTarget=unique(rts{1});
                    LLL=max(PossibleTarget);
                    SS=min(PossibleTarget);
                    MM=PossibleTarget(mode([find(PossibleTarget~=min(PossibleTarget)) find(PossibleTarget~=max(PossibleTarget))]));
                    
                    for z = 1:length(filename)
                        
                        for t=1:length(rts{z})
                            if rts{z}(t)==LLL
                                RDATA(t)=3;
                            elseif rts{z}(t)==SS
                                RDATA(t)=1;
                            elseif rts{z}(t)==MM
                                RDATA(t)=2;
                            else
                                break
                            end
                        end
                        
                        for t=1:length(lts{z})
                            if lts{z}(t)==LLL
                                LDATA(t)=3;
                            elseif lts{z}(t)==SS
                                LDATA(t)=1;
                            elseif lts{z}(t)==MM
                                LDATA(t)=2;
                            else
                                break
                            end
                        end
                        
                        t=1;
                        r=1;
                        RR{z}=[0, 0, 0];
                        while t<length(rts{z})
                            RR{z}(r, RDATA(t))=mean(rhits{z}(t:(find(RDATA(t:end)~=RDATA(t),1, 'first')+t-2)));
                            if isnan(RR{z}(r, RDATA(t)))
                                RR{z}(r, RDATA(t))=mean(rhits{z}(t:end));
                            end
                            t=find(RDATA(t:end)~=RDATA(t),1, 'first')+t-1;
                            if isempty(t)
                                t=length(rts{z});
                            end
                            if  RR{z}(r, RDATA(t))~=0;
                                r=r+1;
                            end
                        end
                        t=1;
                        r=1;
                        LL{z}=[0, 0, 0];
                        while t<length(lts{z})
                            LL{z}(r, LDATA(t))=mean(lhits{z}(t:(find(LDATA(t:end)~=LDATA(t),1, 'first')+t-2)));
                            if isnan(LL{z}(r, LDATA(t)))
                                LL{z}(r, LDATA(t))=mean(lhits{z}(t:end));
                            end
                            t=find(LDATA(t:end)~=LDATA(t),1, 'first')+t-1;
                            if isempty(t)
                                t=length(lts{z});
                            end
                            if  LL{z}(r,LDATA(t))~=0;
                                r=r+1;
                            end
                        end
                        clear RDATA LDATA
                    end
                    DDR{1}=RR{4}-RR{3};
                    DDR{2}=nanmean(RR{5}-RR{2});
                    
                    DDL{1}=LL{4}-LL{3};
                    DDL{2}=nanmean(LL{5}-LL{2});
                    
                    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    for z = 2%1:length(filename)
                        figure(4)
                        if this.fastleg == 'r'
                            subplot(2,3,1)
                        else
                            subplot(2,3,4)
                        end
                        hold on
                        bar(RR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg: Baseline Map Test'])
                        ylabel('Error (m)')
                        legend({'Short', 'Medium', 'Long'})
                        xlabel('Set')
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 2%1:length(filename)
                        figure(4)
                        if this.fastleg == 'l'
                            subplot(2,3,1)
                        else
                            subplot(2,3,4)
                        end
                        hold on
                        bar(LL{z})
                        xlabel('Set')
                        title([this.subjectcode ' SlowLeg: Baseline Map Test'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 5%1:length(filename)
                        figure(4)
                        if this.fastleg == 'r'
                            subplot(2,3,2)
                        else
                            subplot(2,3,5)
                        end
                        hold on
                        bar(RR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg: Post-Adaptation Map Test'])
                        ylabel('Error (m)')
                        xlabel('Set')
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 5%1:length(filename)
                        figure(4)
                        if this.fastleg == 'l'
                            subplot(2,3,2)
                        else
                            subplot(2,3,5)
                        end
                        hold on
                        bar(LL{z})
                        xlabel('Set')
                        title([this.subjectcode ' SlowLeg: Post Adaptation Map Test'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 2%1:length(filename)
                        figure(4)
                        if this.fastleg == 'r'
                            subplot(2,3,3)
                        else
                            subplot(2,3,6)
                        end
                        hold on
                        
                        bar(DDR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg Map Test (Washtout-Baseline)'])
                        ylabel('Error (m)')
                        %legend({'Short', 'Medium', 'Long'})
                        %xlabel('Set')
                        set(gca, 'XTickLabel',{'Short', 'Medium', 'Long'}, 'XTick',1:3)
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 2%1:length(filename)
                        figure(4)
                        if this.fastleg == 'l'
                            subplot(2,3,3)
                        else
                            subplot(2,3,6)
                        end
                        hold on
                        bar(DDL{z})
                        %xlabel('Set')
                        set(gca, 'XTickLabel',{'Short', 'Medium', 'Long'}, 'XTick',1:3)
                        title([this.subjectcode ' SlowLeg Map Test (Washtout-Baseline)'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    
                    
                    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    for z = 3%1:length(filename)
                        figure(5)
                        if this.fastleg == 'r'
                            subplot(2,3,1)
                        else
                            subplot(2,3,4)
                        end
                        hold on
                        bar(RR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg: Baseline Error Clamp'])
                        ylabel('Error (m)')
                        legend({'Short', 'Medium', 'Long'})
                        xlabel('Set')
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 3%1:length(filename)
                        figure(5)
                        if this.fastleg == 'l'
                            subplot(2,3,1)
                        else
                            subplot(2,3,4)
                        end
                        hold on
                        bar(LL{z})
                        xlabel('Set')
                        title([this.subjectcode ' SlowLeg: Baseline Error Clamp'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 4%1:length(filename)
                        figure(5)
                        if this.fastleg == 'r'
                            subplot(2,3,2)
                        else
                            subplot(2,3,5)
                        end
                        hold on
                        bar(RR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg: Post-Adaptation Error Clamp'])
                        ylabel('Error (m)')
                        xlabel('Set')
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 4%1:length(filename)
                        figure(5)
                        if this.fastleg == 'l'
                            subplot(2,3,2)
                        else
                            subplot(2,3,5)
                        end
                        hold on
                        bar(LL{z})
                        xlabel('Set')
                        title([this.subjectcode ' SlowLeg: Post Adaptation Error Clamp'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 1%1:length(filename)
                        figure(5)
                        if this.fastleg == 'r'
                            subplot(2,3,3)
                        else
                            subplot(2,3,6)
                        end
                        hold on
                        %bar(RR{z})
                        bar(DDR{z})
                        h = h+length(rhits{z});
                        title([this.subjectcode ' Fastleg Error Clamp (Washtout-Baseline)'])
                        ylabel('Error (m)')
                        %legend({'Short', 'Medium', 'Long'})
                        
                        xlabel('Set')
                        ylim([-0.255 0.255])
                    end
                    
                    for z = 1%1:length(filename)
                        figure(5)
                        if this.fastleg == 'l'
                            subplot(2,3,3)
                        else
                            subplot(2,3,6)
                        end
                        hold on
                        bar(DDL{z})
                        xlabel('Set')
                        
                        title([this.subjectcode ' SlowLeg Error Clamp (Washtout-Baseline)'])
                        ylabel('Error (m)')
                        h = h+length(lhits{z});
                        ylim([-0.255 0.255])
                    end
                    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                end
            end
        end
        
        function []=editTriallist(this)
            global t
            global ID
            ID = this.subjectcode;
            
            if isempty(this.triallist)%if triallist is empty, start from scratch
                [filenames,~] = uigetfiles('*.*','Select filenames');
                this.data = cell(length(filenames),1);
                if iscell(filenames)
                    f = figure;
                    data = cell(length(filenames),4);
                    data(:,1)=filenames;
                    
                    for z=1:length(filenames)%autodetect if a trial was a train for evaluation
                        tname = filenames{z};
                        if strcmp(tname(end-5:end-4),'V3')
                            data{z,3} = 'train';
                        else
                            data{z,3} = 'eval';
                        end
                    end
                    %                     keyboard
                    colnames = {'Filename','#','type','category'};
                    columnformat = {'char','numeric',{'train','eval'},{'Familiarization','Base Map','Base Clamp','Post Clamp','Post Map'}};
                    t=uitable(f,'Position',[10,10,375,375],'Data',data,'ColumnName',colnames,'ColumnFormat',columnformat,'ColumnEditable',[true true true true]);
                    set(t,'celleditcallback','global ID;global t;temp = get(t,''Data'');eval([ID ''.triallist = temp;'']);');
                    set(t,'DeleteFcn','global ID;eval([ID ''.saveit()'']);');
                else
                    f = figure;
                    data = cell(1,4);
                    data(1,1) = filenames;
                    if strcmp(filenames(end-5:end-4),'V3')
                        data(1,3) = 'train';
                    else
                        data(1,3) = 'eval';
                    end
                    colnames = {'Filename','#','type','category'};
                    columnformat = {'char','numeric',{'train','eval'},{'training','baseline','adaptation','washout'}};
                    t=uitable(f,'Position',[10,10,375,375],'Data',data,'ColumnName',colnames,'ColumnFormat',columnformat,'ColumnEditable',[true true true true]);
                    set(t,'celleditcallback','global ID;global t;temp = get(t,''Data'');eval([ID ''.triallist = temp;'']);');
                    set(t,'DeleteFcn','global ID;eval([ID ''.saveit()'']);');
                end
                
            else %if triallist is already populated, just edit what is already there
                [filenames,~] = uigetfiles('*.*','Select filenames');
                this.data = cell(length(filenames),1);
                if iscell(filenames)
                    f = figure;
                    data = cell(length(filenames),4);
                    data(:,1)=filenames;
                    data(:,2:4) = this.triallist(:,2:4);
                    colnames = {'Filename','#','type','category'};
                    columnformat = {'char','numeric',{'train','eval'},{'training','baseline','adaptation','washout'}};
                    t=uitable(f,'Position',[10,10,375,375],'Data',data,'ColumnName',colnames,'ColumnFormat',columnformat,'ColumnEditable',[true true true true]);
                    set(t,'celleditcallback','global ID;global t;temp = get(t,''Data'');eval([ID ''.triallist = temp;'']);');
                    set(t,'DeleteFcn','global ID;eval([ID ''.saveit()'']);');
                else
                    f = figure;
                    data = cell(1,4);
                    data(1,1) = filenames;
                    data(1,2:4) = this.triallist(1,2:4);
                    colnames = {'Filename','#','type','category'};
                    columnformat = {'char','numeric',{'train','eval'},{'training','baseline','adaptation','washout'}};
                    t=uitable(f,'Position',[10,10,375,375],'Data',data,'ColumnName',colnames,'ColumnFormat',columnformat,'ColumnEditable',[true true true true]);
                    set(t,'celleditcallback','global ID;global t;temp = get(t,''Data'');eval([ID ''.triallist = temp;'']);');
                    set(t,'DeleteFcn','global ID;eval([ID ''.saveit()'']);');
                end
                
            end
        end
        
        function []=saveit(this)%save instance as the "subjectcode_SLBF"
            
            if isempty(this.subjectcode)
                cprintf('err','WARNING: save failed, no valid ID present');
            else
                savename = [this.subjectcode '_PerceptionBF_day.mat'];
                eval([this.subjectcode '=this;']);
                save(savename,this.subjectcode);
            end
        end
        
        function [dataCol]=getDataCol(this, dataname)
            for z=1:length(this.triallist)
                col=find(cellfun(@(x) strcmp(x, dataname), this.dataheader));
                if isempty(col)
                    cprintf('err','WARNING: no data with requested name found');
                    break
                end
                dataCol{z}=this.data{1, z}(:, col);
            end
        end
        
        function [rhits, lhits, rts, lts, color]=getHits(this)
            
            filename = this.triallist(:,1);
            
            if iscell(filename)%if more than one file is selected for analysis
                
                rhits = {0};
                lhits = {0};
                rlqr = {0};
                llqr = {0};
                color = {};
                %WB = waitbar(0,'Processing Trials...');
                for z = 1:length(filename)
                    tempname = filename{z};
                    %waitbar((z-1)/length(filename),WB,['Processing Trial ' num2str(z)]);
                    
                    if strcmp(this.triallist{z,4},'Familiarization')
                        color{z} = [189/255,15/255,18/255];%red
                    elseif strcmp(this.triallist{z,4},'Base Map')
                        color{z} = [48/255,32/255,158/255];%blue
                    elseif strcmp(this.triallist{z,4},'Base Clamp')
                        color{z} = [1,.8,0];%
                    elseif strcmp(this.triallist{z,4},'Post Clamp')
                        color{z} = [91/255,122/255,5/255];%green
                    elseif strcmp(this.triallist{z,4},'Post Map')
                        color{z} = [9/255,109/255,143/255];%bluegrey
                    end
                    %                        keyboard
                    
                    
                    %check to see if data is already processed, it will
                    %save time...
                    if length(this.data)<z
                        disp('Parsing data...');
                        
                        f = fopen(filename{z});
                        g = fgetl(f);
                        fclose(f);
                        
                        if strcmp(g(1),'[')
                            [header,data] = JSONtxt2cell(filename{z});
                            this.data{z} = data;
                            this.dataheader = header;
                        else
                            S = importdata(filename{z},',',1);
                            data = S.data;
                            this.data{z} = S.data;
                            this.dataheader = S.textdata;
                        end
                        
                        
                    else
                        data = cell2mat(this.data(z));
                        header = this.dataheader;
                    end
                    [~,n] = size(data);
                    %                        keyboard
                    data2 = unique(data,'rows','stable');%remove duplicate frames
                    data2(:,1) = data2(:,1)-data2(1,1)+1;%set frame # to start at 1
                    
                    %check for monotonicity
                    checkers = find(diff(data2(:,1))<1);
                    while ~isempty(checkers)
                        for y=1:length(checkers)
                            data2(checkers(y),:)=[];
                        end
                        checkers = find(diff(data2(:,1))<1);
                    end
                    %                        keyboard
                    for zz = 1:n
                        data3(data2(:,1),zz) = data2(:,zz);
                    end
                    frame = data3(:,1);
                    frame2 = 1:1:data2(end,1);
                    %                        keyboard
                    Rz2 = interp1(data2(:,1),data2(:,2),frame2,'linear');
                    Lz2 = interp1(data2(:,1),data2(:,3),frame2,'linear');
                    Rgamma2 = interp1(data2(:,1),data2(:,10),frame2,'linear');
                    Lgamma2 = interp1(data2(:,1),data2(:,11),frame2,'linear');
                    target = interp1(data2(:,1),data2(:,14),frame2,'linear');
                    
                    %detect HS
                    for zz = 1:length(Rz2)-1
                        if Rz2(zz) > -10 && Rz2(zz+1) <= -10
                            RHS(zz) = 1;
                        else
                            RHS(zz) = 0;
                        end
                    end
                    [~,trhs] = findpeaks(RHS,'MinPeakDistance',100);
                    RHS = zeros(length(RHS),1);
                    RHS(trhs) = 1;
                    for zz = 1:length(Lz2)-1
                        if Lz2(zz) > -10 && Lz2(zz+1) <= -10
                            LHS(zz) = 1;
                        else
                            LHS(zz) = 0;
                        end
                    end
                    [~,tlhs] = findpeaks(LHS,'MinPeakDistance',100);
                    LHS = zeros(length(LHS),1);
                    LHS(tlhs) = 1;
                    %                        keyboard
                    %%!!!!!!!!!!!!!!!!!!!!!!!%%!!!!!!!!!!!!!!!!!%%%!!!!!!!!!!!!!!!!
                    %calculate errors
                    %                        tamp = abs(Rgamma2(find(RHS)))'-this.Rtmtarget;
                    %                        tamp2 = abs(Lgamma2(find(LHS)))'-this.Ltmtarget;
                    tamp = Rgamma2(find(RHS))-target(find(RHS)-1);
                    tamp2 = Lgamma2(find(LHS))-target(find(LHS)-1);
                    tamp3 = target(find(RHS));
                    tamp4 = target(find(LHS));
                    
                    %delete 5 strides at each transistion
                    K = find(diff(tamp3));
                    K2 = find(diff(tamp4));
                    for y = 1:length(K)
                        tamp(K(y):K(y)+5)=100;
                        tamp3(K(y):K(y)+5)=100;
                    end
                    for y = 1:length(K2)
                        tamp2(K2(y):K2(y)+5)=100;
                        tamp4(K2(y):K2(y)+5)=100;
                    end
                    tamp(tamp==100)=[];
                    tamp2(tamp2==100)=[];
                    tamp3(tamp3==100)=[];
                    tamp4(tamp4==100)=[];
                    
                    rhits{z} = tamp;
                    lhits{z} = tamp2;
                    rts{z} = tamp3;
                    lts{z} = tamp4;
                    
                    clear RHS LHS tamp tamp2
                end
            end
%             waitbar(1,WB,'Processing complete...');
%             pause(0.5);
%             close(WB);
        end
    end
end
