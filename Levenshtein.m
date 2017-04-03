function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

  SE = 0;
  IE = 0;
  DE = 0;
  LEV_DIST = 0;

  total_wordcount = 0;

  hypothesis_text = textread(hypothesis, '%s', 'delimiter', '\n');

  % Constants for directions
  UP = 10;
  LEFT = 11;
  UP_LEFT = 12;

  diary 'Levenshtein_out.txt';
  diary on;
  for hyp_index=1:length(hypothesis_text)
    split_hyp = regexp(hypothesis_text{hyp_index}, '\s', 'split');
    hyp_sentence = split_hyp(3:end);
    m = length(hyp_sentence);

    ref_filename = sprintf('unkn_%s.txt', num2str(hyp_index));
    ref_text = textread([annotation_dir, filesep, ref_filename], '%s', 'delimiter', '\n');
    split_ref = regexp(ref_text{1}, '\s', 'split');
    ref_sentence = split_ref(3:end);
    n = length(ref_sentence);

    total_wordcount = total_wordcount + n;

    distance_matrix = zeros(n + 1, m + 1);
    %backtracking_matrix = zeros(n + 1, m + 1);
    backtracking_matrix = {};

    distance_matrix(1, :) = Inf;
    distance_matrix(:, 1) = Inf;
    distance_matrix(1, 1) = 0;

    disp('=========================');
    disp(sprintf('Filename: %s', ref_filename));
    disp(sprintf('Reference: %s', strjoin(ref_sentence)));
    disp(sprintf('Hypothesis: %s', strjoin(hyp_sentence)));

    for i=2:n+1
      for j=2:m+1
        del = distance_matrix(i - 1, j) + 1;

        sub_modifier = 1;
        if strcmp(ref_sentence{i - 1}, hyp_sentence{j - 1})
          sub_modifier = 0;
        end
        sub = distance_matrix(i - 1, j - 1) + sub_modifier;

        ins = distance_matrix(i, j - 1) + 1;

        distance_matrix(i, j) = min([del, sub, ins]);

        if distance_matrix(i, j) == del
          %backtracking_matrix(i, j) = UP;
          backtracking_matrix{i, j} = 'up';
        elseif distance_matrix(i, j) == ins
          %backtracking_matrix(i, j) = LEFT;
          backtracking_matrix{i, j} = 'left';
        elseif distance_matrix(i, j) == sub
          %backtracking_matrix(i, j) = UP_LEFT;
          backtracking_matrix{i, j} = 'up-left';
        end
      end
    end

    local_se = 0;
    local_de = 0;
    local_ie = 0;

    % count new IE, DE and SEs
    flat_backtracking_matrix = backtracking_matrix(:)';
    for index=1:length(flat_backtracking_matrix)
      %if flat_backtracking_matrix(index) == UP_LEFT
      if strcmp(flat_backtracking_matrix(index), 'up-left')
        local_se = local_se + 1;
        SE = SE + 1;        
      %elseif flat_backtracking_matrix(index) == UP
      elseif strcmp(flat_backtracking_matrix(index), 'up')
        local_de = local_de + 1;
        DE = DE + 1;
      %elseif flat_backtracking_matrix(index) == LEFT
      elseif strcmp(flat_backtracking_matrix(index), 'left')
        local_ie = local_ie + 1;
        IE = IE + 1;
      end
    end

    local_se = local_se / n;
    local_de = local_de / n;
    local_ie = local_ie / n;
    local_lev = local_se + local_de + local_ie;

    disp(sprintf('%s\t%s\t%s\t%s', 'SE', 'DE', 'IE', 'LEV'));
    disp(sprintf('%s\t%s\t%s\t%s', num2str(local_se), num2str(local_de), num2str(local_ie), num2str(local_lev)));
    diary off;
    diary on;
  end

  SE = SE / total_wordcount;
  IE = IE / total_wordcount;
  DE = DE / total_wordcount;

  LEV_DIST = SE + IE + DE;

  total_wordcount
  disp('=========================');
  disp('FINAL RESULTS');
  disp(sprintf('%s\t%s\t%s\t%s', 'SE', 'DE', 'IE', 'LEV'));
  disp(sprintf('%s\t%s\t%s\t%s', num2str(SE), num2str(DE), num2str(IE), num2str(LEV_DIST)));

  diary off;
end
