% README
% Ordnerpfade sind an mein mac mit meinen Speicherpfaden angepasst ->
% anpassen :)

% Ordnerpfade
famousDir = '/Users/yasminhirsch/Psychtoolbox-3/Psychtoolbox/experiment/famous_faces';
nonFamousDir = '/Users/yasminhirsch/Psychtoolbox-3/Psychtoolbox/experiment/non_famous_faces';

% load faces
famousFiles = dir(fullfile(famousDir, '*.jpg'));
nonFamousFiles = dir(fullfile(nonFamousDir, '*.jpg'));

% number of trials
numTrials = 50;

% initialize outcomes
reactionTimesFamous = [];
reactionTimesNonFamous = [];
falsePositives = 0; % Falsche Reaktionen: famous -> DownArrow
falseNegatives = 0; % Falsche Reaktionen: nonFamous -> UpArrow

% open psychtoolbox 
[win, rect] = Screen('OpenWindow', max(Screen('Screens')));
[centerX, centerY] = RectCenter(rect);

% fixation cross
fixSize = 50;
Screen('TextSize', win, 24);

% mask
maskSize = 200;
noise = uint8(rand(maskSize, maskSize) * 255);

% experiment
try
    for trial = 1:numTrials
    
        % fixation cross
        Screen('FillRect', win, [0 0 0]); 
        Screen('DrawLine', win, [255 255 255], centerX - fixSize, centerY, centerX + fixSize, centerY, 2);
        Screen('DrawLine', win, [255 255 255], centerX, centerY - fixSize, centerX, centerY + fixSize, 2);
        Screen('Flip', win);
        WaitSecs(1);

        % mask for some jittered (random) time 
        randomTime = 0.5 + (rand * 1.0); % Zufälliger Wert zwischen 0.5 und 1.5 Sekunden
        texture = Screen('MakeTexture', win, noise);
        Screen('DrawTexture', win, texture, [], CenterRect([0 0 maskSize maskSize], rect));
        Screen('Flip', win);
        WaitSecs(randomTime);
        Screen('Close', texture);

        % random face 
        isFamous = rand > 0.5;
        if isFamous
            imgFile = famousFiles(randi(length(famousFiles))).name;
            category = 'famous';
            imgPath = fullfile(famousDir, imgFile);
        else
            imgFile = nonFamousFiles(randi(length(nonFamousFiles))).name;
            category = 'nonFamous';
            imgPath = fullfile(nonFamousDir, imgFile);
        end

        % pictures have same size
        img = imread(imgPath);
        img = imresize(img, [300, 300]); 
        texture = Screen('MakeTexture', win, img);
        Screen('DrawTexture', win, texture, [], CenterRect([0 0 300 300], rect));
        Screen('Flip', win);

        % reaction time
        startTime = GetSecs;
        keyIsDown = false;
        while ~keyIsDown
            [keyIsDown, ~, keyCode] = KbCheck;
        end
        reactionTime = GetSecs - startTime;

        % save reaction time and false reactions
        if isFamous
            if keyCode(KbName('UpArrow'))
                reactionTimesFamous = [reactionTimesFamous, reactionTime];
            elseif keyCode(KbName('DownArrow'))
                falsePositives = falsePositives + 1; 
            end
        else
            if keyCode(KbName('DownArrow'))
                reactionTimesNonFamous = [reactionTimesNonFamous, reactionTime];
            elseif keyCode(KbName('UpArrow'))
                falseNegatives = falseNegatives + 1; 
            end
        end

        Screen('Close', texture);
    end

    % end
    Screen('CloseAll');
    avgFamous = mean(reactionTimesFamous);
    avgNonFamous = mean(reactionTimesNonFamous);

    % print outcome
    fprintf('Average Reaction Time (Famous Faces): %.2f Sekunden\n', avgFamous);
    fprintf('Average Reaction Time (Non-Famous Faces): %.2f Sekunden\n', avgNonFamous);
    fprintf('False Positives (Famous Faces, DownArrow): %d\n', falsePositives);
    fprintf('False Negatives (Non-Famous Faces, UpArrow): %d\n', falseNegatives);
catch ME
    Screen('CloseAll');
    rethrow(ME);
end
