function [Indx, dtw_distance] = Query_distance_RankOne(Qdata,ClusterData,joints_no)
num=length(ClusterData);
adjustment_window_size = 50;
m_num = length(joints_no);
dtw_distance = zeros(1,num);
for i=1:num
    fprintf ('dtw computing %d-%d\n',1,i);
    % cross-correlation distance of tensor vector
%     dtw_distance(1,i)= max(xcorr(Qdata(1:m_num),ClusterData{i}(1:m_num)))+...
%                        max(xcorr(Qdata(m_num+1:m_num*2),ClusterData{i}(m_num+1:m_num*2)))+...
%                        max(xcorr(Qdata(2*m_num+1:end),ClusterData{i}(2*m_num+1:end)));
     % dtw distance of tensor vector
     d = distance_matrix_norm2(Qdata(2*m_num+1:end)',ClusterData{i}(2*m_num+1:end)');
     NaN_index = isnan(d);
     d(NaN_index) = 0;
     I = size(d,1);J = size(d,2);
     d=double(d);
     %% search optimal path using C for acceleratting the computation
     [g,steps] = dtwpath(d,adjustment_window_size); %#ok<NASGU>
     N=I+J;
     D=g/N;
     D=D(2:end,2:end);
     % path=traceback_path(steps);
     min_distance = D(end, end);
     dtw_distance(1,i) = min_distance+norm(Qdata(1:m_num)-ClusterData{i}(1:m_num))+...
         norm(Qdata(m_num+1:m_num*2)-ClusterData{i}(m_num+1:m_num*2));
end
[~,Indx] = sort(dtw_distance,2);