function [sorted , idx]= sortDisImg(data, labeled, score,name_label)
    index_pos = find(labeled == 1);
    name_data = name_label(:,end);
    name_pos = name_data(index_pos);
%     data_feed = data(index_pos,1:end -1);

    dis_pos = score(index_pos,2); 
    pos = [num2cell(dis_pos) name_pos];
%     pos = pos(cell2mat(pos(:,1))<=le,:)
    [sortedDistPos indx] = sortrows(pos);
%     sortedImgsPos = sortedDistPos(:, 2);
    
    
    index_neg = find(labeled~= 1);
    name_neg = name_data(index_neg);
%     data_feed_neg = data(index_neg,1:end -1);
%     le = margin(svm,svm.SupportVectors,svm.SupportVectorLabels);
%     le = max(le)/2
    dis_neg = score(index_neg,2);
    neg = [num2cell(dis_neg) name_neg];
    [sortedDistNeg indx1] = sortrows(neg);
    if(size(sortedDistPos,1)~=1)
        sorted = [flip(sortedDistPos);flip(sortedDistNeg)];
        idx = [flip(index_pos(indx));flip(index_neg(indx1))];
    else
         sorted = [sortedDistPos;sortedDistNeg];
         idx = [index_pos(indx) ;index_neg(indx1)];
    end
    
%     sorted = [sortedDistPos;flip(sortedDistNeg)]
%     sortedImgsNeg = sortedDistNeg(:, 2);