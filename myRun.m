% get access to BNT
addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'));

testing_dir_path = '/u/cs401/speechdata/Testing';
hmm_file = 'trained_hmms.mat';

load(hmm_file, '-mat')
disp('Loaded trained hmms');

hmm_keys = fieldnames(trained_hmms);

correct = 0;
total = 0;

phoneme_files = dir([testing_dir_path, filesep, '*.phn']);
mfcc_files = dir([testing_dir_path, filesep, '*.mfcc']);
for i=1:length(phoneme_files)
  mfcc_vectors = dlmread(strcat(testing_dir_path, filesep, mfcc_files(i).name));
  phoneme_text = textread([testing_dir_path, filesep, phoneme_files(i).name], '%s', 'delimiter', '\n');

  for j=1:length(phoneme_text)
    line = regexp(phoneme_text{j}, '\s', 'split');
    p_begin = max(str2num(line{1})/128, 1);
    p_end = min(str2num(line{2})/128, size(mfcc_vectors, 1));

    phoneme = line{3};
    if strcmp(phoneme, 'h#')
      phoneme = 'sil';
    end

    mfcc_section = mfcc_vectors(p_begin:p_end, :)';

    max_ll = -Inf;
    for k=1:length(hmm_keys)
      LL = loglikHMM(trained_hmms.(hmm_keys{k}), mfcc_section);
      if LL > max_ll
        disp(sprintf('new max LL for phoneme %s: %s', phoneme, num2str(LL)));
        max_ll = LL;
        max_ll_phoneme = hmm_keys{k};
      end
    end

    if strcmp(phoneme, max_ll_phoneme)
      correct = correct + 1;
    end
    total = total + 1;
  end
end

disp('Accuracy: %s/%s', num2str(correct), num2str(total));
