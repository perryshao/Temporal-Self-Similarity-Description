function FrenetVector = Estimate_Frenet(Curve_xyz,Width)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
%  Width -- segmentation order authorized for the blurred segments
%  Output:
%  TangentVector -- curvature of width at each point of Curve_xyz
%  Initialisation:
%  a=0, b=1, u=0, w=b,
%  key = 1 for HDM05,MHAD
%  key = 2 for MSRA;
%% perform the Maximal Blurred Segment of arbitrary curve
[Curve_xyz,staindex] = remove_stapoint(Curve_xyz); % delete for occlusion fig
curve_xyz_int = curve_grid(Curve_xyz,1000);
if size(curve_xyz_int,2) > 2
    MBS = splitting_curve_3D(curve_xyz_int,Width);
else
    MBS = splitting_curve_2D(curve_xyz_int,Width);
end
n = size(curve_xyz_int,1);
m = size(MBS.data,2);
FrenetVector = zeros(n,9);
%% determine the Right and Left key point throught MBS
for i = 1:m
    if i == 1,
        E_num = 1;
    else

        E_num = MBS.B_E_seg(i-1,2)+1;
    end

    for k = E_num:MBS.B_E_seg(i,2),
        L(k) = MBS.B_E_seg(i,1);  %#ok<AGROW>
    end

     if i == m,
        B_num = n;
     else
        B_num = MBS.B_E_seg(i+1,1)-1;
    end
    for k = MBS.B_E_seg(i,1):B_num,
        R(k) = MBS.B_E_seg(i,2);  %#ok<AGROW>
    end
end

%% compute the Tangent Vector
for i = 3:n-2
    Ck = Curve_xyz(i,:);Cl = Curve_xyz(L(i),:);Cr = Curve_xyz(R(i),:);
    T1 = Ck-Cl; T2 = Cr-Ck;
    T1 = T1/norm(T1);
    T2 = T2/norm(T2);
%     B = cross(T1,T2); B= B/norm(B);
%     T = (T1+T2)/norm(T1+T2);% modified by perry according to reviews of PR
%     N = cross(B,T);
    Cc = tricircumcenter3d(Cl,Ck,Cr)+Cl; % get the circumcenter
    N = (Cc - Ck)/norm(Cc- Ck);
    B = cross(T1,T2); B= B/norm(B);
    FrenetVector(i,1:3) = cross(N,B);
    FrenetVector(i,4:6) = N;
    FrenetVector(i,7:9) = B;
end
FrenetVector = fillstapoint(FrenetVector,staindex);


