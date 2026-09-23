function area = estimate_integral_fig(Curve_xyz,Ck,Cl,Cr,Radius,pos)
area_o = 0; %#ok<NASGU>
area_n = 0; %#ok<NASGU>
area_r = 0; %#ok<NASGU>
area = 0; %#ok<NASGU>
% s1 = Ck-Cl; s2 = Cr-Ck;
area = 0; %#ok<NASGU>
T1 = Ck-Cl; T2 = Cr-Ck;
T1 = T1/norm(T1);
T2 = T2/norm(T2);
% T = T1;
% B = cross(T1,T2); B= B/norm(B);
% N = cross(B,T1);

% T = (T1+T2)/norm(T1+T2);% modified by perry according to reviews of PR
Cc = tricircumcenter3d(Cl,Ck,Cr)+Cl; % get the circumcenter
N = (Cc - Ck)/norm(Cc- Ck);
B = cross(T1,T2); B= B/norm(B);
T = cross(N,B);

D = -(B*Ck');

% [~, grid] = curve_grid(Segment_curve,500);
%grid = 1/2000; %grid resolution
grid = 2*Radius/50;
% Ck_Rr = Ck + Radius*S1;
Ck_Rl = Ck - Radius*T;
Ck_Ru = Ck + Radius*N;
Ck_Rb = Ck - Radius*N;


%% get the osculating rectangle plane
% rect_point = zeros((n+1)*(n+1),3);
% k=0;
% for i=0:n,
%     for j=0:n,
%         k=k+1;
%         rect_point(k,:) = Ck-Radius*(S1+S3)+j*grid*S1+i*grid*S3;
%     end
% end
% Radius_matrix = rect_point-repmat(Ck,(n+1)*(n+1),1);
% Radius_matrix = sqrt(sum(Radius_matrix.^2,2));
% area = size(find(Radius_matrix<=Radius),1);
%% get the projection on osculating plane
t_dnom = B*B';
t_nom = Curve_xyz*B'+D;
t = t_nom/t_dnom;
Po = Curve_xyz-t*B;

%% get the area for osculating plane projection
r_r = 0;r_l = 0;
l_k = pos;
r_k = pos;
P_l = [];
P_r = [];
Po_length = size(Po,1);

%%
while (r_l <= Radius && l_k > 1) || (r_r <= Radius && r_k < Po_length),

    if r_l <= Radius && l_k > 1
        costheta = (Po(l_k,:)-Po(l_k-1,:))*T'/(norm((Po(l_k,:)-Po(l_k-1,:)))*norm(T));
        grid_l = grid/costheta;
        l_direction = (Po(l_k,:)-Po(l_k-1,:))/norm((Po(l_k,:)-Po(l_k-1,:)));
        n_l = fix(norm((Po(l_k,:)-Po(l_k-1,:)))/grid_l);
        P_l(end+1,:) = Po(l_k,:);

        for i=sign(n_l):sign(n_l):n_l
            P_l(end+1,:) = Po(l_k,:)-i*grid_l*l_direction;
        end

        l_k = l_k-1;
        r_l = norm(Po(l_k,:)-Po(pos,:));
        % bouding condition
        if l_k == 1
            P_l(end+1,:) = Po(l_k,:);
        end

    end

    if r_r <= Radius && r_k < Po_length
        costheta = (Po(r_k+1,:)-Po(r_k,:))*T'/(norm((Po(r_k+1,:)-Po(r_k,:)))*norm(T));
        grid_r = grid/costheta;
        r_direction = (Po(r_k+1,:)-Po(r_k,:))/norm((Po(r_k+1,:)-Po(r_k,:)));
        n_r = fix(norm((Po(r_k+1,:)-Po(r_k,:)))/grid_r);

        P_r(end+1,:) = Po(r_k,:);
        for i=sign(n_r):sign(n_r):n_r
            P_r(end+1,:) = Po(r_k,:)+i*grid_r*r_direction;
        end
        r_k = r_k+1;
        r_r = norm(Po(r_k,:)-Po(pos,:));
        % bouding condition
        if r_k == Po_length
            P_r(end+1,:) = Po(r_k,:);
        end
    end
end

%%

bound_line = [flipud(P_l);P_r];
bound_length = size(bound_line,1);
P_u = [];
for i=1:bound_length
      n = fix(norm(bound_line(i,:)-Ck_Ru)/grid);
      for j=1:n
            P_u(end+1,:) = bound_line(i,:)+j*grid*N;
      end
end


P_area = [bound_line;P_u];
n = size(P_area,1);
Radius_matrix = P_area-repmat(Ck,n,1);
Radius_matrix = sqrt(sum(Radius_matrix.^2,2));
area_o = size(find(Radius_matrix<=Radius),1);
area_o = area_o/(pi*fix(Radius/grid)*fix(Radius/grid)); % normalization for integral invariant
P_area = P_area(find(Radius_matrix<=Radius),:);
area_o(isnan(area_o)) = [];
%% plot the integral area invariant animation
% center_length = fix(2*Radius/grid);
% P_b_bound = zeros(center_length+1,3);
% P_u_bound = zeros(center_length+1,3);
% P_b_point = [];P_u_point = [];
% for i=1:center_length+1
%     center_bound = Ck_Rl+i*grid*T;
%     n = fix(norm(center_bound-Ck_Rb)/grid);
%     for j=1:n+1
%        P_b_point(end+1,:) = center_bound-j*grid*N;
%        P_u_point(end+1,:) = center_bound+j*grid*N;
%        if norm(P_b_point(end,:)-Ck) <= Radius;
%           P_b_bound(i,:) = P_b_point(end,:);
%           P_u_bound(i,:) = P_u_point(end,:);
%        end
%     end
% end
% P_b_bound(ismember(P_b_bound,[0 0 0],'rows'),:)=[];
% P_u_bound(ismember(P_u_bound,[0 0 0],'rows'),:)=[];
%
%
% if mod(pos,20)==0
%     figure(1);
%     hold on;
%     view(-37.5,30);
%     axis equal;
%     plot3(P_area(:,1),P_area(:,2),P_area(:,3),'.','Color',[128/256 128/256 128/256]);hold on;
%     axis equal;
%     plot3(P_b_bound(:,1),P_b_bound(:,2),P_b_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
%           'LineWidth',2);hold on;
%     axis equal;
%     plot3(P_u_bound(:,1),P_u_bound(:,2),P_u_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
%           'LineWidth',2);hold on;
%
% end

%% plot the integral distance invariant
% if pos == 20 || pos == 100
% n = size(Curve_xyz,1);
% for i = 1:n
%     if norm(Ck-Curve_xyz(i,:))<= 0.25
%         plot3([Ck(1,1);Curve_xyz(i,1)],[Ck(1,2);Curve_xyz(i,2)],[Ck(1,3);Curve_xyz(i,3)],...
%        '-','Color',[128/256 128/256 128/256],'LineWidth',1);hold on;
%     end
% end
% end


%% get the area for rectifying plane projection
D = -(N*Ck');
t_dnom = N*N';
t_nom = Curve_xyz*N'+D;
t = t_nom/t_dnom;
Pr = Curve_xyz-t*N;

Ck_Rl = Ck - Radius*T;
Ck_Ru = Ck + Radius*B;
Ck_Rb = Ck - Radius*B;

r_r = 0;r_l = 0;
l_k = pos;
r_k = pos;
P_l = [];
P_r = [];
Pr_length = size(Pr,1);
while (r_l <= Radius && l_k > 1) || (r_r <= Radius && r_k < Pr_length),

    if r_l <= Radius && l_k > 1
        costheta = (Pr(l_k,:)-Pr(l_k-1,:))*T'/(norm((Pr(l_k,:)-Pr(l_k-1,:)))*norm(T));
        grid_l = grid/costheta;
        l_direction = (Pr(l_k,:)-Pr(l_k-1,:))/norm((Pr(l_k,:)-Pr(l_k-1,:)));
        n_l = fix(norm((Pr(l_k,:)-Pr(l_k-1,:)))/grid_l);

        P_l(end+1,:) = Pr(l_k,:);
        for i=sign(n_l):sign(n_l):n_l
            P_l(end+1,:) = Pr(l_k,:)-i*grid_l*l_direction;
        end

        l_k = l_k-1;
        r_l = norm(Pr(l_k,:)-Pr(pos,:));
        % bouding condition
        if l_k == 1
            P_l(end+1,:) = Pr(l_k,:);
        end
    end

    if r_r <= Radius && r_k < Pr_length
        costheta = (Pr(r_k+1,:)-Pr(r_k,:))*T'/(norm((Pr(r_k+1,:)-Pr(r_k,:)))*norm(T));
        grid_r = grid/costheta;
        r_direction = (Pr(r_k+1,:)-Pr(r_k,:))/norm((Pr(r_k+1,:)-Pr(r_k,:)));
        n_r = fix(norm((Pr(r_k+1,:)-Pr(r_k,:)))/grid_r);

        P_r(end+1,:) = Pr(r_k,:);
        for i=sign(n_r):sign(n_r):n_r
            P_r(end+1,:) = Pr(r_k,:)+i*grid_r*r_direction;
        end
        r_k = r_k+1;
        r_r = norm(Pr(r_k,:)-Pr(pos,:));
        % bouding condition
        if r_k == Pr_length
            P_r(end+1,:) = Pr(r_k,:);
        end
    end
end

bound_line = [flipud(P_l);P_r];
bound_length = size(bound_line,1);
P_u = [];
for i=1:bound_length
      n = fix(norm(bound_line(i,:)-Ck_Ru)/grid);
      for j=1:n
            P_u(end+1,:) = bound_line(i,:)+j*grid*B;
      end
end



P_area = [bound_line;P_u];
n = size(P_area,1);
Radius_matrix = P_area-repmat(Ck,n,1);
Radius_matrix = sqrt(sum(Radius_matrix.^2,2));
area_r = size(find(Radius_matrix<=Radius),1);
area_r = area_r/(pi*fix(Radius/grid)*fix(Radius/grid)); % normalization for integral invariant
P_area = P_area(find(Radius_matrix<=Radius),:);
area_r(isnan(area_r)) = [];
area = [area_o area_r];

%% plot the integral area invariant animation
% center_length = fix(2*Radius/grid);
% P_b_bound = zeros(center_length+1,3);
% P_u_bound = zeros(center_length+1,3);
% P_b_point = [];P_u_point = [];
% for i=1:center_length+1
%     center_bound = Ck_Rl+i*grid*T;
%     n = fix(norm(center_bound-Ck_Rb)/grid);
%     for j=1:n+1
%        P_b_point(end+1,:) = center_bound-j*grid*B;
%        P_u_point(end+1,:) = center_bound+j*grid*B;
%        if norm(P_b_point(end,:)-Ck) <= Radius;
%           P_b_bound(i,:) = P_b_point(end,:);
%           P_u_bound(i,:) = P_u_point(end,:);
%        end
%     end
% end
%
% P_b_bound(ismember(P_b_bound,[0 0 0],'rows'),:)=[];
% P_u_bound(ismember(P_u_bound,[0 0 0],'rows'),:)=[];
% if mod(pos,20)==0
%     figure(1);
%     hold on;
%     view(-37.5,30);
%     axis equal;
%     plot3(P_area(:,1),P_area(:,2),P_area(:,3),'.','Color',[128/256 128/256 128/256]);hold on;
%     axis equal;
%     plot3(P_b_bound(:,1),P_b_bound(:,2),P_b_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
%           'LineWidth',2);hold on;
%     axis equal;
%     plot3(P_u_bound(:,1),P_u_bound(:,2),P_u_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
%           'LineWidth',2);hold on;
% end

%% get the area for normal plane projection
% D = -(T*Ck');
% t_dnom = T*T';
% t_nom = Curve_xyz*T'+D;
% t = t_nom/t_dnom;
% Pn = Curve_xyz-t*T;
%
% Ck_Rr = Ck + Radius*B; %#ok<NASGU>
% Ck_Rl = Ck - Radius*B;
% Ck_Rb = Ck - Radius*N;
% Ck_Ru = Ck + Radius*N;
% r_r = 0;r_l = 0;
% l_k = pos;
% r_k = pos;
% P_l = [];
% P_r = [];
% Pn_length = size(Pn,1);
% while (r_l <= Radius && l_k > 1) || (r_r <= Radius && r_k < Pn_length),
%
%     if r_l <= Radius && l_k > 1
%         costheta = (Pn(l_k,:)-Pn(l_k-1,:))*B'/(norm((Pn(l_k,:)-Pn(l_k-1,:)))*norm(B));
%         grid_l = grid/costheta;
%         l_direction = (Pn(l_k,:)-Pn(l_k-1,:))/norm((Pn(l_k,:)-Pn(l_k-1,:)));
%         n_l = fix(norm((Pn(l_k,:)-Pn(l_k-1,:)))/grid_l);
%
%         P_l(end+1,:) = Pn(l_k,:);
%         for i=sign(n_l):sign(n_l):n_l
%             P_l(end+1,:) = Pn(l_k,:)-i*grid_l*l_direction;
%         end
%
%         l_k = l_k-1;
%         r_l = norm(Pn(l_k,:)-Pn(pos,:));
%         if l_k == Pn_length
%             P_l(end+1,:) = Pn(l_k,:);
%         end
%     end
%
%     if r_r <= Radius && r_k < Pn_length
%         costheta = (Pn(r_k+1,:)-Pn(r_k,:))*B'/(norm((Pn(r_k+1,:)-Pn(r_k,:)))*norm(B));
%         grid_r = grid/costheta;
%         r_direction = (Pn(r_k+1,:)-Pn(r_k,:))/norm((Pn(r_k+1,:)-Pn(r_k,:)));
%         n_r = fix(norm((Pn(r_k+1,:)-Pn(r_k,:)))/grid_r);
%
%         P_r(end+1,:) = Pn(r_k,:);
%         for i=sign(n_r):sign(n_r):n_r
%             P_r(end+1,:) = Pn(r_k,:)+i*grid_r*r_direction;
%         end
%         r_k = r_k+1;
%         r_r = norm(Pn(r_k,:)-Pn(pos,:));
%         %bouding condition
%         if r_k == Pn_length
%             P_r(end+1,:) = Pn(r_k,:);
%         end
%     end
% end
%
% bound_line = [flipud(P_l);P_r];
% bound_length = size(bound_line,1);
% P_u = [];P_b_point = [];
% for i=1:bound_length
%       n = fix(norm(bound_line(i,:)-Ck_Ru)/grid);
%       for j=1:n
%             P_u(end+1,:) = bound_line(i,:)+j*grid*N;
%       end
% end
%
% center_length = fix(2*Radius/grid);
% P_b_bound = zeros(center_length+1,3);
% P_u_bound = zeros(center_length+1,3);
% P_b_point = [];P_u_point = [];
% for i=1:center_length+1
%     center_bound = Ck_Rl+i*grid*B;
%     n = fix(norm(center_bound-Ck_Rb)/grid);
%     for j=1:n+1
%        P_b_point(end+1,:) = center_bound-j*grid*N;
%        P_u_point(end+1,:) = center_bound+j*grid*N;
%        if norm(P_b_point(end,:)-Ck) <= Radius;
%           P_b_bound(i,:) = P_b_point(end,:);
%           P_u_bound(i,:) = P_u_point(end,:);
%        end
%     end
% end
%
%
% P_area = [bound_line;P_u];
% n = size(P_area,1);
% Radius_matrix = P_area-repmat(Ck,n,1);
% Radius_matrix = sqrt(sum(Radius_matrix.^2,2));
% area_n = size(find(Radius_matrix<=Radius),1);
% area_n = area_n/(pi*fix(Radius/grid)*fix(Radius/grid)); % normalization for integral invariant
% P_area = P_area(find(Radius_matrix<=Radius),:);
% area = [area_o area_n];

%% plot the integral area invariant animation
% if mod(pos,20)==0
%     figure(1);
%     hold on;
%     plot3(P_area(:,1),P_area(:,2),P_area(:,3),'.','Color',[128/256 128/256 128/256]);hold on;
%     hold on;
% end
% P_area_bound = [P_area;P_b_bound];
% plot the integral area invariant
% P_b_bound(ismember(P_b_bound,[0 0 0],'rows'),:)=[];
% P_u_bound(ismember(P_u_bound,[0 0 0],'rows'),:)=[];
% if mod(pos,10)==0
%     figure(1);
%     hold on;
% %     plot3(P_area(:,1),P_area(:,2),P_area(:,3),'.','Color',[128/256 128/256 128/256]);hold on;
% %     plot3(P_b_bound(:,1),P_b_bound(:,2),P_b_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
% %           'LineWidth',2);hold on;
% %     plot3(P_u_bound(:,1),P_u_bound(:,2),P_u_bound(:,3),'-.','Color',[128/256 128/256 128/256],...
% %           'LineWidth',2);hold on;
%%  plot the Moving Frame

if mod(pos,10)==0
    view(-37.5,30);
    T_fig = Curve_xyz(pos,:)+0.1*T; N_fig = Curve_xyz(pos,:)+0.1*N; B_fig = Curve_xyz(pos,:)+0.1*B;
    axis equal;
    h1 = plot3([Curve_xyz(pos,1),T_fig(1)],[Curve_xyz(pos,2),T_fig(2)],[Curve_xyz(pos,3),T_fig(3)],'-b','LineWidth',2);hold on;
    axis equal;
    h2 = plot3([Curve_xyz(pos,1),N_fig(1)],[Curve_xyz(pos,2),N_fig(2)],[Curve_xyz(pos,3),N_fig(3)],'-r','LineWidth',2);hold on;
    axis equal;
    h3 = plot3([Curve_xyz(pos,1),B_fig(1)],[Curve_xyz(pos,2),B_fig(2)],[Curve_xyz(pos,3),B_fig(3)],'-c','LineWidth',2);hold on;
    H=[h1,h2,h3];
    save H H;
end














