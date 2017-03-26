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

  gmms = {};

  training_dir = strsplit(ls(dir_train));
  % remove last element (always an empty string)
  training_dir(length(training_dir)) = [];

  for dir_index=1:length(training_dir)
    new_gmm = struct();
    new_gmm.name = training_dir{dir_index};

    speaker_directory = dir([dir_train, filesep, training_dir{dir_index}, filesep, '*', '.mfcc']);

    mfcc_vectors = {};
    for file_index=1:length(speaker_directory)
      new_file = textread([dir_train, filesep, training_dir{dir_index}, filesep, speaker_directory(file_index).name], '%s', 'delimiter', '\n');
      mfcc_vectors = [mfcc_vectors; new_file];
    end
    
    theta = initialize_theta(mfcc_vectors, M);

    improvement = Inf;
    prev_L = -Inf;
    i = 0;
    while i < max_iter && improvement >= epsilon
      L = computeLikelihood(theta, mfcc_vectors, M);
      theta = updateParameters(theta, mfcc_vectors, M, L);

      disp(sprintf('Old L: %s       New L: %s', num2str(prev_L), num2str(L)));

      improvement = abs(L - prev_L);
      prev_L = L;

      i = i + 1;
    end

    new_gmm.weights = theta.weight;
    new_gmm.means = theta.mean;
    new_gmm.cov = theta.covariance;
    gmms = [gmms; new_gmm];
  end
return


function theta = initialize_theta( mfcc, M )
  % means are selected randomly
  rand_index = floor(length(mfcc) * rand(1));
  mn = mfcc(rand_index:(rand_index + M - 1), :)';

  % weights are initially uniform
  weight = ones(1, M) * 1/M;

  % covariances are identity matrices
  covariance = repmat(eye(size(mfcc, 2)), 1, 1, M);

  theta = struct();
  theta.mean = mn;
  theta.weight = weight;
  theta.covariance = covariance;

return


function log_likelihood = computeLikelihood( theta, mfcc_vectors, M )
  d = size(mfcc_vectors, 2);
  cov = diag(theta.covariance(:, :, M));

  section_1 = 0;
  for i=1:d
    section_1 = section_1 + (0.5 * (mfcc_vectors{i}^2) * (1 / (cov(i)^2)) - (theta.means{i} * mfcc_vectors{i} * (1 / (cov(i)^2)));
  end
  section_1 = section_1 * -1;

  section_2 = 0;
  for j=1:d
    section_2 = section_2 + ((theta.means{j}^2) / (2 * (1 / (cov(i)^2))));
  end
  section_2 = section_2 + (D/2 * log(2 * pi)) + (0.5 * prod(cov .^ 2));

  log_likelihood = section_1 - section_2;

end

function new_theta = updateParameters( theta, mfcc_vectors, M, L )
  new_theta = struct();
  new_theta.name = theta.name;
end
