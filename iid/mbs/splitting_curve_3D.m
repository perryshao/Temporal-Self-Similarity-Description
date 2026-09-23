function MBS = splitting_curve_3D(Curve_xyz,Width)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
%  Width -- segmentation order authorized for the blurred segments
%  Output:
%  MBS -- structure for a list of blurred segments, each of them being defined by its number of points
%  and the characteristics a, b, u, w of a strictly bounding line
%  Initialisation:
%  a=0, b=1, u=0, w=b,
%  MBS = empty
%% Initialisation
 k = 1;Sb = Curve_xyz(1,:);
 n = size(Curve_xyz,1);
 data = {};
 parameter = [0 0 0 0];
 B_E_seg = [];
 MBS = structure(data,parameter,B_E_seg);

 %% begin main procedure
 while k < n,
     k = k+1; Sb(end+1,:) = Curve_xyz(k,:);
     %% determinde the OXY and OXZ plane parameters respectively
     [~,eSegment_xy] = Determine_segment(Sb(:,1:2),Width);
     [~,eSegment_xz] = Determine_segment(Sb(:,1:2:3),Width);
     if eSegment_xz == 0, eSegment_xz=1000;end % MAX U point = 1000 in MEX files
     if eSegment_xy == 0, eSegment_xy=1000;end % MAX U point = 1000 in MEX files
     if min(eSegment_xy,eSegment_xz) < k
        break;
     end
 end
 bSegment = 1; eSegment = min(eSegment_xy,eSegment_xz);
 MBS.data{end+1} = Curve_xyz(bSegment:eSegment,:);
 MBS.B_E_seg(end+1,:) = [bSegment eSegment];
 while k < n

     while k < n, %% perry
         bSegment = bSegment+1;
         Sb = Curve_xyz(bSegment:k,:);
         %% determinde the OXY and OXZ plane parameters respectively
        [~,eSegment_xy] = Determine_segment(Sb(:,1:2),Width);
        [~,eSegment_xz] = Determine_segment(Sb(:,1:2:3),Width);
        if eSegment_xz == 0, eSegment_xz=1000;end % MAX U point = 1000 in MEX files
        if eSegment_xy == 0, eSegment_xy=1000;end % MAX U point = 1000 in MEX files
        if min(eSegment_xy,eSegment_xz) == size(Sb,1)
            break;
        end
     end
     while k < n,
        k = k+1;
        Sb(end+1,:) = Curve_xyz(k,:);
        %% determinde the OXY plane parameters
        [~,eSegment_xy] = Determine_segment(Sb(:,1:2),Width);
        [~,eSegment_xz] = Determine_segment(Sb(:,1:2:3),Width);
        if eSegment_xz == 0, eSegment_xz=1000;end % MAX U point = 1000 in MEX files
        if eSegment_xy == 0, eSegment_xy=1000;end % MAX U point = 1000 in MEX files
        if min(eSegment_xy,eSegment_xz) < size(Sb,1)
            break;
        end
     end
     eSegment = k-1;
     MBS.data{end+1} = Curve_xyz(bSegment:eSegment,:);
     MBS.B_E_seg(end+1,:) = [bSegment eSegment];
 end



