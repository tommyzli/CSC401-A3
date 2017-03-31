training_dir = '/u/cs401/speechdata/Training';
testing_dir = '/u/cs401/speechdata/Testing';
max_iter = 100;
epsilon = 0.1;
M = 8;
gmm_vector = gmmTrain(training_dir, max_iter, epsilon, M);

test_files = dir([testing_dir, filesep, '*.mfcc']);
for file_index=1:length(test_files)
  disp(num2str(file_index));
  file = dlmread(strcat(testing_dir, filesep, sprintf('unkn_%s.mfcc', num2str(file_index))));
  likelihoods = [];
  for gmm_i=1:length(gmm_vector)
    log_likelihood = calculateLikelihood(gmm_vector{gmm_i}, file, M);
    likelihoods = [likelihoods; log_likelihood];
  end

  [sorted_likelihoods, prev_indexes] = sort(likelihoods, 'descend');

  % print to unkn_N.lik
  diary(sprintf('unkn_%s.lik', num2str(file_index)));
  diary on;

  for i=1:5
    disp(sprintf('Speaker: %s, likelihood: %s ', gmm_vector{prev_indexes(i)}.name, num2str(sorted_likelihoods(i))));
    % force diary to write to file
    diary off;
    diary on;
  end
  diary off;
end
