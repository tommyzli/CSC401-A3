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

  training_dir = strsplit(ls(training_dir));
  % remove last element (always an empty string)
  training_dir(length(training_dir)) = [];

  for dir_index=1:length(training_dir)
    new_gmm = struct();
    new_gmm.name = training_dir{dir_index};

    speaker_directory = dir([training_dir, filesep, training_dir{dir_index}, filesep, '*', 'mfcc']);

    speaker_files = {};
    for file_index=1:length(speaker_directory)
      speaker_files = [speaker_files, textread([speaker_directory, filesep, speaker_directory(file_index).name], '%s', 'delimiter', '\n')];
    end
    
    [mn, weight, covariance] = initialize_theta(speaker_files, M);




    gmms = [gmms, new_gmm];
  end
return


function [mn, weight, covariance] = initialize_theta( files, M )
  weight = ones(1, M) * 1/M;
return
