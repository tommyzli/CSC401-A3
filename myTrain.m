% get access to BNT
addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'));

training_dir_path = '/u/cs401/speechdata/Training';
M = 8;
Q = 3;
init_type = 'kmeans';
max_iter = 15;

if ~exist('phonemes.mat')
  disp('building phoneme struct');
  training_dir_contents = regexp(ls(training_dir_path), '\s', 'split');
  % remove empty strings from the array
  training_dir_contents = training_dir_contents(~cellfun('isempty', training_dir_contents));

  phonemes = struct();
  for speaker_index=1:length(training_dir_contents)
    speaker_path = strcat(training_dir_path, filesep, training_dir_contents(speaker_index), filesep);
    phoneme_files = dir([speaker_path{1}, '*.phn']);
    mfcc_files = dir([speaker_path{1}, '*.mfcc']);

    for file_index=1:length(phoneme_files)
      phoneme_file = phoneme_files(file_index).name;
      mfcc_file = mfcc_files(file_index).name;

      mfcc_vectors = dlmread(strcat(char(speaker_path), mfcc_file));

      phoneme_text = textread([char(speaker_path), phoneme_file], '%s', 'delimiter', '\n');
      for phoneme_index=1:length(phoneme_text)
        line = regexp(phoneme_text{phoneme_index}, '\s', 'split');

        % divide by 128 to match mfcc window, and make sure not to go out of bounds
        p_begin = max(str2num(line{1})/128, 1);
        p_end = min(str2num(line{2})/128, size(mfcc_vectors, 1));

        phoneme = line{3};
        if strcmp(phoneme, 'h#')
          phoneme = 'sil';
        end

        mfcc_section = mfcc_vectors(p_begin:p_end, :)';
        if ~isfield(phonemes, phoneme)
          phonemes.(phoneme) = {mfcc_section};
        else
          count = length(phonemes.(phoneme));
          phonemes.(phoneme){count + 1} = mfcc_section;
        end
      end
    end
  end
  save('phonemes.mat', 'phonemes', '-mat');
else
  disp('loading presaved phoneme struct');
  load('phonemes.mat', '-mat');
end

observed_phonemes = fieldnames(phonemes);
hmms = struct();
trained_hmms = struct();

for i=1:length(observed_phonemes)
  phoneme_data = phonemes.(observed_phonemes{i});

  disp(sprintf('initializing hmm for %s', observed_phonemes{i}));
  hmms.(observed_phonemes{i}) = initHMM(phoneme_data, M, Q, init_type);

  disp(sprintf('training hmm for %s', observed_phonemes{i}));
  [trained_HMM, ~] = trainHMM(hmms.(observed_phonemes{i}), phoneme_data, max_iter);

  trained_hmms.(observed_phonemes{i}) = trained_HMM;
end

save('trained_hmms.mat', 'trained_hmms', '-mat');
