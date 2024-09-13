% Function called by: main.m
% Role of function is to run the experiment, start to finish 
% Parameters: Parameters (Things to be used for the experiment)
% Return Values: None

function Experiment(Parameters)
    %% Do some precalculations
    % Get the word List and randomize it
    importWord = readtable("Words.xlsx");
    importBlock = importWord.Properties.VariableNames;
    wordList = cell(1, width(importWord));
    blockList = cell(1, width(importWord));
    numBlocks = width(importWord);
    numWords = 0;

    for blkIdx = 1:length(importBlock)
        blockList{blkIdx} = split(importBlock{blkIdx}, "_");
        blockWords = importWord.(importBlock{blkIdx});
        blockWords(cellfun(@isempty,blockWords)) = [];
        blockLength = length(blockWords);
        blockWords = blockWords(randperm(blockLength));
        numWords = numWords + blockLength;
        wordList{blkIdx} = blockWords;
    end
    
    wordIdx = 1;
    
    % Instantiate the trial and block indeces
    allChoices = table('Size', [numWords, 4], 'VariableTypes', ["string", "string", "double", "double"], ...
                       'VariableNames', ["Word", "Choice", "ResponseTime", "FixationTime"]);
    
    
    % Change to the directory that saves the data
    cd(Parameters.outputDir);

    
    %% Carry out the task
    % Carry out the Introduction to the task
    % if Parameters.trial.showIntro
    %     Introduction(Parameters);
    % end
    % return
   

    % Go through the word List
    for blockIdx = 1:numBlocks
        blockChoices = table('Size', [length(wordList{blockIdx}), 4], 'VariableTypes', ["string", "string", "double", "double"], ...
                       'VariableNames', ["Word", "Choice", "ResponseTime", "FixationTime"]);
        choices = blockList{blockIdx};
        curWordList = wordList{blockIdx};
        

        block_start(Parameters, blockIdx, choices);
        blockEvents = Create_Event(Parameters.ID, "blockStart", blockIdx);
        
        for trialIdx = 1:length(curWordList)
            % Run the Trial
            [output, trialEvents] = Run_Trial(Parameters, curWordList{trialIdx}, choices, blockIdx, trialIdx);

            % ASSIGN OUTPUT FOR STORAGE
            % Store the overall choices
            allChoices.Word(wordIdx) = curWordList{trialIdx};
            allChoices.Choice(wordIdx) = output.userChoice;
            allChoices.ResponseTime(wordIdx) = output.responseTime;
            allChoices.FixationTime(wordIdx) = output.fixationTime;

            % Store the choices per block
            blockChoices.Word(trialIdx) = curWordList{trialIdx};
            blockChoices.Choice(trialIdx) = output.userChoice;
            blockChoices.ResponseTime(trialIdx) = output.responseTime;
            blockChoices.FixationTime(trialIdx) = output.fixationTime;

            % Store the Events
            blockEvents = [blockEvents; trialEvents];
            Parameters.new_event(blockEvents);

            % END OF LOOP OPERATIONS
            % Increment the trial number
            wordIdx = wordIdx+1;

            % If we need to abort, abort
            if strcmpi(output.userChoice, 'Abort')
                Parameters.new_event(Create_Event(Parameters.ID, "taskAbort"));
                break;
            end
        end

        block_switch(Parameters, blockIdx);

        % Mark the end of the block and store it
        blockEvents = [blockEvents; Create_Event(Parameters.ID, "blockEnd", blockIdx)];
        Parameters.new_event(blockEvents);

        % Save the data that we have
        filename = sprintf("Block_%d.mat", blockIdx);
        save(filename, "blockChoices", "blockEvents");

        % If we need to abort, abort
        if strcmpi(output.userChoice, 'Abort');  break; end
    end
    
    % Save the variables at the end of the experiment
    save("Output.mat", "allChoices", "Parameters");
    Parameters.save_events()
    
    Screen('TextSize', Parameters.screen.window, Parameters.text.size.default);
    DrawFormattedText(Parameters.screen.window, 'End', 'center', 'center', 252:255);
    Flip_Screen(Parameters)
end

%% HELPER FUNCTIONS
% blockStart - prints a message at the start of each block
% Arguments:
%   - Pars       (Reference to the parameters)
%   - Block_Idx  (The block number)
%   - Num_Blocks (The total number of blocks)
%   - Cpu_Name   (The name of the cpu player)
% Outputs: None
function block_start(Pars, Block_Idx, Choices)
    % Generate the text to be printed
    text = sprintf('Starting Block %d\n', Block_Idx);
    text = sprintf("%sChoose between %s and %s.\n", text, upper(Choices{1}), upper(Choices{2}));
    text = sprintf('%sPress any button to continue.', text);
    
    % Print the text and show it
    Screen('TextSize', Pars.screen.window, Pars.text.size.default);
    DrawFormattedText(Pars.screen.window, text, 'center', 'center', 252:255);
    Flip_Screen(Pars);
    
    % Wait for 2 seconds or until a button is pressed
    start = GetSecs();
    while GetSecs()-start < 2
        if KbCheck() || GetXBox().AnyButton; break; end
    end
    WaitSecs(0.3);
end

% blockSwitch - prints a message at the end of each block (except the final one)     
% Arguments:
%   - Pars       (The pointer to the experiment parameters)
%   - Block_Idx  (The block number)
%   - Num_Blocks (The total number of blocks)
%   - Cpu        (A handle to the CPU)
%   - Totals     (The total scores of the experiment)
% Outputs: None
function block_switch(Pars, Block_Idx)
    text = sprintf('Block %d Complete!', Block_Idx);
    text = sprintf('%s\nPress any button to continue.', text);
    
    Screen('TextSize', Pars.screen.window, Pars.text.size.default);
    DrawFormattedText(Pars.screen.window, text, 'center', 'center', 252:255);
    Flip_Screen(Pars);
    
    while ~KbCheck(); end
    WaitSecs(0.3);
end