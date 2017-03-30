function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances.
%                                          (:,:,i) is for i^th mixture

  training_dir = strsplit(ls(dir_train));
  % remove last element (always an empty string)
  training_dir(length(training_dir)) = [];

  for dir_index=1:length(training_dir)
    disp('===============');
    disp(sprintf('Training for %s', training_dir{dir_index}));
    disp('===============');

    new_gmm = struct();
    new_gmm.name = training_dir{dir_index};

    speaker_directory = dir([dir_train, filesep, training_dir{dir_index}, filesep, '*', '.mfcc']);

    mfcc_vectors = [];
    for file_index=1:length(speaker_directory)
      new_file = dlmread(strcat(dir_train, filesep, training_dir{dir_index}, filesep, speaker_directory(file_index).name));
      mfcc_vectors = [mfcc_vectors; new_file];
    end

    theta = initialize_theta(mfcc_vectors, M);

    improvement = Inf;
    prev_L = -Inf;
    i = 0;
    while (i < max_iter & improvement >= epsilon)
      [L, theta] = computeLikelihoodAndUpdateParameters(theta, mfcc_vectors, M);

      disp(sprintf('Old L: %s       New L: %s', prev_L, L));

      improvement = L - prev_L;
      prev_L = L;
      disp(sprintf('Improvement: %s', num2str(improvement)));

      i = i + 1;
    end

    new_gmm.weights = theta.weight;
    new_gmm.means = theta.mean;
    new_gmm.cov = theta.covariance;
    %gmms = [gmms; new_gmm];
    gmms{dir_index} = new_gmm;
  end
  return
end


function theta = initialize_theta( mfcc, M )
  % means are selected randomly
  %{
  rand_indexes = randperm(size(mfcc, 1), M);
  for i=1:M
    mn(:, i) = mfcc(rand_indexes(i), :);
  end
  %}
  for i=1:M
    mn(:, i) = mfcc(1, :);
  end

  % weights are initially uniform
  weight = ones(1, M) * 1/M;

  % covariances are identity matrices
  covariance = repmat(eye(size(mfcc, 2)), 1, 1, M);

  theta = struct();
  theta.mean = mn;
  theta.weight = weight;
  theta.covariance = covariance;

  return
end


function [log_likelihood, theta] = computeLikelihoodAndUpdateParameters( theta, mfcc_vectors, M )
  %  ----- compute log likelihood
  x = size(mfcc_vectors, 1);
  d = size(mfcc_vectors, 2);

  % log(b_m(x_t))
  for i=1:M
    cov = diag(theta.covariance(:, :, i));
    section_1 = -1 * sum( ...
      ((mfcc_vectors - ((ones(x, 1) * theta.mean(:, i)'))) .^ 2) ./ (2 .* cov(:, :, 1))', 2);

    section_2 = ((d/2) * log(2*pi)) + (0.5 * prod(cov));
    log_b_m_xt(:, i) = section_1 - section_2;
  end

  b_m_xt = exp(log_b_m_xt);
  for i=1:M
    weighted_probs(:, i) = theta.weight(i) .* b_m_xt(:, i);
  end

  p_theta_xt = sum(weighted_probs, 2);

  log_likelihood = sum(log(p_theta_xt));

  %  ----- update params
  % P(m | x_t, theta)
  for i=1:M
    p_m_given_xt(:, i) = weighted_probs(:, i) ./ p_theta_xt;
  end

  theta.weight = sum(p_m_given_xt) / x;

  for j=1:M
    sum_p_m_given_xt = sum(p_m_given_xt(:, j));

    multiplier = ones(1, x) - 1;
    multiplier(1) = 1;
    theta.mean(:, j) = sum((p_m_given_xt(:, j) * multiplier) * mfcc_vectors) / sum_p_m_given_xt;

    %{
    mthCov = sum((p_m_given_xt(:, j) * multiplier)' * (mfcc_vectors .^ 2)) / sum_p_m_given_xt;
    theta.covariance(:, :, j) = diag(mthCov(1, :)' - (theta.mean(:, j) .^ 2));
    %}
    cov_section_1 = sum((p_m_given_xt(:, j) * multiplier)' * (mfcc_vectors .^2));
    theta.covariance(:, :, j) = diag((cov_section_1 / sum_p_m_given_xt) - (theta.mean(:, j) .^ 2)');

  end

end
