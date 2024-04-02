%% Analyse output of Callgrind
%%%%%%%%%%%%%%%%%%
% Matthias Kraenzler
% matthias.kraenzler@fau.de
% MK 03-2024
%%%%%%%%%%%%%%%%%%
function callgrindFile = AnalyseCallgrind(callgrindFolder, analysisFolder)

logFileEnding = '.log';
prefixFiles  = '';%'callgrind_';
lengthPrefix = max(length(prefixFiles),1);

nameOfDecoderHelper = strfind(callgrindFolder,filesep);
nameOfDecoder = callgrindFolder(nameOfDecoderHelper(end)+1:end);
callgrindFile = [analysisFolder filesep 'Callgrind_Analysis_' nameOfDecoder '.mat'];

if ~isfile(callgrindFile)
    analysisFiles = dir([callgrindFolder filesep prefixFiles '*' logFileEnding]);

    for i = 1 : size(analysisFiles,1)
        fid = fopen([callgrindFolder filesep analysisFiles(i).name],'r');
        outputText  = fgetl(fid);
        callgrindCollected = 0;
        while ~callgrindCollected
            %Look for:
            %==29096== Events    : Ir Dr Dw I1mr D1mr D1mw ILmr DLmr DLmw Bc Bcm Bi Bim
            %==29096== Collected : 8015504410 1586028897 995317082 14286282 13721311 11602445 99443 223257 6076114 559702608 38672857 3943748 1441734
            if  contains(outputText,'== Events ')
                startOfVariables = strfind(outputText,':');
                eventString{i,1} = outputText(startOfVariables+1:end); %#ok<*NASGU>
                numberOfOutputVariables = length(strfind(outputText(startOfVariables+1:end),' '));
                callgrindCollected = 1;
                % Ir:   I cache reads (Ir, which equals the number of instructions executed)
                % I1mr: I1 cache read misses
                % ILmr: LL cacheinstruction read misses
                % Dr:   D cache reads (Dr, which equals the number of memory reads)
                % D1mr: D1 cache read misses
                % DLmr: LL cache dataread misses
                % Dw:   D cache writes (Dw, which equals the number of memory writes)
                % D1mw: D1 cache write misses
                % DLmw: LL cachedata write misses
                % Bc:   Conditional branches executed
                % Bcm:  conditional branches mispredicted
                % Bi:   Indirect branches executed
                % Bim:  indirect branches mispredicted (Bim).

                % Events    : Ir          Dr         Dw         I1mr     D1mr    D1mw     ILmr   DLmr   DLmw    Bc        Bcm       Bi      Bim
                % Collected : 11513789159 2682299738 1756048555 12488492 9554909 10535630 101460 444530 5710488 731438483 103117235 9544881 4492623
                %
                % I   refs:      11,513,789,159 (Ir)
                % I1  misses:        12,488,492 (I1mr)
                % LLi misses:           101,460 (ILmr)
                % I1  miss rate:           0.11%
                % LLi miss rate:           0.00%
                %
                % D   refs:       4,438,348,293 (Dr+Dw)      (2,682,299,738 rd (Dr) + 1,756,048,555 wr (Dw) )
                % D1  misses:        20,090,539 (D1mr+D1mw)  (    9,554,909 rd (D1mr) +    10,535,630 wr (D1mw))
                % LLd misses:         6,155,018 (DLmr+DLmw)  (      444,530 rd (DLmr) +     5,710,488 wr (DLmw))
                % D1  miss rate:            0.5% (          0.4%   +           0.6%  )
                % LLd miss rate:            0.1% (          0.0%   +           0.3%  )
                %
                % LL refs:           32,579,031 (D1mr+D1mw+I1mr) (   22,043,401 rd (D1mr+I1mr)  +    10,535,630 wr (D1mw))
                % LL misses:          6,256,478 (DLmr+DLmw+ILmr)  (      545,990 rd (DLmr+ILmr) +     5,710,488 wr (DLmw) )
                % LL miss rate:             0.0% (          0.0%   +           0.3%  )
                %
                % Branches:         740,983,364  (  731,438,483 cond (Bc)  +     9,544,881 ind (Bi))
                % Mispredicts:      107,609,858  (  103,117,235 cond (Bcm) +     4,492,623 ind (Bim))
                % Mispred rate:            14.5% (         14.1%     +          47.1%   )

                outputText  = fgetl(fid);
                if numberOfOutputVariables == 13 % Ir Dr Dw I1mr D1mr D1mw ILmr DLmr DLmw Bc Bcm Bi Bim
                    outputValues = textscan(outputText,'%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f ');
                    Irefs(i,1)= outputValues{1,4};%#ok<*AGROW>
                    Dr(i,1)= outputValues{1,5};
                    Dw(i,1)= outputValues{1,6};
                    I1mr(i,1)= outputValues{1,7};
                    D1mr(i,1)= outputValues{1,8};
                    D1mw(i,1)= outputValues{1,9};
                    ILmr(i,1)= outputValues{1,10};
                    DLmr(i,1)= outputValues{1,11};
                    DLmw(i,1)= outputValues{1,12};
                    Bc(i,1)= outputValues{1,13};
                    Bcm(i,1)= outputValues{1,14};
                    Bi(i,1)= outputValues{1,15};
                    Bim(i,1)= outputValues{1,16};

                    Drefs(i,1) = Dr(i,1) + Dw(i,1);
                    D1misses(i,1) = D1mr(i,1)+D1mw(i,1);
                    LLdmisses(i,1) = DLmr(i,1)+DLmw(i,1);

                    LLrefs(i,1) = D1mr(i,1)+D1mw(i,1)+I1mr(i,1);
                    LLmisses(i,1) = DLmr(i,1)+DLmw(i,1)+ILmr(i,1);

                else %  Ir Dr Dw I1mr D1mr D1mw ILmr DLmr DLmw
                    outputValues = textscan(outputText,'%s %s %s %f %f %f %f %f %f %f %f %f ');
                    Irefs(i,1)= outputValues{1,4};
                    Dr(i,1)= outputValues{1,5};
                    Dw(i,1)= outputValues{1,6};
                    I1mr(i,1)= outputValues{1,7};
                    D1mr(i,1)= outputValues{1,8};
                    D1mw(i,1)= outputValues{1,9};
                    ILmr(i,1)= outputValues{1,10};
                    DLmr(i,1)= outputValues{1,11};
                    DLmw(i,1)= outputValues{1,12};

                    Drefs(i,1) = Dr(i,1) + Dw(i,1);
                    D1misses(i,1) = D1mr(i,1)+D1mw(i,1);
                    LLdmisses(i,1) = DLmr(i,1)+DLmw(i,1);

                    LLrefs(i,1) = D1mr(i,1)+D1mw(i,1)+I1mr(i,1);
                    LLmisses(i,1) = DLmr(i,1)+DLmw(i,1)+ILmr(i,1);
                end
            end
            outputText  = fgetl(fid);
        end

        timeCollected = 0;
        try
            while ~timeCollected
                % real	5m10.694s
                % user	5m13.980s
                % sys	0m0.704s
                if  contains(outputText,'real')
                    timeString = outputText(5:end);
                    timeStringMinute = strfind(timeString,'m');
                    minutes = str2double(timeString(1:timeStringMinute-1));
                    seconds = str2double(timeString(timeStringMinute+1:end-1));
                    realTime(i,1) = minutes * 60 + seconds;

                    outputText  = fgetl(fid);
                    timeString = outputText(5:end);
                    timeStringMinute = strfind(timeString,'m');
                    minutes = str2double(timeString(1:timeStringMinute-1));
                    seconds = str2double(timeString(timeStringMinute+1:end-1));
                    userTime(i,1) = minutes * 60 + seconds;

                    outputText  = fgetl(fid);
                    timeString = outputText(4:end);
                    timeStringMinute = strfind(timeString,'m');
                    minutes = str2double(timeString(1:timeStringMinute-1));
                    seconds = str2double(timeString(timeStringMinute+1:end-1));
                    sysTime(i,1) = minutes * 60 + seconds;
                    timeCollected = 1;
                end
                outputText  = fgetl(fid);
            end
        catch 
            realTime = 0;
            userTime = 0;
            sysTime = 0;
        end
        fclose(fid);

        sequenceList{i,1} = analysisFiles(i).name(lengthPrefix:end);

    end


    if numberOfOutputVariables == 13        
        ic.Ir = Irefs;
        ic.Dr = Dr;
        ic.Dw = Dw;
        ic.I1mr = I1mr;
        ic.D1mr = D1mr;  
        ic.D1mw = D1mw;
        ic.ILmr = ILmr;
        ic.DLmr = DLmr;
        ic.DLmw = DLmw;
        ic.Bi = Bi;
        ic.Bim = Bim;
        ic.Bc = Bc;
        ic.Bcm = Bcm;
        ic.branches = Bi + Bc;
        ic.mispred = Bcm + Bim;
        save(callgrindFile,'ic','Irefs','Dr','Dw', ...
            'I1mr','D1mr','D1mw',...
            'ILmr','DLmr','DLmw',...
            'Bc','Bcm','Bi','Bim',...
            'Drefs','D1misses','LLdmisses',...
            'LLrefs','LLmisses',...
            'realTime','userTime','sysTime',...
            'sequenceList','eventString','callgrindFolder');
    else
        ic.Ir = Irefs;
        ic.Dr = Dr;
        ic.Dw = Dw;
        ic.I1mr = I1mr;
        ic.D1mr = D1mr;  
        ic.D1mw = D1mw;
        ic.ILmr = Ilmr;
        ic.DLmr = DLmr;
        ic.DLmw = DLmw;
        save(callgrindFile,'ic','Irefs','Dr','Dw', ...
            'I1mr','D1mr','D1mw',...
            'ILmr','DLmr','DLmw',...
            'Drefs','D1misses','LLdmisses',...
            'LLrefs','LLmisses',...
            'realTime','userTime','sysTime',...
            'sequenceList','eventString','callgrindFolder');
    end
end
end