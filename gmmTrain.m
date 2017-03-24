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

    speaker_files = {};
    for file_index=1:length(speaker_directory)
      new_file = textread([dir_train, filesep, training_dir{dir_index}, filesep, speaker_directory(file_index).name], '%s', 'delimiter', '\n');
      speaker_files = [speaker_files; new_file];
    end
    
    [mn, weight, covariance] = initialize_theta(speaker_files, M);

    % TODO: rest of stuff



    gmms = [gmms; new_gmm];
  end
return


function [mn, weight, covariance] = initialize_theta( files, M )
  % means are selected randomly
  rand_index = floor(length(files) * rand(1));
  mn = files(rand_index:(rand_index + M - 1), :)';

  % weights are initially uniform
  weight = ones(1, M) * 1/M;

  % covariances are identity matrices
  covariance = repmat(eye(size(files, 2)), 1, 1, M);

return
